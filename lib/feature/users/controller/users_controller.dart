import 'package:auth_app/app/app.dart';
import 'package:auth_app/app/message/controller/app_message_controller_mixin.dart';
import 'package:auth_app/feature/users/data/users_repository.dart';
import 'package:auth_model/auth_model.dart';
import 'package:collection/collection.dart';
import 'package:control/control.dart';
import 'package:core_tool/core_tool.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'users_controller.freezed.dart';

@freezed
sealed class UsersState with _$UsersState {
  const factory UsersState.loading(UserId userId, UnmodifiableListView<User> users) = _usersLoadingState;
  const factory UsersState.loaded(UserId userId, UnmodifiableListView<User> users) = UsersLoadedState;
}

final class UsersController extends StateController<UsersState>
    with DroppableControllerHandler, AppMessageControllerMixin {
  UsersController({required IUsersRepository repository, required AppMessageController messageController})
    : _repository = repository,
      super(initialState: UsersState.loading(UserIdX.empty, UnmodifiableListView<User>([]))) {
    this.messageController = messageController;
  }

  final IUsersRepository _repository;
  List<User> _users = const <User>[];

  String? _query;

  void loadUsers(UserId currentUserId) => handle(
    () async {
      if (currentUserId.isEmpty) {
        setState(UsersState.loaded(currentUserId, UnmodifiableListView<User>([])));
        return;
      }

      setState(UsersState.loading(currentUserId, state.users));
      setProgress(AppProgress.started);

      final users = await _repository.loadUsers(currentUserId).toList();
      users.sort();
      _users = users;
      final result = _filter(users, _query);

      setState(UsersState.loaded(currentUserId, result));
    },
    error: (error, stackTrace) async => setError('Error on loading users', error, stackTrace),
    done: () async => setProgress(AppProgress.done),
  );

  void filterUsers(String q) {
    final query = q.toUpperCase();
    if (query == _query) return;
    _query = query;

    if (_users.isEmpty) return;

    final result = _filter(_users, query);

    setState(UsersState.loaded(state.userId, result));
  }

  UnmodifiableListView<User> _filter(List<User> users, String? query) {
    if (query.isNullOrSpace) return UnmodifiableListView<User>(users);
    final qry = query!.toUpperCase();
    final filtered = users.where((i) => '${i.name}${i.email}'.toUpperCase().contains(qry));
    return UnmodifiableListView<User>(filtered);
  }
}
