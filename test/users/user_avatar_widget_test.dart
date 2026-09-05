import 'dart:async';
import 'dart:io';

import 'package:auth_app/_core/environment/model/app_environment.dart';
import 'package:auth_app/_core/message/ui_messenger.dart';
import 'package:auth_app/authentication/authenticated_scope.dart';
import 'package:auth_app/users/controller/avatar_controller.dart';
import 'package:auth_app/users/data/users_repository.dart';
import 'package:auth_app/users/widget/user_avatar_widget.dart';
import 'package:auth_model/auth_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_kit/http_kit.dart';

import '../helpers/pump_app.dart';
import '../helpers/test_dependencies.dart';

const _kUserId = 'a7f1c8d2-0000-4000-8000-00000000000a';
const _kUser = AuthenticatedUser(userId: _kUserId, credentials: null);
const _kInfo = UserInfo(id: _kUserId, name: 'John Doe', email: 'jd@mail.invalid', role: .user, status: .active);

/// A user whose avatar object does not exist answers 404 — the expected negative result of reading an
/// avatar by user id. These tests pin that it costs exactly ONE request per session, and that a
/// transient failure stays retryable.
void main() {
  group('UserAvatarWidget', () {
    testWidgets('asks for a missing avatar once, then renders the initials for free', (tester) async {
      final client = _FakeHttpClient(statusCode: HttpStatus.notFound);
      debugNetworkImageHttpClientProvider = () => client;
      // Reset here, not in `addTearDown`: the binding asserts every painting debug variable is unset
      // as soon as the test body returns, which happens before test-package tear-downs run.
      try {
        final generation = ValueNotifier<int>(0);
        addTearDown(generation.dispose);
        final avatar = await _pumpAvatar(tester, generation);

        expect(find.text('JD'), findsOneWidget, reason: 'the initials are the fallback');
        expect(client.requestCount, equals(1));
        expect(avatar.getUrl(_kUserId), isNull, reason: 'the miss is remembered');

        // A brand-new widget for the same user: a list recycling its tiles, or coming back to a screen.
        // Flutter never caches a failed load, so without the remembered miss this would refetch.
        generation.value = 1;
        await tester.pumpAndSettle();

        expect(find.text('JD'), findsOneWidget);
        expect(client.requestCount, equals(1), reason: 'a known-missing avatar is never requested again');
      } finally {
        debugNetworkImageHttpClientProvider = null;
      }
    });

    // The avatar used to be `CircleAvatar.foregroundImage`, which sized itself. It is now an `Image`
    // inside the circle, so its geometry is this widget's responsibility and is pinned here.
    testWidgets('covers the whole circle while the initials stay underneath', (tester) async {
      final gate = Completer<void>();
      final client = _FakeHttpClient(statusCode: HttpStatus.notFound, gate: gate.future);
      debugNetworkImageHttpClientProvider = () => client;
      try {
        final generation = ValueNotifier<int>(0);
        addTearDown(generation.dispose);
        await _pumpAvatar(tester, generation);

        // `size` is the RADIUS, so a 16 avatar is a 32-logical-pixel circle.
        expect(tester.getSize(find.byType(ClipOval)), equals(const Size(32, 32)));
        expect(find.text('JD'), findsOneWidget);

        // Let the held request finish, so the test never ends with one in flight.
        gate.complete();
        await tester.pumpAndSettle();
      } finally {
        debugNetworkImageHttpClientProvider = null;
      }
    });

    testWidgets('keeps retrying after a transient failure', (tester) async {
      final client = _FakeHttpClient(statusCode: HttpStatus.serviceUnavailable);
      debugNetworkImageHttpClientProvider = () => client;
      try {
        final generation = ValueNotifier<int>(0);
        addTearDown(generation.dispose);
        final avatar = await _pumpAvatar(tester, generation);

        expect(find.text('JD'), findsOneWidget);
        expect(avatar.getUrl(_kUserId), isNotNull, reason: 'a 5xx says nothing about the avatar existing');

        generation.value = 1;
        await tester.pumpAndSettle();

        expect(client.requestCount, equals(2), reason: 'the next widget retries');
      } finally {
        debugNetworkImageHttpClientProvider = null;
      }
    });
  });
}

/// Mounts one avatar inside a session scope and returns that session's controller.
///
/// [generation] keys the avatar, so bumping it mounts a completely fresh widget while the scope — and
/// therefore the controller holding the remembered miss — stays alive.
Future<AvatarController> _pumpAvatar(WidgetTester tester, ValueNotifier<int> generation) async {
  final dependencies = _dependencies();
  addTearDown(dependencies.messenger.dispose);

  late AvatarController avatar;
  await tester.pumpApp(
    AuthenticatedScope(
      authUser: _kUser,
      builder: (context, _) => Builder(
        builder: (context) {
          avatar = AuthenticatedScope.avatarControllerOf(context);
          return ValueListenableBuilder<int>(
            valueListenable: generation,
            builder: (_, value, __) => UserAvatarWidget(key: ValueKey<int>(value), user: _kInfo, size: 16),
          );
        },
      ),
    ),
    dependencies: dependencies,
  );
  await tester.pumpAndSettle();
  return avatar;
}

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
    s3Url: 'https://s3.invalid/bucket',
  );

final Uri _kUri = Uri.parse('https://example.invalid');

/// The narrowest client `NetworkImage` needs to reach its non-200 throw: it opens the GET, closes the
/// request and drains the body before failing (`_network_image_io.dart`). Nothing else is touched,
/// because the avatar image carries no custom headers.
final class _FakeHttpClient extends Fake implements HttpClient {
  _FakeHttpClient({required this.statusCode, this.gate});

  final int statusCode;

  /// When set, the response waits for it — which holds a request in flight so the loading state stays
  /// on screen long enough to be inspected.
  final Future<void>? gate;
  int requestCount = 0;

  @override
  Future<HttpClientRequest> getUrl(Uri url) async {
    requestCount++;
    return _FakeHttpClientRequest(statusCode, gate);
  }
}

final class _FakeHttpClientRequest extends Fake implements HttpClientRequest {
  _FakeHttpClientRequest(this.statusCode, this.gate);

  final int statusCode;
  final Future<void>? gate;

  @override
  Future<HttpClientResponse> close() async {
    await gate;
    return _FakeHttpClientResponse(statusCode);
  }
}

final class _FakeHttpClientResponse extends Fake implements HttpClientResponse {
  _FakeHttpClientResponse(this.statusCode);

  @override
  final int statusCode;

  // `drain` is a Stream instance method, so `implements HttpClientResponse` does not inherit it.
  @override
  Future<E> drain<E>([E? futureValue]) async => futureValue ?? futureValue as E;
}

final class _FakeUsersRepository implements IUsersRepository {
  const _FakeUsersRepository();

  @override
  Stream<User> listUsers({ListUsersFilter? filter}) => const Stream<User>.empty();

  @override
  Stream<IUserInfo> listUsersInfo({ListUsersFilter? filter}) => Stream<IUserInfo>.fromIterable(<IUserInfo>[
    for (final id in filter?.userIds ?? const <UserId>[]) _kInfo.copyWith(id: id),
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
