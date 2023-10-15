import 'package:auth_model/auth_model.dart';

abstract class IUserInfo {
  UserId get id;
  String get name;
  String get email;
  UserRole get role;
  String? get blurhash;

  Map<String, dynamic> toJson();
}
