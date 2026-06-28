import 'package:grpc/grpc.dart';
import 'package:grpc/service_api.dart' as service_api;

class GrpcClientOptions {
  const GrpcClientOptions(
    this.channel, {
    this.timeout = defaultCallTimeout,
    this.metadata,
    this.compression,
    this.interceptors,
  });

  /// Default per-call deadline for **unary** RPCs. gRPC best practice: always deadline a unary
  /// call. Single source of truth — callers no longer hardcode the value.
  static const Duration defaultCallTimeout = Duration(seconds: 30);

  /// Deadline for **server-streaming** RPCs (e.g. list endpoints). The deadline bounds the whole
  /// call, so it must be generous enough not to truncate a large-but-finite stream; it is passed
  /// explicitly per streaming call (a per-call `CallOptions.timeout` overrides the client default,
  /// but cannot un-set it — see grpc `CallOptions.mergedWith`).
  static const Duration streamCallTimeout = Duration(minutes: 5);

  final service_api.ClientChannel channel;

  final Duration? timeout;
  final Map<String, String>? metadata;
  final Codec? compression;
  final Iterable<ClientInterceptor>? interceptors;
}

class GrpcClient<T extends Client> {
  GrpcClient(
    GrpcClientOptions options, {
    required T Function(
      service_api.ClientChannel channel, {
      CallOptions options,
      Iterable<ClientInterceptor>? interceptors,
    })
    factory,
  }) : channel = options.channel,
       client = factory(
         options.channel,
         options: CallOptions(
           timeout: options.timeout,
           metadata: options.metadata,
           compression: options.compression,
         ),
         interceptors: options.interceptors,
       );

  final T client;

  /// The underlying channel, retained so it can be shut down on teardown (A6). Without this the
  /// channel created per service was unreachable and its HTTP/2 socket + keep-alive leaked.
  final service_api.ClientChannel channel;

  /// Shuts the channel down gracefully (lets in-flight RPCs finish). Call once on app teardown.
  Future<void> dispose() => channel.shutdown();
}
