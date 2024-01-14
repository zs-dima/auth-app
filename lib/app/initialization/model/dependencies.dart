// ignore_for_file: avoid-unassigned-late-fields-keyword

import 'package:auth_app/app/database/database.dart';
import 'package:auth_app/app/environment/model/app_environment.dart';
import 'package:auth_app/app/initialization/model/app_metadata.dart';
import 'package:auth_app/app/log/exception_tracking_manager.dart';
import 'package:auth_app/app/message/controller/message_controller.dart';
import 'package:auth_app/feature/authentication/controller/authentication_controller.dart';
import 'package:auth_app/feature/authentication/data/auth_repository.dart';
import 'package:auth_app/feature/settings/data/settings_repository.dart';
import 'package:auth_app/feature/users/controller/users_avatars_controller.dart';
import 'package:auth_app/feature/users/data/users_repository.dart';
import 'package:auth_model/auth_model.dart';
import 'package:flutter/widgets.dart';

extension DependenciesX on BuildContext {
  // Dependencies get dependencies => DependenciesScope.of(this);
}

/// {@template dependencies}
/// Dependencies container
/// {@endtemplate}

class Dependencies {
  /// App metadata
  late final AppMetadata metadata;

  /// Exception tracking manager
  late final IExceptionTrackingManager exceptionTrackingManager;

  /// App environment
  late final IAppEnvironment environment;

  /// Settings repository
  late final ISettingsRepository settings;

  /// Authentication handler
  late final IAuthenticationHandler authenticationHandler;

  /// Authentication repository
  late final IAuthRepository authenticationRepository;

  /// Users repository
  late final IUsersRepository usersRepository;

  /// Database
  late final Database database;

  /// API Client
  // late final Dio dio;

  /// Message controller
  late final AppMessageController messageController;

  /// Authentication controller
  late final AuthenticationController authenticationController;

  /// Users avatars controller
  late final UsersAvatarsController avatarController;

  Dependencies();
}
