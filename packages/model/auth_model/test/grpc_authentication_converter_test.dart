import 'package:auth_model/src/grpc/grpc_authentication_converter.dart';
import 'package:auth_model/src/model/role/role.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grpc_model/grpc_model.dart' as core;

void main() {
  group('proto <-> domain role mapping (A11 — privilege-correctness path)', () {
    test('maps each known role both directions', () {
      expect(core.UserRole.USER_ROLE_ADMIN.toRole(), UserRole.admin);
      expect(core.UserRole.USER_ROLE_USER.toRole(), UserRole.user);
      expect(core.UserRole.USER_ROLE_GUEST.toRole(), UserRole.guest);

      expect(UserRole.admin.toProtoRole(), core.UserRole.USER_ROLE_ADMIN);
      expect(UserRole.user.toProtoRole(), core.UserRole.USER_ROLE_USER);
      expect(UserRole.guest.toProtoRole(), core.UserRole.USER_ROLE_GUEST);
    });

    test('an unknown/unspecified proto role degrades to the least-privileged guest', () {
      expect(core.UserRole.USER_ROLE_UNSPECIFIED.toRole(), UserRole.guest);
    });
  });
}
