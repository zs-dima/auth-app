import 'package:grpc/grpc_connection_interface.dart';
import 'package:grpc/grpc_web.dart';

ClientChannelBase createClientChannel(Uri address) => GrpcWebClientChannel.xhr(address);
