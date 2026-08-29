import 'package:connect_model/src/client/transport_config.dart';
import 'package:connectrpc/connect.dart';
import 'package:connectrpc/web.dart';

/// No response-compression advertisement on web: the browser's fetch stack negotiates HTTP-level
/// content-encoding transparently for unary calls, and per-message stream compression has no web
/// implementation — matching the grpc-web-era behavior (the XHR channel had no codec registry).
const List<Compression> defaultAcceptCompressions = [];

/// Web (fetch) HTTP client — Connect protocol over the browser's HTTP stack. NOTE: the browser
/// manages connections, TLS, and keep-alive, so [config] is intentionally NOT applied here — the
/// parameter is kept only to match the IO factory signature (A24).
RpcHttpClientHandle createRpcHttpClient({ConnectTransportConfig config = .defaultConfig}) => .new(createHttpClient());
