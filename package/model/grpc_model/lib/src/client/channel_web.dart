import 'package:grpc/grpc_connection_interface.dart';
import 'package:grpc/grpc_web.dart';
import 'package:grpc_model/src/client/channel_config.dart';

ClientChannelBase createClientChannel(
  Uri address, {
  // ignore: avoid-unused-parameters
  GrpcChannelConfig config = GrpcChannelConfig.defaultConfig,
}) => GrpcWebClientChannel.xhr(address);
