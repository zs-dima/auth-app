import 'package:auth_model/src/grpc/grpc_exceptions.dart';
import 'package:grpc/grpc.dart';

/// Runs a unary RPC, mapping any [GrpcError] to the domain [GrpcException] family so the API
/// clients never leak `package:grpc` through `IAuthenticationApi` / `IUsersApi` (A8). Single
/// source for the translation idiom shared by both clients (A23). Not exported from the barrel —
/// an internal helper.
Future<T> guardGrpcCall<T>(Future<T> Function() rpc) async {
  try {
    return await rpc();
  } on GrpcError catch (e, st) {
    Error.throwWithStackTrace(GrpcException.from(e), st);
  }
}

/// Server-streaming variant: maps a [GrpcError] surfacing mid-stream to the domain family.
Stream<T> guardGrpcStream<T>(Stream<T> Function() rpc) async* {
  try {
    yield* rpc();
  } on GrpcError catch (e, st) {
    Error.throwWithStackTrace(GrpcException.from(e), st);
  }
}
