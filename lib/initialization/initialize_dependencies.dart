// ignore_for_file: prefer-static-class

import 'dart:async';

import 'package:auth_app/_core/api/connect/middlewares/logger_middleware.dart';
import 'package:auth_app/_core/api/connect/middlewares/sentry_middleware.dart';
import 'package:auth_app/_core/api/http/middlewares/logger_middleware.dart';
import 'package:auth_app/_core/api/http/middlewares/sentry_middleware.dart';
import 'package:auth_app/_core/controller/controller_observer.dart';
import 'package:auth_app/_core/database/database.dart';
import 'package:auth_app/_core/environment/environment_loader.dart';
import 'package:auth_app/_core/log/exception_tracking_manager.dart';
import 'package:auth_app/_core/log/logger.dart';
import 'package:auth_app/_core/message/controller/message_controller.dart';
import 'package:auth_app/_core/model/app_metadata.dart';
import 'package:auth_app/_core/model/dependencies.dart';
import 'package:auth_app/_core/theme/theme_mode_codec.dart';
import 'package:auth_app/authentication/controller/authenticated_user_controller.dart';
import 'package:auth_app/authentication/controller/authentication_controller.dart';
import 'package:auth_app/authentication/data/authentication_repository.dart';
import 'package:auth_app/impersonation/controller/impersonate_controller.dart';
import 'package:auth_app/impersonation/data/impersonate_repository.dart';
import 'package:auth_app/initialization/app_migrator.dart';
import 'package:auth_app/settings/data/dao/app_preferences_dao.dart';
import 'package:auth_app/settings/data/dao/app_secure_preferences_dao.dart';
import 'package:auth_app/settings/data/settings_repository.dart';
import 'package:auth_app/update/controller/platform/update_check.dart';
import 'package:auth_app/update/controller/update_check_controller.dart';
import 'package:auth_app/users/controller/avatar_controller.dart';
import 'package:auth_app/users/controller/users_controller.dart';
import 'package:auth_app/users/data/users_repository.dart';
import 'package:auth_model/auth_model.dart';
import 'package:connect_model/connect_model.dart';
import 'package:connectrpc/connect.dart';
import 'package:control/control.dart';
import 'package:core_tool/core_tool.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http_client/http_client.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

StreamSubscription<List<LogMessage>>? _logSubscription;
// StreamSubscription<List<LogTblCompanion>>? _logTblSubscription;
StreamSubscription<AuthUser>? _authUserSubscription;
StreamSubscription? _authUserInfoSubscription;
StreamSubscription? _impersonationSubscription;

/// Initializes the app and returns a [Dependencies] object
Future<Dependencies> $initializeDependencies({void Function(int progress, String message)? onProgress}) async {
  final dependencies = Dependencies();
  final totalSteps = _initializationSteps.length;
  var currentStep = 0;
  for (final step in _initializationSteps.entries) {
    try {
      currentStep++;
      final stopWatch = Stopwatch()..start();
      final percent = (currentStep * 100 ~/ totalSteps).clamp(0, 100);
      onProgress?.call(percent, step.key);

      final onStep = step.value(dependencies);
      final _ = onStep is Future ? await onStep : onStep;

      stopWatch.stop();
      logger.v6(
        '💫${currentStep.toString().padLeft(2)}/$totalSteps ${percent.toString().padLeft(2)}%'
        '${percent == 100 ? '' : ' '}${stopWatch.elapsed.formattedMs.padLeft(5)} '
        '| ${step.key}',
      );
    } on Object catch (error, stackTrace) {
      logger.e('🚧 failed at step "${step.key}"', error: error, stackTrace: stackTrace);
      Error.throwWithStackTrace('Initialization failed at step "${step.key}": $error', stackTrace);
    }
  }
  return dependencies;
}

final _initializationSteps = <String, FutureOr<void> Function(Dependencies)>{
  'Creating app metadata': (dependencies) => dependencies.metadata = AppMetadata.platform(),
  'Observer state management': (_) => Controller.observer = ControllerObserver.instance(logger),
  'Initializing analytics': (_) {
    // TODO(planned): initialize analytics here.
    // await Firebase.initializeApp(
    //   options: DefaultFirebaseOptions.currentPlatform,
    // );
  },
  'Log app open': (_) {
    /* TODO(planned): emit app-open analytics event. */
  },
  'Get remote config': (_) {
    /* TODO(planned): fetch remote config. */
  },
  'Restore settings': (_) {
    /* TODO(planned): restore persisted settings. */
  },
  'Environment': (dependencies) async {
    final environmentLoader = EnvironmentLoader();
    dependencies.environment = await environmentLoader();

    await initializeDateFormatting('en_US', null);
  },
  'Error tracking': (dependencies) async {
    if (kDebugMode) return;

    final environment = dependencies.environment;
    final trackingManager = SentryTrackingManager(
      environment: environment.type,
      sentryDsn: environment.sentryDsn,
      logger: logger,
    );
    await trackingManager.enableReporting();
    dependencies.exceptionTrackingManager = trackingManager;
  },
  'Connect to database': (dependencies) {
    final environment = dependencies.environment;

    return (dependencies.database =
            environment
                .inMemoryDatabase //
            ? Database.memory(environment.databaseName)
            : Database.lazy(environment.databaseName))
        .refresh();
  },
  'Shrink database': (dependencies) async {
    await dependencies.database.customStatement('VACUUM;');
    await dependencies.database.transaction(() async {
      final log =
          await (dependencies.database.select<LogTbl, LogTblData>(dependencies.database.logTbl)
                ..orderBy([(tbl) => OrderingTerm(expression: tbl.id, mode: .desc)])
                ..limit(1, offset: 1000))
              .getSingleOrNull();
      if (log != null) {
        await (dependencies.database.delete(
          dependencies.database.logTbl,
        )..where((tbl) => tbl.time.isSmallerOrEqualValue(log.time))).go();
      }
    });
    if (DateTime.now().second % 10 == 0) await dependencies.database.customStatement('VACUUM;');
  },
  'Migrate app from previous version': (dependencies) => AppMigrator.migrate(dependencies.database),

  'Settings': (dependencies) async {
    final sharedPreferences = await SharedPreferences.getInstance();
    final preferencesDao = AppPreferencesDao(sharedPreferences);
    // Apple keychain pinned to first_unlock_this_device: background writes after the first unlock,
    // no cross-device keychain restore. Android v10 defaults are already strong; existing entries
    // stay readable and self-heal via F2 (refresh_token.md §10.2).
    const secureStorage = FlutterSecureStorage(
      iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock_this_device),
      mOptions: MacOsOptions(accessibility: KeychainAccessibility.first_unlock_this_device),
    );
    const securePreferencesDao = AppSecurePreferencesDao(secureStorage);
    final settings = SettingsRepository(
      preferences: preferencesDao,
      securePreferences: securePreferencesDao,
      codec: const ThemeModeCodec(),
    );
    dependencies.settings = settings;
  },
  'Storage repository': (dependencies) {
    // TODO(planned): wire the storage repository.
  },
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
  'Connect client factory': (dependencies) {
    // A6: Connect clients are intentionally NOT wired to the session CancelToken — per-call
    // deadlines, subscription teardown, and server-side token rejection already cover it. If a hard
    // "abort all on logout" is ever needed, prefer closing the shared HTTP client + lazy re-init
    // over a token bridge.
    List<Interceptor> interceptorsFactory([Iterable<Interceptor>? middlewares]) => <Interceptor>[
      // Order (outermost → innermost): Logger → Metadata → Sentry → Retry → Authentication → wire.
      // connect-dart applies the FIRST interceptor in this list as the outermost layer — pinned by
      // connect_model's interceptor_chain_order_test (the upstream doc wording is ambiguous).
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
        noRetryPaths: {
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

  // General Connect client initialization
  'General Connect Client': (dependencies) {
    final authenticationMiddleware = ConnectAuthenticationMiddleware(
      getToken: () async {
        try {
          return await dependencies.authenticationRepository.getAccessCredentials();
        } on Object catch (e, st) {
          // Surface a transient credential-resolution failure (do NOT collapse to `null`, which the
          // middleware treats as "definitively no token" and would force a spurious logout — A3).
          logger.w('Error resolving access credentials', error: e);
          Error.throwWithStackTrace(e, st);
        }
      },
      refreshCredentials: (usedAccessToken) => dependencies.authenticationRepository.refreshCredentials(usedAccessToken),
      // Logout only via the single auth-state bus (A26); the repository performs the sign-out.
      onAuthError: () {
        logger.w('Received an unauthenticated RPC response; signing out via the auth bus');
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

  ///
  'Prepare notifications': (dependencies) => dependencies.messageController = AppMessageController(),
  'Prepare updates check': (dependencies) => dependencies.updateCheckController = UpdateCheckController(
    updateCheckApi: UpdateCheckApiImpl(),
    metadata: dependencies.metadata,
    messageController: dependencies.messageController,
  ),
  'Prepare authentication handler': (dependencies) => dependencies.authenticationHandler = AuthenticationHandler(),
  'Prepare authentication repository': (dependencies) {
    final settings = dependencies.settings;
    final authenticationHandler = dependencies.authenticationHandler;

    return dependencies.authenticationRepository = AuthenticationRepository(
      api: dependencies.authClient,
      authHandler: authenticationHandler,
      settings: settings,
      metadata: dependencies.metadata, // TODO: extract app version from requests metadata
    );
  },

  // External HTTP client (S3 presigned / third-party): deliberately no auth and no first-party
  // X-* headers (must not leak off-domain); session-bound so logout tears down in-flight uploads.
  'Prepare external HTTP client': (dependencies) {
    dependencies.externalHttpClient = ApiClient(
      // Only used for QUIC hints + relative-path merge; requests pass absolute URLs (S3).
      baseUrl: () => Uri.parse(dependencies.environment.s3Url),
      sessionToken: () => dependencies.authenticationRepository.sessionCancelToken,
      middlewares: <ApiClientMiddleware>[
        const HttpLoggerMiddleware().call,
        // propagateTrace: false — never inject sentry-trace/baggage into third-party (S3) requests;
        // the span + error capture still run for upload monitoring.
        const HttpSentryMiddleware(propagateTrace: false).call,
        RetryMiddleware().call,
        const TimeoutMiddleware().call,
      ],
    );
  },
  'Prepare authentication controller': (dependencies) =>
      dependencies.authenticationController = AuthenticationController(
        repository: dependencies.authenticationRepository,
        messageController: dependencies.messageController,
      ),
  'Prepare users repository': (dependencies) {
    dependencies
      ..usersRepository = UsersRepository(
        api: dependencies.usersClient,
        getUserId: dependencies.authenticationRepository.getUserId,
      )
      ..usersController = UsersController(
        repository: dependencies.usersRepository,
        messageController: dependencies.messageController,
      )
      ..avatarController = AvatarController(
        s3Url: dependencies.environment.s3Url,
        repository: dependencies.usersRepository,
        httpClient: dependencies.externalHttpClient,
        messageController: dependencies.messageController,
      );
  },
  'Prepare authenticated user controller': (dependencies) =>
      dependencies.authenticatedUserController = AuthenticatedUserController(
        usersController: dependencies.usersController,
        messageController: dependencies.messageController,
      ),
  'Prepare users handlers': (dependencies) {
    final impersonateController = ImpersonateController(
      repository: ImpersonateRepository(currentUser: dependencies.authenticatedUserController.state.user),
      messageController: dependencies.messageController,
    );

    dependencies.impersonateController = impersonateController;
    final authenticatedUserController = dependencies.authenticatedUserController;

    _authUserSubscription = dependencies
        .authenticationRepository
        .userChanges //
        .listen(
          authenticatedUserController.getUser,
          // if (user case final AuthenticatedUser i) dependencies.avatarController.loadAvatar(i.userId, reload: false);
          cancelOnError: false,
        );

    _authUserInfoSubscription =
        authenticatedUserController //
            .toStream()
            .listen(
              (state) => switch (state) {
                AuthenticatedUserLoadedState(:final user) => impersonateController.impersonate(user),
                _ => null,
              },
              cancelOnError: false,
            );

    _impersonationSubscription =
        impersonateController //
            .toStream()
            .whereType<ImpersonateIdleState>()
            .listen(
              (state) {
                // Update dependencies
              },
              cancelOnError: false,
            );
  },

  // Awaited via the repository (blocks on the local storage read only, §11.1); the controller
  // mirrors the emitted state via its userChanges subscription.
  'Restore credentials': (dependencies) => dependencies.authenticationRepository.restore(),

  // 'Prepare authentication controller': (dependencies) =>
  //     dependencies.authenticationController = AuthenticationController(
  //       repository: AuthenticationRepositoryImpl(
  //         settings: dependencies.settings,
  //       ),
  //     ),
  // 'Restore last user': (dependencies) => dependencies.authenticationController.restore(),
  // 'Initialize localization': (_) {},
  // 'Collect logs': (dependencies) async {
  //   await (dependencies.database.select<LogTbl, LogTblData>(dependencies.database.logTbl)
  //         ..orderBy([(tbl) => OrderingTerm(expression: tbl.time, mode: OrderingMode.desc)])
  //         ..limit(LogBuffer.bufferLimit))
  //       .get()
  //       .then<List<LogMessage>>(
  //         (logs) => logs
  //             .map(
  //               (l) => l.stack != null
  //                   ? LogMessageWithStackTrace(
  //                       date: DateTime.fromMillisecondsSinceEpoch(l.time * 1000),
  //                       level: LogLevel.fromValue(l.level),
  //                       message: l.message,
  //                       stackTrace: StackTrace.fromString(l.stack!),
  //                     )
  //                   : LogMessage(
  //                       date: DateTime.fromMillisecondsSinceEpoch(l.time * 1000),
  //                       level: LogLevel.fromValue(l.level),
  //                       message: l.message,
  //                     ),
  //             )
  //             .toList(),
  //       )
  //       .then<void>(LogBuffer.instance.addAll);
  //   l.bufferTime(const Duration(seconds: 1)).where((logs) => logs.isNotEmpty).listen(LogBuffer.instance.addAll, cancelOnError: false,);
  //   l
  //       .map<LogTblCompanion>(
  //         (log) => LogTblCompanion.insert(
  //           level: log.level.level,
  //           message: log.message.toString(),
  //           time: Value<int>(log.date.millisecondsSinceEpoch ~/ 1000),
  //           stack: Value<String?>(
  //             switch (log) {
  //               final LogMessageWithStackTrace l => l.stackTrace.toString(),
  //               _ => null,
  //             },
  //           ),
  //         ),
  //       )
  //       .bufferTime(const Duration(seconds: 5))
  //       .where((logs) => logs.isNotEmpty)
  //       .listen(
  //         (logs) =>
  //             dependencies.database.batch((batch) => batch.insertAll(dependencies.database.logTbl, logs)).ignore(),
  //         cancelOnError: false,
  //       );
  // },
  'Log app initialized': (_) {
    /* TODO(planned): emit app-initialized analytics event. */
  },
};

Future<void> $disposeDependencies(Dependencies dependencies) async {
  await _logSubscription?.cancel();
  // await _logTblSubscription?.cancel();
  await _authUserSubscription?.cancel();
  await _authUserInfoSubscription?.cancel();
  await _impersonationSubscription?.cancel();

  // Tear down auth + transport resources (A6). Best-effort: a teardown error must not crash app
  // shutdown.
  try {
    // Source → sink order: shut transports down first so no late RPC/stream event races a closing
    // controller, then tear down the auth coordinator and its streams. The shared Connect HTTP
    // client owns every RPC connection (connectrpc 1.0.0 exposes no hard close — see
    // RpcHttpClientHandle.close; idle connections are reaped by idleConnectionTimeout).
    await dependencies.rpcHttpClient.close();
    dependencies.externalHttpClient.close();
    await dependencies.authenticationRepository.terminate();
    await dependencies.authenticationHandler.close();
  } on Object catch (e, stackTrace) {
    logger.w('Error disposing dependencies', error: e, stackTrace: stackTrace);
  }
}
