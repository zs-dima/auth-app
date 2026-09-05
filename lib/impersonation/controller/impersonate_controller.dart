import 'dart:async';

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

final class ImpersonateController extends StateController<ImpersonateState> with SequentialControllerHandler {
  ImpersonateController({required IImpersonateRepository repository})
    : _repository = repository,
      super(initialState: ImpersonateState.idle(user: repository.currentUser)) {
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

  @override
  void dispose() {
    _userSubscription?.cancel();
    super.dispose();
  }
}
