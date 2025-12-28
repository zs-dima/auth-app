import 'dart:async';

import 'package:auth_app/_core/message/controller/app_message_controller_mixin.dart';
import 'package:auth_app/_core/message/controller/message_controller.dart';
import 'package:auth_app/impersonation/data/impersonate_repository.dart';
import 'package:auth_model/auth_model.dart';
import 'package:control/control.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'impersonate_controller.freezed.dart';

@freezed
sealed class ImpersonateState with _$ImpersonateState {
  const factory ImpersonateState.idle({required IUserInfo user, @Default('Idling') String message, String? error}) =
      ImpersonateIdleState;
  const factory ImpersonateState.processing({required IUserInfo user, @Default('Processing') String message}) =
      ImpersonateProcessingState;
}

final class ImpersonateController extends StateController<ImpersonateState>
    with SequentialControllerHandler, AppMessageControllerMixin {
  ImpersonateController({required IImpersonateRepository repository, required AppMessageController messageController})
    : _repository = repository,
      super(initialState: ImpersonateState.idle(user: repository.currentUser)) {
    this.messageController = messageController;
    _userSubscription = repository.userChanges
        .map<ImpersonateState>((u) => ImpersonateState.idle(user: u))
        .where(
          (newState) =>
              switch (newState) {
                ImpersonateProcessingState _ => true,
                _ => false,
              } ||
              !identical(newState.user, state.user),
        )
        .listen(setState, cancelOnError: false);
  }

  final IImpersonateRepository _repository;
  StreamSubscription<ImpersonateState>? _userSubscription;

  void impersonate(IUserInfo user) => _repository.impersonate(user);

  /*handle(
        () async {
          setState(
            ImpersonateState.processing(
              user: state.user,
              message: 'Impersonating ${user.name}...',
            ),
          );
          _repository.impersonate(user);
        },
        error: (e, s) async => setError(
          'Error on impersonating ${user.name}',
          e,
          s,
          (message) => setState(
            ImpersonateState.idle(
              user: state.user,
              error: message,
            ),
          ),
        ),
        done: () async => setState(
          ImpersonateState.idle(user: state.user),
        ),
        name: 'impersonate',
      );*/

  @override
  void dispose() {
    _userSubscription?.cancel();
    super.dispose();
  }
}
