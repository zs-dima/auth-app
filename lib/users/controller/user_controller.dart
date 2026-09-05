import 'package:auth_app/_core/log/telemetry.dart';
import 'package:auth_app/_core/message/ui_messenger.dart';
import 'package:auth_app/_core/message/user_facing_error.dart';
import 'package:auth_app/users/data/users_repository.dart';
import 'package:auth_model/auth_model.dart';
import 'package:control/control.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_controller.freezed.dart';

@freezed
class UserState with _$UserState {
  const factory UserState.idle() = _idleState;
  const factory UserState.created(User user) = UserCreatedState;
  const factory UserState.updated(User user) = UserUpdatedState;
}

final class UserController extends StateController<UserState> with DroppableControllerHandler {
  UserController({
    required this._repository,
    required this._messenger,
    super.initialState = const UserState.idle(),
  });

  final IUsersRepository _repository;
  final UiMessenger _messenger;

  void createUser(CreateUserData data) => handle(
    () => _messenger.track(() async {
      final result = await _repository.createUser(data);
      if (result == null) {
        // A null result is the repository saying "nothing was created" without throwing: there is
        // no error to classify, so the caption is the whole story.
        log('Users | create | empty result').description('Error on saving user')
          ..warn()
          ..toast(tone: .alert);
        return;
      }
      log('Users | create | ok').description('User successfully saved')
        ..info()
        ..toast(tone: .ok);
      setState(UserState.created(result));
    }),
    error: (error, stackTrace) async {
      reportFailure('Users | create | failed', error, stackTrace: stackTrace, caption: 'Error on saving user');
    },
    done: () async {
      setState(const UserState.idle());
    },
  );

  void updateUser(UpdateUserData data) => handle(
    () => _messenger.track(() async {
      final result = await _repository.updateUser(data);
      if (result == null) {
        log('Users | update | empty result').description('Error on saving user')
          ..warn()
          ..toast(tone: .alert);
        return;
      }
      log('Users | update | ok').description('User successfully saved')
        ..info()
        ..toast(tone: .ok);
      setState(UserState.updated(result));
    }),
    error: (error, stackTrace) async {
      reportFailure('Users | update | failed', error, stackTrace: stackTrace, caption: 'Error on saving user');
    },
    done: () async {
      setState(const UserState.idle());
    },
  );
}
