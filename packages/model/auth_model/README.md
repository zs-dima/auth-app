# auth_model

Authentication & users **domain model** and its **Connect RPC implementation**, in one cohesive package.

## Layout

```
lib/src/
  model/    # Domain models — transport-free (User, AuthResult, credentials, roles…).
            # Zero imports of connectrpc/protobuf/connect_model. This is the heart of the package.
  api/      # Domain-typed contracts: IAuthenticationApi, IUsersApi, auth_exceptions, and the
            # RpcException family (transport-neutral error classification — A8).
            # Method signatures use only domain types — no proto/RPC types leak through.
  connect/  # The single transport implementation: Connect clients, converter, authorization
            # constant, call guards, and the auth middleware.
  proto/    # Generated protobuf messages + Connect stubs (see Code generation below).
  client/   # Transport-neutral glue: AuthenticationHandler (logout bus).
```

## Why does a "model" package depend on `connectrpc` / `connect_model`?

By design. `auth_model` is a self-contained feature package that ships its domain **and** its only
implementation (Connect RPC). The dependency on `connectrpc`/`protobuf`/`connect_model`/`fixnum` comes
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
The shared `core/v1` types are a single source of truth in `connect_model`; the copies under
`proto/core/v1/` are thin re-export shims to it, and `proto/google/protobuf/` re-exports the
well-known types bundled with `package:protobuf` (the connect plugin emits relative
`google/protobuf` imports).
