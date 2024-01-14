import 'dart:typed_data';

import 'package:auth_app/app/app.dart';
import 'package:auth_app/app/message/controller/app_message_controller_mixin.dart';
import 'package:auth_app/feature/users/data/users_repository.dart';
import 'package:auth_model/auth_model.dart';
import 'package:collection/collection.dart';
import 'package:control/control.dart';
import 'package:core_tool/core_tool.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'users_avatars_controller.freezed.dart';

@freezed
class UsersAvatarsState with _$UsersAvatarsState {
  const factory UsersAvatarsState.loaded(UnmodifiableListView<UserAvatar> avatars) = UsersAvatarsLoadedState;
}

// @freezed
// class UsersAvatarsEvent with _$UsersAvatarsEvent {
//   const factory UsersAvatarsEvent.loadAvatar(UserId userId, {required bool reload}) = _loadAvatarEvent;
//   const factory UsersAvatarsEvent.savePhoto(UserId userId, Uint8List? photo) = _saveAvatarEvent;
// }

final class UsersAvatarsController extends StateController<UsersAvatarsState>
    with DroppableControllerHandler, AppMessageControllerMixin {
  final IUsersRepository _repository;

  UsersAvatarsController({
    required IUsersRepository usersRepository,
    required AppMessageController messageController,
  })  : _repository = usersRepository,
        super(initialState: UsersAvatarsState.loaded(UnmodifiableListView<UserAvatar>([]))) {
    this.messageController = messageController;
  }

  void loadAvatar(UserId userId, {required bool reload}) => handle(
        () async {
          if (userId.isNullOrEmpty) return;

          final stateAvatar = state.avatars.firstWhereOrNull((i) => i.userId == userId);
          if (stateAvatar != null && stateAvatar.loaded && !reload) return;

          final avatars = state.avatars.where((i) => i.userId != userId);
          final loadingAvatar = UserAvatar.empty.copyWith(userId: userId);
          setState(UsersAvatarsState.loaded(UnmodifiableListView<UserAvatar>([...avatars, loadingAvatar])));

          setProgress(AppProgress.started);

          // TODO: loadAvatar: (List<UserId>
          final loadedAvatar =
              (await _repository.loadUserAvatar([userId]).toList()).firstOrNull ?? loadingAvatar.copyWith(loaded: true);

          setState(UsersAvatarsState.loaded(UnmodifiableListView<UserAvatar>([...avatars, loadedAvatar])));
        },
        (error, stackTrace) {
          setError('Error on loading user avatar', error, stackTrace);
          Error.throwWithStackTrace(error, stackTrace);
        },
        () {
          setProgress(AppProgress.done);
          // setState(const UsersAvatarsState.idle());
        },
      );

  void savePhoto(UserId userId, Uint8List? photo) => handle(
        () async {
          setProgress(AppProgress.started);

          final result = await _repository.saveUserPhoto(userId, photo);
          if (!result) {
            setError('Error on saving user avatar');
            return;
          }

          loadAvatar(userId, reload: true);
        },
        (error, stackTrace) {
          setError('Error on saving user avatar', error, stackTrace);
          Error.throwWithStackTrace(error, stackTrace);
        },
        () {
          setProgress(AppProgress.done);
          // setState(const UsersAvatarsState.idle());
        },
      );
}

// TODO: move to auth_model package
typedef UserAvatarMapCallback<T extends Object> = T Function(Uint8List avatar);
typedef UserBlurhashMapCallback<T extends Object> = T Function(String blurhash);

extension UsersAvatarsStateX on UsersAvatarsState {
  UserAvatar? avatar(UserId userId) => avatars.firstWhereOrNull((i) => i.userId == userId);

  T? map<T extends Object>(
    IUserInfo userInfo, {
    UserAvatarMapCallback<T>? avatar,
    UserBlurhashMapCallback<T>? blurhash,
  }) {
    final userAvatar = avatars.firstWhereOrNull((i) => i.userId == userInfo.id);
    if (userAvatar == null || !userAvatar.loaded) {
      return userInfo.blurhash.isNullOrSpace ? null : blurhash?.call(userInfo.blurhash!);
    }
    return userAvatar.avatar == null ? null : avatar?.call(userAvatar.avatar!);
  }
}
