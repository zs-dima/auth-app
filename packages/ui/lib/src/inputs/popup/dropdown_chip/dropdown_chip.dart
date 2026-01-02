import 'package:flutter/material.dart';
import 'package:ui/src/inputs/popup/core/dropdown_entry.dart';

class DropdownChip<T> extends StatelessWidget {
  const DropdownChip(
    this.entry, {
    super.key,
    this.icon,
    this.tooltip,
    this.side,
    this.onDeleted,
    required this.onSelected,
  });

  final DropdownEntry<T> entry;
  final String? tooltip;
  final BorderSide? side;
  final IconData? icon;

  final ValueChanged<T>? onDeleted;
  final ValueChanged<T> onSelected;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const .only(right: 5.0, top: 4.0),
    child: InputChip(
      tooltip: tooltip,
      key: ObjectKey(entry.value),
      label: Text(entry.label, maxLines: 1, overflow: .ellipsis),
      avatar: icon == null ? null : Icon(icon),
      // avatar: CircleAvatar(
      //   child: Text('$value'[0].toUpperCase()),
      // ),
      onDeleted: onDeleted == null ? null : () => onDeleted?.call(entry.value),
      onSelected: (_) => onSelected(entry.value),
      materialTapTargetSize: .shrinkWrap,
      padding: const .all(2.0),
      side: side,
    ),
  );
}
