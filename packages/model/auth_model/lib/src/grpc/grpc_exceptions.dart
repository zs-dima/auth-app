import 'package:grpc/grpc.dart';
import 'package:meta/meta.dart';

/// Domain-level transport error for the gRPC API.
///
/// Wraps `package:grpc`'s [GrpcError]/[StatusCode] so callers of `IAuthenticationApi` /
/// `IUsersApi` can classify failures (network vs auth vs server vs bad-request vs cancelled)
/// WITHOUT importing `package:grpc`. Parallel to — but NOT interchangeable with — `http_client`'s
/// `ApiClientException`: both share the `Cancelled`/`Network`/`Authentication` backbone, but this
/// family adds `Request`/`Server` while HTTP adds `Client`/`Timeout`, and [code] here is the raw
/// gRPC status as an `int` whereas HTTP's is a semantic `String`. The shared idea is
/// transport-agnostic classification, not one identical vocabulary (A8). [code] is never the grpc
/// enum, keeping the public surface transport-agnostic.
@immutable
sealed class GrpcException implements Exception {
  const GrpcException(this.message, {this.code, this.cause});

  /// Maps any error to the domain family. A [GrpcException] passes through unchanged; a
  /// [GrpcError] is classified by its [StatusCode]; anything else becomes a [GrpcException$Server].
  factory GrpcException.from(Object error) {
    if (error is GrpcException) return error;
    if (error is GrpcError) {
      final message = error.message ?? 'gRPC error (${error.code})';
      return switch (error.code) {
        StatusCode.cancelled => GrpcException$Cancelled(message, code: error.code, cause: error),
        StatusCode.unauthenticated || StatusCode.permissionDenied => GrpcException$Authentication(
          message,
          code: error.code,
          cause: error,
        ),
        StatusCode.unavailable || StatusCode.deadlineExceeded => GrpcException$Network(
          message,
          code: error.code,
          cause: error,
        ),
        StatusCode.invalidArgument ||
        StatusCode.failedPrecondition ||
        StatusCode.notFound ||
        StatusCode.alreadyExists ||
        StatusCode.outOfRange => GrpcException$Request(message, code: error.code, cause: error),
        _ => GrpcException$Server(message, code: error.code, cause: error),
      };
    }
    return GrpcException$Server(error.toString(), cause: error);
  }

  /// Human-readable message (server-provided when available).
  final String message;

  /// Raw gRPC status code value (see `StatusCode`), or `null` for a non-gRPC cause.
  final int? code;

  /// The original error (e.g. `GrpcError`) for diagnostics/logging.
  final Object? cause;

  @override
  String toString() => 'GrpcException(code: $code, message: $message)';
}

/// The call was cancelled (caller navigated away / session ended). Usually not user-facing.
final class GrpcException$Cancelled extends GrpcException {
  const GrpcException$Cancelled(super.message, {super.code, super.cause});
}

/// Transport could not reach the server in time (unavailable / deadline exceeded). Retryable.
final class GrpcException$Network extends GrpcException {
  const GrpcException$Network(super.message, {super.code, super.cause});
}

/// Authentication/authorization failure (unauthenticated / permission denied).
final class GrpcException$Authentication extends GrpcException {
  const GrpcException$Authentication(super.message, {super.code, super.cause});
}

/// The request was rejected as invalid (bad argument / failed precondition / not found / …).
final class GrpcException$Request extends GrpcException {
  const GrpcException$Request(super.message, {super.code, super.cause});
}

/// Server-side or otherwise unclassified failure (internal / unknown / data loss / …).
final class GrpcException$Server extends GrpcException {
  const GrpcException$Server(super.message, {super.code, super.cause});
}
