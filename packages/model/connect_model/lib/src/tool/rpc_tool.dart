import 'dart:developer' as developer;
import 'dart:typed_data';

import 'package:connect_model/src/well_known_types.dart' as rpc;
import 'package:connectrpc/connect.dart';
import 'package:core_model/core_model.dart';
import 'package:fixnum/fixnum.dart' as fn;
import 'package:uuid/uuid.dart';

extension RpcIdX on Guid? {
  rpc.UUID toUUID() => this == null ? rpc.UUID() : (rpc.UUID()..value = this!);
  bool get isNull => this == null || this!.isEmpty || this == Uuid.NAMESPACE_NIL;
}

extension RpcUuidX on rpc.UUID {
  Guid toId() => (value.isNull) ? Uuid.NAMESPACE_NIL : value;

  bool get isNull => toId().isNull;
}

extension DurationRpcX on rpc.Duration {
  Duration toDuration() => .new(seconds: seconds.toInt());
}

extension DurationRpc1X on Duration {
  rpc.Duration toDuration() => rpc.Duration()..seconds = fn.Int64(inSeconds);
}

extension DoubleValueX on rpc.DoubleValue {
  double? toDouble() => hasValue() ? value : null;
}

extension RpcDoubleX on double? {
  rpc.DoubleValue toDoubleValue() =>
      this == null ? rpc.DoubleValue.getDefault() : (rpc.DoubleValue()..setField(1, this!));
}

extension BoolValueX on rpc.BoolValue {
  bool? toBool() => hasValue() ? value : null;
}

extension RpcBoolX on bool? {
  rpc.BoolValue toBoolValue() => this == null ? rpc.BoolValue.getDefault() : (rpc.BoolValue()..setField(1, this!));
}

extension RpcBytesX on Uint8List? {
  rpc.BytesValue toBytesValue() => this == null ? rpc.BytesValue.getDefault() : (rpc.BytesValue()..setField(1, this!));
}

extension BytesValueX on rpc.BytesValue {
  Uint8List? toBytes() => hasValue() ? .fromList(value) : null;
}

extension Int32ValueX on rpc.Int32Value {
  int? toInt() => hasValue() ? value : null;
}

extension RpcIntX on int? {
  rpc.Int32Value toIntValue() => this == null ? rpc.Int32Value.getDefault() : (rpc.Int32Value()..setField(1, this!));
}

/// User-facing message mapping for RPC failures — the single copy shared by the message
/// controllers (the grpc-era `GrpcErrorX.detail` existed in two identical copies; consolidated
/// here).
extension ConnectExceptionX on ConnectException {
  String detail(String caption) {
    for (final detail in details) {
      // Typed google.rpc error details arrive as raw `Any` payloads (type + bytes); log their
      // presence for diagnostics (the grpc-era code decoded `DebugInfo` — connect-dart exposes
      // details untyped).
      developer.log(
        detail.debug != null ? '${detail.type}: ${detail.debug}' : detail.type,
        name: 'ConnectException',
        error: this,
      );
    }

    return switch (code) {
      Code.unauthenticated => message.isNotEmpty ? '$caption. $message' : caption,
      Code.permissionDenied => '$caption: Permission denied',
      Code.unavailable => 'Backend unavailable. Please contact support',
      Code.aborted => '$caption: Network request aborted',
      Code.dataLoss => '$caption: Network data loss',
      Code.deadlineExceeded => 'Backend error. Please contact support',
      Code.canceled => '$caption: Network request cancelled',
      Code.internal => '$caption: $message',
      Code.failedPrecondition => '$caption: Network request failed precondition',
      Code.unknown when message.contains('CORS') => '$caption: CORS error',
      _ => '$caption: Network error: $this',
    };
  }
}
