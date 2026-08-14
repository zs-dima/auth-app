import 'package:flutter/material.dart';

/// {@template case_wrap_widget.case_wrap_widget}
/// CaseWrapWidget widget
/// {@endtemplate}
class CaseWrapWidget extends StatelessWidget {
  /// {@macro case_wrap_widget.case_wrap_widget}
  const CaseWrapWidget({super.key, this._getWrapper, required this.child});

  final Widget Function(Widget child)? _getWrapper;
  final Widget child;

  @override
  Widget build(BuildContext context) => _getWrapper?.call(child) ?? child;
}
