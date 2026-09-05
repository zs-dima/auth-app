import 'dart:async';

import 'package:auth_model/src/api/i_users_api.dart';
import 'package:auth_model/src/connect/authentication_converter.dart';
import 'package:auth_model/src/connect/call_guard.dart';
import 'package:auth_model/src/model/user/avatar_upload_url.dart';
import 'package:auth_model/src/model/user/i_user_info.dart';
import 'package:auth_model/src/model/user/user.dart';
import 'package:auth_model/src/model/user/user_id.dart';
import 'package:auth_model/src/proto/core/v1/uuid_x.dart';
import 'package:auth_model/src/proto/users/v1/users.connect.client.dart' as rpc;
import 'package:auth_model/src/proto/users/v1/users.pb.dart' as rpc;
import 'package:connect_kit/connect_kit.dart';
import 'package:fixnum/fixnum.dart';

/// Connect RPC client for the user management service.
class ConnectUsersClient extends ConnectClient implements IUsersApi {
  const ConnectUsersClient(super.transport);

  /// Generated Connect client — an extension type over [transport]; construction is free.
  rpc.UserServiceClient get client => rpc.UserServiceClient(transport);

  // ===========================================================================
  // USER MANAGEMENT
  // ===========================================================================

  @override
  Stream<IUserInfo> listUsersInfo(UserId currentUserId, {ListUsersFilter? filter}) =>
      // Server-streaming: the guard applies the (generous) stream deadline so a large-but-finite
      // list isn't truncated, maps a ConnectException surfacing mid-stream to the domain
      // [RpcException] family (A8), and aborts the RPC when the consumer unsubscribes (A17).
      guardRpcStream((signal) {
        final request = _buildListUsersRequest(currentUserId, filter);
        return client.listUsersInfo(request, signal: signal).map((u) => u.toUserInfo());
      });

  @override
  Stream<User> listUsers(UserId currentUserId, {ListUsersFilter? filter}) => guardRpcStream((signal) {
    final request = _buildListUsersRequest(currentUserId, filter);
    return client.listUsers(request, signal: signal).map((u) => u.toUser());
  });

  @override
  Future<User?> createUser(CreateUserData data) async {
    final request = rpc.CreateUserRequest()
      ..name = data.name
      ..email = data.email;

    if (data.phone != null) request.phone = data.phone!;
    if (data.password != null) request.password = data.password!;
    if (data.role != null) request.role = data.role!.toProtoRole();
    if (data.locale != null) request.locale = data.locale!;
    if (data.timezone != null) request.timezone = data.timezone!;

    final result = await guardRpcCall((signal) => client.createUser(request, signal: signal));
    return result.toUser();
  }

  @override
  Future<User?> updateUser(UpdateUserData data) async {
    final request = rpc.UpdateUserRequest()
      ..userId = data.userId.toUUID()
      ..updateMask = (FieldMask()..paths.addAll(data.updateFields));

    if (data.name != null) request.name = data.name!;
    if (data.email != null) request.email = data.email!;
    if (data.phone != null) request.phone = data.phone!;
    if (data.role != null) request.role = data.role!.toProtoRole();
    if (data.status != null) request.status = data.status!.toProtoStatus();
    if (data.locale != null) request.locale = data.locale!;
    if (data.timezone != null) request.timezone = data.timezone!;

    final result = await guardRpcCall((signal) => client.updateUser(request, signal: signal));
    return result.toUser();
  }

  @override
  Future<bool> setPassword({required UserId userId, required String password}) async {
    // Throws a domain [RpcException] on a transport/server error (A4) rather than swallowing it.
    await guardRpcCall(
      (signal) => client.setPassword(
        rpc.SetPasswordRequest()
          ..userId = userId.toUUID()
          ..password = password,
        signal: signal,
      ),
    );
    return true;
  }

  // ===========================================================================
  // AVATAR MANAGEMENT
  // ===========================================================================

  @override
  Future<AvatarUploadUrl> getAvatarUploadUrl(UserId userId, String contentType, int contentSize) async {
    final result = await guardRpcCall(
      (signal) => client.getAvatarUploadUrl(
        rpc.GetAvatarUploadUrlRequest()
          ..userId = userId.toUUID()
          ..contentType = contentType
          ..contentSize = Int64(contentSize),
        signal: signal,
      ),
    );
    return AvatarUploadUrl(
      uploadUrl: result.uploadUrl,
      expiresIn: result.expiresIn.seconds.toInt(),
    );
  }

  @override
  Future<bool> confirmAvatarUpload(UserId userId) async {
    await guardRpcCall(
      (signal) =>
          client.confirmAvatarUpload(rpc.ConfirmAvatarUploadRequest()..userId = userId.toUUID(), signal: signal),
    );
    return true;
  }

  @override
  Future<bool> deleteUserAvatar(UserId userId) async {
    await guardRpcCall(
      (signal) => client.deleteAvatar(rpc.DeleteAvatarRequest()..userId = userId.toUUID(), signal: signal),
    );
    return true;
  }

  // ===========================================================================
  // PRIVATE HELPERS
  // ===========================================================================

  rpc.ListUsersRequest _buildListUsersRequest(UserId currentUserId, ListUsersFilter? filter) {
    final request = rpc.ListUsersRequest()..userId = currentUserId.toUUID();

    if (filter != null) {
      if (filter.userIds != null) {
        request.userIds.addAll(filter.userIds!.map((e) => e.toUUID()));
      }
      if (filter.statuses != null) {
        request.statuses.addAll(filter.statuses!.map((s) => s.toProtoStatus()));
      }
      if (filter.roles != null) {
        request.roles.addAll(filter.roles!.map((r) => r.toProtoRole()));
      }
      if (filter.query != null) {
        request.query = filter.query!;
      }
      if (filter.pageSize != null) {
        request.pageSize = filter.pageSize!;
      }
      if (filter.pageToken != null) {
        request.pageToken = filter.pageToken!;
      }
    }

    return request;
  }
}
