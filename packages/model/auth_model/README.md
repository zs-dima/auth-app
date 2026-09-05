# auth_model

Authentication & users **domain model** and its **Connect RPC implementation**, in one cohesive package.

## Layout

```
lib/src/
  model/    # Domain models — transport-free (User, AuthResult, credentials, roles…).
            # Zero imports of connectrpc/protobuf/connect_kit. This is the heart of the package.
  api/      # Domain-typed contracts: IAuthenticationApi, IUsersApi, auth_exceptions, and the
            # RpcException family (transport-neutral error classification — A8).
            # Method signatures use only domain types — no proto/RPC types leak through.
  connect/  # The single transport implementation: Connect clients, converter, authorization
            # constant, call guards, and the auth middleware.
  proto/    # Generated protobuf messages + Connect stubs (see Code generation below).
  client/   # Transport-neutral glue: AuthenticationHandler (logout bus).
```

## Why does a "model" package depend on `connectrpc` / `connect_kit`?

By design. `auth_model` is a self-contained feature package that ships its domain **and** its only
implementation (Connect RPC). The dependency on `connectrpc`/`protobuf`/`connect_kit`/`fixnum` comes
entirely from `lib/src/connect/` + `lib/src/proto/` — the domain code (`lib/src/model/`) and the
interfaces (`lib/src/api/`) are transport-free.

We deliberately do **not** split this into a separate `auth_connect` package: there is a single
transport, the internal domain↔transport boundary is already clean (enforced by the folder layout
above), and an extra package would add boundary overhead without a real second consumer. If a second
transport ever appears, the split is mechanical — move `lib/src/connect/` into a new package that
depends on this one.

## Code generation

Proto for `auth/v1` + `users/v1` is generated into `lib/src/proto/` via
[`api/proto/buf.gen.auth.yaml`](../../../api/proto/buf.gen.auth.yaml): `*.pb.dart` messages
(protobuf plugin) plus `*.connect.client.dart` / `*.connect.spec.dart` stubs (connect-dart plugin).
`core/v1` is generated HERE, into `proto/core/v1/`, via
[`api/proto/buf.gen.core.yaml`](../../../api/proto/buf.gen.core.yaml). It used to live in
`connect_model` with re-export shims in this package; when that package became the standalone
`connect_kit` (2026-09-04) the schema stayed with its owner — a transport runtime ships no service
or message definitions. `proto/core/v1/uuid_x.dart` is hand-written: the `Guid` ↔ `UUID`
conversions belong to this schema, not to the runtime. `proto/google/protobuf/` re-exports the
well-known types bundled with `package:protobuf` (the connect plugin emits relative
`google/protobuf` imports).
