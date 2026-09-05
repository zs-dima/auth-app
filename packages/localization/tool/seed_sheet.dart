// One-off seeder: pushes the legacy ARB catalog into the Google Sheet that
// sheety_localization consumes. Idempotent — clears and rewrites every tab.
//
// Run from packages/localization: `dart run tool/seed_sheet.dart`
// Requires credentials.json (service account, Sheets API, sheet shared to its email).

import 'dart:convert';
import 'dart:io';

import 'package:googleapis/sheets/v4.dart' as sheets;
import 'package:googleapis_auth/auth_io.dart';

import 'package:l10n_tool/l10n_tool.dart';

import 'migration.dart';

/// The shape of the catalog: sheet, locales, buckets, factual labels. One file, read by every
/// command and by the offline gate.
final _config = L10nConfig.read('l10n_tool.json');

/// Factual per-locale values — data, not translation guesswork.
const kFactualRows = <String, Map<String, String>>{
  'lang': {'en': 'English', 'ru': 'Русский', 'es': 'Español', 'de': 'Deutsch'},
  'langEn': {'en': 'English', 'ru': 'Russian', 'es': 'Spanish', 'de': 'German'},
  'localeTag': {'en': 'en_US', 'ru': 'ru_RU', 'es': 'es_ES', 'de': 'de_DE'},
  'localeCode': {'en': 'en', 'ru': 'ru', 'es': 'es', 'de': 'de'},
};

const kErrorsKeys = <String>{
  'errInvalidFormat',
  'errTimeOutExceeded',
  'errNotImplementedYet',
  'errUnsupportedOperation',
  'errFileSystemException',
  'errAssertionError',
  'errAnErrorHasOccurred',
  'errAnExceptionHasOccurred',
  'somethingWentWrong',
  'error',
  'exception',
  'anErrorHasOccurred',
  'anExceptionHasOccurred',
  'tryAgainLater',
  'invalidFormat',
  'timeOutExceeded',
  'invalidCredentials',
  'unimplemented',
  'notImplementedYet',
  'unsupportedOperation',
  'fileSystemException',
  'assertionError',
  'badStateError',
  'badRequest',
  'unauthorized',
  'forbidden',
  'notFound',
  'notAcceptable',
  'requestTimeout',
  'tooManyRequests',
  'internalServerError',
  'badGateway',
  'serviceUnavailable',
  'gatewayTimeout',
  'unknownServerError',
  'anUnknownErrorWasReceivedFromTheServer',
};

const kAuthKeys = <String>{
  'authenticate',
  'authenticated',
  'authentication',
  'logOutButton',
  'logInButton',
  'signUpButton',
  'signInButton',
  'logOutDescription',
  'email',
  'password',
  'confirmPassword',
  'profileButton',
  'currentUser',
};

const kSettingsKeys = <String>{
  'settings',
  'customColors',
  'defaultThemes',
  'locales',
  'localeTag',
  'localeCode',
  'lang',
  'langEn',
  'languageSelection',
  'textSize',
};

String bucketOf(String label) => kErrorsKeys.contains(label)
    ? 'errors'
    : kAuthKeys.contains(label)
    ? 'auth'
    : kSettingsKeys.contains(label)
    ? 'settings'
    : 'app';

Map<String, String> readArbMessages(String path) {
  final json = jsonDecode(File(path).readAsStringSync()) as Map<String, Object?>;
  return {
    for (final MapEntry(:key, :value) in json.entries)
      if (!key.startsWith('@') && value is String) key: value,
  };
}

/// bucket → rows (label|description|meta|en|ru|es|de), source ARB order preserved.
Map<String, List<List<String>>> buildBuckets() {
  // Frozen snapshot of the pre-migration catalog (moved out of lib/ when the sheet became
  // the source of truth) — seeding again would overwrite sheet edits, re-run consciously.
  const translationDir = 'tool/legacy_baseline';
  final en = readArbMessages('$translationDir/intl_en.arb');
  final es = readArbMessages('$translationDir/intl_es.arb');

  String renamed(String key) => kRenames[key] ?? key;
  final esByLabel = {for (final MapEntry(:key, :value) in es.entries) renamed(key): value};

  final buckets = {
    for (final tab in ['app', 'errors', 'settings', 'auth']) tab: <List<String>>[],
  };

  for (final MapEntry(:key, :value) in en.entries) {
    final label = renamed(key);
    final description = label == 'appTitle' ? 'The title of the application' : '';
    final factual = kFactualRows[label];
    buckets[bucketOf(label)]!.add([
      label,
      description,
      '',
      factual?['en'] ?? value,
      factual?['ru'] ?? '',
      factual?['es'] ?? esByLabel[label] ?? '',
      factual?['de'] ?? '',
    ]);
  }

  // langEn is new (no legacy key) — append next to lang.
  final settingsRows = buckets['settings']!;
  final langIndex = settingsRows.indexWhere((row) => row.first == 'lang');
  settingsRows.insert(langIndex + 1, [
    'langEn',
    'Language name in English',
    '',
    for (final locale in _config.locales) kFactualRows['langEn']![locale]!,
  ]);

  // ICU round-trip probe — the reference example for placeholders via the meta column.
  buckets['app']!.add([
    'samplePlaceholder',
    'ICU round-trip probe — reference example for placeholders',
    jsonEncode({
      'placeholders': {
        'name': {'type': 'String'},
      },
    }),
    'Hello, {name}!',
    '',
    '',
    '',
  ]);

  return buckets;
}

Future<void> ensureTabs(sheets.SheetsApi api, Iterable<String> tabs) async {
  final spreadsheet = await api.spreadsheets.get(_config.sheetId);
  final existingTabs = {for (final sheet in spreadsheet.sheets ?? <sheets.Sheet>[]) sheet.properties?.title};
  final missingTabs = tabs.where((tab) => !existingTabs.contains(tab)).toList();
  if (missingTabs.isEmpty) return;
  await api.spreadsheets.batchUpdate(
    sheets.BatchUpdateSpreadsheetRequest(
      requests: [
        for (final tab in missingTabs)
          sheets.Request(
            addSheet: sheets.AddSheetRequest(properties: sheets.SheetProperties(title: tab)),
          ),
      ],
    ),
    _config.sheetId,
  );
  stdout.writeln('Created tabs: ${missingTabs.join(', ')}');
}

Future<void> main() async {
  final buckets = buildBuckets();

  final credentials = ServiceAccountCredentials.fromJson(File('credentials.json').readAsStringSync());
  final client = await clientViaServiceAccount(credentials, [sheets.SheetsApi.spreadsheetsScope]);
  try {
    final api = sheets.SheetsApi(client);
    await ensureTabs(api, buckets.keys);

    for (final MapEntry(key: tab, value: rows) in buckets.entries) {
      await api.spreadsheets.values.clear(sheets.ClearValuesRequest(), _config.sheetId, "'$tab'!A:Z");
      await api.spreadsheets.values.update(
        sheets.ValueRange(
          values: [
            ['label', 'description', 'meta', ..._config.locales],
            ...rows,
          ],
        ),
        _config.sheetId,
        "'$tab'!A1",
        // RAW: ICU braces and leading +/= must never be parsed as formulas.
        valueInputOption: 'RAW',
      );
      stdout.writeln('Seeded $tab: ${rows.length} rows');
    }
  } finally {
    client.close();
  }
}
