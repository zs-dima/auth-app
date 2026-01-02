import 'package:auth_model/src/model/role/role.dart';
import 'package:auth_model/src/model/user/user_id.dart';

/// User information contract for authentication.
abstract interface class IUserInfo {
  UserId get id;
  String get name;
  String get email;
  UserRole get role;

  Map<String, dynamic> toJson();
}
