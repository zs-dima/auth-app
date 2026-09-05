import 'package:auth_app/_core/localization/localization.dart';
import 'package:auth_app/_core/log/telemetry.dart';
import 'package:auth_app/_core/message/user_facing_error.dart';
import 'package:auth_model/auth_model.dart' show RequestSessionEndedException, RpcException, RpcException$Cancelled;
import 'package:connectrpc/connect.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_kit/http_kit.dart';

/// Loads the sheets for [locale], which is what `describeError` reads through
/// `Localization.currentErrors`. The capture is process-wide and survives the
/// test that set it, so any test asserting on wording must pump its own locale.
Future<void> pumpLocale(WidgetTester tester, Locale locale) async {
  await tester.pumpWidget(
    MaterialApp(
      locale: locale,
      localizationsDelegates: Localization.localizationDelegates,
      supportedLocales: Localization.supportedLocales,
      home: const SizedBox.shrink(),
    ),
  );
  await tester.pump();
}

void main() {
  group('describeError — Connect localization', () {
    String errorTextFor(ConnectException exception, String caption) =>
        describeError(exception, caption: caption)?.text ?? fail('Expected a described error');

    testWidgets('standalone codes render the localized sentence (ru)', (tester) async {
      await pumpLocale(tester, const Locale('ru'));
      expect(
        errorTextFor(ConnectException(.unavailable, ''), 'Sign in failed'),
        equals('Сервер недоступен. Свяжитесь со службой поддержки'),
      );
    });

    testWidgets('suffix codes compose caption + localized text (ru)', (tester) async {
      await pumpLocale(tester, const Locale('ru'));
      expect(
        errorTextFor(ConnectException(.permissionDenied, ''), 'Sign in failed'),
        equals('Sign in failed: Доступ запрещён'),
      );
    });

    testWidgets('server-provided message passes through untranslated (ru)', (tester) async {
      await pumpLocale(tester, const Locale('ru'));
      expect(
        errorTextFor(ConnectException(.unauthenticated, 'Invalid credentials'), 'Sign in failed'),
        equals('Sign in failed. Invalid credentials'),
      );
    });

    testWidgets('english locale keeps the legacy detail() wording', (tester) async {
      await pumpLocale(tester, const Locale('en'));
      expect(
        errorTextFor(ConnectException(.unavailable, ''), 'Sign in failed'),
        equals('Backend unavailable. Please contact support'),
      );
      expect(
        errorTextFor(ConnectException(.aborted, ''), 'Sign in failed'),
        equals('Sign in failed: Network request aborted'),
      );
    });
  });

  group('describeError — severity', () {
    // The rule the rework exists for: a condition the user or the network can resolve is a
    // warning, and only a warning is kept out of the crash reporter's issue stream.
    test('a network condition is a warning, a protocol violation is an error', () {
      expect(describeError(ConnectException(.unavailable, ''), caption: 'x')?.level, LogLevel.warn);
      expect(describeError(ConnectException(.deadlineExceeded, ''), caption: 'x')?.level, LogLevel.warn);
      expect(describeError(ConnectException(.unauthenticated, ''), caption: 'x')?.level, LogLevel.warn);
      expect(describeError(ConnectException(.internal, ''), caption: 'x')?.level, LogLevel.error);
      expect(describeError(ConnectException(.unimplemented, ''), caption: 'x')?.level, LogLevel.error);
      expect(describeError(ConnectException(.dataLoss, ''), caption: 'x')?.level, LogLevel.error);
    });

    test('a refusal the server answered belongs to the user, not to the issue list', () {
      // These are answers, not faults: the address is taken, the record is gone, this account may
      // not do that. Filing an issue for each filled the tracker with other people's typing.
      for (final code in <Code>[
        .invalidArgument,
        .alreadyExists,
        .notFound,
        .permissionDenied,
        .failedPrecondition,
        .outOfRange,
        .aborted,
      ]) {
        expect(
          describeError(ConnectException(code, ''), caption: 'x')?.level,
          LogLevel.warn,
          reason: '$code must not reach the crash reporter',
        );
      }
    });

    test('an expired capability on a presigned upload is a race, not a defect', () {
      const expired = ApiClientException$Request(code: 'forbidden', message: 'nope', statusCode: 403);
      const unauthorized = ApiClientException$Request(code: 'unauthorized', message: 'nope', statusCode: 401);
      expect(describeError(expired, caption: 'x')?.level, LogLevel.warn);
      expect(describeError(unauthorized, caption: 'x')?.level, LogLevel.warn);
    });

    test('the level can be overridden by a caller that owns the error type', () {
      // A file the platform codec cannot decode is the user's file, not our defect.
      final described = describeError(const FormatException('bad'), caption: 'Cannot read that image');
      expect(described?.level, LogLevel.error, reason: 'unclassified, so a defect by default');
    });

    test('transient and server HTTP statuses are warnings, client mistakes are errors', () {
      const down = ApiClientException$Server(code: 'server', message: 'down', statusCode: 503);
      const throttled = ApiClientException$Request(code: 'rate_limited', message: 'slow down', statusCode: 429);
      const malformed = ApiClientException$Request(code: 'bad_request', message: 'nope', statusCode: 400);
      expect(describeError(down, caption: 'x')?.level, LogLevel.warn);
      expect(describeError(throttled, caption: 'x')?.level, LogLevel.warn);
      expect(describeError(malformed, caption: 'x')?.level, LogLevel.error);
    });

    test('an unclassified failure keeps the caption and reports', () {
      final described = describeError(StateError('boom'), caption: 'Failed to save');
      expect(described?.text, 'Failed to save');
      expect(described?.level, LogLevel.error);
    });

    testWidgets('with no caption the localized type sentence is used', (tester) async {
      await pumpLocale(tester, const Locale('en'));
      expect(describeError(const FormatException('bad'))?.text, 'Invalid format');

      await pumpLocale(tester, const Locale('ru'));
      expect(describeError(const FormatException('bad'))?.text, 'Неверный формат');
    });
  });

  group('describeError — expected teardown says nothing', () {
    // refresh_token.md §13: the user's own sign-out aborts in-flight calls, and none of them may
    // produce a toast or an issue.
    test('a cancelled call and an ended session are silent', () {
      expect(describeError(const RequestSessionEndedException(), caption: 'x'), isNull);
      expect(describeError(ConnectException(.canceled, 'aborted'), caption: 'x'), isNull);
      expect(describeError(const ApiClientException$Cancelled(), caption: 'x'), isNull);
    });

    // The shape a cancelled RPC actually arrives in: `guardRpcCall`/`guardRpcStream` map every
    // ConnectException to the domain family (A8), so the bare type above is never what a screen
    // sees. Matching only it left "…: canceled" on screen after a sign-out.
    test('the DOMAIN-mapped cancellation is silent too', () {
      final cancelled = RpcException.from(ConnectException(.canceled, 'aborted'));

      expect(cancelled, isA<RpcException$Cancelled>(), reason: 'the guards map it to this type');
      expect(describeError(cancelled, caption: 'Failed to load users'), isNull);
    });
  });
}
