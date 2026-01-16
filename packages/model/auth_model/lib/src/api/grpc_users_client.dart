import 'dart:async';

import 'package:auth_model/src/api/grpc_authentication_converter.dart';
import 'package:auth_model/src/api/i_users_api.dart';
import 'package:auth_model/src/api/proto/users.pbgrpc.dart' as rpc;
import 'package:auth_model/src/model/user/avatar_upload_url.dart';
import 'package:auth_model/src/model/user/i_user_info.dart';
import 'package:auth_model/src/model/user/user.dart';
import 'package:auth_model/src/model/user/user_id.dart';
import 'package:fixnum/fixnum.dart';
import 'package:grpc_model/grpc_model.dart' as grpc;
import 'package:protobuf/well_known_types/google/protobuf/field_mask.pb.dart';

/// gRPC client for user management service.
class GrpcUsersClient extends grpc.GrpcClient<rpc.UserServiceClient> implements IUsersApi {
  GrpcUsersClient(super.options) : super(factory: rpc.UserServiceClient.new);

  // ===========================================================================
  // USER MANAGEMENT
  // ===========================================================================

  @override
  Stream<IUserInfo> listUsersInfo(UserId currentUserId, {ListUsersFilter? filter}) async* {
    final request = _buildListUsersRequest(currentUserId, filter);
    final users = client.listUsersInfo(request);
    yield* users.map((u) => u.toUserInfo());
  }

  @override
  Stream<User> listUsers(UserId currentUserId, {ListUsersFilter? filter}) async* {
    final request = _buildListUsersRequest(currentUserId, filter);
    final users = client.listUsers(request);
    yield* users.map((u) => u.toUser());
  }

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

    final result = await client.createUser(request);
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

    final result = await client.updateUser(request);
    return result.toUser();
  }

  @override
  Future<bool> setPassword({required UserId userId, required String password}) async {
    try {
      await client.setPassword(
        rpc.SetPasswordRequest()
          ..userId = userId.toUUID()
          ..password = password,
      );
      return true;
    } on Exception {
      return false;
    }
  }

  // ===========================================================================
  // AVATAR MANAGEMENT
  // ===========================================================================

  @override
  Future<AvatarUploadUrl> getAvatarUploadUrl(UserId userId, String contentType, int contentSize) async {
    final result = await client.getAvatarUploadUrl(
      rpc.GetAvatarUploadUrlRequest()
        ..userId = userId.toUUID()
        ..contentType = contentType
        ..contentSize = Int64(contentSize),
    );
    return AvatarUploadUrl(
      uploadUrl: result.uploadUrl,
      expiresIn: result.expiresIn.seconds.toInt(),
    );
  }

  @override
  Future<bool> confirmAvatarUpload(UserId userId) async {
    try {
      await client.confirmAvatarUpload(rpc.ConfirmAvatarUploadRequest()..userId = userId.toUUID());
      return true;
    } on Exception {
      return false;
    }
  }

  @override
  Future<bool> deleteUserAvatar(UserId userId) async {
    try {
      await client.deleteAvatar(rpc.DeleteAvatarRequest()..userId = userId.toUUID());
      return true;
    } on Exception {
      return false;
    }
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
