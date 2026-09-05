// ignore_for_file: prefer-static-class

import 'dart:async';

import 'package:auth_app/_core/api/_core/transport_log.dart';
import 'package:auth_app/_core/api/connect/middlewares/logger_middleware.dart';
import 'package:auth_app/_core/api/connect/middlewares/sentry_middleware.dart';
import 'package:auth_app/_core/api/http/middlewares/logger_middleware.dart';
import 'package:auth_app/_core/api/http/middlewares/sentry_middleware.dart';
import 'package:auth_app/_core/controller/controller_observer.dart';
import 'package:auth_app/_core/database/database.dart';
import 'package:auth_app/_core/environment/environment_loader.dart';
import 'package:auth_app/_core/log/journal_sink.dart';
import 'package:auth_app/_core/log/logging_bridge.dart';
import 'package:auth_app/_core/log/sentry_sink.dart';
import 'package:auth_app/_core/log/telemetry.dart';
import 'package:auth_app/_core/message/toast_sink.dart';
import 'package:auth_app/_core/message/ui_messenger.dart';
import 'package:auth_app/_core/model/app_metadata.dart';
import 'package:auth_app/_core/model/dependencies.dart';
import 'package:auth_app/_core/theme/theme_mode_codec.dart';
import 'package:auth_app/authentication/controller/authentication_controller.dart';
import 'package:auth_app/authentication/data/authentication_repository.dart';
import 'package:auth_app/initialization/app_migrator.dart';
import 'package:auth_app/initialization/init_step.dart';
import 'package:auth_app/settings/data/dao/app_preferences_dao.dart';
import 'package:auth_app/settings/data/dao/app_secure_preferences_dao.dart';
import 'package:auth_app/settings/data/settings_repository.dart';
import 'package:auth_app/update/controller/platform/update_check.dart';
import 'package:auth_app/update/controller/update_check_controller.dart';
import 'package:auth_app/users/data/users_repository.dart';
import 'package:auth_model/auth_model.dart';
import 'package:connect_kit/connect_kit.dart' hide Value;
import 'package:connectrpc/connect.dart';
import 'package:control/control.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http_kit/http_kit.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Initializes the app and returns a [Dependencies] object
Future<Dependencies> $initializeDependencies({void Function(int progress, String message)? onProgress}) =>
    composeDependencies(initializationSteps, onProgress: onProgress);

/// Runs [steps] in order, building a [Dependencies].
///
/// On a failing step, the completed steps — and the failed one, whose `create` may have partially
/// built resources — are disposed in reverse order so a retry starts clean (fresh HTTP clients,
/// closed database, no leaked subscriptions).
@visibleForTesting
Future<Dependencies> composeDependencies(
  List<InitStep> steps, {
  void Function(int progress, String message)? onProgress,
}) async {
  final dependencies = Dependencies();
  final totalSteps = steps.length;
  var currentStep = 0;
  for (final step in steps) {
    try {
      currentStep++;
      final stopWatch = Stopwatch()..start();
      final percent = (currentStep * 100 ~/ totalSteps).clamp(0, 100);
      onProgress?.call(percent, step.name);

      final onStep = step.create(dependencies);
      final _ = onStep is Future ? await onStep : onStep;

      stopWatch.stop();
      // `debug`, with the values as attributes. It was a `v6` trace line, which no
      // sink accepts (`maxVerbosity: 4`) — so the one line per init step, the thing
      // a slow-boot question is answered with, was emitted nowhere in any build.
      log.d(
        'Boot | step | done',
        meta: <String, Object?>{
          'app.boot.step': step.name,
          'app.boot.index': currentStep,
          'app.boot.total': totalSteps,
          'app.boot.ms': stopWatch.elapsedMilliseconds,
        },
      );
    } on Object catch (error, stackTrace) {
      // The ONE line for a failed boot. The step name is an attribute, not part of the body: as
      // `🚧 failed at step "Collect logs"` every step grouped into its own crash-reporter issue,
      // and the callers above (`$initializeApp`, `main`) each logged the same failure again — one
      // boot, three error events, two of them after this sink was already removed.
      // Named: `ReportThrottle` dedupes on the name and the Sentry sink
      // fingerprints on it, so every failed boot is one issue however the line
      // is later reworded, and the step stays an attribute.
      log('Boot | step | failed')
          .name('boot.step.failed')
          .cause(error, stackTrace)
          .meta(<String, Object?>{'app.boot.step': step.name})
          .error();
      await disposeSteps(steps.sublist(0, currentStep), dependencies);
      Error.throwWithStackTrace('Initialization failed at step "${step.name}": $error', stackTrace);
    }
  }
  return dependencies;
}

/// The composition, as data. Each step colocates creation with its teardown (`dispose`);
/// the dispose mirror is DERIVED by reversing this list — see [InitStep].
@visibleForTesting
final List<InitStep> initializationSteps = <InitStep>[
  InitStep(
    'Creating app metadata',
    (dependencies) => dependencies.metadata = AppMetadata.platform(),
  ),
  InitStep(
    'Observer state management',
    (_) => Controller.observer = ControllerObserver.instance(),
  ),
  InitStep(
    'Initializing analytics',
    (_) {
      // TODO(planned): initialize analytics here.
      // await Firebase.initializeApp(
      //   options: DefaultFirebaseOptions.currentPlatform,
      // );
    },
  ),
  InitStep(
    'Log app open',
    (_) {
      /* TODO(planned): emit app-open analytics event. */
    },
  ),
  InitStep(
    'Get remote config',
    (_) {
      /* TODO(planned): fetch remote config. */
    },
  ),
  InitStep(
    'Restore settings',
    (_) {
      /* TODO(planned): restore persisted settings. */
    },
  ),
  InitStep(
    'Environment',
    (dependencies) async {
      final environmentLoader = EnvironmentLoader();
      final environment = dependencies.environment = await environmentLoader();

      // What identifies this LAUNCH, on every event from here on: OpenTelemetry
      // calls it the resource. Set once, rather than repeated as `.meta` on the
      // lines that happen to remember it — which is how a crash report used to
      // arrive without the build it came from.
      log.resource = <String, Object?>{
        'app.version': environment.version,
        'app.environment': environment.type.value,
      };

      await initializeDateFormatting('en_US', null);
    },
  ),
  InitStep(
    'Settings',
    (dependencies) async {
      final sharedPreferences = await SharedPreferences.getInstance();
      final preferencesDao = AppPreferencesDao(sharedPreferences);
      // Apple keychain pinned to first_unlock_this_device: background writes after the first unlock,
      // no cross-device keychain restore. Android v10 defaults are already strong; existing entries
      // stay readable and self-heal via F2 (refresh_token.md §10.2).
      const secureStorage = FlutterSecureStorage(
        iOptions: IOSOptions(accessibility: .first_unlock_this_device),
        mOptions: MacOsOptions(accessibility: .first_unlock_this_device),
      );
      const securePreferencesDao = AppSecurePreferencesDao(secureStorage);
      final settings = SettingsRepository(
        preferences: preferencesDao,
        securePreferences: securePreferencesDao,
        codec: const ThemeModeCodec(),
      );
      dependencies.settings = settings;
    },
  ),
  InitStep(
    // Runs AFTER 'Settings': reporting is gated on the user's crash-reports switch.
    'Error tracking',
    (dependencies) async {
      final environment = dependencies.environment;
      // The sink is registered unconditionally so the crash-reports switch can
      // (de)activate reporting at runtime and the derived dispose always has a live target.
      final crashReporting = SentryTelemetry(
        telemetry: log,
        dsn: environment.sentryDsn,
        environment: environment.type,
      );
      dependencies.crashReporting = crashReporting;
      // Debug builds never report — the DSN is a production project and local noise would drown
      // real crashes. The user's crash-reports switch governs everything else.
      if (kDebugMode) return;
      if (!dependencies.settings.sendCrashReports) {
        log.i('Sentry | init | reporting disabled by the user');
        return;
      }
      // Best effort: a native Sentry init failure is a reporting problem, not a
      // reason the app cannot start.
      try {
        await crashReporting.enableReporting();
      } on Object catch (error, stackTrace) {
        log.w('Sentry | init | failed', error: error, stackTrace: stackTrace);
      }
    },
    dispose: (dependencies) => dependencies.crashReporting.disableReporting(),
  ),
  InitStep(
    'Connect to database',
    (dependencies) {
      final environment = dependencies.environment;

      // `dropDatabase` is FORWARDED: without it `--dart-define=DB_DROP=true` (and the container's
      // `DB_DROP`) resolved into `AppEnvironment` and then went nowhere — the launch config that
      // exists to start from an empty database quietly reused the old one.
      return (dependencies.database =
              environment
                  .inMemoryDatabase //
              ? Database.memory(environment.databaseName)
              : Database.lazy(environment.databaseName, dropDatabase: environment.dropDatabase))
          .refresh();
    },
    dispose: (dependencies) => dependencies.database.close(),
  ),
  InitStep(
    'Migrate app from previous version',
    (dependencies) => AppMigrator.migrate(dependencies.database),
  ),

  InitStep(
    // The journal writer. Everything from `debug` up is stored — controller
    // transitions included — because the value of a journal is answering
    // "what led to this", and that answer is made of the quiet lines.
    'Collect logs',
    (dependencies) {
      // `drain` BEFORE `addSink`: the ring buffer holds everything logged since the first line of
      // `main` — the environment, the migration, the crash-reporter decision — and until now none
      // of it reached the journal a tester's bug report is made of.
      final journal = dependencies.journal = JournalSink(dependencies.database)..drain(log.buffer.events);
      // The journal owns those events now; the ring keeps only `trace`, which
      // has no other home (see `LogBuffer`).
      log.buffer.markDrained();
      log.addSink(journal);
      // The drained events are queued, not written: the sink batches for five seconds, and the
      // lines this step exists to keep are exactly the ones a crash in the next second takes.
      journal.flush().ignore();
      // `cupertino_http` logs through `package:logging`, and nothing in this app ever listened —
      // a transport saying "the session invalidated" went nowhere at all.
      dependencies.loggingBridge = LoggingBridge();
    },
    dispose: (dependencies) async {
      // The journal FIRST. `disposeSteps` treats a `LateInitializationError` as
      // "this step never ran" and abandons the rest of the closure, so whichever
      // release comes first decides what a half-built container gives back — and
      // a live sink writing to a database the next step closes is the worse of
      // the two. Awaited: that database is closed by a step that tears down
      // after this one.
      log.removeSink(dependencies.journal);
      // The ring takes the boot back: this container can be rebuilt (a retried boot, an
      // abandoned one being replaced), and the next composition's lines need a keeper until its
      // own journal opens.
      //
      // Only when no journal is left. A sink list is not a slot: an ABANDONED composition (the
      // seven-minute timeout in `$initializeApp` builds a second container without disposing the
      // first) is still registered when the retry installs its own, so asking whether THIS journal
      // was registered says yes for both. The ring must go back to keeping `debug` and up only
      // once nothing is writing it to disk.
      if (!log.sinks.any((sink) => sink is JournalSink)) log.buffer.undrain();
      await dependencies.journal.dispose();
      await dependencies.loggingBridge.dispose();
    },
  ),

  InitStep(
    'Storage repository',
    (dependencies) {
      // TODO(planned): wire the storage repository.
    },
  ),
  // 'Theme repository': (dependencies) {
  //   final settings = dependencies.settings;
  //   final themeDataSource = ThemeDataSource(settings: settings);
  //   final themeRepository = ThemeRepository(themeDataSource);
  //   dependencies.themeRepository = themeRepository;
  // },
  // 'Locale repository': (dependencies) {
  //   final settings = dependencies.settings;
  //   final localeDataSource = LocaleDataSource(settings: settings);
  //   final localeRepository = LocaleRepository(localeDataSource);
  //   dependencies.localeRepository = localeRepository;
  // },
  InitStep(
    'Connect client factory',
    (dependencies) {
      // A6: Connect clients are intentionally NOT wired to the session CancelToken — per-call
      // deadlines, subscription teardown, and server-side token rejection already cover it. If a hard
      // "abort all on logout" is ever needed, prefer closing the shared HTTP client + lazy re-init
      // over a token bridge.
      List<Interceptor> interceptorsFactory([Iterable<Interceptor>? middlewares]) => <Interceptor>[
        // Order (outermost → innermost): Logger → Metadata → Sentry → Retry → Authentication → wire.
        // connect-dart applies the FIRST interceptor in this list as the outermost layer — pinned by
        // connect_kit's interceptor chain-order test (the upstream doc wording is ambiguous).
        // - Logger: logs the final outcome + total duration (outside Retry ⇒ one line per logical call).
        // - Metadata: static X-* headers (app version, locale, environment); before Sentry so Sentry
        //   captures (and redacts) them.
        // - Sentry: span wraps Retry so it covers every attempt.
        // - Retry: transient RPC codes only; UNAUTHENTICATED is excluded (recovered by auth's refresh).
        // - Authentication (appended via `middlewares` below): innermost ⇒ token attached per attempt and
        //   401→refresh→retry-once runs closest to the wire (mirrors the HTTP Retry→Auth pipeline).
        // TODO: Deduplicate requests interceptor
        // TODO: Cache interceptor

        // Logger middleware
        const ConnectLoggerMiddleware().call,

        // Metadata middleware
        ConnectMetadataMiddleware(
          metadata: {
            ...dependencies.metadata.toHeaders(),
            'X-Environment': dependencies.environment.type.name,
          },
        ).call,

        // Sentry middleware
        const ConnectSentryMiddleware().call,

        // Retry middleware
        // GrpcRetryMiddleware(
        //   retries: 3,
        //   retryEvaluator: (error, attempt) =>
        //       attempt <= 3 &&
        //       switch (error) {
        //         ApiClientException$Authentication() => false, // Do not retry on authentication errors
        //         TimeoutException() || ApiClientException$Timeout() => true, // Retry on timeout exceptions
        //         ApiClientException$Internal(:final code) => !const <String>{
        //           'canceled',
        //           'aborted',
        //           'cancel',
        //           'cancelled',
        //           'abort',
        //           'unexpected_error',
        //           'unknown error',
        //         }.contains(code), // Do not retry on cancellation or abort errors
        //         ApiClientException(:final statusCode) => const <int>{ // 4xx→$Request, 5xx→$Server
        //           400, // Bad Request
        //           //401, // Unauthorized
        //           //403, // Forbidden
        //           408, // Request Timeout
        //           409, // Conflict
        //           422, // Unprocessable Entity
        //           //429, // Too Many Requests
        //           500, // Internal Server Error
        //           502, // Bad Gateway
        //           503, // Service Unavailable
        //           504, // Gateway Timeout
        //         }.contains(statusCode), // Retry on specific network errors
        //         _ => true, // Retry on other errors
        //       },
        //   retryDelays: const <Duration>[
        //     Duration(seconds: 1), // wait 1 sec before first retry
        //     Duration(seconds: 2), // wait 2 sec before second retry
        //     Duration(seconds: 3), // wait 3 sec before third retry
        //   ],
        // ),

        // Retry middleware — transient ConnectException codes only (unavailable / aborted / internal /
        // deadlineExceeded; resourceExhausted only with server pushback). UNAUTHENTICATED is excluded
        // and recovered by the auth middleware's reactive refresh. Inner of Sentry (so its span covers
        // retries), outer of auth (appended below). Default RetryBackoff = full-jitter exponential
        // backoff + per-attempt ceiling + total budget; honors `grpc-retry-pushback-ms`.
        // `noRetryPaths` = the dangerous-replay set (gRFC A6 / AIP-194): a replayed RefreshTokens
        // trips reuse detection (§12.2); Authenticate/SignUp duplicate sessions/accounts; the
        // senders duplicate emails. SignOut (idempotent revocation) and GetOAuthUrl (read) stay
        // retryable.
        ConnectRetryMiddleware(
          // Retries are invisible to the logger above (it sits outside this one and only sees the
          // final outcome), so the middleware reports each one itself.
          onRetry: (error, attempt, delay) =>
              logTransportRetry(area: 'Rpc', error: error, attempt: attempt, delay: delay),
          noRetryPaths:
              {
                ...kAuthServicePublicPaths,
                // Authenticated email resend — same hazard, not in the public set.
                '/auth.v1.AuthService/RequestVerification',
              }.difference(const {
                '/auth.v1.AuthService/SignOut',
                '/auth.v1.AuthService/GetOAuthUrl',
              }),
        ).call,

        // Any other middlewares you need
        ...?middlewares,
      ];

      // ONE shared HTTP client behind every transport: a single per-origin HTTP/2 connection pool
      // with pinned TLS (native) or the browser fetch stack (web); owned by the container for
      // teardown (A6). Each service keeps its own transport/base-URL (authService may differ from
      // appService) and the shared interceptor stack. Per-call deadlines default to
      // ConnectClient.defaultCallTimeout (30s, unary) via the call guards; streaming RPCs use the
      // stream deadline per call.
      final rpcHttpClient = createRpcHttpClient();
      Transport transportFactory(Uri address, Iterable<Interceptor>? middlewares) =>
          createConnectTransport(address, httpClient: rpcHttpClient, interceptors: interceptorsFactory(middlewares));

      ConnectAuthenticationClient connectAuthFactory([Iterable<Interceptor>? middlewares]) =>
          .new(transportFactory(dependencies.environment.authService, middlewares));

      ConnectUsersClient connectUsersFactory([Iterable<Interceptor>? middlewares]) =>
          .new(transportFactory(dependencies.environment.appService, middlewares));

      dependencies
        ..rpcHttpClient = rpcHttpClient
        ..interceptorsFactory = interceptorsFactory
        ..connectAuthFactory = connectAuthFactory
        ..connectUsersFactory = connectUsersFactory;
    },
    dispose: (dependencies) => dependencies.rpcHttpClient.close(),
  ),

  // General Connect client initialization
  InitStep(
    'General Connect Client',
    (dependencies) {
      final authenticationMiddleware = ConnectAuthenticationMiddleware(
        getToken: () async {
          try {
            return await dependencies.authenticationRepository.getAccessCredentials();
          } on Object catch (e, st) {
            // Surface a transient credential-resolution failure (do NOT collapse to `null`, which the
            // middleware treats as "definitively no token" and would force a spurious logout — A3).
            log.w('Auth | credentials | resolve failed', error: e);
            Error.throwWithStackTrace(e, st);
          }
        },
        refreshCredentials: (usedAccessToken) =>
            dependencies.authenticationRepository.refreshCredentials(usedAccessToken),
        // Logout only via the single auth-state bus (A26); the repository performs the sign-out.
        onAuthError: () {
          log.w('Auth | transport | unauthenticated');
          dependencies.authenticationHandler.handleAuthenticationError();
        },
        // Single source of truth lives in auth_model and is asserted against the generated stub (A19).
        unauthenticatedPaths: kAuthServicePublicPaths,
        // Only a rejected RefreshTokens ends the session; other public-path auth errors are flow errors.
        sessionEndingPaths: const <String>{kAuthServiceRefreshTokensPath},
      );

      dependencies
        ..authClient = dependencies.connectAuthFactory([authenticationMiddleware.call])
        ..usersClient = dependencies.connectUsersFactory([authenticationMiddleware.call]);
    },
  ),

  ///
  InitStep(
    'Prepare notifications',
    (dependencies) {
      final messenger = dependencies.messenger = UiMessenger();
      // From here on a controller can say `..toast(...)` on any event and the
      // localized text reaches the user through the bus — the pipeline itself
      // stays free of Flutter.
      log.toastSink = UiMessengerToastSink(messenger);
    },
    dispose: (dependencies) async {
      // Only if it is still OURS: an abandoned composition (the 7-minute timeout
      // in `$initializeApp`) tearing down after a retry would otherwise silence
      // the live app's toasts. The escalation sink has had this guard all along.
      if (log.toastSink case UiMessengerToastSink(:final messenger) when identical(messenger, dependencies.messenger)) {
        log.toastSink = null;
      }
      await dependencies.messenger.dispose();
    },
  ),
  InitStep(
    'Prepare updates check',
    (dependencies) => dependencies.updateCheckController = UpdateCheckController(
      updateCheckApi: UpdateCheckApiImpl(),
      metadata: dependencies.metadata,
    ),
    dispose: (dependencies) => dependencies.updateCheckController.dispose(),
  ),
  InitStep(
    'Prepare authentication handler',
    (dependencies) => dependencies.authenticationHandler = AuthenticationHandler(),
    dispose: (dependencies) => dependencies.authenticationHandler.close(),
  ),
  InitStep(
    'Prepare authentication repository',
    (dependencies) {
      final settings = dependencies.settings;
      final authenticationHandler = dependencies.authenticationHandler;

      dependencies.authenticationRepository = AuthenticationRepository(
        api: dependencies.authClient,
        authHandler: authenticationHandler,
        settings: settings,
        metadata: dependencies.metadata, // TODO: extract app version from requests metadata
      );
    },
    dispose: (dependencies) => dependencies.authenticationRepository.terminate(),
  ),

  // External HTTP client (S3 presigned / third-party): deliberately no auth and no first-party
  // X-* headers (must not leak off-domain); session-bound so logout tears down in-flight uploads.
  InitStep(
    'Prepare external HTTP client',
    (dependencies) {
      dependencies.externalHttpClient = ApiClient(
        // Only used for QUIC hints + relative-path merge; requests pass absolute URLs (S3).
        baseUrl: () => Uri.parse(dependencies.environment.s3Url),
        sessionToken: () => dependencies.authenticationRepository.sessionCancelToken,
        middlewares: <ApiClientMiddleware>[
          const HttpLoggerMiddleware().call,
          // propagateTrace: false — never inject sentry-trace/baggage into third-party (S3) requests;
          // the span + error capture still run for upload monitoring.
          const HttpSentryMiddleware(propagateTrace: false).call,
          RetryMiddleware(
            onRetry: (error, attempt, delay) =>
                logTransportRetry(area: 'Http', error: error, attempt: attempt, delay: delay),
          ).call,
          const TimeoutMiddleware().call,
        ],
      );
    },
    dispose: (dependencies) => dependencies.externalHttpClient.close(),
  ),
  InitStep(
    'Prepare authentication controller',
    (dependencies) => dependencies.authenticationController = AuthenticationController(
      repository: dependencies.authenticationRepository,
      messenger: dependencies.messenger,
    ),
    dispose: (dependencies) => dependencies.authenticationController.dispose(),
  ),
  // The repository only: it is stateless and keyed per call by `getUserId`, so it is safe to share
  // across sessions. The controllers it feeds are per-user and live under `AuthenticatedScope`.
  InitStep(
    'Prepare users repository',
    (dependencies) => dependencies.usersRepository = UsersRepository(
      api: dependencies.usersClient,
      getUserId: dependencies.authenticationRepository.getUserId,
    ),
  ),
  // Awaited via the repository (blocks on the local storage read only, §11.1); the controller
  // mirrors the emitted state via its userChanges subscription.
  InitStep(
    'Restore credentials',
    (dependencies) => dependencies.authenticationRepository.restore(),
  ),

  // 'Prepare authentication controller': (dependencies) =>
  //     dependencies.authenticationController = AuthenticationController(
  //       repository: AuthenticationRepositoryImpl(
  //         settings: dependencies.settings,
  //       ),
  //     ),
  // 'Restore last user': (dependencies) => dependencies.authenticationController.restore(),
  // 'Initialize localization': (_) {},
  InitStep(
    'Log app initialized',
    (_) {
      /* TODO(planned): emit app-initialized analytics event. */
    },
  ),
];

/// Tears down everything [initializationSteps] created. The dispose mirror is DERIVED by
/// reversing the step list, so create and teardown can never drift apart (the hand-written
/// mirror this replaces had drifted to 5 disposed resources out of ~25 steps).
///
/// Effective order (reverse of creation): module subscriptions and controllers first — no late
/// RPC/stream event lands in a disposed listener — then the auth coordinator, the transports
/// (the shared Connect HTTP client owns every RPC connection; connectrpc exposes no hard close —
/// see RpcHttpClientHandle.close), the database (nothing above may touch it once closed: a
/// re-init would otherwise reopen sqlite against a live connection), and Sentry last, so
/// teardown errors are still reported.
Future<void> $disposeDependencies(Dependencies dependencies) => disposeSteps(initializationSteps, dependencies);

/// Best-effort reverse-order teardown of [steps]' resources (A6): one failing dispose must
/// neither crash shutdown nor skip the disposes after it.
@visibleForTesting
Future<void> disposeSteps(List<InitStep> steps, Dependencies dependencies) async {
  for (final step in steps.reversed) {
    final dispose = step.dispose;
    if (dispose == null) continue;
    try {
      await dispose(dependencies);
    } on Object catch (error, stackTrace) {
      // A LateInitializationError is expected on the failed-init path: the field this step's
      // dispose touches was never set (its create did not run or did not complete). Silent by
      // design — a warning would ship a non-event to Sentry for every unbuilt step. The type is
      // not denotable (dart:_internal), hence the toString probe.
      if (error is Error && error.toString().startsWith('LateInitializationError')) continue;
      log.w(
        'Boot | dispose | failed',
        error: error,
        stackTrace: stackTrace,
        meta: <String, Object?>{
          'app.boot.step': step.name,
        },
      );
    }
  }
}

/// Trims the log journal to its newest 1000 rows and reclaims space when the trim was worth it.
///
/// Replaces the template's 'Shrink database' INIT STEP, which ran an unconditional VACUUM (a
/// full-database rewrite) on the startup critical path plus a second one on a
/// `DateTime.now().second % 10 == 0` wall-clock lottery. Scheduled a few seconds after the first
/// frame instead (see `$initializeApp`); the VACUUM runs only when the trim actually removed
/// enough rows to be worth reclaiming.
Future<void> $maintainDatabase(Dependencies dependencies) async {
  try {
    final database = dependencies.database;
    final logTbl = database.logTbl;
    final deleted = await database.transaction<int>(() async {
      final cutoff =
          await (database.select<LogTbl, LogTblData>(logTbl)
                ..orderBy([(tbl) => OrderingTerm(expression: tbl.id, mode: .desc)])
                ..limit(1, offset: 1000))
              .getSingleOrNull();
      if (cutoff == null) return 0;
      return (database.delete(logTbl)..where((tbl) => tbl.time.isSmallerOrEqualValue(cutoff.time))).go();
    });
    // Deterministic, and proportionate: a VACUUM only pays for itself after a real trim. 500 rows
    // is half the ring buffer — reached after a busy session, never on a quiet relaunch.
    if (deleted >= 500) {
      await database.customStatement('VACUUM;');
      log.i('Maintenance | database | trimmed and vacuumed', meta: <String, Object?>{'db.rows_deleted': deleted});
    } else if (deleted > 0) {
      log.i('Maintenance | database | trimmed', meta: <String, Object?>{'db.rows_deleted': deleted});
    }
  } on Object catch (error, stackTrace) {
    // Maintenance racing shutdown (database already closed) is expected and must never crash.
    log.w('Maintenance | database | skipped', error: error, stackTrace: stackTrace);
  }
}
