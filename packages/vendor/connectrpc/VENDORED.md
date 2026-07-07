# Vendored: connectrpc 1.0.0

Byte-for-byte copy of [`connectrpc` 1.0.0 from pub.dev](https://pub.dev/packages/connectrpc)
(the latest release; upstream `main` is unchanged since), vendored as a pub-workspace member
because the hosted package cannot be used with this workspace's `protobuf: ^6.0.0`:

1. Upstream pins `protobuf: ">=3.1.0 <5.0.0"` — an unsolvable constraint conflict.
2. Upstream's **embedded generated protos** (`lib/src/grpc/gen/**` — `google.rpc.Status` +
   `google.protobuf.Any`, used by `StatusParser` for the gRPC / gRPC-Web protocols) were generated
   with a protobuf-4-era plugin and do not compile against protobuf 6 (`BuilderInfo` signature
   change, `PbList()` constructor removal). A `dependency_overrides: protobuf` alone therefore
   fails at compile time.

The runtime APIs connectrpc actually uses (`writeToBuffer` / `mergeFromBuffer` / proto3 JSON /
`ExtensionRegistry` / `TypeRegistry`) are stable across protobuf 3→6 — pinned permanently by
`packages/model/connect_model/test/protobuf_override_spike_test.dart`.

## Delta vs upstream

- `pubspec.yaml`: version `1.0.0` → `1.0.0+protobuf6`; `protobuf` widened to `">=3.1.0 <7.0.0"`;
  upstream `dev_dependencies` removed (`conformance`/`tools` are upstream-repo path deps that don't
  exist here; `lints ^4.0.0` conflicts with the workspace's `flutter_lints 6`); `executables`
  section removed (see next point).
- `bin/` (the `protoc-gen-connect-dart` plugin) **deleted**: it carries its own protobuf-4-era
  generated descriptor/plugin protos that break workspace analysis, and code generation here uses
  the buf remote plugin (`buf.build/connectrpc/dart`) instead. For local plugin use,
  `dart pub global activate connectrpc` still works — global activation resolves its own
  (protobuf 4) dependency set independently of this workspace.
- `lib/src/grpc/gen/**` **regenerated** from the package's own `lib/src/grpc/proto/status.proto`
  (+ the `google/protobuf/any.proto` well-known type) with `buf.build/protocolbuffers/dart:v25.0.0`
  — the same plugin version this repo generates all its protos with, whose output compiles against
  protobuf 6.
- `analysis_options.yaml`: dropped the `include: package:lints/recommended.yaml` line (the `lints`
  dev-dependency is gone); everything else kept.

No `lib/` source code was modified.

## Updating

When upstream publishes a release that supports protobuf ≥6, delete this directory, remove the
`packages/vendor/connectrpc` entry from the root `pubspec.yaml` `workspace:` list, and let the
hosted `connectrpc: ^x.y.z` dependency resolve normally. Until then, to pick up an upstream patch:
re-copy the package from the pub cache and re-apply the delta above.
