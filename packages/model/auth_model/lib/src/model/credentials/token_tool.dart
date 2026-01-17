import 'dart:convert';
import 'dart:math' as math;

sealed class TokenTool {
  static final math.Random _random = math.Random.secure();

  /// Generate a random token.
  static String generate([int length = 64]) {
    final byteLength = (length * 6 + 7) ~/ 8;
    final values = List<int>.generate(byteLength, (i) => _random.nextInt(256));
    final token = base64Url.encode(values);
    assert(token.length >= length, 'Token length to short');
    // ignore: avoid-substring
    return token.length > length ? token.substring(0, length) : token;
  }
}
