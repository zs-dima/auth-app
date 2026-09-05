/// What the 2026 sheet migration renamed and added, which no config field describes.
///
/// `verify_l10n.dart` measures the pipeline against the frozen pre-migration catalog in
/// `tool/legacy_baseline/`, so it has to know which legacy keys became which sheet labels and
/// which labels the migration introduced. Both sets go away with the legacy baseline itself.
library;

/// Legacy key to sheet label; must stay in sync with the sheet.
const kRenames = <String, String>{
  'localeName': 'localeTag',
  'language': 'lang',
  'custom_colors': 'customColors',
  'default_themes': 'defaultThemes',
};

/// Labels the migration introduced, absent from the legacy catalog.
const kAddedLabels = {'langEn', 'samplePlaceholder', 'rpcErrorMessages'};
