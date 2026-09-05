import 'package:auth_app/_core/environment/model/app_environment.dart';
import 'package:auth_app/_core/message/ui_messenger.dart';
import 'package:auth_app/authentication/authenticated_scope.dart';
import 'package:auth_app/users/controller/avatar_controller.dart';
import 'package:auth_app/users/controller/users_controller.dart';
import 'package:auth_app/users/data/users_repository.dart';
import 'package:auth_model/auth_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_kit/http_kit.dart';

import '../helpers/pump_app.dart';
import '../helpers/test_dependencies.dart';

const _kUserA = AuthenticatedUser(userId: 'a7f1c8d2-0000-4000-8000-00000000000a', credentials: null);
const _kUserB = AuthenticatedUser(userId: 'a7f1c8d2-0000-4000-8000-00000000000b', credentials: null);

/// What the scope reads out of the composition root — everything else about a
/// session it builds itself.
TestDependencies _dependencies() => .new()
  ..usersRepository = const _FakeUsersRepository()
  ..messenger = UiMessenger()
  ..externalHttpClient = ApiClient(baseUrl: () => Uri.parse('https://example.invalid'))
  ..environment = AppEnvironment.development(
    version: '0.0.0',
    authService: _kUri,
    appService: _kUri,
    sentryDsn: '',
    dropDatabase: false,
    databaseName: 'test',
    inMemoryDatabase: true,
    s3Url: 'https://s3.invalid',
  );

final Uri _kUri = Uri.parse('https://example.invalid');

/// The controllers one mount of the scope created.
typedef _Session = ({UsersController users, AvatarController avatar});

void main() {
  group('AuthenticatedScope', () {
    /// Pumps the scope for [user] and returns the controllers it handed down.
    Future<_Session> pumpFor(WidgetTester tester, AuthUser user, TestDependencies dependencies) async {
      late _Session session;
      await tester.pumpApp(
        AuthenticatedScope(
          key: ValueKey<String>(switch (user) {
            AuthenticatedUser(:final userId) => userId,
            _ => '',
          }),
          authUser: user,
          builder: (context, _) => Builder(
            builder: (context) {
              session = (
                users: AuthenticatedScope.usersControllerOf(context),
                avatar: AuthenticatedScope.avatarControllerOf(context),
              );
              return const SizedBox.shrink();
            },
          ),
        ),
        dependencies: dependencies,
      );
      return session;
    }

    testWidgets('a different user gets fresh controllers and the old ones are disposed', (tester) async {
      final dependencies = _dependencies();
      addTearDown(dependencies.messenger.dispose);

      final first = await pumpFor(tester, _kUserA, dependencies);
      final second = await pumpFor(tester, _kUserB, dependencies);

      // The defect this prevents: the composition root owned these, so signing in as someone else
      // reused one AvatarController — with the previous account's cache-busting versions still in
      // it — and one UsersController still holding the previous account's list.
      expect(identical(first.users, second.users), isFalse);
      expect(identical(first.avatar, second.avatar), isFalse);
      expect(first.users.isDisposed, isTrue);
      expect(first.avatar.isDisposed, isTrue);
      expect(second.users.isDisposed, isFalse);
    });

    testWidgets('signing out disposes the session', (tester) async {
      final dependencies = _dependencies();
      addTearDown(dependencies.messenger.dispose);

      final session = await pumpFor(tester, _kUserA, dependencies);
      await pumpFor(tester, const AuthUser.unauthenticated(), dependencies);

      expect(session.users.isDisposed, isTrue);
      expect(session.avatar.isDisposed, isTrue);
    });

    testWidgets('the same user keeps the same controllers across a rebuild', (tester) async {
      final dependencies = _dependencies();
      addTearDown(dependencies.messenger.dispose);

      Future<_Session> mount() => pumpFor(tester, _kUserA, dependencies);
      final first = await mount();
      final again = await mount();

      expect(identical(first.users, again.users), isTrue, reason: 'a token refresh must not restart the session');
      expect(first.users.isDisposed, isFalse);
    });
  });
}

final class _FakeUsersRepository implements IUsersRepository {
  const _FakeUsersRepository();

  @override
  Stream<User> listUsers({ListUsersFilter? filter}) => const Stream<User>.empty();

  @override
  Stream<IUserInfo> listUsersInfo({ListUsersFilter? filter}) => Stream<IUserInfo>.fromIterable(<IUserInfo>[
    for (final id in filter?.userIds ?? const <UserId>[])
      UserInfo(id: id, name: 'User $id', email: '$id@mail.invalid', role: .user, status: .active),
  ]);

  @override
  Future<User?> createUser(CreateUserData data) async => null;

  @override
  Future<User?> updateUser(UpdateUserData data) async => null;

  @override
  Future<AvatarUploadUrl> getAvatarUploadUrl(UserId userId, String contentType, int contentSize) =>
      throw UnimplementedError();

  @override
  Future<bool> confirmAvatarUpload(UserId userId) async => true;

  @override
  Future<bool> deleteUserAvatar(UserId userId) async => true;
}
