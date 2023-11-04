import 'dart:async';

import 'package:core_model/core_model.dart';

typedef UserId = Guid;
typedef UserIdCallback = Future<UserId?> Function();

sealed class UserIdX {
  static const UserId empty = '';
}
