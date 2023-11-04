import 'dart:async';

import 'package:auth_app/app/app.dart';
import 'package:core_tool/core_tool.dart';
import 'package:flutter/material.dart';
import 'package:ui_tool/ui_tool.dart';

extension AppMessageScopeX on BuildContext {
  AppMessageController get message => AppMessageScope.of(this, listen: false);
}

/// {@template app_message_controller}
/// A controller that holds and operates the app internal messages.
/// {@endtemplate}
abstract interface class AppMessageController {
  AppMessageBloc get bloc;
}

/// {@template app_message_scope}
/// Theme scope is responsible for handling theme-related stuff.
///
/// See [AppMessageScope] for more info.
/// {@endtemplate}
class AppMessageScope extends StatefulWidget {
  /// {@macro app_message_scope}
  const AppMessageScope({
    required this.child,
    super.key,
  });

  /// Get the [AppMessageController] of the closest [AppMessageScope] ancestor.
  static AppMessageController of(BuildContext context, {bool listen = true}) =>
      context.scopeOf<_AppMessageInherited>(listen: listen).controller;

  /// The child widget.
  final Widget child;

  @override
  State<AppMessageScope> createState() => _AppMessageScopeState();
}

class _AppMessageScopeState extends State<AppMessageScope> implements AppMessageController {
  StreamSubscription<void>? _messageSubscription;

  @override
  late final AppMessageBloc bloc;

  @override
  void initState() {
    super.initState();

    bloc = AppMessageBloc();
  }

  void _subscribeMessages(BuildContext context) {
    _messageSubscription?.cancel();
    _messageSubscription = bloc.stream.listen(
      (MessageState i) {
        if (!mounted) return;
        i.whenOrNull(
          appMessage: (message, backgroundColor) => context.showInfo(message, backgroundColor: backgroundColor),
          appError: (error) => context.showError(error),
          netError: (error) => context.showError(error),
          progress: (progress, type, message) => message.isNullOrSpace ? null : context.showProgress('$message'),
        );
      },
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _subscribeMessages(context);
  }

  @override
  void dispose() {
    _messageSubscription?.cancel();
    bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => _AppMessageInherited(
        controller: this,
        child: widget.child,
      );
}

class _AppMessageInherited extends InheritedWidget {
  const _AppMessageInherited({
    required this.controller,
    required super.child,
  });

  /// {@macro app_message_scope}
  final AppMessageController controller;

  @override
  bool updateShouldNotify(covariant _AppMessageInherited oldWidget) => false;
}
