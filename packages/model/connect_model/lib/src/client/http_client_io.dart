import 'dart:convert';
import 'dart:io';

import 'package:connect_model/src/client/root_certificates.dart';
import 'package:connect_model/src/client/transport_config.dart';
import 'package:connect_model/src/tool/uri_tool.dart';
import 'package:connectrpc/connect.dart';
import 'package:connectrpc/http2.dart';
import 'package:connectrpc/io.dart' show GzipCompression;

/// Compressions the client advertises and can DECODE in responses (`accept-encoding` /
/// `connect-accept-encoding`) — parity with the grpc-era `CodecRegistry([GzipCodec(),
/// IdentityCodec()])`, which let the server gzip its responses. SEND-side compression stays a
/// separate, deliberate opt-in (see middlewares/compression_middleware.dart).
final List<Compression> defaultAcceptCompressions = [GzipCompression()];

/// Chooses TLS by URI scheme: `https`/`wss` → secure (pinned to the Let's Encrypt roots),
/// `http`/`ws` → insecure h2c. Pure and public so the trust decision stays unit-testable without
/// constructing a real client (A24). connect-dart applies the same scheme branch internally
/// (`SecureSocket` + ALPN `h2` for https; a plain prior-knowledge h2c socket for http) and
/// consults the [SecurityContext] only for TLS origins — which is why the shared client below can
/// always carry the pinned context.
SecurityContext? securityContextForAddress(Uri address) => address.ssl ? rpcSecurityContext() : null;

/// Trust pinned to the Let's Encrypt ISRG Root X1: a [SecurityContext] WITHOUT system roots plus
/// the pinned root — matching the grpc-era `ChannelCredentials.secure(certificates:)` behavior
/// (grpc-dart builds `SecurityContext()`, i.e. `withTrustedRoots: false`, and adds the provided
/// roots).
SecurityContext rpcSecurityContext() =>
    SecurityContext(withTrustedRoots: false)..setTrustedCertificatesBytes(utf8.encode(RootCertificates.letsEncrypt));

/// Native HTTP client: HTTP/2 with prior-knowledge h2c for `http` and pinned TLS for `https`;
/// keep-alive and idle behavior from [config].
RpcHttpClientHandle createRpcHttpClient({ConnectTransportConfig config = .defaultConfig}) => .new(
  createHttpClient(
    transport: Http2ClientTransport(
      context: rpcSecurityContext(),
      pingInterval: config.pingInterval,
      pingTimeout: config.pingTimeout,
      pingIdleConnections: config.pingIdleConnections,
      idleConnectionTimeout: config.idleConnectionTimeout,
    ),
  ),
);
