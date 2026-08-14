// Pins the [ConnectMiddleware] streaming semantics ported from the grpc-era base:
//  1. the (path, metadata) handler observes the WHOLE stream lifetime — every message and any
//     mid-stream error (what auth's repair-without-replay and the Sentry span rely on);
//  2. a failure before response headers surfaces as a failure of the call itself (unary-like);
//  3. cancelling the response subscription aborts the underlying call via the substituted child
//     signal (the in-chain half of A17; the caller-facing half lives in guardRpcStream).

import 'dart:async';

import 'package:connect_model/connect_model.dart';
import 'package:connectrpc/connect.dart';
import 'package:connectrpc/test.dart';
import 'package:flutter_test/flutter_test.dart';

int _zero() => 0;

const _spec = Spec<int, int>('/svc.v1.Service/List', StreamType.server, _zero, _zero);

/// Records the handler lifecycle and any error it observes, then rethrows.
class _StreamRecorder extends ConnectMiddleware {
  const _StreamRecorder(this.log);

  final List<String> log;

  @override
  ConnectMiddlewareHandler handle(ConnectMiddlewareHandler invoker) => (path, metadata) async {
    log.add('before');
    try {
      await invoker(path, metadata);
      log.add('after');
    } on ConnectException catch (e) {
      log.add('error:${e.code.name}');
      rethrow;
    }
  };
}

void main() {
  group('ConnectMiddleware streaming', () {
    test('handler observes the whole stream (completes only after the last message)', () async {
      final log = <String>[];
      final transport = FakeTransportBuilder()
          .server(_spec, (req, context) => Stream.fromIterable([1, 2, 3]))
          .build(interceptors: [_StreamRecorder(log).call]);

      final events = <int>[];
      await for (final event in Client(transport).server(_spec, 0)) {
        events.add(event);
      }
      // Let the driver's handler finish (it completes on the pump's onDone).
      await pumpEventQueue();

      expect(events, equals([1, 2, 3]));
      expect(log, equals(['before', 'after']));
    });

    test('handler observes a mid-stream error and the consumer still receives it', () async {
      final log = <String>[];
      final transport = FakeTransportBuilder()
          .server(_spec, (req, context) async* {
            yield 1;
            throw ConnectException(Code.unauthenticated, 'expired');
          })
          .build(interceptors: [_StreamRecorder(log).call]);

      final events = <int>[];
      await expectLater(
        () async {
          await for (final event in Client(transport).server(_spec, 0)) {
            events.add(event);
          }
        }(),
        throwsA(isA<ConnectException>().having((e) => e.code, 'code', Code.unauthenticated)),
      );
      await pumpEventQueue();

      expect(events, equals([1]), reason: 'messages before the error must be delivered');
      expect(log, equals(['before', 'error:unauthenticated']), reason: 'the handler must see the mid-stream error');
    });

    test('failure before response headers surfaces as a failure of the call itself', () async {
      final log = <String>[];
      final transport = FakeTransportBuilder()
          .server(_spec, (req, context) async* {
            throw ConnectException(Code.unavailable, 'down');
            // ignore: dead_code
            yield 0;
          })
          .build(interceptors: [_StreamRecorder(log).call]);

      await expectLater(
        transport.stream(_spec, Stream.value(0), const CallOptions()),
        throwsA(isA<ConnectException>().having((e) => e.code, 'code', Code.unavailable)),
      );
      await pumpEventQueue();

      expect(log, equals(['before', 'error:unavailable']));
    });

    test('consumer pause/resume propagates to the wire subscription (back-pressure)', () async {
      var pausedAtSource = false;
      var resumedAtSource = false;
      final source = StreamController<int>(
        onPause: () => pausedAtSource = true,
        onResume: () => resumedAtSource = true,
      )..add(1);
      final log = <String>[];
      final transport = FakeTransportBuilder()
          .server(_spec, (req, context) => source.stream)
          .build(interceptors: [_StreamRecorder(log).call]);

      final response = await transport.stream(_spec, Stream.value(0), const CallOptions());
      final sub = response.message.listen((_) {});
      await pumpEventQueue();

      sub.pause();
      await pumpEventQueue();
      expect(pausedAtSource, isTrue, reason: 'pause must reach the wire subscription (flow control)');

      sub.resume();
      await pumpEventQueue();
      expect(resumedAtSource, isTrue);

      await source.close();
      await pumpEventQueue();
      await sub.cancel();
    });

    test('cancelling the response subscription aborts the call via the child signal (A17)', () async {
      final log = <String>[];
      final serverAborted = Completer<void>();
      final transport = FakeTransportBuilder()
          .server(_spec, (req, context) {
            // Emit one value, then hang until aborted — like a live server stream.
            final controller = StreamController<int>()..add(1);
            context.signal.future.then((_) {
              if (!serverAborted.isCompleted) serverAborted.complete();
              controller.close().ignore();
            }).ignore();
            return controller.stream;
          })
          .build(interceptors: [_StreamRecorder(log).call]);

      final response = await transport.stream(_spec, Stream.value(0), const CallOptions());
      final received = Completer<int>();
      final sub = response.message.listen((event) {
        if (!received.isCompleted) received.complete(event);
      });

      expect(await received.future, equals(1));
      await sub.cancel();

      // The middleware substitutes a child CancelableSignal into the forwarded request and cancels
      // it when its stream is cancelled — the (fake) wire observes the abort.
      await expectLater(serverAborted.future, completes);
      await pumpEventQueue();
      expect(log.first, equals('before'));
    });
  });
}
