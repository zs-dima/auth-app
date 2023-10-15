import 'dart:typed_data';

import 'package:core_model/core_model.dart';
import 'package:fixnum/fixnum.dart' as fn;
import 'package:grpc/grpc.dart';
import 'package:grpc_model/grpc_model.dart' as rpc;
import 'package:uuid/uuid.dart';

extension GrpcIdX on Guid? {
  rpc.UUID toUUID() => this == null ? rpc.UUID() : (rpc.UUID()..value = this!);
  bool isNull() => this == null || this!.isEmpty || this == Uuid.NAMESPACE_NIL;
}

extension GrpcUuidX on rpc.UUID {
  Guid toId() => (value.isNull()) ? Uuid.NAMESPACE_NIL : value;

  bool isNull() => toId().isNull();
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
          print(detail); // TODO: log details
        }
      }
    }

    switch (code) {
      case StatusCode.unauthenticated:
        final shortMessage = message;
        if (shortMessage?.isNotEmpty ?? false) return '$caption. $shortMessage';
        return caption;

      case StatusCode.permissionDenied:
        return '$caption: Permission denied';

      case StatusCode.unavailable:
        return 'Backend error. Please contact support'; // '$caption: GRPC unavailable';

      case StatusCode.aborted:
        return '$caption: Network request aborted';

      case StatusCode.dataLoss:
        return '$caption: Network data loss';

      case StatusCode.deadlineExceeded:
        return 'Backend error. Please contact support'; // '$caption: GRPC deadline exceeded';

      case StatusCode.cancelled:
        return '$caption: Network request cancelled';

      case StatusCode.internal:
        return '$caption: $message';

      case StatusCode.failedPrecondition:
        return '$caption: Network request failed precondition';

      case StatusCode.unknown:
        if (message?.contains('CORS') ?? false) return '$caption: CORS error';
    }

    return '$caption: Network error: $this';
  }
}
