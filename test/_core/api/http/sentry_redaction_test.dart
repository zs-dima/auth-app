import 'package:auth_app/_core/api/_core/sentry_redaction.dart';
import 'package:flutter_test/flutter_test.dart';

/// The `<redacted>` mask `redactSensitive*` writes in place of a secret, as a header value and as a
/// single-element query value.
final _isMasked = equals('<redacted>');
final _isMaskedList = equals(<String>['<redacted>']);

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

      expect(redacted['Authorization'], _isMasked);
      expect(redacted['X-CSRF-Token'], _isMasked);
      expect(redacted['Cookie'], _isMasked);
      // Non-sensitive headers pass through unchanged.
      expect(redacted['Content-Type'], equals('application/json'));
      expect(redacted['X-Trace-Id'], equals('trace-123'));
    });

    test('matches header names case-insensitively', () {
      final redacted = redactSensitiveHeaders(<String, String>{'authorization': 'Bearer x'});
      expect(redacted['authorization'], _isMasked);
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

      expect(redacted['token'], _isMaskedList);
      expect(redacted['access_token'], _isMaskedList);
      expect(redacted['page'], equals(['2']));
      expect(redacted['id'], equals(['1', '2']));
    });

    test('matches query names case-insensitively', () {
      final redacted = redactSensitiveQuery(<String, List<String>>{
        'Access_Token': ['x'],
      });
      expect(redacted['Access_Token'], _isMaskedList);
    });

    test('redacts AWS SigV4 presigned-URL material', () {
      final redacted = redactSensitiveQuery(<String, List<String>>{
        'X-Amz-Signature': ['deadbeef'],
        'X-Amz-Credential': ['AKIA123/20260703/us-east-1/s3/aws4_request'],
        'X-Amz-Security-Token': ['sts-secret'],
        'X-Amz-Expires': ['900'], // public metadata — preserved
      });

      expect(redacted['X-Amz-Signature'], _isMaskedList);
      expect(redacted['X-Amz-Credential'], _isMaskedList);
      expect(redacted['X-Amz-Security-Token'], _isMaskedList);
      expect(redacted['X-Amz-Expires'], equals(['900']));
    });
  });

  group('redactSensitiveUrl', () {
    test('masks presigned-URL secrets while preserving scheme/host/path and public params', () {
      final url = Uri.parse(
        'https://bucket.s3.example.com/avatars/u-1.png'
        '?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIA123%2Fscope'
        '&X-Amz-Signature=deadbeef&X-Amz-Expires=900',
      );

      final redacted = redactSensitiveUrl(url);

      expect(redacted, isNot(contains('deadbeef')));
      expect(redacted, isNot(contains('AKIA123')));
      // The marker is percent-encoded by Uri.replace ('%3Credacted%3E') — assert encoding-agnostically.
      expect(redacted, contains('redacted'));
      expect(redacted, contains('https://bucket.s3.example.com/avatars/u-1.png'));
      expect(redacted, contains('X-Amz-Algorithm=AWS4-HMAC-SHA256'));
      expect(redacted, contains('X-Amz-Expires=900'));
    });

    test('returns a query-less URL unchanged', () {
      final url = Uri.parse('https://api.example.com/v2/users');
      expect(redactSensitiveUrl(url), equals(url.toString()));
    });
  });
}
