import 'package:auth_app/app/app.dart';
import 'package:auth_app/app/message/bloc/app_message_bloc_mixin.dart';
import 'package:auth_app/feature/users/data/users_repository.dart';
import 'package:auth_model/auth_model.dart';
import 'package:bloc/bloc.dart';
import 'package:collection/collection.dart';
import 'package:core_tool/core_tool.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'users_bloc.freezed.dart';

@freezed
class UsersEvent with _$UsersEvent {
  const factory UsersEvent.loadUsers({required UserId userId}) = _loadUsersEvent;
  const factory UsersEvent.filterUsers(String query) = _filterUsersEvent;
}

@freezed
class UsersState with _$UsersState {
  const factory UsersState.loading(UserId userId, UnmodifiableListView<User> users) = _usersLoadingState;
  const factory UsersState.loaded(UserId userId, UnmodifiableListView<User> users) = UsersLoadedState;
}

class UsersBloc extends Bloc<UsersEvent, UsersState> with AppMessageBlocMixin {
  final IUsersRepository _repository;

  List<User> _users = const <User>[];
  String? _query;

  UsersBloc({
    required IUsersRepository repository,
    required AppMessageBloc messageBloc,
  })  : _repository = repository,
        super(UsersState.loading(UserIdX.empty, UnmodifiableListView<User>([]))) {
    this.messageBloc = messageBloc;
    on(onEvents);
  }

  void onEvents(UsersEvent event, Emitter emit) => event.when(
        loadUsers: (UserId currentUserId) async {
          if (currentUserId.isEmpty) {
            emit(UsersState.loaded(currentUserId, UnmodifiableListView<User>([])));
            return;
          }

          emit(UsersState.loading(currentUserId, state.users));

          emitProgress(AppProgress.startedEvent);
          try {
            final users = await _repository.loadUsers(currentUserId).toList();
            users.sort();
            _users = users;
            final result = _filter(users, _query);

            emit(UsersState.loaded(currentUserId, result));
          } on Exception catch (e, s) {
            emitError('Error on loading users', e, s);
          } finally {
            emitProgress(AppProgress.doneEvent);
          }
        },
        filterUsers: (String q) {
          final query = q.toUpperCase();
          if (query == _query) return;
          _query = query;

          if (_users.isEmpty) return;

          final result = _filter(_users, query);

          emit(UsersState.loaded(state.userId, result));
        },
      );

  UnmodifiableListView<User> _filter(List<User> users, String? query) {
    if (query.isNullOrSpace) return UnmodifiableListView<User>(users);
    final q = query!.toUpperCase();
    final filtered = users.where((i) => '${i.name}${i.email}'.toUpperCase().contains(q));
    return UnmodifiableListView<User>(filtered);
  }
}
