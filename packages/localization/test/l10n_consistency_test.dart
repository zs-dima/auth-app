// Offline gate: runs in CI, touches no network.
//
// It proves the COMMITTED artefacts are self-consistent, which is what every build and every CI run
// actually compiles. The checks live in `package:l10n_tool/testing.dart`; `l10n_tool.json` is the
// shape they read, and it is the same file the pipeline reads.
//
// `requireDescriptions` is off: this catalog carries 4 descriptions across 115 keys. Authoring them
// is content work; turn the rule on once the rows have them.

import 'package:l10n_tool/l10n_tool.dart';
import 'package:l10n_tool/testing.dart';
import 'package:localization/localization.dart';

void main() => l10nConsistencyTests(
  L10nConfig.read('l10n_tool.json'),
  generatedLocales: Locales.values.map((locale) => locale.languageCode).toSet(),
  requireDescriptions: false,
);
