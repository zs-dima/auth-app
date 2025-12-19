import 'dart:developer' as developer;
import 'dart:typed_data';

import 'package:core_model/core_model.dart';
import 'package:fixnum/fixnum.dart' as fn;
import 'package:grpc/grpc.dart';
import 'package:grpc/protos.dart' show DebugInfo;
import 'package:grpc_model/grpc_model.dart' as rpc;
import 'package:uuid/uuid.dart';

extension GrpcIdX on Guid? {
  rpc.UUID toUUID() => this == null ? rpc.UUID() : (rpc.UUID()..value = this!);
  bool get isNull => this == null || this!.isEmpty || this == Uuid.NAMESPACE_NIL;
}

extension GrpcUuidX on rpc.UUID {
  Guid toId() => (value.isNull) ? Uuid.NAMESPACE_NIL : value;

  bool get isNull => toId().isNull;
}

extension DurationGrpcX on rpc.Duration {
  Duration toDuration() => Duration(seconds: seconds.toInt());
}

extension DurationGrpc1X on Duration {
  rpc.Duration toDuration() => rpc.Duration()..seconds = fn.Int64(inSeconds);
}

extension DoubleValueX on rpc.DoubleValue {
  double? toDouble() => hasValue() ? value : null;
}

extension GrpcDoubleX on double? {
  rpc.DoubleValue toDoubleValue() =>
      this == null ? rpc.DoubleValue.getDefault() : (rpc.DoubleValue()..setField(1, this!));
}

extension BoolValueX on rpc.BoolValue {
  bool? toBool() => hasValue() ? value : null;
}

extension GrpcBoolX on bool? {
  rpc.BoolValue toBoolValue() => this == null ? rpc.BoolValue.getDefault() : (rpc.BoolValue()..setField(1, this!));
}

extension GrpcBytesX on Uint8List? {
  rpc.BytesValue toBytesValue() => this == null ? rpc.BytesValue.getDefault() : (rpc.BytesValue()..setField(1, this!));
}

extension BytesValueX on rpc.BytesValue {
  Uint8List? toBytes() => hasValue() ? Uint8List.fromList(value) : null;
}

extension Int32ValueX on rpc.Int32Value {
  int? toInt() => hasValue() ? value : null;
}

extension GrpcIntX on int? {
  rpc.Int32Value toIntValue() => this == null ? rpc.Int32Value.getDefault() : (rpc.Int32Value()..setField(1, this!));
}

extension GrpcErrorX on GrpcError {
  String detail(String caption) {
    final details = this.details;
    if (details != null) {
      for (final detail in details) {
        if (detail is DebugInfo) {
          developer.log(detail.toString(), name: 'GrpcError', error: this);
        }
      }
    }

    return switch (code) {
      StatusCode.unauthenticated => (message?.isNotEmpty ?? false) ? '$caption. $message' : caption,
      StatusCode.permissionDenied => '$caption: Permission denied',
      StatusCode.unavailable => 'Backend unavailable. Please contact support',
      StatusCode.aborted => '$caption: Network request aborted',
      StatusCode.dataLoss => '$caption: Network data loss',
      StatusCode.deadlineExceeded => 'Backend error. Please contact support',
      StatusCode.cancelled => '$caption: Network request cancelled',
      StatusCode.internal => '$caption: $message',
      StatusCode.failedPrecondition => '$caption: Network request failed precondition',
      StatusCode.unknown when message?.contains('CORS') ?? false => '$caption: CORS error',
      _ => '$caption: Network error: $this',
    };
  }
}
