import 'package:grpc/grpc.dart';
import 'package:grpc_model/src/middleware/grpc_middleware.dart';
import 'package:meta/meta.dart';

/// Callback for capturing exceptions to an error tracking service.
typedef CaptureExceptionCallback =
    Future<void> Function(
      Object exception,
      StackTrace stackTrace, {
      Map<String, dynamic>? extra,
    });

/// Callback for starting a transaction/span.
typedef StartTransactionCallback =
    Object Function(
      String name,
      String operation, {
      String? description,
      DateTime? startTimestamp,
    });

/// Callback for finishing a transaction/span.
typedef FinishTransactionCallback =
    void Function(
      Object transaction, {
      String? status,
      DateTime? endTimestamp,
    });

/// {@template grpc_error_tracking_middleware}
/// Middleware for integrating with error tracking services (e.g., Sentry).
///
/// Captures exceptions and creates performance transactions for gRPC calls.
/// {@endtemplate}
@immutable
class GrpcErrorTrackingMiddleware extends GrpcMiddlewareBase {
  /// {@macro grpc_error_tracking_middleware}
  const GrpcErrorTrackingMiddleware({
    required this.captureException,
    this.startTransaction,
    this.finishTransaction,
    this.setTransactionData,
  });

  /// Callback to capture exceptions.
  final CaptureExceptionCallback captureException;

  /// Callback to start a performance transaction.
  final StartTransactionCallback? startTransaction;

  /// Callback to finish a performance transaction.
  final FinishTransactionCallback? finishTransaction;

  /// Callback to set data on a transaction.
  final void Function(Object transaction, String key, Object? value)? setTransactionData;

  @override
  GrpcHandler<Q, R> call<Q, R>(GrpcHandler<Q, R> next) => (request, context) async {
    final methodPath = request.method.path;
    final operation = context['operation']?.toString() ?? '[gRPC] $methodPath';

    // Start transaction if available
    Object? transaction;
    if (startTransaction != null) {
      transaction = startTransaction!(
        'grpc.client',
        operation,
        description: operation,
        startTimestamp: DateTime.now().toUtc(),
      );

      setTransactionData?.call(transaction, 'grpc.method', methodPath);
      setTransactionData?.call(transaction, 'grpc.path', request.method.path);

      context['error_tracking.transaction'] = transaction;
    }

    try {
      final response = await next(request, context);

      // Finish transaction with success
      if (transaction != null && finishTransaction != null) {
        setTransactionData?.call(transaction, 'grpc.status', 'ok');
        finishTransaction!(
          transaction,
          status: 'ok',
          endTimestamp: DateTime.now().toUtc(),
        );
      }

      return response;
    } on Object catch (e, s) {
      // Capture exception
      await captureException(
        e,
        s,
        extra: {
          'grpc.method': methodPath,
          'grpc.path': request.method.path,
          'grpc.metadata': request.options.metadata,
        },
      );

      // Finish transaction with error
      if (transaction != null && finishTransaction != null) {
        final status = _getErrorStatus(e);
        setTransactionData?.call(transaction, 'grpc.status', status);
        finishTransaction!(
          transaction,
          status: status,
          endTimestamp: DateTime.now().toUtc(),
        );
      }

      rethrow;
    }
  };

  String _getErrorStatus(Object error) {
    if (error is GrpcError) {
      return switch (error.code) {
        StatusCode.unavailable => 'unavailable',
        StatusCode.unimplemented => 'unimplemented',
        StatusCode.internal => 'internal_error',
        StatusCode.resourceExhausted => 'resource_exhausted',
        StatusCode.aborted => 'aborted',
        StatusCode.notFound => 'not_found',
        StatusCode.permissionDenied => 'permission_denied',
        StatusCode.unauthenticated => 'unauthenticated',
        StatusCode.failedPrecondition => 'failed_precondition',
        StatusCode.deadlineExceeded => 'deadline_exceeded',
        StatusCode.cancelled => 'cancelled',
        _ => 'unknown_error',
      };
    }

    return error is GrpcClientException
        ? switch (error.statusCode) {
            StatusCode.unavailable => 'unavailable',
            StatusCode.unimplemented => 'unimplemented',
            StatusCode.internal => 'internal_error',
            StatusCode.resourceExhausted => 'resource_exhausted',
            StatusCode.aborted => 'aborted',
            StatusCode.notFound => 'not_found',
            StatusCode.permissionDenied => 'permission_denied',
            StatusCode.unauthenticated => 'unauthenticated',
            StatusCode.failedPrecondition => 'failed_precondition',
            StatusCode.deadlineExceeded => 'deadline_exceeded',
            StatusCode.cancelled => 'cancelled',
            _ => 'unknown_error',
          }
        : 'unknown_error';
  }
}
