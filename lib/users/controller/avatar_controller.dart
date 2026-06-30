import 'package:auth_app/_core/message/controller/app_message_controller_mixin.dart';
import 'package:auth_app/_core/message/controller/message_controller.dart';
import 'package:auth_app/users/controller/platform/image_converter.dart';
import 'package:auth_app/users/controller/upload_image_controller.dart';
import 'package:auth_app/users/data/users_repository.dart';
import 'package:auth_model/auth_model.dart';
import 'package:control/control.dart';
import 'package:core_tool/core_tool.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:http_client/http_client.dart';

part 'avatar_controller.freezed.dart';

@freezed
sealed class AvatarState with _$AvatarState {
  const factory AvatarState.idle(UserId user, String avatarUrl) = _idleState;
  const factory AvatarState.updated(UserId user, String avatarUrl) = AvatarUpdatedState;
}

final class AvatarController extends StateController<AvatarState>
    with DroppableControllerHandler, AppMessageControllerMixin {
  AvatarController({
    super.initialState = const AvatarState.idle(UserIdX.empty, ''),
    required String s3Url,
    required IUsersRepository repository,
    required ApiClient httpClient,
    required AppMessageController messageController,
  }) : _repository = repository,
       _httpClient = httpClient,
       _s3Url = s3Url {
    this.messageController = messageController;
  }

  final IUsersRepository _repository;
  final ApiClient _httpClient;
  final Map<UserId, int> _versions = {};
  final String _s3Url;

  /// Per-upload cancellation token. Lets the user abort an in-flight avatar upload via [cancelUpload]
  /// without ending the whole session (A25); the http_client pipeline aborts the socket on cancel.
  CancelToken? _uploadCancelToken;

  /// Aborts the in-flight avatar upload, if any.
  void cancelUpload() => _uploadCancelToken?.cancel();

  void uploadAvatar(User user, ImageInfo image) => handle(
    () async {
      setProgressStarted();

      /// Todo: Compress image to 'webp' before upload 4 platforms
      print('??? mime: ${image.mimeType} and size: ${image.image?.length} bytes');
      final (data, mime) = await toWebPBytes(image, quality: 0.3);
      print('!!! mime: $mime and size: ${data?.length} bytes');
      if (data == null) {
        setError('Failed to process avatar image.');
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

      /// Invalidate specific user's avatar.
      _versions[user.id] = DateTime.now().millisecondsSinceEpoch;

      setState(AvatarState.updated(user.id, getUrl(user.id)));
    },
    error: (error, stackTrace) async {
      // A user-initiated cancel is expected, not a failure — surface nothing.
      if (error is ApiClientException$Cancelled) return;
      setError('Failed to upload avatar.', error, stackTrace);
      Error.throwWithStackTrace(error, stackTrace);
    },
    done: () async {
      _uploadCancelToken = null;
      setProgressDone();
      setState(AvatarState.idle(state.user, state.avatarUrl));
    },
  );

  void deleteAvatar(User user) => handle(
    () async {
      setProgressStarted();

      // The API throws a domain error on failure (A4); success always reaches here. Failure is
      // surfaced by the `error:` handler below.
      await _repository.deleteUserAvatar(user.id);
      _versions[user.id] = DateTime.now().millisecondsSinceEpoch;
      setState(AvatarState.updated(user.id, getUrl(user.id)));
    },
    error: (error, stackTrace) async {
      setError('Failed to delete avatar.', error, stackTrace);
      Error.throwWithStackTrace(error, stackTrace);
    },
    done: () async {
      setProgressDone();
      setState(AvatarState.idle(state.user, state.avatarUrl));
    },
  );

  /// Get avatar URL with cache-busting version.
  String getUrl(UserId userId) {
    if (userId.isEmpty) return '';

    final version = _versions[userId] ?? DateTime.now().millisecondsSinceEpoch;
    return '${_s3Url.trimEnd2('/')}/users/$userId/avatar.webp?v=$version';
  }
}
