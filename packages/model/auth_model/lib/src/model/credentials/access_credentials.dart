// ignore_for_file: avoid-dynamic

import 'package:auth_model/src/model/credentials/access_token.dart';
import 'package:auth_model/src/model/credentials/refresh_token.dart';
import 'package:meta/meta.dart';

/// OAuth2 Credentials.
/// Inspired by https://pub.dev/packages/googleapis_auth
@immutable
class AccessCredentials {
  const AccessCredentials({required this.accessToken, required this.refreshToken, this.scopes = const <String>[]});

  /// Decodes a persisted blob; tolerant of older schemas (missing `scopes` → empty) so a
  /// returning user is never hard-failed at startup.
  factory AccessCredentials.fromJson(Map<String, dynamic> json) => AccessCredentials(
    accessToken: AccessToken.fromJson((json['accessToken'] as Map).cast<String, dynamic>()),
    refreshToken: RefreshToken(json['refreshToken'] as String),
    scopes: (json['scopes'] as List<dynamic>?)?.map((e) => e as String).toList() ?? const <String>[],
  );

  /// An access token.
  final AccessToken accessToken;

  /// A refresh token, which can be used to refresh the access credentials.
  final RefreshToken refreshToken;

  /// Scopes these credentials are valid for.
  final List<String> scopes;

  @override
  int get hashCode => Object.hash(accessToken, refreshToken, Object.hashAll(scopes));

  /// Serializes to a plain JSON map (`accessToken` as a nested map).
  Map<String, dynamic> toJson() => <String, dynamic>{
    'accessToken': accessToken.toJson(),
    'refreshToken': refreshToken.value,
    'scopes': scopes,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AccessCredentials &&
          other.accessToken == accessToken &&
          other.refreshToken == refreshToken &&
          _scopesEqual(other.scopes, scopes);

  // Redacts both secrets: the refresh token is masked HERE because an extension type can't
  // override toString — `'$refreshToken'` would print the raw value (refresh_token.md §13).
  @override
  String toString() => 'AccessCredentials(accessToken=$accessToken, refreshToken=***, scopes=$scopes)';
}

bool _scopesEqual(List<String> a, List<String> b) {
  if (identical(a, b)) return true;
  if (a.length != b.length) return false;
  for (final (index, value) in a.indexed) {
    if (value != b[index]) return false;
  }
  return true;
}
