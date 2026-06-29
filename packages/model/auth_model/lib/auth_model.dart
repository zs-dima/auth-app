library auth_model;

// ── Interfaces (domain-typed contracts) + domain exception ───────────────────
export 'src/api/auth_exceptions.dart';
export 'src/api/i_authentication_api.dart';
export 'src/api/i_users_api.dart';
// ── Transport-neutral glue ───────────────────────────────────────────────────
export 'src/client/authentication_handler.dart';
// ── gRPC transport ───────────────────────────────────────────────────────────
export 'src/grpc/grpc_authentication_client.dart';
export 'src/grpc/grpc_exceptions.dart';
export 'src/grpc/grpc_users_client.dart';
export 'src/grpc/middlewares/grpc_authentication_middleware.dart';
// ── Domain models (transport-free) ───────────────────────────────────────────
export 'src/model/credentials/access_credentials.dart';
export 'src/model/credentials/access_token.dart';
export 'src/model/credentials/auth_result.dart';
export 'src/model/credentials/refresh_token.dart';
export 'src/model/credentials/sign_in_data.dart';
export 'src/model/role/role.dart';
export 'src/model/user/auth_user.dart';
export 'src/model/user/avatar_upload_url.dart';
export 'src/model/user/i_user_info.dart';
export 'src/model/user/user.dart';
export 'src/model/user/user_id.dart';
export 'src/model/user/user_info.dart';
// ── REST/HTTP transport (auth middleware; clients live in the consuming app) ──
export 'src/rest/middlewares/rest_authentication_middleware.dart';
