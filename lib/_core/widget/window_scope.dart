import 'dart:io' as io;

import 'package:auth_app/_core/localization/localization.dart';
import 'package:flutter/foundation.dart';
import 'package:platform_info/platform_info.dart';
import 'package:ui/ui.dart';
import 'package:window_manager/window_manager.dart';

/// {@template window_scope}
/// WindowScope widget.
/// {@endtemplate}
class WindowScope extends StatelessWidget {
  /// {@macro window_scope}
  const WindowScope({super.key, required this.title, required this.height, required this.child});

  /// Title of the window.
  final String title;

  final double height;

  /// The widget below this widget in the tree.
  final Widget child;

  @override
  Widget build(BuildContext context) => kIsWeb || io.Platform.isAndroid || io.Platform.isIOS
      ? child
      : Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const _WindowTitle(),
            Expanded(child: child),
          ],
        );
}

class _WindowTitle extends StatefulWidget {
  const _WindowTitle();

  @override
  State<_WindowTitle> createState() => _WindowTitleState();
}

// ignore: prefer_mixin
class _WindowTitleState extends State<_WindowTitle> with WindowListener {
  final ValueNotifier<bool> _isFullScreen = ValueNotifier(false);
  final ValueNotifier<bool> _isAlwaysOnTop = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
  }

  void _setAlwaysOnTop(bool value) {
    Future<void>(() async {
      await windowManager.setAlwaysOnTop(value);
      _isAlwaysOnTop.value = await windowManager.isAlwaysOnTop();
    }).ignore();
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    _isFullScreen.dispose();
    _isAlwaysOnTop.dispose();
    super.dispose();
  }

  @override
  void onWindowEnterFullScreen() {
    super.onWindowEnterFullScreen();
    _isFullScreen.value = true;
  }

  @override
  void onWindowLeaveFullScreen() {
    super.onWindowLeaveFullScreen();
    _isFullScreen.value = false;
  }

  @override
  void onWindowFocus() {
    // Make sure to call once.
    setState(() {});
    // do something
  }

  @override
  Widget build(BuildContext context) {
    final scope = context.findAncestorWidgetOfExactType<WindowScope>();
    final title = scope?.title ?? Localization.of(context).app;

    return SizedBox(
      height: scope?.height ?? 24,
      child: DragToMoveArea(
        child: Material(
          color: Theme.of(context).primaryColor,
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              Builder(
                builder: (ctx) {
                  final size = MediaQuery.sizeOf(ctx);
                  return AnimatedPositioned(
                    duration: Durations.medium3,
                    left: size.width < 800 ? 8 : 78,
                    right: 78,
                    top: 0,
                    bottom: 0,
                    child: Center(
                      child: AnimatedSwitcher(
                        duration: Durations.medium1,
                        transitionBuilder: (child, animation) => FadeTransition(
                          opacity: animation,
                          child: ScaleTransition(scale: animation, child: child),
                        ),
                        child: AppText.labelLarge(
                          title,
                          height: 1,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  );
                },
              ),
              if (platform.windows)
                _WindowButtons$Windows(
                  isFullScreen: _isFullScreen,
                  isAlwaysOnTop: _isAlwaysOnTop,
                  setAlwaysOnTop: _setAlwaysOnTop,
                  onPressedMinimize: windowManager.minimize,
                  onPressedMaximize: () async {
                    final isMaximized = await windowManager.isMaximized();
                    if (isMaximized) {
                      await windowManager.unmaximize();
                      _isFullScreen.value = false;
                    } else {
                      await windowManager.maximize();
                      _isFullScreen.value = true;
                    }
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WindowButtons$Windows extends StatelessWidget {
  const _WindowButtons$Windows({
    required ValueListenable<bool> isFullScreen,
    required ValueListenable<bool> isAlwaysOnTop,
    required this.onPressedMinimize,
    required this.onPressedMaximize,
    required this.setAlwaysOnTop,
  }) : _isFullScreen = isFullScreen,
       _isAlwaysOnTop = isAlwaysOnTop;

  final VoidCallback onPressedMinimize;
  final VoidCallback onPressedMaximize;

  // ignore: unused_field
  final ValueListenable<bool> _isFullScreen;
  final ValueListenable<bool> _isAlwaysOnTop;

  final ValueChanged<bool> setAlwaysOnTop;

  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.centerRight,
    child: Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        // Is always on top
        ValueListenableBuilder<bool>(
          valueListenable: _isAlwaysOnTop,
          builder: (_, isAlwaysOnTop, __) => _WindowButton(
            onPressed: () => setAlwaysOnTop(!isAlwaysOnTop),
            icon: isAlwaysOnTop ? Icons.push_pin : Icons.push_pin_outlined,
          ),
        ),

        // Minimize
        _WindowButton(onPressed: onPressedMinimize, icon: Icons.minimize),

        // Maximize
        ValueListenableBuilder<bool>(
          valueListenable: _isFullScreen,
          builder: (_, isFullScreen, __) => _WindowButton(
            onPressed: onPressedMaximize,
            icon: isFullScreen ? Icons.fullscreen_exit : Icons.fullscreen,
          ),
        ),

        // Close
        _WindowButton(onPressed: windowManager.close, icon: Icons.close),
        const SizedBox(width: 4),
      ],
    ),
  );
}

class _WindowButton extends StatelessWidget {
  const _WindowButton({required this.onPressed, required this.icon});

  final VoidCallback onPressed;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 4),
    child: IconButton(
      onPressed: onPressed,
      icon: Icon(icon),
      iconSize: 16,
      alignment: Alignment.center,
      padding: EdgeInsets.zero,
      splashRadius: 12,
      constraints: const BoxConstraints.tightFor(width: 24, height: 24),
    ),
  );
}
