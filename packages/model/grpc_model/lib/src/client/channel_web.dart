import 'package:grpc/grpc_connection_interface.dart';
import 'package:grpc/grpc_web.dart';
import 'package:grpc_model/src/client/channel_config.dart';

/// Web (grpc-web over XHR) channel. NOTE: the grpc-web transport does not expose connection-level
/// knobs, so [config] (connection timeout / keep-alive) is intentionally NOT applied here — the
/// browser manages those. The parameter is kept only to match the IO factory signature (A24).
ClientChannelBase createClientChannel(
  Uri address, {
  GrpcChannelConfig config = .defaultConfig,
}) => GrpcWebClientChannel.xhr(address);
