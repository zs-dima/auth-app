import 'package:flutter/widgets.dart';
import 'package:ui/src/fonts/text.dart';

/// A field with its label above it, on the layouts that put it there.
///
/// **The shape is constant.** Both halves of this widget used to change the tree depending on a
/// runtime value: an empty [label] returned the child bare, and the call sites reached it through
/// a "wrap the child only on a large screen" helper. `Widget.canUpdate` compares exactly two
/// things — the runtime type and the key — so a child that moves depth, or that gains a sibling
/// above it, is not updated but REBUILT: a text field losing its element loses its focus, its
/// selection and the composing region the IME is holding. That fired on the label arriving and on
/// every crossing of the large-screen breakpoint, which is what resizing a desktop window does
/// continuously.
///
/// So the label is a SLOT ([Visibility] keeps the field at index 1 whatever the label does) and
/// "no label" is the empty string rather than a different tree.
class LabelWidget extends StatelessWidget {
  /// {@macro label_widget}
  const LabelWidget({required this.label, required this.child, this.spacing = 5.0, this.expands = false, super.key});

  /// Text above the field. Empty draws nothing and takes no space — and still keeps the slot.
  final String label;

  /// Gap between the label and the field. Applied to the label's slot, so an empty label
  /// contributes zero height rather than a stray gap.
  final double spacing;

  /// Whether the field takes the free space of the surrounding column.
  ///
  /// A parameter, not `Expanded(child: child)` at the call site: swapping `Expanded` in and out
  /// is the same reshape this widget exists to avoid. `flex: 0` with a loose fit is what a plain
  /// child already gets from a [Flex], so the off state costs nothing.
  ///
  /// Only pass `true` where the surrounding column is BOUNDED — a tight flex child under an
  /// unbounded main axis throws, exactly as an `Expanded` there would.
  final bool expands;

  /// The field.
  final Widget child;

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: .min,
    crossAxisAlignment: .start,
    children: <Widget>[
      Visibility(
        visible: label.isNotEmpty,
        child: Padding(
          padding: EdgeInsets.only(bottom: spacing),
          child: AppText.titleMedium(label),
        ),
      ),
      Flexible(
        flex: expands ? 1 : 0,
        fit: expands ? .tight : .loose,
        child: child,
      ),
    ],
  );
}
