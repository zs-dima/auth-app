import 'package:auth_app/_core/widget/text_placeholder.dart';
import 'package:ui/ui.dart';

/// {@template form_placeholder}
/// FormPlaceholder widget.
/// {@endtemplate}
class FormPlaceholder extends StatelessWidget {
  /// {@macro form_placeholder}
  const FormPlaceholder({
    this.title = false,
    super.key,
  });

  final bool title;

  @override
  Widget build(BuildContext context) => Column(
    children: <Widget>[
      if (title)
        Padding(
          padding: const .all(8.0),
          child: Shimmer(
            size: const Size(64.0, 64.0),
            highlight: Colors.grey[400]!,
            background: Colors.grey[100]!,
            radius: const .circular(24.0),
          ),
        ),
      const SizedBox(height: 16.0),
      TextPlaceholder(width: 152.0),
      const SizedBox(height: 16.0),
      TextPlaceholder(width: 256.0),
      const SizedBox(height: 16.0),
      TextPlaceholder(width: 128.0),
      const SizedBox(height: 16.0),
      TextPlaceholder(width: 64.0),
      const SizedBox(height: 16.0),
      TextPlaceholder(width: 256.0),
      const SizedBox(height: 16.0),
      TextPlaceholder(width: 512.0),
      const SizedBox(height: 16.0),
      TextPlaceholder(width: 256.0),
      const SizedBox(height: 16.0),
      TextPlaceholder(width: 128.0),
    ],
  );
}
