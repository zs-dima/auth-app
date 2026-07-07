// Static proxy (not generated): the connect-dart codegen emits relative `google/protobuf/*`
// imports, while the message codegen (`*.pb.dart`) uses the WKTs bundled with package:protobuf.
// Re-exporting the bundled type here keeps a single `Empty` type identity across both.
export 'package:protobuf/well_known_types/google/protobuf/empty.pb.dart';
