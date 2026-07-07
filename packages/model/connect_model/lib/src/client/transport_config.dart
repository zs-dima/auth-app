import 'package:connectrpc/connect.dart';

/// Configuration for the native HTTP/2 client behind the Connect transports.
class ConnectTransportConfig {
  static const defaultConfig = ConnectTransportConfig();

  const ConnectTransportConfig({
    this.pingInterval,
    this.pingTimeout = const Duration(minutes: 5),
    this.pingIdleConnections = false,
    this.idleConnectionTimeout = const Duration(minutes: 15),
  });

  /// Interval between keep-alive pings on a connection. `null` (default) disables client-initiated
  /// keep-alive entirely — set it to keep idle HTTP/2 connections warm. Keep it conservative
  /// (minutes): aggressive pinging can trigger a server `GOAWAY`. (grpc-era `keepAlivePingInterval`.)
  final Duration? pingInterval;

  /// How long to wait for a keep-alive ping ack before treating the connection as dead. Only has
  /// effect when [pingInterval] is set — without an interval no pings are sent (A24).
  /// (grpc-era `keepAliveTimeout`; connect-dart's own default is 15s — 5min preserves the previous
  /// channel config.)
  final Duration pingTimeout;

  /// Whether keep-alive pings are also sent on idle connections (off matches the grpc-era behavior).
  final bool pingIdleConnections;

  /// Closes a connection when the time since its last request stream exceeds this value.
  final Duration idleConnectionTimeout;

  // The grpc-era `connectionTimeout` (connection-establishment bound) has no connect-dart 1.0.0
  // equivalent — connection setup is bounded by the per-call deadline (`TimeoutSignal`) instead.
  // Per-call deadlines are NOT a transport concern: they live in the call guards
  // (default [ConnectClient.defaultCallTimeout]).
}

/// Owner of the platform HTTP client shared by the app's Connect transports: create once in DI,
/// pass to every `createConnectTransport`, close on teardown (A6). Sharing one handle lets all
/// services multiplex per-origin HTTP/2 connections.
final class RpcHttpClientHandle {
  const RpcHttpClientHandle(this.client);

  /// The connect-dart HTTP client function backing the transports.
  final HttpClient client;

  /// Releases the underlying connections. connectrpc 1.0.0 exposes no connection-close API
  /// (`Http2ClientTransport` only offers `makeRequest`), so this is currently a no-op and idle
  /// connections are reaped via [ConnectTransportConfig.idleConnectionTimeout]; kept as the single
  /// disposal point so a future connectrpc can close for real without rewiring (A6).
  Future<void> close() async {}
}
