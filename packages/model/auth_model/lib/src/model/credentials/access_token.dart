import 'dart:convert';

import 'package:intl/intl.dart';
import 'package:meta/meta.dart';

/// An OAuth2 access token.
/// Inspired by https://pub.dev/packages/googleapis_auth
@immutable
class AccessToken {
  /// [expiry] must be a UTC `DateTime`.
  AccessToken({this.type = 'Bearer', required this.token, required this.expiry})
    : assert(type.isNotEmpty, 'The token type must not be empty'),
      assert(token.isNotEmpty, 'The token must not be empty'),
      assert(expiry.isUtc, 'The expiry date must be a Utc DateTime') {
    if (!expiry.isUtc) {
      throw ArgumentError.value(expiry, 'expiry', 'The expiry date must be a Utc DateTime');
    }
  }

  /// Parses a signed JWT and reads its `exp` claim. Throws a typed [FormatException] on any
  /// structural problem — callers map it to a failed sign-in or a definitive rejection (A12).
  factory AccessToken.fromJwtToken(String token) {
    final tokenMap = _decodeJwtToken(token);

    final expiry = tokenMap['exp'];
    if (expiry is! int) throw const FormatException('Malformed JWT: missing or non-integer "exp" claim');

    return AccessToken(token: token, expiry: DateTime.fromMillisecondsSinceEpoch(expiry * 1000, isUtc: true));
  }

  factory AccessToken.fromJson(Map<String, dynamic> json) => AccessToken(
    type: json['type'] as String,
    token: json['data'] as String,
    expiry: DateTime.parse(json['expiry'] as String),
  );

  /// The token type, usually "Bearer"
  final String type;

  /// The access token data.
  final String token;

  /// Time at which the token will be expired (UTC time)
  final DateTime expiry;

  /// True when the token expires within 30 seconds — the proactive-refresh window covering
  /// request latency and small clock skew (refresh_token.md §4.1).
  bool get expiresSoon => DateTime.now().toUtc().isAfter(expiry.subtract(const Duration(seconds: 30)));

  bool get hasExpired => DateTime.now().toUtc().isAfter(expiry);

  /// `'<scheme> <token>'` — the single transport-neutral Authorization value used by both the
  /// Connect and HTTP auth middlewares.
  String get authorizationHeaderValue => '$type $token';

  @override
  int get hashCode => Object.hash(type, token, expiry);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AccessToken && other.type == type && other.token == token && other.expiry == expiry;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'type': type,
    'data': token,
    'expiry': expiry.toIso8601String(),
  };

  // Redact-at-source: `toString` is reachable from logs/state-observer/Sentry span data; header
  // and query redaction does NOT cover object serialization (refresh_token.md §13).
  @override
  String toString() => 'AccessToken(type=$type, data=***, expiry=${DateFormat().format(expiry)})';

  // Decode-only by design: a public client can't verify the signature — only `exp` matters.
  static Map<String, Object?> _decodeJwtToken(String token) {
    final parts = token.split('.');
    if (parts.length != 3) {
      throw const FormatException('Malformed JWT: expected 3 dot-separated segments');
    }

    // All decode steps throw FormatException — the same typed error the callers handle.
    final normalized = base64Url.normalize(parts[1]);
    final decoded = jsonDecode(utf8.decode(base64Url.decode(normalized)));
    if (decoded is! Map<String, Object?>) {
      throw const FormatException('Malformed JWT: payload is not a JSON object');
    }
    return decoded;
  }
}
