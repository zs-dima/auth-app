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
import 'package:auth_app/users/controller/avatar_controller.dart';
import 'package:auth_app/users/controller/users_controller.dart';
import 'package:auth_app/users/data/users_repository.dart';
import 'package:auth_model/auth_model.dart';
import 'package:connect_model/connect_model.dart';
import 'package:connectrpc/connect.dart';
import 'package:flutter/widgets.dart';
import 'package:http_client/http_client.dart';

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

  /// Interceptors factory
  late final List<Interceptor> Function([Iterable<Interceptor>? middlewares]) interceptorsFactory;

  /// Connect Authentication client factory
  late final ConnectAuthenticationClient Function([Iterable<Interceptor>? middlewares]) connectAuthFactory;

  /// Connect Users client factory
  late final ConnectUsersClient Function([Iterable<Interceptor>? middlewares]) connectUsersFactory;

  /// Shared Connect HTTP client behind every transport (one per-origin HTTP/2 pool, pinned TLS on
  /// native). The container owns it so transport connections can be released on teardown (A6).
  late final RpcHttpClientHandle rpcHttpClient;

  /// Connect Authentication client. The container owns the concrete client; consumers
  /// (repositories) receive the narrowed `IAuthenticationApi` interface, so dependency inversion
  /// still holds at the boundary (A21). Connection teardown is owned by [rpcHttpClient] (A6).
  late final ConnectAuthenticationClient authClient;

  /// Connect Users client (owned concretely; consumers receive `IUsersApi`).
  late final ConnectUsersClient usersClient;

  /// Authentication handler
  late final IAuthenticationHandler authenticationHandler;

  /// Authentication repository
  late final IAuthenticationRepository authenticationRepository;

  /// Users repository
  late final IUsersRepository usersRepository;

  /// Users controller
  late final UsersController usersController;

  /// AvatarCache
  late final AvatarController avatarController;

  /// Database
  late final Database database;

  /// HTTP client for external / unauthenticated requests (e.g. S3 presigned uploads,
  /// static manifests). Carries retry / timeout / Sentry / session-cancellation, but NOT
  /// the auth or app-metadata middleware — those are first-party concerns and must not ride
  /// along on third-party requests (a presigned URL is self-authenticated).
  late final ApiClient externalHttpClient;

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
