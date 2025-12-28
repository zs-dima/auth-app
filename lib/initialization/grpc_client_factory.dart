// // ignore_for_file: prefer-static-class

// import 'dart:async';

// import 'package:auth_model/auth_model.dart';
// import 'package:grpc/grpc.dart';
// import 'package:grpc_model/grpc_model.dart';

// /// Configuration for gRPC client middleware.
// class GrpcMiddlewareConfig {
//   const GrpcMiddlewareConfig({
//     this.timeout = const Duration(seconds: 30),
//     this.retries = 3,
//     this.logRequest = false,
//     this.logResponse = true,
//     this.logError = true,
//   });

//   final Duration timeout;
//   final int retries;
//   final bool logRequest;
//   final bool logResponse;
//   final bool logError;
// }

// /// Creates a list of standard gRPC middlewares for authenticated requests.
// ///
// /// This mirrors the HTTP middleware pattern used in the app.
// /// Middlewares are applied in order (first added = outermost in chain).
// List<GrpcMiddleware> createStandardMiddlewares({
//   required String environment,
//   required Map<String, String> metadata,
//   required Future<AccessCredentials?> Function() getToken,
//   required void Function() onAuthError,
//   GrpcMiddlewareConfig config = const GrpcMiddlewareConfig(),
//   CaptureExceptionCallback? captureException,
// }) => <GrpcMiddleware>[
//   // 1. Metadata - adds app info headers
//   GrpcMetadataMiddleware(metadata: {...metadata, 'x-environment': environment}),

//   // 2. Retry - handles transient failures with exponential backoff
//   GrpcRetryMiddleware(retries: config.retries, retryEvaluator: _retryEvaluator),

//   // 3. Logger - logs requests/responses
//   GrpcLoggerMiddleware(
//     logRequest: config.logRequest,
//     logResponse: config.logResponse,
//     logError: config.logError,
//   ),

//   // 4. Error tracking (optional)
//   if (captureException != null) GrpcErrorTrackingMiddleware(captureException: captureException),

//   // 6. Authentication - adds auth headers (innermost)
//   GrpcAuthenticationMiddleware(
//     getToken: () async {
//       try {
//         return await dependencies.credentialsManager.getAccessCredentials();
//       } on Object catch (e, _) {
//         logger.w('Error getting token: $e');
//         return null;
//       }
//     },
//     logOut: () {
//       logger.w('Received "Not authenticated" HTTP response, logging out... ');
//       dependencies.authenticationController.signOut();
//     },
//   ),
// ];

// /// Creates a list of middlewares for unauthenticated requests.
// List<GrpcMiddleware> createUnauthenticatedMiddlewares({
//   required String environment,
//   required Map<String, String> metadata,
//   GrpcMiddlewareConfig config = const GrpcMiddlewareConfig(),
//   CaptureExceptionCallback? captureException,
// }) => <GrpcMiddleware>[
//   GrpcMetadataMiddleware(metadata: {...metadata, 'x-environment': environment}),
//   GrpcRetryMiddleware(retries: config.retries),
//   GrpcLoggerMiddleware(
//     logRequest: config.logRequest,
//     logResponse: config.logResponse,
//     logError: config.logError,
//   ),
//   if (captureException != null) GrpcErrorTrackingMiddleware(captureException: captureException),
// ];

// /// Standard retry evaluator for gRPC requests.
// bool _retryEvaluator(Object error, int attempt) {
//   // Don't retry authentication errors
//   if (error is GrpcError && error.code == StatusCode.unauthenticated) return false;
//   if (error is GrpcError && error.code == StatusCode.permissionDenied) return false;

//   // Retry on timeout
//   if (error is TimeoutException || (error is GrpcError && error.code == StatusCode.deadlineExceeded)) return true;

//   return error is! GrpcError ||
//       const {
//         StatusCode.unavailable,
//         StatusCode.resourceExhausted,
//         StatusCode.aborted,
//         StatusCode.internal,
//         StatusCode.deadlineExceeded,
//       }.contains(error.code);
// }
