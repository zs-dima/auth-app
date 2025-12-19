import 'package:auth_model/auth_model.dart';

/// User information contract for authentication.
abstract interface class IUserInfo {
  UserId get id;
  String get name;
  String get email;
  UserRole get role;
  String? get blurhash;

  Map<String, dynamic> toJson();
}
