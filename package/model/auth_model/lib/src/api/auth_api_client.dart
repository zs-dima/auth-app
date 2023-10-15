import 'package:auth_model/auth_model.dart';
import 'package:auth_model/src/api/proto/auth.pbgrpc.dart' as rpc;
import 'package:grpc/grpc.dart';
import 'package:grpc_model/grpc_model.dart' hide Duration;

class AuthApiClient extends rpc.AuthServiceClient {
  static AuthApiClient? _instance;

  AuthApiClient._(
    super.channel, {
    required CredentialsCallbacks credentialsManager,
  }) : super(
          options: CallOptions(
            timeout: const Duration(seconds: 30),
            providers: [
              GrpcAuthenticator(
                credentialsManager: credentialsManager,
              ).authenticate,
            ],
          ),
        );

  static AuthApiClient instance({
    required GrpcClientChannel channel,
    required CredentialsCallbacks credentialsManager,
  }) =>
      _instance ??= AuthApiClient._(
        channel,
        credentialsManager: credentialsManager,
      );
}
