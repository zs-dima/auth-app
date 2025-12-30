import 'package:grpc/grpc.dart';
import 'package:grpc/service_api.dart' as service_api;

class GrpcClientOptions {
  const GrpcClientOptions(
    this.channel, {
    this.timeout,
    this.metadata,
    this.compression,
    this.interceptors,
  });

  final service_api.ClientChannel channel;

  final Duration? timeout;
  final Map<String, String>? metadata;
  final Codec? compression;
  final Iterable<ClientInterceptor>? interceptors;
}

class GrpcClient<T extends Client> {
  GrpcClient(
    GrpcClientOptions options, {
    required T Function(
      service_api.ClientChannel channel, {
      CallOptions options,
      Iterable<ClientInterceptor>? interceptors,
    })
    factory,
  }) : client = factory(
         options.channel,
         options: CallOptions(
           timeout: options.timeout,
           metadata: options.metadata,
           compression: options.compression,
         ),
         interceptors: options.interceptors,
       );

  final T client;
}
