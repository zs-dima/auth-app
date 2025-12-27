import 'dart:async';

import 'package:grpc/grpc.dart';
import 'package:grpc/grpc_connection_interface.dart';
import 'package:grpc/service_api.dart' as service_api;
import 'package:grpc_model/src/client/channel_config.dart';
import 'package:grpc_model/src/client/channel_io.dart'
    // ignore: uri_does_not_exist
    if (dart.library.js_interop) 'package:grpc_model/src/client/channel_web.dart'
    // ignore: uri_does_not_exist
    if (dart.library.io) 'package:grpc_model/src/client/channel_io.dart';

/// Platform-aware gRPC client channel.
///
/// Automatically selects the appropriate channel implementation
/// based on the current platform (web or IO).
class GrpcClientChannel implements service_api.ClientChannel {
  GrpcClientChannel(Uri address, {GrpcChannelConfig config = GrpcChannelConfig.defaultConfig}) {
    _channel = createClientChannel(address, config: config);
  }

  late final ClientChannelBase _channel;

  @override
  Stream<ConnectionState> get onConnectionStateChanged => _channel.onConnectionStateChanged;

  @override
  ClientCall<Q, R> createCall<Q, R>(ClientMethod<Q, R> method, Stream<Q> requests, CallOptions options) =>
      _channel.createCall(method, requests, options);

  @override
  Future<void> shutdown() => _channel.shutdown();

  @override
  Future<void> terminate() => _channel.terminate();
}
