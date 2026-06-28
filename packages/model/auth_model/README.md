# auth_model

Authentication & users **domain model** and its **gRPC implementation**, in one cohesive package.

## Layout

```
lib/src/
  model/    # Domain models — transport-free (User, AuthResult, credentials, roles…).
            # Zero imports of grpc/protobuf/grpc_model. This is the heart of the package.
  api/      # Domain-typed contracts: IAuthenticationApi, IUsersApi, auth_exceptions.
            # Method signatures use only domain types — no proto/gRPC types leak through.
  grpc/     # The single transport implementation: gRPC clients, converter, exceptions,
            # call guard, auth middleware, and the generated proto (grpc/proto/**).
  client/   # Transport-neutral glue: AuthenticationHandler (logout bus), credentials callbacks.
```

## Why does a "model" package depend on `grpc` / `grpc_model`?

By design. `auth_model` is a self-contained feature package that ships its domain **and** its only
implementation (gRPC). The dependency on `grpc`/`protobuf`/`grpc_model`/`fixnum` comes entirely from
`lib/src/grpc/` — the domain code (`lib/src/model/`) and the interfaces (`lib/src/api/`) are
transport-free.

We deliberately do **not** split this into a separate `auth_grpc` package: there is a single transport,
the internal domain↔transport boundary is already clean (enforced by the folder layout above), and an
extra package would add boundary overhead without a real second consumer. If a second transport ever
appears, the split is mechanical — move `lib/src/grpc/` into a new package that depends on this one.

## Code generation

Proto for `auth/v2` + `users/v2` is generated into `lib/src/grpc/proto/` via
[`api/proto/buf.gen.auth.yaml`](../../../api/proto/buf.gen.auth.yaml). The shared `core/v2` types are a
single source of truth in `grpc_model`; the copies under `grpc/proto/core/v2/` are thin re-export shims
to it.
