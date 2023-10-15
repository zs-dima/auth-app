import 'dart:async';

import 'package:auth_app/app/bloc/app_bloc_observer.dart';
import 'package:auth_app/app/environment/environment_loader.dart';
import 'package:auth_app/app/environment/model/environment.dart';
import 'package:auth_app/app/initialization/model/dependencies.dart';
import 'package:auth_app/app/initialization/platform/initialization_vm.dart'
    // ignore: uri_does_not_exist
    if (dart.library.html) 'package:auth_app/app/initialization/platform/initialization_js.dart';
import 'package:auth_app/app/locale/data/locale_datasource.dart';
import 'package:auth_app/app/locale/data/locale_repository.dart';
import 'package:auth_app/app/log/exception_tracking_manager.dart';
import 'package:auth_app/app/log/logger.dart';
import 'package:auth_app/app/settings/dao/app_preferences_dao.dart';
import 'package:auth_app/app/settings/dao/app_secure_preferences_dao.dart';
import 'package:auth_app/app/settings/repository/settings_repository.dart';
import 'package:auth_app/app/theme/data/theme_datasource.dart';
import 'package:auth_app/app/theme/data/theme_repository.dart';
import 'package:auth_app/feature/auth/data/auth_repository.dart';
import 'package:auth_app/feature/users/data/users_repository.dart';
import 'package:auth_model/auth_model.dart';
import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart' as bloc_concurrency;
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:grpc_model/grpc_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A function which represents a single initialization step.
typedef StepAction = FutureOr<void> Function(DependenciesMutable dependencies);

/// The initialization steps, which are executed in the order they are defined.
///
/// The [Dependencies] object is passed to each step, which allows the step to
/// set the dependency, and the next step to use it.
mixin InitializationSteps {
  /// The initialization steps,
  /// which are executed in the order they are defined.
  final initializationSteps = <String, StepAction>{
    'Platform pre-initialization': (dependencies) => $platformInitialization(),
    'Observer state management': (dependencies) {
      Bloc.observer = AppBlocObserver.instance(logger);
      Bloc.transformer = bloc_concurrency.sequential();
    },
    'Environment': (dependencies) async {
      final environmentLoader = EnvironmentLoader();
      dependencies.environment = await environmentLoader();
    },
    'Error tracking': (dependencies) async {
      final environment = dependencies.environment;
      if (!(!kDebugMode && environment.type == Environment.production)) {
        final trackingManager = SentryTrackingManager(
          environment: environment.type,
          sentryDsn: environment.sentryDsn,
          logger: logger,
        );
        await trackingManager.enableReporting();
        dependencies.exceptionTrackingManager = trackingManager;
      }
    },
    'Settings': (dependencies) async {
      final sharedPreferences = await SharedPreferences.getInstance();
      final preferencesDao = AppPreferencesDao(
        sharedPreferences,
      );
      const secureStorage = FlutterSecureStorage();
      final securePreferencesDao = AppSecurePreferencesDao.instance(
        secureStorage,
        getUserId: () => dependencies.authenticationRepository.getUserId(),
      );
      final settings = SettingsRepository(
        preferences: preferencesDao,
        securePreferences: securePreferencesDao,
      );
      dependencies.settings = settings;
    },
    'Storage repository': (dependencies) async {
      //
    },
    'Theme repository': (dependencies) async {
      final settings = dependencies.settings;
      final themeDataSource = ThemeDataSource(settings: settings);
      final themeRepository = ThemeRepository(themeDataSource);
      dependencies.themeRepository = themeRepository;
    },
    'Locale repository': (dependencies) async {
      final settings = dependencies.settings;
      final localeDataSource = LocaleDataSource(settings: settings);
      final localeRepository = LocaleRepository(localeDataSource);
      dependencies.localeRepository = localeRepository;
    },
    'Authentication handler': (dependencies) => dependencies.authenticationHandler = AuthenticationHandler(),
    'Authentication repository': (dependencies) async {
      final environment = dependencies.environment;
      final settings = dependencies.settings;

      final credentialsManager = CredentialsCallbacks(
        getAccessCredentials: () => dependencies.authenticationRepository.getAccessCredentials(),
        refreshTokens: (t) => dependencies.authenticationRepository.refreshTokens(t),
        authHandler: dependencies.authenticationHandler,
        allowAnonymous: true,
      );

      final authChannel = GrpcClientChannel(environment.authService);
      final authClient = AuthApiClient.instance(
        channel: authChannel,
        credentialsManager: credentialsManager,
      );
      final authApi = AuthApi(client: authClient);

      final authenticationRepository = AuthRepository(
        apiClient: authApi,
        authHandler: dependencies.authenticationHandler,
        settings: settings,
      );

      dependencies
        ..authenticationRepository = authenticationRepository
        ..usersRepository = UsersRepository(apiClient: authApi);

      final userInfo = settings.user;
      final credentials = await settings.getCredentials();
      if (userInfo != null && credentials != null) {
        final user = AuthenticatedUser(
          userInfo: userInfo,
          credentials: credentials,
        );
        await authenticationRepository.validateCredentials(user);
      }
    },
  };
}
