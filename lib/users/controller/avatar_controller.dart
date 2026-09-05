import 'package:auth_app/_core/log/telemetry.dart';
import 'package:auth_app/_core/message/ui_messenger.dart';
import 'package:auth_app/_core/message/user_facing_error.dart';
import 'package:auth_app/users/controller/platform/image_converter.dart';
import 'package:auth_app/users/controller/upload_image_controller.dart';
import 'package:auth_app/users/data/users_repository.dart';
import 'package:auth_model/auth_model.dart';
import 'package:control/control.dart';
import 'package:core_tool/core_tool.dart';
import 'package:flutter/painting.dart' show ImageCache, NetworkImageLoadException;
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:http_kit/http_kit.dart';

part 'avatar_controller.freezed.dart';

@freezed
sealed class AvatarState with _$AvatarState {
  const factory AvatarState.idle(UserId user, String avatarUrl) = _idleState;
  const factory AvatarState.updated(UserId user, String avatarUrl) = AvatarUpdatedState;
}

final class AvatarController extends StateController<AvatarState> with DroppableControllerHandler {
  /// Statuses that mean "this user has no avatar": 404, plus 403 — MinIO answers that for a missing
  /// object under an anonymous GetObject-only policy — and 204, an edge answering "no content".
  static const Set<int> _missingStatuses = <int>{204, 403, 404};

  AvatarController({
    super.initialState = const AvatarState.idle(UserIdX.empty, ''),
    required this._s3Url,
    required this._repository,
    required this._httpClient,
    required this._messenger,
  });

  final IUsersRepository _repository;
  final ApiClient _httpClient;
  final UiMessenger _messenger;

  /// Cache-busting version per user, set only by an own upload. The URL is otherwise stable, so
  /// [ImageCache], the browser and the CDN each keep one entry per avatar instead of one per time window.
  final Map<UserId, int> _versions = {};

  /// Users observed to have no avatar. An own upload clears the entry; otherwise the miss lasts the
  /// session — exactly as long as an avatar changed elsewhere stays invisible without a server signal.
  final Set<UserId> _missing = {};

  final String _s3Url;

  /// Per-upload cancellation token. Lets the user abort an in-flight avatar upload via [cancelUpload]
  /// without ending the whole session (A25); the http_kit pipeline aborts the socket on cancel.
  CancelToken? _uploadCancelToken;

  /// Aborts the in-flight avatar upload, if any.
  void cancelUpload() => _uploadCancelToken?.cancel();

  void uploadAvatar(User user, ImageInfo image) => handle(
    () => _messenger.track(() async {
      /// Todo: Compress image to 'webp' before upload 4 platforms
      log.d(
        'Avatar | upload | source',
        meta: <String, Object?>{
          'app.avatar.mime_type': image.mimeType,
          'app.avatar.bytes': image.image?.length,
        },
      );
      final (data, mime) = await toWebPBytes(image, quality: 0.3);
      log.d(
        'Avatar | upload | converted',
        meta: <String, Object?>{
          'app.avatar.mime_type': mime,
          'app.avatar.bytes': data?.length,
        },
      );
      if (data == null) {
        log('Avatar | upload | conversion produced nothing')
            .meta(<String, Object?>{'app.avatar.mime_type': image.mimeType})
            .description('Failed to process avatar image.')
          ..warn()
          ..toast(tone: .alert);
        return;
      }

      // 1. Get presigned upload URL from server
      final uploadInfo = await _repository.getAvatarUploadUrl(user.id, mime, data.length);

      // 2. Upload directly to S3 using the presigned URL (absolute → baseUrl is bypassed).
      // PUT is idempotent so the byte body is safely retried; a non-2xx status throws an
      // ApiClientException that the `error` handler below surfaces. No bearer / X-* headers
      // are attached (external client). `.toBytes()` drains the (empty) S3 response. A per-upload
      // CancelToken makes the request abortable via [cancelUpload].
      final cancelToken = _uploadCancelToken = CancelToken();
      await _httpClient
          .put(uploadInfo.uploadUrl, headers: {'Content-Type': mime}, body: data, cancelToken: cancelToken)
          .toBytes();

      // 3. Confirm upload with server
      await _repository.confirmAvatarUpload(user.id);

      // The new image is live: bust every cache layer for this client and forget any recorded miss.
      _versions[user.id] = DateTime.now().millisecondsSinceEpoch;
      _missing.remove(user.id);

      setState(AvatarState.updated(user.id, getUrl(user.id) ?? ''));
    }),
    error: (error, stackTrace) async {
      // A user-initiated cancel is expected, not a failure — `describeError` suppresses it.
      reportFailure('Avatar | upload | failed', error, stackTrace: stackTrace, caption: 'Failed to upload avatar.');
    },
    done: () async {
      _uploadCancelToken = null;
      setState(AvatarState.idle(state.user, state.avatarUrl));
    },
  );

  void deleteAvatar(User user) => handle(
    () => _messenger.track(() async {
      // The API throws a domain error on failure (A4); success always reaches here. Failure is
      // surfaced by the `error:` handler below.
      await _repository.deleteUserAvatar(user.id);
      // Known gone: [getUrl] returns null from here on, so this user is never requested again.
      _missing.add(user.id);
      setState(AvatarState.updated(user.id, getUrl(user.id) ?? ''));
    }),
    error: (error, stackTrace) async {
      reportFailure('Avatar | delete | failed', error, stackTrace: stackTrace, caption: 'Failed to delete avatar.');
    },
    done: () async {
      setState(AvatarState.idle(state.user, state.avatarUrl));
    },
  );

  /// Avatar URL for [userId], or `null` when there is nothing to load: no storage configured, no user,
  /// or a miss already recorded by [recordLoadError].
  ///
  /// The URL is stable — it carries a `?v=` only after this client uploaded a new image, which is the
  /// one moment the previously cached bytes are known to be wrong.
  String? getUrl(UserId userId) {
    if (userId.isEmpty || _s3Url.isEmpty || _missing.contains(userId)) return null;

    final version = _versions[userId];
    return '${_s3Url.trimEnd2('/')}/users/$userId/avatar.webp${version == null ? '' : '?v=$version'}';
  }

  /// Remembers a definitive "no avatar" answer (see [_missingStatuses]) so the object is asked for once.
  ///
  /// Network errors (status 0), 5xx and non-HTTP failures are transient: the URL is kept and the next
  /// widget retries.
  void recordLoadError(UserId userId, Object error) {
    if (error is! NetworkImageLoadException || !_missingStatuses.contains(error.statusCode)) return;

    // `Image.errorBuilder` runs on every rebuild of a failed image, so trace the first miss only.
    final firstMiss = _missing.add(userId);
    // 403 means "missing" only under the expected bucket policy. If it is really a misconfiguration
    // (policy, CDN rule, wrong S3_URL), this is the line that says so.
    if (firstMiss && error.statusCode == 403) {
      log.d('Avatar | load | forbidden', meta: <String, Object?>{'app.user.id': userId});
    }
  }
}
