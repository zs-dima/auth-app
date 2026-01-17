import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:ui/src/inputs/form/text_field/label_field.dart';
import 'package:ui/src/inputs/popup/core/dropdown_entry.dart';
import 'package:ui/src/inputs/popup/core/dropdown_suggestions.dart';
import 'package:ui/src/inputs/popup/popup_builder.dart';
import 'package:ui/src/inputs/widget/input_decorations.dart';
import 'package:ui/src/inputs/widget/label_widget.dart';
import 'package:ui/src/widgets/case_wrap_widget.dart';

class DropdownPush<T> extends StatelessWidget {
  const DropdownPush(
    this.largeScreen, {
    super.key,
    this.title,
    required this.items,
    required this.value,
    required this.onSelected,
    this.intrinsicPopup = false,
    this.enabled = true,
    this.icon,
    this.errorText,
    this.helperText,
    this.decoration,
  });

  const DropdownPush.large({
    super.key,
    this.title,
    required this.items,
    required this.value,
    required this.onSelected,
    this.intrinsicPopup = false,
    this.enabled = true,
    this.icon,
    this.errorText,
    this.helperText,
    this.decoration,
  }) : largeScreen = true;

  final bool largeScreen;

  final String? title;
  final List<DropdownEntry<T>> items;
  final T? value;
  final ValueChanged<T>? onSelected;
  final bool intrinsicPopup;
  final bool enabled;
  final Widget? icon;
  final String? errorText;
  final String? helperText;
  final InputDecoration? decoration;

  @override
  Widget build(BuildContext context) {
    final item = items.firstWhereOrNull((i) => i.value == value);

    final labelField = LabelField(
      title: largeScreen ? null : title,
      label: item?.label ?? '',
      suffixIcon: const Icon(Icons.arrow_drop_down, size: 14.0),
      prefixIcon: icon,
      errorText: errorText,
      helperText: helperText,
      decoration: largeScreen
          ? (decoration ?? const InputDecoration()).applyDefaults(InputDecorations.flatTheme).copyWith(labelText: '')
          : decoration,
    );

    return CaseWrapWidget(
      getWrapper: largeScreen
          ? (child) => LabelWidget(
              label: title ?? decoration?.labelText ?? '',
              child: child,
            )
          : null,
      child: enabled
          ? PopupBuilder(
              followerAnchor: .topLeft,
              targetAnchor: .bottomLeft,
              targetBuilder: (context, controller) => TapRegion(
                debugLabel: 'PopupDropdown',
                groupId: controller,
                child: InkWell(
                  borderRadius: const .all(.circular(8.0)),
                  onTap: onSelected == null
                      ? null
                      : () {
                          controller.isShowing ? controller.hide() : controller.show();
                        },
                  child: labelField,
                ),
              ),
              followerBuilder: (context, controller) => PopupFollower(
                onDismiss: controller.hide,
                tapRegionGroupId: controller,
                constraints: intrinsicPopup
                    ? const BoxConstraints()
                    : const BoxConstraints(maxHeight: 300.0, maxWidth: 370.0),
                child: DropdownSuggestions<T>(
                  suggestions: items,
                  onSelected: (i) {
                    onSelected?.call(i);
                    controller.hide();
                  },
                  focusedValue: value,
                  intrinsicWidth: intrinsicPopup,
                ),
              ),
            )
          : labelField,
    );
  }
}
