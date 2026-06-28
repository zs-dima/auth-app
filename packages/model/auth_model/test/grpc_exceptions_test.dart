import 'package:auth_model/auth_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grpc/grpc.dart';

void main() {
  group('GrpcException.from (A8 classification)', () {
    test('maps gRPC status codes to the domain family', () {
      expect(GrpcException.from(const GrpcError.unavailable()), isA<GrpcException$Network>());
      expect(GrpcException.from(const GrpcError.deadlineExceeded()), isA<GrpcException$Network>());
      expect(GrpcException.from(const GrpcError.unauthenticated()), isA<GrpcException$Authentication>());
      expect(GrpcException.from(const GrpcError.permissionDenied()), isA<GrpcException$Authentication>());
      expect(GrpcException.from(const GrpcError.cancelled()), isA<GrpcException$Cancelled>());
      expect(GrpcException.from(const GrpcError.invalidArgument()), isA<GrpcException$Request>());
      expect(GrpcException.from(const GrpcError.notFound()), isA<GrpcException$Request>());
      expect(GrpcException.from(const GrpcError.internal()), isA<GrpcException$Server>());
    });

    test('preserves the original GrpcError as cause and the int status code (F1/R2)', () {
      const original = GrpcError.unavailable('backend down');
      final mapped = GrpcException.from(original);

      // F1: the UI boundary recovers the cause to render a code-specific message.
      expect(mapped.cause, same(original));
      // R2: code is the raw int status value (StatusCode.* are int constants), not the grpc enum.
      expect(mapped.code, StatusCode.unavailable);
      expect(mapped.code, isA<int>());
    });

    test('passes an existing GrpcException through unchanged', () {
      const existing = GrpcException$Server('already mapped');
      expect(GrpcException.from(existing), same(existing));
    });

    test('wraps a non-gRPC error as a server exception with no code', () {
      final mapped = GrpcException.from(StateError('boom'));
      expect(mapped, isA<GrpcException$Server>());
      expect(mapped.code, isNull);
    });
  });
}
