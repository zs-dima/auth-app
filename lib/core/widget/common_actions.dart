import 'dart:collection';

import 'package:auth_app/core/widget/history_button.dart';
import 'package:auth_app/feature/account/widget/profile_icon_button.dart';
import 'package:auth_app/feature/authentication/widget/log_out_button.dart';
import 'package:auth_app/feature/developer/widget/developer_button.dart';
import 'package:auth_app/feature/settings/settings_button.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

class CommonActions extends ListBase<Widget> {
  final List<Widget> _actions;

  @override
  int get length => _actions.length;

  @override
  set length(int value) => _actions.length = value;

  CommonActions([List<Widget>? actions])
      : _actions = <Widget>[
          ...?actions,
          if (kDebugMode) const DeveloperButton(),
          const HistoryButton(),
          const SettingsButton(),
          const ProfileIconButton(),
          const LogOutButton(),
        ];

  @override
  Widget operator [](int index) => _actions[index];

  @override
  void operator []=(int index, Widget value) => _actions[index] = value;
}
