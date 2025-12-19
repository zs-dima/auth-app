import 'package:auth_model/auth_model.dart';
import 'package:auth_model/src/api/proto/auth.pb.dart' as auth;
import 'package:auth_model/src/api/proto/auth.pbgrpc.dart' as rpc;
import 'package:auth_model/src/api/proto/core.pb.dart' as core;
import 'package:grpc/grpc.dart';
import 'package:grpc/service_api.dart' as service_api;
import 'package:protobuf/well_known_types/google/protobuf/empty.pb.dart' as pb;

/// gRPC client for authentication service.
///
/// Creates two internal clients:
/// - Authenticated client for protected endpoints
/// - Unauthenticated client for signIn, refreshTokens, etc.
class AuthApiClient {
  final rpc.AuthServiceClient _authenticatedClient;
  final rpc.AuthServiceClient _unauthenticatedClient;

  const AuthApiClient._(this._authenticatedClient, this._unauthenticatedClient);

  factory AuthApiClient(
    service_api.ClientChannel channel, {
    required CredentialsCallbacks credentialsManager,
    Duration timeout = const Duration(seconds: 30),
  }) {
    final authenticator = GrpcAuthenticator(credentialsManager: credentialsManager);

    final authenticatedClient = rpc.AuthServiceClient(
      channel,
      options: CallOptions(timeout: timeout, providers: [authenticator.authenticate]),
    );

    final unauthenticatedClient = rpc.AuthServiceClient(channel, options: CallOptions(timeout: timeout));

    return AuthApiClient._(authenticatedClient, unauthenticatedClient);
  }

  // Unauthenticated endpoints
  ResponseFuture<auth.AuthInfo> signIn(auth.SignInRequest request) => _unauthenticatedClient.signIn(request);

  ResponseFuture<auth.RefreshTokenReply> refreshTokens(auth.RefreshTokenRequest request) =>
      _unauthenticatedClient.refreshTokens(request);

  ResponseFuture<core.ResultReply> resetPassword(auth.ResetPasswordRequest request) =>
      _unauthenticatedClient.resetPassword(request);

  // Authenticated endpoints
  ResponseFuture<core.ResultReply> signOut(pb.Empty request) => _authenticatedClient.signOut(request);

  ResponseFuture<core.ResultReply> validateCredentials(pb.Empty request) =>
      _authenticatedClient.validateCredentials(request);

  ResponseFuture<core.ResultReply> setPassword(auth.SetPasswordRequest request) =>
      _authenticatedClient.setPassword(request);

  ResponseStream<auth.UserInfo> loadUsersInfo(pb.Empty request) => _authenticatedClient.loadUsersInfo(request);

  ResponseStream<auth.UserAvatar> loadUserAvatar(auth.LoadUserAvatarRequest request) =>
      _authenticatedClient.loadUserAvatar(request);

  ResponseStream<auth.User> loadUsers(auth.UserId request) => _authenticatedClient.loadUsers(request);

  ResponseFuture<core.ResultReply> createUser(auth.CreateUserRequest request) =>
      _authenticatedClient.createUser(request);

  ResponseFuture<core.ResultReply> updateUser(auth.UpdateUserRequest request) =>
      _authenticatedClient.updateUser(request);

  ResponseFuture<core.ResultReply> saveUserPhoto(auth.UserPhoto request) => _authenticatedClient.saveUserPhoto(request);
}
