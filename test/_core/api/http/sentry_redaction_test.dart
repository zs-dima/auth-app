import 'package:auth_app/_core/api/_core/sentry_redaction.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('redactSensitiveHeaders', () {
    test('replaces credential-bearing header values with <redacted>', () {
      final redacted = redactSensitiveHeaders(<String, String>{
        'Authorization': 'Bearer secret-access',
        'X-CSRF-Token': 'secret-refresh',
        'Cookie': 'sid=abc',
        'Content-Type': 'application/json',
        'X-Trace-Id': 'trace-123',
      });

      expect(redacted['Authorization'], '<redacted>');
      expect(redacted['X-CSRF-Token'], '<redacted>');
      expect(redacted['Cookie'], '<redacted>');
      // Non-sensitive headers pass through unchanged.
      expect(redacted['Content-Type'], 'application/json');
      expect(redacted['X-Trace-Id'], 'trace-123');
    });

    test('matches header names case-insensitively', () {
      final redacted = redactSensitiveHeaders(<String, String>{'authorization': 'Bearer x'});
      expect(redacted['authorization'], '<redacted>');
    });
  });

  group('redactSensitiveQuery', () {
    test('redacts sensitive-named values, preserves others and multi-value params', () {
      final redacted = redactSensitiveQuery(<String, List<String>>{
        'token': ['secret'],
        'access_token': ['secret2'],
        'page': ['2'],
        'id': ['1', '2'], // multi-value preserved
      });

      expect(redacted['token'], ['<redacted>']);
      expect(redacted['access_token'], ['<redacted>']);
      expect(redacted['page'], ['2']);
      expect(redacted['id'], ['1', '2']);
    });

    test('matches query names case-insensitively', () {
      final redacted = redactSensitiveQuery(<String, List<String>>{
        'Access_Token': ['x'],
      });
      expect(redacted['Access_Token'], ['<redacted>']);
    });
  });
}
