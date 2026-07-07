import 'package:connectrpc/connect.dart';

/// Base class for Connect RPC API clients: holds the shared [Transport] plus the app-wide
/// per-call deadline defaults. With Connect the deadline is a per-call `TimeoutSignal` (applied
/// by the call guards), not a stub-level option — and it bounds the whole logical call including
/// middleware retries (grpc-dart re-armed the deadline per attempt; the server still enforces its
/// own per-attempt deadline).
abstract class ConnectClient {
  /// Default per-call deadline for **unary** RPCs. RPC best practice: always deadline a unary
  /// call. Single source of truth — callers do not hardcode the value.
  static const Duration defaultCallTimeout = Duration(seconds: 30);

  /// Deadline for **server-streaming** RPCs (e.g. list endpoints). The deadline bounds the whole
  /// call, so it must be generous enough not to truncate a large-but-finite stream; it is passed
  /// explicitly per streaming call.
  static const Duration streamCallTimeout = Duration(minutes: 5);

  const ConnectClient(this.transport);

  /// The transport carrying this client's RPCs (interceptors are registered on it).
  ///
  /// NOTE (A6): connection disposal is owned by the shared `RpcHttpClientHandle` in DI — clients
  /// hold no per-client channel to shut down (unlike the grpc-era `GrpcClient.dispose`).
  final Transport transport;
}
