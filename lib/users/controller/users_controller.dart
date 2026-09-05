import 'package:auth_app/_core/message/ui_messenger.dart';
import 'package:auth_app/_core/message/user_facing_error.dart';
import 'package:auth_app/users/data/users_repository.dart';
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

final class UsersController extends StateController<UsersState> with DroppableControllerHandler {
  /// Upper bound on how long [getUserInfo] waits for an in-flight [listUsers].
  static const Duration _kLoadWait = Duration(seconds: 30);

  UsersController({required this._repository, required this._messenger})
    : super(initialState: UsersState.loading(UserIdX.empty, UnmodifiableListView<User>([])));

  final IUsersRepository _repository;
  final UiMessenger _messenger;
  List<User> _users = <User>[];

  String? _query;

  Future<void> reset() async {
    // Reassign, not clear(): published states hold views over the previous list.
    _users = <User>[];
    _query = null;
    setState(UsersState.loading(UserIdX.empty, UnmodifiableListView<User>([])));
  }

  Future<IUserInfo> getUserInfo(UserId userId) async {
    // First check if user is already in cache
    final cachedUser = _users.firstWhereOrNull((i) => i.id == userId);
    if (cachedUser != null) return cachedUser;

    // If users are currently loading, wait for the load to complete
    if (isProcessing) {
      final loadedState = await toStream()
          .firstWhere((s) => s is UsersLoadedState)
          .timeout(_kLoadWait, onTimeout: () => state);
      final user = loadedState.users.firstWhereOrNull((i) => i.id == userId);
      if (user != null) return user;
    }

    // Check again after loading completed
    final user = _users.firstWhereOrNull((i) => i.id == userId);
    if (user != null) return user;

    // Only fetch from API if user is not found after loading
    return _repository
        .listUsersInfo(
          filter: ListUsersFilter(
            userIds: [userId],
          ),
        )
        .first;
  }

  void listUsers(UserId currentUserId) {
    handle(
      () async {
        if (currentUserId.isEmpty) {
          setState(UsersState.loaded(currentUserId, UnmodifiableListView<User>([])));
          return;
        }

        setState(UsersState.loading(currentUserId, state.users));
        // The early return above is OUTSIDE the tracked region, which is the
        // whole point: the `progress` flag this used to carry existed only to
        // stop `done:` emitting a `progressDone` the return never matched.
        await _messenger.track(() async {
          final users = await _repository.listUsers().toList();
          users.sort();
          _users = users;
          final result = _filter(users, _query);

          setState(UsersState.loaded(currentUserId, result));
        });
      },
      error: (error, stackTrace) async {
        reportFailure('Users | list | failed', error, stackTrace: stackTrace, caption: 'Error on loading users');
        // Unblock [getUserInfo] waiters parked on `firstWhere(loaded)` — else a failed load wedges
        // them forever.
        setState(UsersState.loaded(state.userId, state.users));
      },
    );
  }

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
