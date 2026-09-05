import 'package:auth_model/src/proto/core/v1/core.pb.dart';
// `Guid` and `GuidNullX.isNull` both come from here (it re-exports the core_model types it uses).
// A second `isNull` on `Guid?` in this file would make every `.isNull` in anything importing both
// an `ambiguous_extension_member_access` error.
import 'package:connect_kit/connect_kit.dart';

/// Conversions between a [Guid] and the wire's [UUID] message.
///
/// They live here rather than in the transport package because the message is this schema's, not
/// the runtime's.
extension GuidRpcX on Guid? {
  /// The wire message for this id; an empty message when there is none.
  UUID toUUID() => this == null ? UUID() : (UUID()..value = this!);
}

/// The [Guid] behind a wire [UUID].
extension UuidRpcX on UUID {
  /// The id as a string, or the nil UUID when the message is empty.
  Guid toId() => value.isNull ? GuidX.nil : value;

  /// Whether the message carries no id.
  bool get isNull => toId().isNull;
}
