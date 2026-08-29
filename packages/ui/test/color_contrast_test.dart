import 'package:flutter_test/flutter_test.dart';
import 'package:ui/src/colors/colors.dart';
import 'package:ui/ui.dart';

/// WCAG 2.x contrast ratio: (L_lighter + 0.05) / (L_darker + 0.05).
double _contrastRatio(Color a, Color b) {
  final la = a.computeLuminance();
  final lb = b.computeLuminance();
  final lighter = la > lb ? la : lb;
  final darker = la > lb ? lb : la;
  return (lighter + 0.05) / (darker + 0.05);
}

/// WCAG AA for normal text.
const _kAaNormalText = 4.5;

/// Ratchet allowlist: pairs known to fail today. Fixing them is a visual/brand decision;
/// this test only prevents NEW failures and flags entries that start passing (tighten then).
const _kKnownFailures = <String>{
  'light primary/onPrimary', // #25D366 vs white ≈ 1.98
  'light primaryContainer/onPrimaryContainer', // ≈ 1.98
  'light error/onError', // #EA4335 vs white ≈ 3.92
  'light errorContainer/onErrorContainer', // ≈ 3.92
};

void main() {
  group('AppColors WCAG contrast (AA normal text, ratchet)', () {
    for (final (brightness, colors) in [('light', AppColors.light), ('dark', AppColors.dark)]) {
      test('$brightness scheme foreground/background pairs', () {
        final scheme = colors.scheme;
        final pairs = <String, (Color, Color)>{
          'primary/onPrimary': (scheme.primary, scheme.onPrimary),
          'primaryContainer/onPrimaryContainer': (scheme.primaryContainer, scheme.onPrimaryContainer),
          'secondary/onSecondary': (scheme.secondary, scheme.onSecondary),
          'secondaryContainer/onSecondaryContainer': (scheme.secondaryContainer, scheme.onSecondaryContainer),
          'tertiary/onTertiary': (scheme.tertiary, scheme.onTertiary),
          'error/onError': (scheme.error, scheme.onError),
          'errorContainer/onErrorContainer': (scheme.errorContainer, scheme.onErrorContainer),
          'surface/onSurface': (scheme.surface, scheme.onSurface),
          'surface/onSurfaceVariant': (scheme.surface, scheme.onSurfaceVariant),
          'inverseSurface/onInverseSurface': (scheme.inverseSurface, scheme.onInverseSurface),
        };

        final failures = <String>{
          for (final MapEntry(key: name, value: (background, foreground)) in pairs.entries)
            if (_contrastRatio(background, foreground) < _kAaNormalText) '$brightness $name',
        };

        final knownForBrightness = _kKnownFailures.where((name) => name.startsWith(brightness)).toSet();
        expect(
          failures,
          equals(knownForBrightness),
          reason:
              'New entries = a contrast regression; missing entries = a pair now passes, '
              'remove it from _knownFailures. Ratios: '
              '${pairs.entries.map((e) => '${e.key}=${_contrastRatio(e.value.$1, e.value.$2).toStringAsFixed(2)}').join(', ')}',
        );
      });
    }
  });
}
