import 'package:auth_model/auth_model.dart';
import 'package:auth_model/src/api/proto/auth.pb.dart' as auth;
import 'package:auth_model/src/api/proto/auth.pbgrpc.dart' as rpc;
import 'package:auth_model/src/api/proto/core.pb.dart' as core;
import 'package:grpc/grpc.dart';
import 'package:grpc/service_api.dart' as service_api;
import 'package:grpc_model/grpc_model.dart';
import 'package:protobuf/well_known_types/google/protobuf/empty.pb.dart' as pb;

/// gRPC client for authentication service.
///
/// Supports two patterns:
/// - Traditional [CredentialsCallbacks] via default constructor
/// - Middleware pattern via [withMiddlewares] constructor
class GrpcAuthenticationClient {
  /// Creates a client using the traditional [CredentialsCallbacks] pattern.
  factory GrpcAuthenticationClient(
    service_api.ClientChannel channel, {
    required CredentialsCallbacks credentialsManager,
    Duration timeout = const Duration(seconds: 30),
  }) {
    final authenticator = GrpcAuthenticator(credentialsManager: credentialsManager);
    return GrpcAuthenticationClient._(
      rpc.AuthServiceClient(
        channel,
        options: CallOptions(timeout: timeout, providers: [authenticator.authenticate]),
      ),
      rpc.AuthServiceClient(channel, options: CallOptions(timeout: timeout)),
    );
  }

  /// Creates a client using the middleware pattern.
  ///
  /// Middlewares that implement [GrpcMiddlewareBase.metadataProvider] will have
  /// their metadata applied to all authenticated requests.
  factory GrpcAuthenticationClient.withMiddlewares(
    service_api.ClientChannel channel, {
    required List<GrpcMiddlewareBase> middlewares,
    Duration timeout = const Duration(seconds: 30),
  }) {
    // Extract metadata providers from middlewares
    final providers = <MetadataProvider>[
      for (final mw in middlewares)
        if (mw.metadataProvider case final provider?) provider,
    ];

    return GrpcAuthenticationClient._(
      rpc.AuthServiceClient(
        channel,
        options: CallOptions(timeout: timeout, providers: providers),
      ),
      rpc.AuthServiceClient(channel, options: CallOptions(timeout: timeout)),
    );
  }

  const GrpcAuthenticationClient._(this._authenticated, this._unauthenticated);

  final rpc.AuthServiceClient _authenticated;
  final rpc.AuthServiceClient _unauthenticated;

  // Unauthenticated endpoints
  ResponseFuture<auth.AuthInfo> signIn(auth.SignInRequest request) => _unauthenticated.signIn(request);
  ResponseFuture<auth.RefreshTokenReply> refreshTokens(auth.RefreshTokenRequest request) =>
      _unauthenticated.refreshTokens(request);
  ResponseFuture<core.ResultReply> resetPassword(auth.ResetPasswordRequest request) =>
      _unauthenticated.resetPassword(request);

  // Authenticated endpoints
  ResponseFuture<core.ResultReply> signOut(pb.Empty request) => _authenticated.signOut(request);
  ResponseFuture<core.ResultReply> validateCredentials(pb.Empty request) => _authenticated.validateCredentials(request);
  ResponseFuture<core.ResultReply> setPassword(auth.SetPasswordRequest request) => _authenticated.setPassword(request);
  ResponseStream<auth.UserInfo> loadUsersInfo(pb.Empty request) => _authenticated.loadUsersInfo(request);
  ResponseStream<auth.UserAvatar> loadUserAvatar(auth.LoadUserAvatarRequest request) =>
      _authenticated.loadUserAvatar(request);
  ResponseStream<auth.User> loadUsers(auth.UserId request) => _authenticated.loadUsers(request);
  ResponseFuture<core.ResultReply> createUser(auth.CreateUserRequest request) => _authenticated.createUser(request);
  ResponseFuture<core.ResultReply> updateUser(auth.UpdateUserRequest request) => _authenticated.updateUser(request);
  ResponseFuture<core.ResultReply> saveUserPhoto(auth.UserPhoto request) => _authenticated.saveUserPhoto(request);
}
