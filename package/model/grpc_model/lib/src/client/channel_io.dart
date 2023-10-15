import 'dart:convert';

import 'package:grpc/grpc.dart';
import 'package:grpc/grpc_connection_interface.dart';
import 'package:grpc_model/grpc_model.dart' hide Duration;
import 'package:grpc_model/src/tool/uri_tool.dart';

ClientChannelBase createClientChannel(Uri address) => //
    ClientChannel(
      address.host,
      port: address.port,
      options: ChannelOptions(
        keepAlive: const ClientKeepAliveOptions(
          timeout: Duration(minutes: 30),
        ),
        codecRegistry: CodecRegistry(codecs: const [GzipCodec(), IdentityCodec()]),
        connectionTimeout: const Duration(minutes: 50),
        credentials: address.ssl
            ? ChannelCredentials.secure(
                certificates: utf8.encode(RootCertificates.letsEncrypt),
              )
            : const ChannelCredentials.insecure(),
      ),
    );
