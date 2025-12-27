// import 'dart:async';

// import 'package:auth_model/src/client/credentials_callbacks.dart';
// import 'package:auth_model/src/model/credentials/access_token.dart';
// import 'package:grpc/grpc.dart' as $grpc;

// const _kTokenExpirationThreshold = Duration(seconds: 30);

// extension StringExtension on AccessToken? {
//   bool get expiresSoon => this?.expiry.subtract(_kTokenExpirationThreshold).isBefore(DateTime.now().toUtc()) ?? false;
// }

// /// {@template grpc_authenticator}
// /// A Grpc Authenticator for automatic token refresh.
// /// Requires a concrete implementation of [AccessCredentialsCallback] and [RefreshTokensCallback].
// /// Handles transparently refreshing/caching tokens.
// /// {@endtemplate}
// class GrpcAuthenticator {
//   /// {@macro grpc_authenticator}
//   GrpcAuthenticator({
//     required CredentialsCallbacks credentialsManager,
//   }) : _credentialsManager = credentialsManager;

//   final CredentialsCallbacks _credentialsManager;
//   AccessToken? _accessToken;

//   $grpc.CallOptions get toCallOptions => $grpc.CallOptions(providers: [authenticate]);

//   Future<void> authenticate(Map<String, String> metadata, String _) async {
//     if (_accessToken == null || _accessToken.expiresSoon) {
//       try {
//         final credentials = await _credentialsManager.getAccessCredentials();
//         if (credentials == null) return;

//         final accessToken = credentials.accessToken;
//         if (accessToken.expiresSoon) {
//           final refresh = await _credentialsManager.getRefreshTokens(credentials.refreshToken);
//           _accessToken = refresh?.accessToken;
//         } else {
//           _accessToken = accessToken;
//         }

//         // ignore: avoid_catches_without_on_clauses
//       } catch (error, s) {
//         _credentialsManager.authHandler?.handleAuthenticationError();
//         Error.throwWithStackTrace(error, s);
//       }
//     }

//     final accessToken = _accessToken;
//     if (accessToken == null) {
//       _credentialsManager.authHandler?.handleAuthenticationError();
//       throw const $grpc.GrpcError.unauthenticated('Require Authentication.');
//     }

//     _credentialsManager.authHandler?.handleAuthenticated();

//     metadata['authorization'] = '${accessToken.type} ${accessToken.token}';
//   }
// }
