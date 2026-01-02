// ignore_for_file: avoid-unassigned-late-fields-keyword

import 'package:auth_app/_core/database/database.dart';
import 'package:auth_app/_core/environment/model/app_environment.dart';
import 'package:auth_app/_core/log/exception_tracking_manager.dart';
import 'package:auth_app/_core/message/controller/message_controller.dart';
import 'package:auth_app/_core/model/app_metadata.dart';
import 'package:auth_app/authentication/controller/authenticated_user_controller.dart';
import 'package:auth_app/authentication/controller/authentication_controller.dart';
import 'package:auth_app/authentication/data/authentication_repository.dart';
import 'package:auth_app/impersonation/controller/impersonate_controller.dart';
import 'package:auth_app/initialization/widget/inherited_dependencies.dart';
import 'package:auth_app/settings/data/settings_repository.dart';
import 'package:auth_app/update/controller/update_check_controller.dart';
import 'package:auth_app/users/controller/avatar_cache.dart';
import 'package:auth_app/users/controller/users_controller.dart';
import 'package:auth_app/users/data/users_repository.dart';
import 'package:auth_model/auth_model.dart';
import 'package:flutter/widgets.dart';
import 'package:grpc/grpc.dart';

extension DependenciesX on BuildContext {
  // Dependencies get dependencies => DependenciesScope.of(this);
}

/// {@template dependencies}
/// Dependencies container
/// {@endtemplate}

class Dependencies {
  Dependencies();

  /// The state from the closest instance of this class.
  factory Dependencies.of(BuildContext context) => InheritedDependencies.of(context);

  /// App metadata
  late final AppMetadata metadata;

  /// Exception tracking manager
  late final IExceptionTrackingManager exceptionTrackingManager;

  /// App environment
  late final IAppEnvironment environment;

  /// Settings repository
  late final ISettingsRepository settings;

  /// gRPC Authentication factory
  late final GrpcAuthenticationClient Function([Iterable<ClientInterceptor>? middlewares]) grpsAuthFactory;

  /// gRPC Authentication client
  late final GrpcAuthenticationClient authClient;

  /// Authentication handler
  late final IAuthenticationHandler authenticationHandler;

  /// Authentication repository
  late final IAuthenticationRepository authenticationRepository;

  /// CredentialsManager
  late final CredentialsCallbacks credentialsManager;

  /// Users repository
  late final IUsersRepository usersRepository;

  /// Users controller
  late final UsersController usersController;

  /// AvatarCache
  late final AvatarCache avatarCache;

  /// Database
  late final Database database;

  /// API Client
  // late final ApiClient apiClient;

  /// Message controller
  late final AppMessageController messageController;

  /// UpdateCheck controller
  late final UpdateCheckController updateCheckController;

  /// Authentication controller
  late final AuthenticationController authenticationController;

  /// AuthenticatedUser controller
  late final AuthenticatedUserController authenticatedUserController;

  /// Impersonate controller
  late final ImpersonateController impersonateController;
}
