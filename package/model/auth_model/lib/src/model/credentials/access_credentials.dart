import 'access_token.dart';
import 'refresh_token.dart';

/// OAuth2 Credentials.
/// Inspired by https://pub.dev/packages/googleapis_auth
class AccessCredentials {
  /// An access token.
  final AccessToken accessToken;

  /// A refresh token, which can be used to refresh the access credentials.
  final RefreshToken refreshToken;

  /// Scopes these credentials are valid for.
  final List<String> scopes;

  AccessCredentials({
    required this.accessToken,
    required this.refreshToken,
    this.scopes = const <String>[],
  });

  factory AccessCredentials.fromJson(Map<String, dynamic> json) => AccessCredentials(
        accessToken: AccessToken.fromJson(json['accessToken'] as Map<String, dynamic>),
        refreshToken: json['refreshToken'] as RefreshToken,
        scopes: (json['scopes'] as List<dynamic>).map((e) => e as String).toList(),
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        'accessToken': accessToken,
        'refreshToken': refreshToken,
        'scopes': scopes,
      };
}
