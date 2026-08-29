import 'package:auth_app/_core/localization/localization.dart';
import 'package:auth_app/_core/message/controller/message_controller.dart';
import 'package:connectrpc/connect.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppMessageController.showConnectError localization', () {
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

    String errorTextFor(ConnectException exception, String caption) {
      final controller = AppMessageController();
      addTearDown(controller.dispose);
      controller.showConnectError(exception, caption);
      return switch (controller.state) {
        NetErrorState(:final error) => error,
        final other => fail('Expected NetErrorState, got $other'),
      };
    }

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
}
