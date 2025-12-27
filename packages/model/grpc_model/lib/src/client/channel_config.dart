/// Configuration for gRPC client channels.
class GrpcChannelConfig {
  /// Timeout for establishing a connection.
  final Duration connectionTimeout;

  /// Keep-alive timeout for idle connections.
  final Duration keepAliveTimeout;

  /// Default timeout for RPC calls.
  final Duration callTimeout;

  static const defaultConfig = GrpcChannelConfig();

  const GrpcChannelConfig({
    this.connectionTimeout = const Duration(seconds: 30),
    this.keepAliveTimeout = const Duration(minutes: 5),
    this.callTimeout = const Duration(seconds: 30),
  });
}
