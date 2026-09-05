import 'package:auth_app/_core/localization/localization.dart';
import 'package:auth_app/initialization/widget/error_box.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// What takes the place of a widget that threw while building.
///
/// The framework default is the red box with the exception text on it — exactly right in debug
/// and exactly wrong in release: it turns one broken row of the panel grid into a screen that
/// looks like a crash, and it prints internal detail onto the user's screen and into the
/// screenshot they attach to a support mail.
///
/// Every test runs in debug, so what is assertable here is the debug half plus the shape of the
/// release box: no text, a real semantics label, and bounds that survive an unbounded axis.
void main() {
  testWidgets('in debug it is still the framework box, with the exception on it', (tester) async {
    await tester.pumpWidget(
      MaterialApp(home: buildAppErrorWidget(FlutterErrorDetails(exception: StateError('boom')))),
    );

    expect(find.byType(ErrorWidget), findsOneWidget);
  });

  testWidgets('the release box carries a label but no words of its own', (tester) async {
    // Pumped directly: `buildAppErrorWidget` picks the debug branch under test, and what is worth
    // pinning is the box it would return in release.
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: ReleaseErrorBox())));

    expect(find.byType(Text), findsNothing, reason: 'the words of an exception are not for a user');
    expect(
      find.bySemanticsLabel('Content unavailable'),
      findsOneWidget,
      reason: 'a screen reader is the one place where the words are all there is',
    );
  });

  testWidgets('it fits inside an unbounded axis instead of taking the screen', (tester) async {
    // An `ErrorWidget` replaces a widget wherever it was — including inside a Row or a ListView,
    // where one axis has no bound. `LimitedBox` is what keeps that from throwing.
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Row(
            children: <Widget>[ReleaseErrorBox()],
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(tester.getSize(find.byType(ReleaseErrorBox)).width, lessThanOrEqualTo(160));
  });

  testWidgets('the label is the localized sentence when a bucket has loaded', (tester) async {
    Localization.debugSetCurrent(errors: await ErrorsLocalization.delegate.load(Locales.en));
    addTearDown(Localization.debugSetCurrent);

    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: ReleaseErrorBox())));

    expect(find.bySemanticsLabel(Localization.currentErrors!.somethingWentWrong), findsOneWidget);
  });
}
