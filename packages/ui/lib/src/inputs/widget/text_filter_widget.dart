import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rxdart/rxdart.dart';
import 'package:ui/src/inputs/widget/text_field.dart';

class TextFilterWidget extends StatefulWidget {
  const TextFilterWidget(
    this.largeScreen, {
    super.key,
    this.onChanged,
    this.decoration,
  });

  const TextFilterWidget.large({
    super.key,
    this.onChanged,
    this.decoration,
  }) : largeScreen = true;

  const TextFilterWidget.small({
    super.key,
    this.onChanged,
    this.decoration,
  }) : largeScreen = false;

  final bool largeScreen;

  final ValueChanged<String>? onChanged;
  final InputDecoration? decoration;

  @override
  State<TextFilterWidget> createState() => _TextFilterWidgetState();
}

class _TextFilterWidgetState extends State<TextFilterWidget> {
  late FocusNode _searchPartFocus;
  late TextEditingController _searchPartController;

  final _textChangeSubject = BehaviorSubject<String>();
  late final StreamSubscription<String> _debounceSubscription;

  @override
  void initState() {
    super.initState();

    _searchPartFocus = FocusNode();
    _searchPartController = TextEditingController();

    // Listen to the subject's stream with a 300ms debounce
    _debounceSubscription = _textChangeSubject
        .debounceTime(const Duration(milliseconds: 300))
        .listen((value) => widget.onChanged?.call(value));
  }

  @override
  void dispose() {
    _debounceSubscription.cancel();
    _textChangeSubject.close();

    _searchPartFocus.dispose();
    _searchPartController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AppTextField(
    widget.largeScreen,
    focusNode: _searchPartFocus,
    controller: _searchPartController,
    decoration:
        widget.decoration ??
        InputDecoration(
          labelText: 'Search...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: IconButton(
            onPressed: () {
              HapticFeedback.mediumImpact().ignore();
              _searchPartFocus.unfocus();
              _searchPartController.clear();
              widget.onChanged?.call('');
            },
            icon: const Icon(Icons.close),
          ),
        ),
    onChanged: _textChangeSubject.add,
  );
}
