import 'package:flutter/material.dart';
import 'package:ui/src/inputs/popup/popup.dart';
import 'package:ui/src/inputs/widget/input_decorations.dart';
import 'package:ui/src/inputs/widget/label_widget.dart';
import 'package:ui/src/widgets/case_wrap_widget.dart';

typedef ChipValueChanged<T> = void Function(List<T> value, bool selected);

class ChipsWidget<T> extends StatelessWidget {
  const ChipsWidget(
    this.largeScreen, {
    super.key,
    this.title,
    required this.suggestions,
    required this.getValues,
    required this.onSelected,
    this.enabled = true,
    this.visualDensity,
    this.spacing = 8, //10,
    this.decoration,
    this.itemPadding,
    this.itemLabelPadding,
    this.itemSide,
    this.itemShowCheckmark = true,
  });

  const ChipsWidget.large({
    super.key,
    this.title,
    required this.suggestions,
    required this.getValues,
    required this.onSelected,
    this.enabled = true,
    this.visualDensity,
    this.spacing = 8, //10,
    this.decoration,
    this.itemPadding,
    this.itemLabelPadding,
    this.itemSide,
    this.itemShowCheckmark = true,
  }) : largeScreen = true;

  final bool largeScreen;

  final String? title;
  final List<DropdownEntry<T>> suggestions;
  final ChipValueChanged<T>? onSelected;
  final Iterable<T> Function() getValues;
  final bool enabled;
  final VisualDensity? visualDensity;
  final double spacing;
  final InputDecoration? decoration;
  final EdgeInsetsGeometry? itemPadding;
  final EdgeInsetsGeometry? itemLabelPadding;
  final BorderSide? itemSide;
  final bool itemShowCheckmark;

  @override
  Widget build(BuildContext context) => CaseWrapWidget(
    getWrapper: largeScreen
        ? (child) => LabelWidget(
            label: title ?? decoration?.labelText ?? '',
            child: child,
          )
        : null,
    child: InputDecorator(
      decoration: largeScreen
          ? (decoration ?? const InputDecoration()).applyDefaults(InputDecorations.flatTheme).copyWith(labelText: '')
          : (decoration ??
                InputDecoration(
                  isCollapsed: false,
                  isDense: false,
                  labelText: title,
                  enabled: enabled,
                  helperText: null,
                  errorText: null,
                  helperMaxLines: 0,
                  errorMaxLines: 0,
                )),

      child: Padding(
        padding: const .only(top: 4.0, bottom: 2.0),
        child: Wrap(
          spacing: spacing,
          runSpacing: 8.0,
          children: [
            for (final suggestion in suggestions)
              FilterChip(
                key: ValueKey(suggestion.value),
                showCheckmark: itemShowCheckmark,
                side: suggestion.icon == null ? itemSide : .none,
                avatar: suggestion.icon == null
                    ? null
                    : Icon(
                        suggestion.icon,
                        size: 16.0,
                        color: enabled ? null : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                      ),

                label: suggestion.tooltip == null
                    ? Text(suggestion.label)
                    : Tooltip(message: suggestion.tooltip, child: Text(suggestion.label)),
                selected: getValues().contains(suggestion.value),
                onSelected: enabled ? (selected) => onSelected?.call([suggestion.value], selected) : null,
                visualDensity: visualDensity,
                padding: itemPadding,
                labelPadding: itemLabelPadding,
              ),
          ],
        ),
      ),
    ),
  );
}
