import 'dart:async';

import 'package:auth_model/src/api/rpc_exceptions.dart';
import 'package:connect_model/connect_model.dart';
import 'package:connectrpc/connect.dart';

/// Runs a unary RPC with the app-default deadline, mapping any [ConnectException] to the domain
/// [RpcException] family so the API clients never leak `package:connectrpc` through
/// `IAuthenticationApi` / `IUsersApi` (A8). Single source for the translation idiom shared by
/// both clients (A23). The deadline rides as a per-call [TimeoutSignal] (Connect derives the
/// `connect-timeout-ms` header from its deadline) and bounds the whole logical call including
/// middleware retries — the server still enforces its own per-attempt deadline. Not exported from
/// the barrel — an internal helper.
Future<T> guardRpcCall<T>(
  Future<T> Function(AbortSignal signal) rpc, {
  Duration timeout = ConnectClient.defaultCallTimeout,
}) async {
  try {
    return await rpc(TimeoutSignal(timeout));
  } on ConnectException catch (e, st) {
    Error.throwWithStackTrace(RpcException.from(e), st);
  }
}

/// Server-streaming variant: applies the (generous) stream deadline and maps a [ConnectException]
/// surfacing mid-stream to the domain family.
///
/// It also restores the grpc-era subscription semantics (A17): with connect-dart, tearing down
/// the Dart stream alone does NOT abort the RPC — cancellation is signal-based — so this guard
/// cancels its per-call signal when the consumer unsubscribes (screen popped, `.first`, …), which
/// terminates the underlying HTTP/2 stream.
Stream<T> guardRpcStream<T>(
  Stream<T> Function(AbortSignal signal) rpc, {
  Duration timeout = ConnectClient.streamCallTimeout,
}) {
  final signal = CancelableSignal(parent: TimeoutSignal(timeout));
  StreamSubscription<T>? sub;
  late final StreamController<T> controller;
  controller = StreamController<T>(
    onListen: () {
      sub = rpc(signal).listen(
        controller.add,
        onError: (Object error, StackTrace stackTrace) {
          controller
            ..addError(error is ConnectException ? RpcException.from(error) : error, stackTrace)
            // Errors are terminal (parity with the grpc-era guard, where a mapped error ended the
            // stream); the source subscription self-cancels via cancelOnError.
            ..close().ignore();
        },
        onDone: controller.close,
        cancelOnError: true,
      );
    },
    onPause: () => sub?.pause(),
    onResume: () => sub?.resume(),
    onCancel: () async {
      signal.cancel(); // abort the RPC before tearing down the local subscription (A17)
      await sub?.cancel();
    },
  );
  return controller.stream;
}
