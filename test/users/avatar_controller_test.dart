import 'dart:typed_data';

import 'package:auth_app/_core/message/ui_messenger.dart';
import 'package:auth_app/users/controller/avatar_controller.dart';
import 'package:auth_app/users/controller/upload_image_controller.dart';
import 'package:auth_app/users/data/users_repository.dart';
import 'package:auth_model/auth_model.dart';
import 'package:flutter/painting.dart' show NetworkImageLoadException;
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:http_kit/http_kit.dart';

/// The avatar URL is derived from the user id alone — no request is ever spent discovering whether an
/// avatar exists. These tests pin the two properties that makes that affordable: the URL is STABLE (so
/// every cache layer keeps one entry per user) and a definitive "no avatar" answer is asked for ONCE.
void main() {
  const kUserId = 'a7f1c8d2-0000-4000-8000-000000000001';
  const kS3Url = 'https://s3.test/bucket';
  const kUrl = '$kS3Url/users/$kUserId/avatar.webp';

  group('AvatarController.getUrl', () {
    test('is stable and carries no version until this client uploads', () {
      final controller = _buildController();
      addTearDown(controller.dispose);

      expect(controller.getUrl(kUserId), equals(kUrl));
      expect(controller.getUrl(kUserId), equals(kUrl), reason: 'a second call must not mint a new URL');
    });

    test('trims a trailing slash off the configured storage URL', () {
      final controller = _buildController(s3Url: '$kS3Url/');
      addTearDown(controller.dispose);

      expect(controller.getUrl(kUserId), equals(kUrl));
    });

    test('returns null for an empty user id', () {
      final controller = _buildController();
      addTearDown(controller.dispose);

      expect(controller.getUrl(UserIdX.empty), isNull);
    });

    // S3 is optional server-side. Without a base URL the path would resolve against the app's own
    // origin, where the web build answers `index.html` with 200 and the decoder fails on every rebuild.
    test('returns null when no storage is configured', () {
      final controller = _buildController(s3Url: '');
      addTearDown(controller.dispose);

      expect(controller.getUrl(kUserId), isNull);
    });
  });

  group('AvatarController.recordLoadError', () {
    for (final status in <int>[404, 403, 204]) {
      test('stops requesting the avatar after $status', () {
        final controller = _buildController();
        addTearDown(controller.dispose);

        controller.recordLoadError(kUserId, _loadFailure(status));

        expect(controller.getUrl(kUserId), isNull);
      });
    }

    // Transient failures must not be memoized: a flaky or offline start-up would otherwise hide every
    // avatar for the rest of the session.
    for (final status in <int>[0, 500, 503]) {
      test('keeps the URL after a transient $status', () {
        final controller = _buildController();
        addTearDown(controller.dispose);

        controller.recordLoadError(kUserId, _loadFailure(status));

        expect(controller.getUrl(kUserId), equals(kUrl));
      });
    }

    test('keeps the URL for a failure that is not an image load error', () {
      final controller = _buildController();
      addTearDown(controller.dispose);

      controller.recordLoadError(kUserId, Exception('socket closed'));

      expect(controller.getUrl(kUserId), equals(kUrl));
    });

    test('records the miss only for the user that failed', () {
      const otherId = 'a7f1c8d2-0000-4000-8000-000000000002';
      final controller = _buildController();
      addTearDown(controller.dispose);

      controller.recordLoadError(kUserId, _loadFailure(404));

      expect(controller.getUrl(kUserId), isNull);
      expect(controller.getUrl(otherId), isNotNull);
    });
  });

  group('AvatarController own actions', () {
    test('delete stops requesting the avatar without waiting for a 404', () async {
      final controller = _buildController();
      addTearDown(controller.dispose);

      controller.deleteAvatar(_user(kUserId));
      await pumpEventQueue();

      expect(controller.getUrl(kUserId), isNull);
    });

    test('upload clears a recorded miss and busts caches with a fresh version', () async {
      final requests = <http.BaseRequest>[];
      final controller = _buildController(
        client: MockClient((request) async {
          requests.add(request);
          return http.Response('', 200);
        }),
      );
      addTearDown(controller.dispose);

      controller.recordLoadError(kUserId, _loadFailure(404));
      expect(controller.getUrl(kUserId), isNull);

      // A WebP under 2500 bytes short-circuits the native encoder (`image_converter_vm.dart`), so the
      // upload path runs under a plain `flutter test`.
      controller.uploadAvatar(_user(kUserId), ImageInfo(image: Uint8List(16), mimeType: 'image/webp'));
      await pumpEventQueue();

      final url = controller.getUrl(kUserId);
      expect(url, isNotNull);
      expect(url, startsWith('$kUrl?v='), reason: 'the previously cached bytes are known to be stale');
      expect(requests.single.url.toString(), equals(_kUploadUrl), reason: 'the presigned URL is used verbatim');
      expect(requests.single.headers['Content-Type'], equals('image/webp'));
    });
  });
}

const _kUploadUrl = 'https://s3.test/bucket/users/upload?X-Amz-Signature=abc';

AvatarController _buildController({String s3Url = 'https://s3.test/bucket', http.Client? client}) => .new(
  s3Url: s3Url,
  repository: const _FakeUsersRepository(),
  httpClient: ApiClient(
    baseUrl: () => Uri.parse('https://s3.test'),
    client: client ?? MockClient((_) async => http.Response('', 200)),
  ),
  messenger: UiMessenger(),
);

/// What `NetworkImage` throws for a non-2xx response, on both the io and the web decode paths.
NetworkImageLoadException _loadFailure(int statusCode) =>
    .new(statusCode: statusCode, uri: Uri.parse('https://s3.test/bucket/x.webp'));

User _user(UserId id) => .new(id: id, name: 'User $id', email: '$id@mail.com', role: .user, status: .active);

final class _FakeUsersRepository implements IUsersRepository {
  const _FakeUsersRepository();

  @override
  Stream<User> listUsers({ListUsersFilter? filter}) => const Stream<User>.empty();

  @override
  Stream<IUserInfo> listUsersInfo({ListUsersFilter? filter}) => const Stream<IUserInfo>.empty();

  @override
  Future<User?> createUser(CreateUserData data) async => null;

  @override
  Future<User?> updateUser(UpdateUserData data) async => null;

  @override
  Future<AvatarUploadUrl> getAvatarUploadUrl(UserId userId, String contentType, int contentSize) async =>
      const AvatarUploadUrl(uploadUrl: _kUploadUrl, expiresIn: 300);

  @override
  Future<bool> confirmAvatarUpload(UserId userId) async => true;

  @override
  Future<bool> deleteUserAvatar(UserId userId) async => true;
}
