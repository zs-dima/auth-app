// ignore_for_file: avoid-dynamic

import 'package:auth_model/src/model/credentials/access_token.dart';
import 'package:auth_model/src/model/credentials/refresh_token.dart';
import 'package:meta/meta.dart';

/// OAuth2 Credentials.
/// Inspired by https://pub.dev/packages/googleapis_auth
@immutable
class AccessCredentials {
  const AccessCredentials({required this.accessToken, required this.refreshToken, this.scopes = const <String>[]});

  /// Decodes a persisted blob. Tolerant of older/partial schemas — a missing `scopes` list is
  /// treated as empty rather than throwing — so a returning user with a pre-existing blob is not
  /// hard-failed at startup (the repository additionally clears an undecodable blob).
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

  /// Serializes to a plain JSON map. `accessToken` is emitted as a nested map (via
  /// [AccessToken.toJson]) — not the object — so callers can inspect/merge the map before encoding.
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

  @override
  String toString() => 'AccessCredentials(accessToken=$accessToken, refreshToken=$refreshToken, scopes=$scopes)';
}

bool _scopesEqual(List<String> a, List<String> b) {
  if (identical(a, b)) return true;
  if (a.length != b.length) return false;
  for (final (index, value) in a.indexed) {
    if (value != b[index]) return false;
  }
  return true;
}
