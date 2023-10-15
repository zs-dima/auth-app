import 'dart:typed_data';

import 'package:auth_app/app/app.dart';
import 'package:auth_app/app/message/bloc/app_message_bloc_mixin.dart';
import 'package:auth_app/feature/users/data/users_repository.dart';
import 'package:auth_model/auth_model.dart';
import 'package:bloc/bloc.dart';
import 'package:collection/collection.dart';
import 'package:core_tool/core_tool.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'users_avatars_bloc.freezed.dart';

@freezed
class UsersAvatarsEvent with _$UsersAvatarsEvent {
  const factory UsersAvatarsEvent.loadAvatar(UserId userId, {required bool reload}) = _loadAvatarEvent;
  const factory UsersAvatarsEvent.savePhoto(UserId userId, Uint8List? photo) = _saveAvatarEvent;
}

@freezed
class UsersAvatarsState with _$UsersAvatarsState {
  const factory UsersAvatarsState.loaded(UnmodifiableListView<UserAvatar> avatars) = UsersAvatarsLoadedState;
}

class UsersAvatarsBloc extends Bloc<UsersAvatarsEvent, UsersAvatarsState> with AppMessageBlocMixin {
  final IUsersRepository _repository;

  UsersAvatarsBloc({
    required IUsersRepository usersRepository,
    required AppMessageBloc messageBloc,
  })  : _repository = usersRepository,
        super(UsersAvatarsState.loaded(UnmodifiableListView<UserAvatar>([]))) {
    this.messageBloc = messageBloc;
    on(onEvents);
  }

  void onEvents(UsersAvatarsEvent event, Emitter emit) => event.when(
        loadAvatar: (UserId userId, bool reload) async {
          if (userId.isNullOrEmpty) return;

          final stateAvatar = state.avatars.firstWhereOrNull((i) => i.userId == userId);
          if (stateAvatar != null && stateAvatar.loaded && !reload) return;

          final avatars = state.avatars.where((i) => i.userId != userId);
          final loadingAvatar = UserAvatar.empty.copyWith(userId: userId);
          emit(UsersAvatarsState.loaded(UnmodifiableListView<UserAvatar>([...avatars, loadingAvatar])));

          emitProgress(AppProgress.startedEvent);

          try {
            // TODO: loadAvatar: (List<UserId>
            final loadedAvatar = (await _repository.loadUserAvatar([userId]).toList()).firstOrNull ??
                loadingAvatar.copyWith(loaded: true);

            emit(UsersAvatarsState.loaded(UnmodifiableListView<UserAvatar>([...avatars, loadedAvatar])));
          } on Exception catch (e, s) {
            emitError('Error on loading user avatar', e, s);
            Error.throwWithStackTrace(e, s);
          } finally {
            emitProgress(AppProgress.doneEvent);
          }
        },
        savePhoto: (UserId userId, Uint8List? photo) async {
          emitProgress(AppProgress.startedEvent);
          try {
            final result = await _repository.saveUserPhoto(userId, photo);
            if (!result) {
              emitError('Error on saving user avatar');
              return;
            }

            add(UsersAvatarsEvent.loadAvatar(userId, reload: true));
          } on Exception catch (e, s) {
            emitError('Error on saving user avatar', e, s);
            Error.throwWithStackTrace(e, s);
          } finally {
            emitProgress(AppProgress.doneEvent);
          }
        },
      );
}

extension UsersAvatarsStateX on UsersAvatarsState {
  UserAvatar? avatar(UserId userId) => avatars.firstWhereOrNull((i) => i.userId == userId);

  T? map<T extends Object>(
    IUserInfo userInfo, {
    T Function(Uint8List avatar)? avatar,
    T Function(String blurhash)? blurhash,
  }) {
    final userAvatar = avatars.firstWhereOrNull((i) => i.userId == userInfo.id);
    if (userAvatar == null || !userAvatar.loaded) {
      return userInfo.blurhash.isNullOrSpace ? null : blurhash?.call(userInfo.blurhash!);
    }
    return userAvatar.avatar == null ? null : avatar?.call(userAvatar.avatar!);
  }
}
