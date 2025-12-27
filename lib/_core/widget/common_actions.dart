import 'dart:collection';

import 'package:auth_app/_core/widget/history_button.dart';
import 'package:auth_app/account/widget/profile_icon_button.dart';
import 'package:auth_app/authentication/widget/log_out_button.dart';
import 'package:auth_app/developer/widget/developer_button.dart';
import 'package:auth_app/settings/settings_button.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

class CommonActions extends ListBase<Widget> {
  CommonActions([List<Widget>? actions])
    : _actions = <Widget>[
        ...?actions,
        if (kDebugMode) const DeveloperButton(),
        const HistoryButton(),
        const SettingsButton(),
        const ProfileIconButton(),
        const LogOutButton(),
      ];

  final List<Widget> _actions;

  @override
  int get length => _actions.length;

  @override
  set length(int value) => _actions.length = value;

  @override
  Widget operator [](int index) => _actions[index];

  @override
  void operator []=(int index, Widget value) => _actions[index] = value;
}
