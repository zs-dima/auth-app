// Shared test harness, meant to be imported by tests — public members are the point.
// ignore_for_file: avoid-top-level-members-in-tests

import 'package:auth_app/_core/model/dependencies.dart';

/// [Dependencies] for widget/unit tests: assign only the fields the test needs.
///
/// Every field of [Dependencies] is `late final`, so reading an unassigned one fails fast
/// with a named error ("Field 'x' has not been initialized") — no stubbing boilerplate,
/// and assignments stay type-checked:
///
/// ```dart
/// final dependencies = TestDependencies()..usersRepository = fakeUsersRepository;
/// await tester.pumpApp(const UsersScreen(), dependencies: dependencies);
/// ```
final class TestDependencies extends Dependencies {}
