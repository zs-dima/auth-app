import 'dart:async';

import 'package:grpc/grpc.dart';
import 'package:grpc/grpc_connection_interface.dart';
import 'package:grpc/service_api.dart' as service_api;

import 'channel_io.dart'
// ignore: uri_does_not_exist
    if (dart.library.html) 'channel_web.dart'
// ignore: uri_does_not_exist
    if (dart.library.io) 'channel_io.dart';

class GrpcClientChannel implements service_api.ClientChannel {
  late ClientChannelBase _channel;

  GrpcClientChannel(Uri address) : super() {
    _channel = createClientChannel(address);
  }

  @override
  ClientCall<Q, R> createCall<Q, R>(ClientMethod<Q, R> method, Stream<Q> requests, CallOptions options) =>
      _channel.createCall(method, requests, options);

  @override
  Future<void> shutdown() => _channel.shutdown();

  @override
  Future<void> terminate() => _channel.terminate();

  @override
  Stream<ConnectionState> get onConnectionStateChanged => _channel.onConnectionStateChanged;
}
