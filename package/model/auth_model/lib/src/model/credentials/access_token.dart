import 'dart:convert';

/// An OAuth2 access token.
/// Inspired by https://pub.dev/packages/googleapis_auth
class AccessToken {
  /// The token type, usually "Bearer"
  final String type;

  /// The access token data.
  final String token;

  /// Time at which the token will be expired (UTC time)
  final DateTime expiry;

  /// [expiry] must be a UTC `DateTime`.
  AccessToken({
    this.type = 'Bearer',
    required this.token,
    required this.expiry,
  }) {
    if (!expiry.isUtc) {
      throw ArgumentError.value(expiry, 'expiry', 'The expiry date must be a Utc DateTime');
    }
  }

  factory AccessToken.fromJwtToken(String token) {
    final tokenMap = _decodeJwtToken(token);

    final expiry = tokenMap['exp'];
    if (expiry is! int) throw Exception('invalid token');

    return AccessToken(
      token: token,
      expiry: DateTime.fromMillisecondsSinceEpoch(expiry * 1000, isUtc: true),
    );
  }

  bool get hasExpired => DateTime.now().toUtc().isAfter(expiry);

  static Map<String, Object?> _decodeJwtToken(String token) {
    final parts = token.split('.');
    if (parts.length != 3) {
      throw Exception('Invalid token');
    }

    final payload = parts[1];
    final normalized = base64Url.normalize(payload);
    final resp = utf8.decode(base64Url.decode(normalized));

    return jsonDecode(resp) as Map<String, Object?>;
  }

  factory AccessToken.fromJson(Map<String, dynamic> json) => AccessToken(
        type: json['type'] as String,
        token: json['data'] as String,
        expiry: DateTime.parse(json['expiry'] as String),
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        'type': type,
        'data': token,
        'expiry': expiry.toIso8601String(),
      };

  @override
  String toString() => 'AccessToken(type=$type, data=$token, expiry=$expiry)';
}
