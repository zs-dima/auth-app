import 'dart:async';

import 'package:auth_model/auth_model.dart';

abstract interface class IImpersonateRepository {
  Stream<IUserInfo> get userChanges;
  IUserInfo get currentUser;

  void impersonate(IUserInfo user);

  void terminate();
}

class ImpersonateRepository implements IImpersonateRepository {
  ImpersonateRepository({required this.currentUser});

  final StreamController<IUserInfo> _currentUserController = StreamController<IUserInfo>.broadcast();

  @override
  IUserInfo currentUser;

  @override
  Stream<IUserInfo> get userChanges => _currentUserController.stream;

  @override
  void impersonate(IUserInfo user) => Future<void>.sync(() async => _currentUserController.add(currentUser = user));

  @override
  void terminate() {
    _currentUserController.close();
  }
}
