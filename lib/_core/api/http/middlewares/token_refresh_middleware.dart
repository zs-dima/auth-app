// import 'package:auth_model/auth_model.dart';
// import 'package:meta/meta.dart';
// import 'package:auth_app/_core/util/http/api_client.dart';
// import 'package:auth_app/_core/util/http/mutex.dart';

// const _kTokenExpirationThreshold = Duration(seconds: 30);

// extension StringExtension on AccessToken? {
//   bool get expiresSoon => this?.expiry.subtract(_kTokenExpirationThreshold).isBefore(DateTime.now().toUtc()) ?? false;
// }

// /// {@template token_refresh_middleware}
// /// Middleware for automatically refreshing expired tokens and retrying requests.
// /// {@endtemplate}
// @immutable
// class TokenRefreshMiddleware {
//   /// Prevents concurrent refresh attempts
//   static final Mutex _refreshingMutex = Mutex();

//   /// {@macro token_refresh_middleware}
//   const TokenRefreshMiddleware({required CredentialsCallbacks credentialsManager})
//     : _credentialsManager = credentialsManager;

//   /// Credentials manager for handling authentication tokens
//   final CredentialsCallbacks _credentialsManager;

//   ApiClientHandler call(ApiClientHandler innerHandler) =>
//       (request, context) async => _refreshingMutex.synchronize(() async {
//         try {
//           final credentials = await _credentialsManager.getAccessCredentials();
//           final accessToken = credentials?.accessToken;

//           if (credentials == null || accessToken == null) {
//             _credentialsManager.authHandler?.handleAuthenticationError();
//             throw const ApiClientException$Authentication(
//               error: 'Session expired please login',
//               code: 'no_auth_credentials',
//               statusCode: 401,
//               message: 'Session expired please login',
//             );
//           }

//           final refreshToken = context[kRefreshToken] == true;
//           if (!refreshToken && accessToken.expiresSoon) {
//             final refresh = await _credentialsManager.getRefreshTokens(credentials.refreshToken);
//             accessToken = refresh?.accessToken;
//             if (accessToken == null) {
//               final error = DioException(
//                 error: 'Session expired please login',
//                 requestOptions: options,
//                 response: Response(
//                   statusMessage: 'Session expired please login',
//                   statusCode: 401,
//                   requestOptions: options,
//                 ),
//               );

//               handler.reject(error);
//               _credentialsManager.authHandler?.handleAuthenticationError();
//               return;
//             }
//           }

//           return await innerHandler(request, context);
//         } on ApiClientException catch (e) {
//           // Only handle 401 Unauthorized errors
//           if (e.statusCode != 401) rethrow;

//           try {
//             final credentials = await _credentialsManager.getAccessCredentials();
//             if (credentials?.refreshToken == null) {
//               _credentialsManager.authHandler?.handleAuthenticationError();
//               rethrow;
//             }

//             // Attempt to refresh tokens
//             final newCredentials = await _credentialsManager.getRefreshTokens(credentials!.refreshToken);
//             if (newCredentials?.accessToken == null) {
//               _credentialsManager.authHandler?.handleAuthenticationError();
//               rethrow;
//             }

//             // Update request headers with new tokens
//             request.headers['Authorization'] = 'Bearer ${newCredentials!.accessToken.token}';
//             request.headers['X-CSRF-Token'] = newCredentials.refreshToken;

//             // Retry the request
//             return await innerHandler(request, context);
//           } catch (e) {
//             _credentialsManager.authHandler?.handleAuthenticationError();
//             rethrow;
//           }
//         }
//       });
// }
