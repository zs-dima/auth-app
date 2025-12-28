import 'dart:convert';

import 'package:grpc/grpc.dart';
import 'package:grpc/grpc_connection_interface.dart';
import 'package:grpc_model/src/client/channel_config.dart';
import 'package:grpc_model/src/client/root_certificates.dart';
import 'package:grpc_model/src/tool/uri_tool.dart';

ClientChannelBase createClientChannel(Uri address, {GrpcChannelConfig config = GrpcChannelConfig.defaultConfig}) =>
    ClientChannel(
      address.host,
      port: address.port,
      options: ChannelOptions(
        keepAlive: ClientKeepAliveOptions(timeout: config.keepAliveTimeout),
        codecRegistry: CodecRegistry(codecs: const [GzipCodec(), IdentityCodec()]),
        connectionTimeout: config.connectionTimeout,
        credentials: address.ssl
            ? ChannelCredentials.secure(certificates: utf8.encode(RootCertificates.letsEncrypt))
            : const ChannelCredentials.insecure(),
      ),
    );
