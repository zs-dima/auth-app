import 'dart:convert';

import 'package:crypto/crypto.dart';

abstract final class JwtValidator {
  static Map<String, dynamic> validateToken(String token, {String? secretKey, String algorithm = 'HS256'}) {
    final parts = token.split('.');
    if (parts.length != 3) {
      throw const FormatException('Invalid token structure');
    }

    final header = json.decode(_decodeBase64(parts.first)) as Map<String, dynamic>;
    final payload = json.decode(_decodeBase64(parts[1])) as Map<String, dynamic>;

    // Verify algorithm
    if (header['alg'] != algorithm.toUpperCase()) {
      throw FormatException('Invalid algorithm. Expected $algorithm');
    }

    // Verify signature
    if (secretKey != null) {
      final signature = _decodeBase64Url(parts[2]);

      final dataToVerify = '${parts.first}.${parts[1]}';
      final isSignatureValid = _verifySignature(dataToVerify, signature, secretKey);
      if (!isSignatureValid) {
        throw const FormatException('Invalid signature');
      }
    }

    // Validate expiration
    _validateExpiration(payload);

    return payload;
  }

  static String _decodeBase64(String str) {
    final output = base64Url.normalize(str);
    return utf8.decode(base64Url.decode(output));
  }

  static List<int> _decodeBase64Url(String str) {
    final output = base64Url.normalize(str);
    return base64Url.decode(output);
  }

  static bool _verifySignature(String data, List<int> signature, String secretKey) {
    final key = utf8.encode(secretKey);
    final bytes = utf8.encode(data);
    final hmac = Hmac(sha256, key);
    final digest = hmac.convert(bytes);
    return _constantTimeEquality(digest.bytes, signature);
  }

  static bool _constantTimeEquality(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    var result = 0;
    for (final (i, value) in a.indexed) {
      result |= value ^ b[i];
    }
    return result == 0;
  }

  static void _validateExpiration(Map<String, dynamic> payload) {
    if (!payload.containsKey('exp')) throw const FormatException('Missing expiration claim');

    final currentTime = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final expTime = payload['exp'];

    if (expTime is int && expTime < currentTime) {
      throw const FormatException('Token has expired');
    } else if (expTime is! int) {
      throw const FormatException('Invalid expiration claim format');
    }
  }
}
