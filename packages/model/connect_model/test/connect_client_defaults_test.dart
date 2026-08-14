import 'package:connect_model/connect_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ConnectClient deadlines (S2)', () {
    test('defaultCallTimeout stays 30s (unary calls are always deadlined via the call guards)', () {
      expect(ConnectClient.defaultCallTimeout, equals(const Duration(seconds: 30)));
    });

    test('streamCallTimeout is generous (> unary default) so list streams are not truncated', () {
      expect(ConnectClient.streamCallTimeout, greaterThan(ConnectClient.defaultCallTimeout));
    });
  });
}
