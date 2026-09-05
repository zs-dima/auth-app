// Round-trip gate: proves the sheet → ARB pipeline lost nothing vs the legacy catalog.
//
// Run from packages/localization: `dart run tool/verify_l10n.dart` (wired into `make l10n`).
// Exits non-zero on any loss; prints per-locale coverage as information.
//
// Upgraded 2026-09-02 to the BreakerSonar shape: the shape moved to `l10n_tool.json` (read through
// `L10nConfig`) and the migration's renames to `tool/migration.dart`, the ICU
// placeholder check runs for EVERY key with placeholders in EVERY locale (it used to probe one
// key in en), and factual rows are asserted to actually differ from en per locale. The baseline
// model stays AA's own: the frozen pre-migration legacy catalog (this app HAS migration history).

import 'dart:convert';
import 'dart:io';

import 'package:l10n_tool/l10n_tool.dart';

import 'migration.dart';

/// The shape of the catalog: sheet, locales, buckets, factual labels. One file, read by every
/// command and by the offline gate.
final _config = L10nConfig.read('l10n_tool.json');

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
  for (final bucket in _config.buckets) {
    generated[bucket] = {};
    for (final locale in _config.locales) {
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
    } else if (generatedValue != value && !_config.factualLabels.contains(label)) {
      problems.add('VALUE DRIFT: $label — source "$value" vs generated "$generatedValue"');
    }
  }
  final known = sourceEn.keys.map(_renamed).toSet()..addAll(kAddedLabels);
  for (final label in unionEn.keys) {
    if (!known.contains(label)) problems.add('UNEXPECTED KEY: $label (not in legacy catalog)');
  }
  // The migration's own additions have no legacy row to be lost from, so the loop above cannot
  // miss them. `samplePlaceholder` is the ICU probe the placeholder check below reads; the old
  // gate asserted it by name ("ICU PROBE BROKEN") and the rewrite dropped that with it — a sheet
  // that lost the row would have made the placeholder check pass over nothing.
  for (final label in kAddedLabels) {
    if (!unionEn.containsKey(label)) problems.add('LOST MIGRATION KEY: $label missing from generated en ARBs');
  }
}

/// Values from a locale's legacy baseline must survive the pipeline untouched.
void checkBaselinePreserved(
  String locale,
  Map<String, String> baseline,
  Map<String, String> generated,
  List<String> problems,
) {
  for (final MapEntry(:key, :value) in baseline.entries) {
    final label = _renamed(key);
    if (_config.factualLabels.contains(label)) continue;
    if (generated[label] != value) {
      problems.add('LOST ${locale.toUpperCase()} VALUE: $label — expected "$value", got "${generated[label]}"');
    }
  }
}

/// ICU placeholders are code, not prose: `{name}` must stay `{name}` in every locale.
/// Sheets' built-in auto-translate renames them, which is exactly the failure this catches.
void checkPlaceholders(
  Map<String, String> unionEn,
  Map<String, Map<String, String>> unions,
  List<String> problems,
) {
  final placeholder = RegExp(r'\{(\w+)[,}]');
  for (final MapEntry(:key, :value) in unionEn.entries) {
    final expected = placeholder.allMatches(value).map((m) => m.group(1)!).toSet();
    if (expected.isEmpty) continue;
    for (final locale in _config.locales) {
      final translated = unions[locale]?[key];
      if (translated == null) continue;
      final actual = placeholder.allMatches(translated).map((m) => m.group(1)!).toSet();
      if (!actual.containsAll(expected)) {
        problems.add(
          'ICU PLACEHOLDER BROKEN: $key [$locale] — expected ${expected.toList()}, got ${actual.toList()}',
        );
      }
    }
  }
}

void main() {
  final problems = <String>[];
  final generated = readGeneratedArbs(problems);

  final unions = <String, Map<String, String>>{
    for (final locale in _config.locales)
      locale: {for (final bucket in _config.buckets) ...?generated[bucket]?[locale]},
  };
  final unionEn = unions['en']!;

  // Frozen pre-migration catalog — the round-trip baseline. en is complete by construction;
  // other locales are checked for exactly what their legacy file carries (only es exists today —
  // ru/de were born translated by the sheet pipeline and have no pre-migration baseline).
  const translationDir = 'tool/legacy_baseline';
  checkEnUnion(readArbMessages('$translationDir/intl_en.arb'), unionEn, problems);
  for (final locale in _config.locales.skip(1)) {
    final file = File('$translationDir/intl_$locale.arb');
    if (!file.existsSync()) continue;
    checkBaselinePreserved(locale, readArbMessages(file.path), unions[locale]!, problems);
  }

  // ALL locales, ALL keys with placeholders (the old gate probed one key in en).
  checkPlaceholders(unionEn, unions, problems);

  // Factual rows must actually differ from en in every locale — if ru still reads "English" the
  // pipeline copied the template cell instead of carrying the fact across.
  for (final label in _config.factualLabels) {
    for (final locale in _config.locales.skip(1)) {
      final value = unions[locale]![label];
      if (value != null && value == unionEn[label]) {
        problems.add('FACTUAL ROW NOT LOCALISED: $label is "${unionEn[label]}" in both en and $locale');
      }
    }
  }

  // Informational: per-locale translation coverage.
  stdout.writeln('Coverage (translated keys per bucket/locale):');
  for (final bucket in _config.buckets) {
    final counts = _config.locales.map((l) => '$l=${generated[bucket]?[l]?.length ?? 0}').join(' ');
    stdout.writeln('  $bucket: $counts');
  }

  if (problems.isNotEmpty) {
    stderr.writeln('\nROUND-TRIP FAILURES (${problems.length}):');
    problems.forEach(stderr.writeln);
    exit(1);
  }
  stdout.writeln('\nRound-trip OK: ICU placeholders intact in every locale, factual rows localised.');
}
