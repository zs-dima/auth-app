import 'package:flutter/material.dart';

/// {@template case_wrap_widget.case_wrap_widget}
/// CaseWrapWidget widget
/// {@endtemplate}
class CaseWrapWidget extends StatelessWidget {
  /// {@macro case_wrap_widget.case_wrap_widget}
  const CaseWrapWidget({super.key, Widget Function(Widget child)? getWrapper, required this.child})
    : _getWrapper = getWrapper;

  final Widget Function(Widget child)? _getWrapper;
  final Widget child;

  @override
  Widget build(BuildContext context) => _getWrapper?.call(child) ?? child;
}
