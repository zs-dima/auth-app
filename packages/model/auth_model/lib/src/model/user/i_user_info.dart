import 'package:auth_model/src/model/role/role.dart';
import 'package:auth_model/src/model/user/user.dart';
import 'package:auth_model/src/model/user/user_id.dart';

/// User information contract for authentication.
abstract interface class IUserInfo {
  UserId get id;
  String get name;
  String get email;
  String? get phone;
  UserRole get role;
  UserStatus get status;
  String? get avatarUrl;
  String? get locale;
  String? get timezone;

  Map<String, dynamic> toJson();
}
