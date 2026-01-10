// ignore_for_file: prefer-static-class

import 'dart:async';

import 'package:auth_app/_core/api/grpc/middlewares/logger_middleware.dart';
import 'package:auth_app/_core/api/grpc/middlewares/sentry_middleware.dart';
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
import 'package:auth_app/update/controller/update_check_api.dart';
import 'package:auth_app/update/controller/update_check_controller.dart';
import 'package:auth_app/users/controller/avatar_controller.dart';
import 'package:auth_app/users/controller/users_controller.dart';
import 'package:auth_app/users/data/users_repository.dart';
import 'package:auth_model/auth_model.dart';
import 'package:control/control.dart';
import 'package:core_tool/core_tool.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:grpc/grpc.dart';
import 'package:grpc_model/grpc_model.dart';
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
  'Initializing analytics': (_) {},
  'Log app open': (_) {},
  'Get remote config': (_) {},
  'Restore settings': (_) {},
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
    const secureStorage = FlutterSecureStorage();
    const securePreferencesDao = AppSecurePreferencesDao(secureStorage);
    final settings = SettingsRepository(
      preferences: preferencesDao,
      securePreferences: securePreferencesDao,
      codec: const ThemeModeCodec(),
    );
    dependencies.settings = settings;
  },
  'Storage repository': (dependencies) {
    //
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
  'gRPC Client factory': (dependencies) {
    GrpcAuthenticationClient grpsFactory([Iterable<ClientInterceptor>? middlewares]) {
      final list = <ClientInterceptor>[
        // Add your interceptors here
        // e.g. LoggerInterceptor(), RetryInterceptor(), etc.
        // TODO: Deduplicate requests interceptor
        // TODO: Cache interceptor

        // Metadata middleware
        GrpcMetadataMiddleware(
          metadata: {
            ...dependencies.metadata.toHeaders(),
            'X-Environment': dependencies.environment.type.name,
          },
        ),

        // Retry middleware
        // GrpcRetryMiddleware(
        //   retries: 3,
        //   retryEvaluator: (error, attempt) =>
        //       attempt <= 3 &&
        //       switch (error) {
        //         ApiClientException$Authentication() => false, // Do not retry on authentication errors
        //         TimeoutException() || ApiClientException$Timeout() => true, // Retry on timeout exceptions
        //         ApiClientException$Client(:final code) => !const <String>{
        //           'canceled',
        //           'aborted',
        //           'cancel',
        //           'cancelled',
        //           'abort',
        //           'unexpected_error',
        //           'unknown error',
        //         }.contains(code), // Do not retry on cancellation or abort errors
        //         ApiClientException$Network(:final statusCode) => const <int>{
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

        // Logger middleware
        const GrpcLoggerMiddleware(),

        // Sentry middleware
        const GrpcSentryMiddleware(),

        // Any other middlewares you need
        ...?middlewares,
      ];

      // Create the gRPC channel
      final environment = dependencies.environment;
      final authChannel = GrpcClientChannel(environment.authService);

      // Create auth client with middleware support
      return GrpcAuthenticationClient(
        GrpcClientOptions(
          authChannel,
          interceptors: list,
          timeout: const Duration(seconds: 30),
        ),
      );
    }

    dependencies.grpsAuthFactory = grpsFactory;
  },

  // General gRPC client initialization
  'General gRPC Client': (dependencies) {
    dependencies.authClient = dependencies.grpsAuthFactory([
      GrpcAuthenticationMiddleware(
        getToken: () async {
          try {
            return await dependencies.credentialsManager.getAccessCredentials();
          } on Object catch (e, _) {
            logger.w('Error getting token: $e');
            return null;
          }
        },
        onAuthError: () {
          logger.w('Received "Not authenticated" gRPC response, logging out... ');
          dependencies.authenticationController.signOut();
        },
        unauthenticatedPaths: const <String>{
          '/auth.AuthService/SignIn',
          '/auth.AuthService/SignOut',
          '/auth.AuthService/RefreshTokens',
          '/auth.AuthService/ResetPassword',
        },
      ),
    ]);
  },

  ///
  'Prepare notifications': (dependencies) => dependencies.messageController = AppMessageController(),
  'Prepare updates check': (dependencies) => dependencies.updateCheckController = UpdateCheckController(
    updateCheckApi: const UpdateCheckApiImpl(),
    metadata: dependencies.metadata,
    messageController: dependencies.messageController,
  ),
  'Prepare authentication handler': (dependencies) => dependencies.authenticationHandler = AuthenticationHandler(),
  'Prepare authentication repository': (dependencies) {
    final settings = dependencies.settings;
    final authenticationHandler = dependencies.authenticationHandler;

    dependencies.credentialsManager = CredentialsCallbacks(
      getAccessCredentials: () => dependencies.authenticationRepository.getAccessCredentials(),
      getRefreshTokens: (_) async => null, // dependencies.authenticationRepository.refreshTokens(),
      authHandler: authenticationHandler,
      allowAnonymous: true,
    );

    return dependencies.authenticationRepository = AuthenticationRepository(
      api: dependencies.authClient,
      authHandler: authenticationHandler,
      settings: settings,
      metadata: dependencies.metadata, // TODO: extract app version from requests metadata
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
        apiClient: dependencies.authClient,
        getUserId: dependencies.authenticationRepository.getUserId,
      )
      ..usersController = UsersController(
        repository: dependencies.usersRepository,
        messageController: dependencies.messageController,
      )
      ..avatarController = AvatarController(
        s3Url: dependencies.environment.s3Url,
        repository: dependencies.usersRepository,
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
          authenticatedUserController.loadUser,
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

  'Restore credentials': (dependencies) => dependencies.authenticationController.restore(),

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
  'Log app initialized': (_) {},
};

Future<void> $disposeDependencies() async {
  await _logSubscription?.cancel();
  // await _logTblSubscription?.cancel();
  await _authUserSubscription?.cancel();
  await _authUserInfoSubscription?.cancel();
  await _impersonationSubscription?.cancel();
}
