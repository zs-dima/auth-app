import 'package:connectrpc/connect.dart';
import 'package:meta/meta.dart';

/// Domain-level transport error for the RPC API.
///
/// Wraps `package:connectrpc`'s [ConnectException]/[Code] so callers of `IAuthenticationApi` /
/// `IUsersApi` can classify failures (network vs auth vs server vs bad-request vs cancelled)
/// WITHOUT importing `package:connectrpc`. Parallel to — but NOT interchangeable with —
/// `http_client`'s `ApiClientException`: both share the `Cancelled`/`Network`/`Authentication`/
/// `Request`/`Server` backbone, while HTTP additionally has `Internal`/`Timeout`, and [code] here
/// is the raw RPC status as an `int` whereas HTTP's is a semantic `String`. The shared idea is
/// transport-agnostic classification, not one identical vocabulary (A8). [code] is never the
/// connect-dart enum, keeping the public surface transport-agnostic (the 16 status codes are the
/// gRPC/Connect shared vocabulary, so the ints survived the gRPC → Connect migration unchanged).
@immutable
sealed class RpcException implements Exception {
  const RpcException(this.message, {this.code, this.cause});

  /// Maps any error to the domain family. An [RpcException] passes through unchanged; a
  /// [ConnectException] is classified by its [Code]; anything else becomes an [RpcException$Server].
  factory RpcException.from(Object error) {
    if (error is RpcException) return error;
    if (error is ConnectException) {
      final message = error.message.isNotEmpty ? error.message : 'RPC error (${error.code.name})';
      return switch (error.code) {
        Code.canceled => RpcException$Cancelled(message, code: error.code.value, cause: error),
        Code.unauthenticated || Code.permissionDenied => RpcException$Authentication(
          message,
          code: error.code.value,
          cause: error,
        ),
        Code.unavailable || Code.deadlineExceeded => RpcException$Network(
          message,
          code: error.code.value,
          cause: error,
        ),
        Code.invalidArgument ||
        Code.failedPrecondition ||
        Code.notFound ||
        Code.alreadyExists ||
        Code.outOfRange => RpcException$Request(message, code: error.code.value, cause: error),
        _ => RpcException$Server(message, code: error.code.value, cause: error),
      };
    }
    return RpcException$Server(error.toString(), cause: error);
  }

  /// Human-readable message (server-provided when available).
  final String message;

  /// Raw RPC status code value (see connect-dart's `Code`), or `null` for a non-RPC cause.
  final int? code;

  /// The original error (e.g. `ConnectException`) for diagnostics/logging.
  final Object? cause;

  @override
  String toString() => 'RpcException(code: $code, message: $message)';
}

/// The call was cancelled (caller navigated away / session ended). Usually not user-facing.
final class RpcException$Cancelled extends RpcException {
  const RpcException$Cancelled(super.message, {super.code, super.cause});
}

/// Transport could not reach the server in time (unavailable / deadline exceeded). Retryable.
final class RpcException$Network extends RpcException {
  const RpcException$Network(super.message, {super.code, super.cause});
}

/// Authentication/authorization failure (unauthenticated / permission denied).
final class RpcException$Authentication extends RpcException {
  const RpcException$Authentication(super.message, {super.code, super.cause});
}

/// The request was rejected as invalid (bad argument / failed precondition / not found / …).
final class RpcException$Request extends RpcException {
  const RpcException$Request(super.message, {super.code, super.cause});
}

/// Server-side or otherwise unclassified failure (internal / unknown / data loss / …).
final class RpcException$Server extends RpcException {
  const RpcException$Server(super.message, {super.code, super.cause});
}
