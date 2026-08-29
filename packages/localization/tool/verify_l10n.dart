// Round-trip gate: proves the sheet → ARB pipeline lost nothing vs the legacy catalog.
//
// Run from packages/localization: `dart run tool/verify_l10n.dart`
// Exits non-zero on any loss; prints per-locale coverage as information.

import 'dart:convert';
import 'dart:io';

const kBuckets = ['app', 'errors', 'settings', 'auth'];
const kLocales = ['en', 'ru', 'es', 'de'];

/// Legacy key → sheet label (must mirror tool/seed_sheet.dart).
const kRenames = <String, String>{
  'localeName': 'localeTag',
  'language': 'lang',
  'custom_colors': 'customColors',
  'default_themes': 'defaultThemes',
};

/// Labels whose values are intentionally rewritten as factual per-locale data.
const kFactualLabels = {'lang', 'langEn', 'localeTag', 'localeCode'};

/// Labels added by the migration (not present in the legacy catalog).
const kAddedLabels = {'langEn', 'samplePlaceholder', 'rpcErrorMessages'};

Map<String, String> readArbMessages(String path) {
  final json = jsonDecode(File(path).readAsStringSync()) as Map<String, Object?>;
  return {
    for (final MapEntry(:key, :value) in json.entries)
      if (!key.startsWith('@') && value is String) key: value,
  };
}

String _renamed(String key) => kRenames[key] ?? key;

/// bucket → locale → messages; records a problem for every missing ARB.
Map<String, Map<String, Map<String, String>>> readGeneratedArbs(List<String> problems) {
  final generated = <String, Map<String, Map<String, String>>>{};
  for (final bucket in kBuckets) {
    generated[bucket] = {};
    for (final locale in kLocales) {
      final file = File('lib/src/l10n/$bucket/app_$locale.arb');
      if (!file.existsSync()) {
        problems.add('MISSING ARB: $bucket/$locale');
        continue;
      }
      generated[bucket]![locale] = readArbMessages(file.path);
    }
  }
  return generated;
}

/// The en union must carry every legacy key (renamed) with a byte-identical value.
void checkEnUnion(Map<String, String> sourceEn, Map<String, String> unionEn, List<String> problems) {
  for (final MapEntry(:key, :value) in sourceEn.entries) {
    final label = _renamed(key);
    final generatedValue = unionEn[label];
    if (generatedValue == null) {
      problems.add('LOST KEY: $key (label $label) missing from generated en ARBs');
    } else if (generatedValue != value && !kFactualLabels.contains(label)) {
      problems.add('VALUE DRIFT: $label — source "$value" vs generated "$generatedValue"');
    }
  }
  final known = sourceEn.keys.map(_renamed).toSet()..addAll(kAddedLabels);
  for (final label in unionEn.keys) {
    if (!known.contains(label)) problems.add('UNEXPECTED KEY: $label (not in legacy catalog)');
  }
}

void checkEsSurvived(Map<String, String> sourceEs, Map<String, String> unionEs, List<String> problems) {
  for (final MapEntry(:key, :value) in sourceEs.entries) {
    final label = _renamed(key);
    if (kFactualLabels.contains(label)) continue;
    if (unionEs[label] != value) {
      problems.add('LOST ES VALUE: $label — expected "$value", got "${unionEs[label]}"');
    }
  }
}

void main() {
  // Frozen pre-migration catalog — the round-trip baseline.
  const translationDir = 'tool/legacy_baseline';
  final sourceEn = readArbMessages('$translationDir/intl_en.arb');
  final sourceEs = readArbMessages('$translationDir/intl_es.arb');

  final problems = <String>[];
  final generated = readGeneratedArbs(problems);
  final unionEn = {for (final bucket in kBuckets) ...?generated[bucket]?['en']};
  final unionEs = {for (final bucket in kBuckets) ...?generated[bucket]?['es']};

  checkEnUnion(sourceEn, unionEn, problems);
  checkEsSurvived(sourceEs, unionEs, problems);

  // The ICU probe kept its placeholder.
  final probe = unionEn['samplePlaceholder'];
  if (probe == null || !probe.contains('{name}')) {
    problems.add('ICU PROBE BROKEN: samplePlaceholder = "$probe"');
  }

  // Informational: per-locale translation coverage.
  stdout.writeln('Coverage (translated keys per bucket/locale):');
  for (final bucket in kBuckets) {
    final counts = kLocales.map((l) => '$l=${generated[bucket]?[l]?.length ?? 0}').join(' ');
    stdout.writeln('  $bucket: $counts');
  }

  if (problems.isNotEmpty) {
    stderr.writeln('\nROUND-TRIP FAILURES (${problems.length}):');
    problems.forEach(stderr.writeln);
    exit(1);
  }
  stdout.writeln('\nRound-trip OK: ${sourceEn.length} legacy keys accounted for, ICU probe intact.');
}
