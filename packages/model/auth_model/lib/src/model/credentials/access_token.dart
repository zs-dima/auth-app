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

  /// Parses a signed JWT and reads its `exp` claim.
  ///
  /// Throws a [FormatException] (a typed, recognized error — never a bare `Exception`) when the
  /// token is not a well-formed JWT or lacks an integer `exp`. Callers map this deliberately: on
  /// the sign-in/success path to a failed result, on the refresh path to a definitive rejection —
  /// so a malformed token never slips through the auth-error policy as an opaque crash (A12).
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

  /// Returns true if the token expires within 30 seconds.
  ///
  /// The window must be large enough to refresh proactively before the token
  /// reaches the server expired, accounting for request latency and clock skew.
  bool get expiresSoon => DateTime.now().toUtc().isAfter(expiry.subtract(const Duration(seconds: 30)));

  bool get hasExpired => DateTime.now().toUtc().isAfter(expiry);

  /// `'<scheme> <token>'` — the single transport-neutral Authorization value, used both as the gRPC
  /// `authorization` metadata value and the HTTP `Authorization` header value. The scheme is [type]
  /// (usually `Bearer`); the gRPC and REST auth middlewares both build their header from this getter.
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

  @override
  String toString() => 'AccessToken(type=$type, data=$token, expiry=${DateFormat().format(expiry)})';

  // Decode-only by design: a public OAuth client holds no server HMAC secret, so client-side
  // signature verification would be meaningless (hence no JwtValidator here — only `exp` matters).
  static Map<String, Object?> _decodeJwtToken(String token) {
    final parts = token.split('.');
    if (parts.length != 3) {
      throw const FormatException('Malformed JWT: expected 3 dot-separated segments');
    }

    // base64Url.decode / utf8.decode / jsonDecode all throw FormatException on bad input, which
    // propagates as the same typed error the callers handle.
    final normalized = base64Url.normalize(parts[1]);
    final decoded = jsonDecode(utf8.decode(base64Url.decode(normalized)));
    if (decoded is! Map<String, Object?>) {
      throw const FormatException('Malformed JWT: payload is not a JSON object');
    }
    return decoded;
  }
}
