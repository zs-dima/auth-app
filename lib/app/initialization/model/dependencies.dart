// ignore_for_file: avoid-unassigned-late-fields-keyword

import 'package:auth_app/app/environment/model/app_environment.dart';
import 'package:auth_app/app/initialization/widget/dependencies_scope.dart';
import 'package:auth_app/app/locale/data/i_locale_repository.dart';
import 'package:auth_app/app/log/exception_tracking_manager.dart';
import 'package:auth_app/app/settings/repository/settings_repository.dart';
import 'package:auth_app/app/theme/data/i_theme_repository.dart';
import 'package:auth_app/feature/auth/data/auth_repository.dart';
import 'package:auth_app/feature/users/data/users_repository.dart';
import 'package:auth_model/auth_model.dart';
import 'package:flutter/widgets.dart';

extension DependenciesX on BuildContext {
  Dependencies get dependencies => DependenciesScope.of(this);
}

/// {@template dependencies}
/// Dependencies container
/// {@endtemplate}
abstract base class Dependencies {
  /// Exception tracking manager
  abstract final IExceptionTrackingManager exceptionTrackingManager;

  /// App environment
  abstract final IAppEnvironment environment;

  /// Settings repository
  abstract final ISettingsRepository settings;

  /// Theme repository
  abstract final IThemeRepository themeRepository;

  /// Locale repository
  abstract final ILocaleRepository localeRepository;

  /// Authentication handler
  abstract final IAuthenticationHandler authenticationHandler;

  /// Authentication repository
  abstract final IAuthRepository authenticationRepository;

  /// Users repository
  abstract final IUsersRepository usersRepository;

  /// {@macro dependencies}
  const Dependencies();
}

/// {@template mutable_dependencies}
/// Mutable version of dependencies
///
/// Used to build dependencies
/// {@endtemplate}
final class DependenciesMutable extends Dependencies {
  @override
  late IExceptionTrackingManager exceptionTrackingManager;

  @override
  late IAppEnvironment environment;

  @override
  late ISettingsRepository settings;

  @override
  late IThemeRepository themeRepository;

  @override
  late ILocaleRepository localeRepository;

  @override
  late IAuthenticationHandler authenticationHandler;

  @override
  late IAuthRepository authenticationRepository;

  @override
  late IUsersRepository usersRepository;

  /// {@macro mutable_dependencies}
  DependenciesMutable();
}

/// {@template initialization_result}
/// Result of initialization
/// {@endtemplate}
final class InitializationResult {
  /// The dependencies
  final Dependencies dependencies;

  /// The number of steps
  final int stepCount;

  /// The number of milliseconds spent
  final int msSpent;

  /// {@macro initialization_result}
  const InitializationResult({
    required this.dependencies,
    required this.stepCount,
    required this.msSpent,
  });

  @override
  String toString() => 'InitializationResult('
      'dependencies: $dependencies, '
      'stepCount: $stepCount, '
      'msSpent: $msSpent'
      ')';
}
