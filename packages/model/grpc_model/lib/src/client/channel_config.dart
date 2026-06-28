/// Configuration for gRPC client channels.
class GrpcChannelConfig {
  static const defaultConfig = GrpcChannelConfig();

  const GrpcChannelConfig({
    this.connectionTimeout = const Duration(seconds: 30),
    this.keepAliveTimeout = const Duration(minutes: 5),
    this.keepAlivePingInterval,
  });

  /// Timeout for establishing a connection.
  final Duration connectionTimeout;

  /// How long to wait for a keep-alive ping ack before treating the connection as dead. Only has
  /// effect when [keepAlivePingInterval] is set — without an interval no pings are sent (A24).
  final Duration keepAliveTimeout;

  /// Interval between keep-alive pings on an (idle) connection. `null` (default) disables
  /// client-initiated keep-alive entirely — set it to keep idle HTTP/2 connections warm. Keep it
  /// conservative (minutes): aggressive pinging can trigger a server `GOAWAY`.
  final Duration? keepAlivePingInterval;

  // Per-call deadline is NOT a channel concern — it lives in [GrpcClientOptions.timeout]
  // (default [GrpcClientOptions.defaultCallTimeout]), applied via CallOptions per call.
}
