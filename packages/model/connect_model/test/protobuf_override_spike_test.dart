// Phase-0 gate of the gRPC → Connect migration, kept permanently as the protobuf-interop canary.
//
// Upstream `connectrpc` 1.0.0 pins `protobuf <5.0.0` while the workspace uses protobuf ^6, so the
// workspace links the vendored copy at packages/vendor/connectrpc (widened constraint + regenerated
// embedded protos — see its VENDORED.md). connectrpc touches only stable protobuf APIs
// (`writeToBuffer` / `mergeFromBuffer` / proto3 JSON); this test pins that interop against real
// protoc_plugin v25-generated messages, both at the codec level and through the real transport
// plumbing (interceptor fold, signals, Client extension).

import 'package:connect_model/src/proto/core/v1/core.pb.dart';
import 'package:connectrpc/connect.dart';
import 'package:connectrpc/protobuf.dart';
import 'package:connectrpc/test.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('connectrpc <-> protobuf ^6 interop', () {
    test('ProtoCodec round-trips a protoc_plugin v25 message', () {
      const codec = ProtoCodec();
      final source = UUID(value: '0198c5b6-1f2a-7c3d-9e4f-5a6b7c8d9e0f');

      final bytes = codec.encode(source);
      final target = UUID();
      codec.decode(bytes, target);

      expect(target, equals(source));
      expect(target.value, equals(source.value));
    });

    test('JsonCodec round-trips via proto3 JSON', () {
      const codec = JsonCodec();
      final source = UUID(value: '0198c5b6-1f2a-7c3d-9e4f-5a6b7c8d9e0f');

      final bytes = codec.encode(source);
      final target = UUID();
      codec.decode(bytes, target);

      expect(target, equals(source));
    });

    test('unary call flows through the real transport plumbing', () async {
      const spec = Spec<UUID, UUID>(
        '/spike.v1.SpikeService/Check',
        .unary,
        UUID.create,
        UUID.create,
      );
      final transport = FakeTransportBuilder().unary(spec, (req, context) {
        expect(req.value, equals('ping'));
        return UUID(value: 'pong');
      }).build();

      final result = await Client(transport).unary(spec, UUID(value: 'ping'));

      expect(result.value, equals('pong'));
    });
  });
}
