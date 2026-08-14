import 'package:core_model/core_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CancelToken', () {
    test('starts uncancelled with no reason and no linked children', () {
      final token = CancelToken();
      expect(token.isCancelled, isFalse);
      expect(token.reason, isNull);
      expect(token.debugLinkedCount, isZero);
    });

    test('cancel completes whenCancel and records the reason', () async {
      final token = CancelToken();
      final cancelled = token.whenCancel;
      token.cancel('logout');
      await expectLater(cancelled, completes);
      expect(token.isCancelled, isTrue);
      expect(token.reason, equals('logout'));
    });

    test('cancel is idempotent — a second cancel does not overwrite the reason', () {
      final token = CancelToken()
        ..cancel('first')
        ..cancel('second');
      expect(token.reason, equals('first'));
    });

    test('link cancels children transitively with the same reason', () {
      final session = CancelToken();
      final request = CancelToken();
      final subRequest = CancelToken();
      session.link(request);
      request.link(subRequest);

      session.cancel('logout');

      expect(request.isCancelled, isTrue);
      expect(subRequest.isCancelled, isTrue);
      expect(request.reason, equals('logout'));
      expect(subRequest.reason, equals('logout'));
    });

    test('the unlink callback detaches the child so it survives a later cancel', () {
      final session = CancelToken();
      final request = CancelToken();
      final unlink = session.link(request);
      expect(session.debugLinkedCount, equals(1));

      unlink();
      expect(session.debugLinkedCount, isZero);

      session.cancel();
      expect(request.isCancelled, isFalse);
    });

    test('linking to an already-cancelled token cancels the child immediately with the parent reason', () {
      final session = CancelToken()..cancel('logout');
      final request = CancelToken();
      final unlink = session.link(request);

      expect(request.isCancelled, isTrue);
      expect(request.reason, equals('logout'));
      expect(session.debugLinkedCount, isZero);
      expect(unlink, returnsNormally); // no-op unlink
    });

    test('cancel releases the linked children set (no retention after cascade)', () {
      final session = CancelToken()
        ..link(CancelToken())
        ..link(CancelToken());
      expect(session.debugLinkedCount, equals(2));

      session.cancel();
      expect(session.debugLinkedCount, isZero);
    });
  });
}
