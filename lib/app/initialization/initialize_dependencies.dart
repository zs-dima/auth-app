// ignore_for_file: prefer-static-class

import 'dart:async';

import 'package:auth_app/_core/database/database.dart';
import 'package:auth_app/app/controller/controller_observer.dart';
import 'package:auth_app/app/environment/environment_loader.dart';
import 'package:auth_app/app/initialization/app_migrator.dart';
import 'package:auth_app/app/initialization/grpc_client_factory.dart';
import 'package:auth_app/app/initialization/model/app_metadata.dart';
import 'package:auth_app/app/initialization/model/dependencies.dart';
import 'package:auth_app/app/initialization/platform/platform_initialization.dart';
import 'package:auth_app/app/log/exception_tracking_manager.dart';
import 'package:auth_app/app/log/logger.dart';
import 'package:auth_app/app/message/controller/message_controller.dart';
import 'package:auth_app/app/settings/dao/app_preferences_dao.dart';
import 'package:auth_app/app/settings/dao/app_secure_preferences_dao.dart';
import 'package:auth_app/feature/authentication/controller/authentication_controller.dart';
import 'package:auth_app/feature/authentication/data/auth_repository.dart';
import 'package:auth_app/feature/settings/data/settings_repository.dart';
import 'package:auth_app/feature/settings/data/theme_mode_codec.dart';
import 'package:auth_app/feature/users/controller/users_avatars_controller.dart';
import 'package:auth_app/feature/users/data/users_repository.dart';
import 'package:auth_model/auth_model.dart';
import 'package:control/control.dart';
import 'package:core_tool/core_tool.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:grpc_model/grpc_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
      final stepFunction = step.value(dependencies);
      final _ =
          stepFunction
              is Future //
          ? await stepFunction
          : stepFunction;
      stopWatch.stop();
      logger.v6(
        '⚡${currentStep.toString().padLeft(2)}/$totalSteps ${percent.toString().padLeft(2)}%'
        '${percent == 100 ? '' : ' '}${stopWatch.elapsed.formattedMs.padLeft(5)} '
        '| ${step.key}',
      );
    } on Object catch (error, stackTrace) {
      logger.e('⚡ failed at step "${step.key}"', error: error, stackTrace: stackTrace);
      Error.throwWithStackTrace('Initialization failed at step "${step.key}": $error', stackTrace);
    }
  }
  return dependencies;
}

final _initializationSteps = <String, FutureOr<void> Function(Dependencies)>{
  'Platform pre-initialization': (_) => $platformInitialization(),
  'Creating app metadata': (dependencies) => dependencies.metadata = AppMetadata.fromApp(),
  'Observer state management': (_) => Controller.observer = ControllerObserver.instance(logger),
  'Initializing analytics': (_) {},
  'Log app open': (_) {},
  'Get remote config': (_) {},
  'Restore settings': (_) {},
  'Environment': (dependencies) async {
    final environmentLoader = EnvironmentLoader();
    dependencies.environment = await environmentLoader();
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
                ..orderBy([(tbl) => OrderingTerm(expression: tbl.id, mode: OrderingMode.desc)])
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
    final securePreferencesDao = AppSecurePreferencesDao.instance(
      secureStorage,
      getUserId: () => dependencies.authenticationRepository.getUserId(),
    );
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
  'Messages controller': (dependencies) => dependencies.messageController = AppMessageController(),
  'Authentication handler': (dependencies) => dependencies.authenticationHandler = AuthenticationHandler(),
  'Authentication repository': (dependencies) async {
    final environment = dependencies.environment;
    final settings = dependencies.settings;
    final metadata = dependencies.metadata;

    // Create repository first, then wire up credentials manager
    late final AuthRepository authenticationRepository;

    // Create the gRPC channel
    final authChannel = GrpcClientChannel(environment.authService);

    // Create middlewares for the gRPC client
    final middlewares = createStandardMiddlewares(
      environment: environment.type.name,
      metadata: metadata.toHeaders(),
      getToken: () async => (await authenticationRepository.getAccessCredentials())?.accessToken.token,
      onAuthError: () => dependencies.authenticationHandler.handleAuthenticationError(),
    );

    // Create auth client with middleware support
    final authClient = GrpcAuthenticationClient.withMiddlewares(
      authChannel,
      middlewares: middlewares,
    );
    final authApi = GrpcAuthenticationApi(client: authClient);

    authenticationRepository = AuthRepository(
      apiClient: authApi,
      authHandler: dependencies.authenticationHandler,
      settings: settings,
    );

    dependencies
      ..authenticationRepository = authenticationRepository
      ..authenticationController = AuthenticationController(
        repository: authenticationRepository,
        messageController: dependencies.messageController,
      )
      ..usersRepository = UsersRepository(apiClient: authApi);

    final userInfo = settings.user;
    final credentials = await settings.getCredentials();
    if (userInfo != null && credentials != null) {
      final user = AuthenticatedUser(userInfo: userInfo, credentials: credentials);
      await authenticationRepository.validateCredentials(user);
    }
  },
  'Users avatars controller': (dependencies) => dependencies.avatarController = UsersAvatarsController(
    usersRepository: dependencies.usersRepository,
    messageController: dependencies.messageController,
  ),

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
  //   l.bufferTime(const Duration(seconds: 1)).where((logs) => logs.isNotEmpty).listen(LogBuffer.instance.addAll);
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
