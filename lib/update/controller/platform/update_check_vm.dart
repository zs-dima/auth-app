import 'dart:async';

import 'package:auth_app/update/controller/update_check_api.dart';

final class UpdateCheckApiImpl implements UpdateCheckApi {
  final StreamController<void> _updateController = StreamController<void>.broadcast();

  bool _disposed = false;

  @override
  bool get hasPendingUpdate => false;

  @override
  Stream<void> get onUpdateAvailable => _updateController.stream;

  @override
  Future<void> updateApplication() async {}

  @override
  void dispose() {
    if (_disposed) return;
    _disposed = true;
    unawaited(_updateController.close());
  }
}
