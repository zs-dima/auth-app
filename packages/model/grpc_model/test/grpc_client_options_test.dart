import 'package:flutter_test/flutter_test.dart';
import 'package:grpc_model/grpc_model.dart';

void main() {
  group('GrpcClientOptions deadlines (S2)', () {
    test('timeout defaults to defaultCallTimeout (unary calls are always deadlined)', () {
      final channel = GrpcClientChannel(Uri.parse('https://localhost:443'));
      expect(GrpcClientOptions(channel).timeout, GrpcClientOptions.defaultCallTimeout);
    });

    test('an explicit timeout overrides the default', () {
      final channel = GrpcClientChannel(Uri.parse('https://localhost:443'));
      const custom = Duration(seconds: 5);
      expect(GrpcClientOptions(channel, timeout: custom).timeout, custom);
    });

    test('streamCallTimeout is generous (> unary default) so list streams are not truncated', () {
      expect(GrpcClientOptions.streamCallTimeout, greaterThan(GrpcClientOptions.defaultCallTimeout));
    });
  });
}
