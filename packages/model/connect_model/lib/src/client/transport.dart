import 'package:connect_model/src/client/http_client_io.dart'
    // ignore: uri_does_not_exist
    if (dart.library.js_interop) 'package:connect_model/src/client/http_client_web.dart'
    // ignore: uri_does_not_exist
    if (dart.library.io) 'package:connect_model/src/client/http_client_io.dart';
import 'package:connect_model/src/client/transport_config.dart';
import 'package:connectrpc/connect.dart';
import 'package:connectrpc/protobuf.dart';
import 'package:connectrpc/protocol/connect.dart' as connect_protocol;

export 'package:connect_model/src/client/http_client_io.dart'
    // ignore: uri_does_not_exist
    if (dart.library.js_interop) 'package:connect_model/src/client/http_client_web.dart'
    // ignore: uri_does_not_exist
    if (dart.library.io) 'package:connect_model/src/client/http_client_io.dart';

/// Creates a Connect-protocol [Transport] for [address] — binary protobuf on every platform
/// (JSON stays an ad-hoc debugging option by swapping the codec).
///
/// One [RpcHttpClientHandle] (see `createRpcHttpClient`) is shared across transports so all
/// services multiplex per-origin HTTP/2 connections. [interceptors] wrap outermost-first in list
/// order (pinned by the chain-order test).
///
/// [acceptCompressions] defaults to the platform's `defaultAcceptCompressions` (gzip response
/// decoding on IO, none on web — grpc-era parity); [sendCompression] stays off by default — see
/// `middlewares/compression_middleware.dart` (standby).
Transport createConnectTransport(
  Uri address, {
  required RpcHttpClientHandle httpClient,
  List<Interceptor> interceptors = const [],
  Compression? sendCompression,
  List<Compression>? acceptCompressions,
}) => connect_protocol.Transport(
  baseUrl: address.toString(),
  codec: const ProtoCodec(),
  httpClient: httpClient.client,
  interceptors: interceptors,
  sendCompression: sendCompression,
  acceptCompressions: acceptCompressions ?? defaultAcceptCompressions,
);
