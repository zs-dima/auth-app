import 'dart:convert';

import 'package:grpc/grpc.dart';
import 'package:grpc/grpc_connection_interface.dart';
import 'package:grpc_model/src/client/channel_config.dart';
import 'package:grpc_model/src/client/root_certificates.dart';
import 'package:grpc_model/src/tool/uri_tool.dart';

/// Chooses TLS by URI scheme: `https`/`wss` → secure (pinned to the Let's Encrypt roots),
/// `http`/`ws` → insecure. Pure and public so the credential decision is unit-testable without
/// constructing a real channel (A24).
ChannelCredentials channelCredentialsForAddress(Uri address) => address.ssl
    ? .secure(certificates: utf8.encode(RootCertificates.letsEncrypt))
    : const .insecure();

ClientChannelBase createClientChannel(Uri address, {GrpcChannelConfig config = .defaultConfig}) => ClientChannel(
  address.host,
  port: address.port,
  options: ChannelOptions(
    // `pingInterval` null (default) ⇒ no client keep-alive pings, so `timeout` has no effect (A24).
    // Set GrpcChannelConfig.keepAlivePingInterval to actually keep idle connections warm.
    keepAlive: ClientKeepAliveOptions(
      pingInterval: config.keepAlivePingInterval,
      timeout: config.keepAliveTimeout,
    ),
    codecRegistry: CodecRegistry(codecs: const [GzipCodec(), IdentityCodec()]),
    connectionTimeout: config.connectionTimeout,
    credentials: channelCredentialsForAddress(address),
  ),
);
