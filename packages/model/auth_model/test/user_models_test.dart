import 'package:auth_model/auth_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PII redaction in toString (redact-at-source)', () {
    test('User.toString masks name/email/phone and keeps non-PII fields', () {
      const user = User(
        id: 'user-1',
        name: 'Alice Example',
        email: 'alice@example.com',
        role: .user,
        status: .active,
        phone: '+15551234567',
      );

      final rendered = user.toString();

      expect(rendered, contains('***'));
      expect(rendered, isNot(contains('Alice')), reason: 'name is PII and must not reach logs/Sentry');
      expect(rendered, isNot(contains('alice@example.com')), reason: 'email is PII');
      expect(rendered, isNot(contains('5551234567')), reason: 'phone is PII');
      expect(rendered, contains('user-1'), reason: 'the pseudonymous id stays for diagnostics');
      expect(rendered, contains('active'));
    });

    test('UserInfo.toString masks name/email/phone and keeps non-PII fields', () {
      const info = UserInfo(
        id: 'user-2',
        name: 'Bob Example',
        email: 'bob@example.com',
        role: .admin,
        status: .active,
        phone: '+15557654321',
      );

      final rendered = info.toString();

      expect(rendered, contains('***'));
      expect(rendered, isNot(contains('Bob')));
      expect(rendered, isNot(contains('bob@example.com')));
      expect(rendered, isNot(contains('5557654321')));
      expect(rendered, contains('user-2'));
      expect(rendered, contains('admin'));
    });
  });
}
