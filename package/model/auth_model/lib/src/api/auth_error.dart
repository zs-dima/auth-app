import 'package:grpc/grpc.dart';

/// Base class for authentication errors.
sealed class AuthError implements Exception {
  final String message;
  final GrpcError? grpcError;

  const AuthError(this.message, [this.grpcError]);

  factory AuthError.fromGrpc(GrpcError error, String operation) => switch (error.code) {
    StatusCode.unauthenticated => UnauthenticatedError(error.message ?? 'Authentication required'),
    StatusCode.permissionDenied => PermissionDeniedError(operation),
    StatusCode.unavailable => ServiceUnavailableError(error),
    StatusCode.deadlineExceeded => TimeoutError(operation, error),
    StatusCode.cancelled => CancelledError(operation),
    _ => UnknownAuthError('$operation failed', error),
  };

  @override
  String toString() => 'AuthError: $message';
}

final class UnauthenticatedError extends AuthError {
  const UnauthenticatedError(super.message);
}

final class PermissionDeniedError extends AuthError {
  PermissionDeniedError(String operation) : super('$operation: Permission denied');
}

final class ServiceUnavailableError extends AuthError {
  ServiceUnavailableError(GrpcError? error) : super('Service unavailable. Please try again later.', error);
}

final class TimeoutError extends AuthError {
  TimeoutError(String operation, GrpcError? error) : super('$operation timed out', error);
}

final class CancelledError extends AuthError {
  CancelledError(String operation) : super('$operation was cancelled');
}

final class UnknownAuthError extends AuthError {
  const UnknownAuthError(super.message, super.grpcError);
}
