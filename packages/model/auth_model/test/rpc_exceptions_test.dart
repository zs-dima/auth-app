import 'package:auth_model/auth_model.dart';
import 'package:connectrpc/connect.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RpcException.from (A8 classification)', () {
    test('maps RPC status codes to the domain family', () {
      expect(RpcException.from(ConnectException(Code.unavailable, '')), isA<RpcException$Network>());
      expect(RpcException.from(ConnectException(Code.deadlineExceeded, '')), isA<RpcException$Network>());
      expect(RpcException.from(ConnectException(Code.unauthenticated, '')), isA<RpcException$Authentication>());
      expect(RpcException.from(ConnectException(Code.permissionDenied, '')), isA<RpcException$Authentication>());
      expect(RpcException.from(ConnectException(Code.canceled, '')), isA<RpcException$Cancelled>());
      expect(RpcException.from(ConnectException(Code.invalidArgument, '')), isA<RpcException$Request>());
      expect(RpcException.from(ConnectException(Code.notFound, '')), isA<RpcException$Request>());
      expect(RpcException.from(ConnectException(Code.internal, '')), isA<RpcException$Server>());
    });

    test('preserves the original ConnectException as cause and the int status code (F1/R2)', () {
      final original = ConnectException(Code.unavailable, 'backend down');
      final mapped = RpcException.from(original);

      // F1: the UI boundary recovers the cause to render a code-specific message.
      expect(mapped.cause, same(original));
      // R2: code is the raw int status value (Code.*.value), not the connect-dart enum.
      expect(mapped.code, Code.unavailable.value);
      expect(mapped.code, isA<int>());
    });

    test('falls back to a code-named message when the server message is empty', () {
      final mapped = RpcException.from(ConnectException(Code.unavailable, ''));
      expect(mapped.message, 'RPC error (unavailable)');
    });

    test('passes an existing RpcException through unchanged', () {
      const existing = RpcException$Server('already mapped');
      expect(RpcException.from(existing), same(existing));
    });

    test('wraps a non-RPC error as a server exception with no code', () {
      final mapped = RpcException.from(StateError('boom'));
      expect(mapped, isA<RpcException$Server>());
      expect(mapped.code, isNull);
    });
  });
}
