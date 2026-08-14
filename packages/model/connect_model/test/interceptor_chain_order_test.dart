// Pins the connect-dart interceptor application order, which the upstream docs state ambiguously
// ("the interceptor at the end of the array is applied first" — that is the WRAPPING order):
// the transport folds `interceptors.reversed`, so the FIRST element in the list is the OUTERMOST
// layer and sees the request first. The DI wiring (Logger → Metadata → Sentry → Retry → Auth,
// outermost → innermost) relies on this — if a connectrpc upgrade flips the fold, this test fails.

import 'package:connect_model/connect_model.dart';
import 'package:connectrpc/connect.dart';
import 'package:connectrpc/test.dart';
import 'package:flutter_test/flutter_test.dart';

int _zero() => 0;

const _spec = Spec<int, int>('/svc.v1.Service/Method', StreamType.unary, _zero, _zero);

/// Handler-based recorder (the [ConnectMiddleware] contract used by logger/metadata/sentry/auth).
class _Recorder extends ConnectMiddleware {
  const _Recorder(this.name, this.log);

  final String name;
  final List<String> log;

  @override
  ConnectMiddlewareHandler handle(ConnectMiddlewareHandler invoker) => (path, metadata) async {
    log.add('$name:before');
    await invoker(path, {...metadata, name: 'seen'});
    log.add('$name:after');
  };
}

/// Raw-contract recorder (the [Interceptor] shape used by retry).
class _RawRecorder {
  const _RawRecorder(this.name, this.log);

  final String name;
  final List<String> log;

  AnyFn<I, O> call<I extends Object, O extends Object>(AnyFn<I, O> next) => (req) async {
    log.add('$name:before');
    final res = await next(req);
    log.add('$name:after');
    return res;
  };
}

void main() {
  test('first interceptor in the list is the outermost layer (both contracts)', () async {
    final log = <String>[];
    Headers? wireHeaders;

    final transport = FakeTransportBuilder()
        .unary(_spec, (req, context) {
          log.add('wire');
          wireHeaders = context.requestHeaders;
          return 2;
        })
        .build(
          interceptors: [
            _Recorder('outer', log).call,
            _RawRecorder('mid', log).call,
            _Recorder('inner', log).call,
          ],
        );

    final result = await Client(transport).unary(_spec, 1);

    expect(result, equals(2));
    expect(
      log,
      equals(['outer:before', 'mid:before', 'inner:before', 'wire', 'inner:after', 'mid:after', 'outer:after']),
      reason: 'list order must be outermost → innermost',
    );
    // Metadata added by the handler-based middleware reaches the wire (merge direction pinned).
    expect(wireHeaders?['outer'], equals('seen'));
    expect(wireHeaders?['inner'], equals('seen'));
  });
}
