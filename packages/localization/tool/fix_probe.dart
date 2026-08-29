// One-off: repair the samplePlaceholder row after Sheets auto-translate mangled
// the ICU placeholder ({name} → {имя}). Placeholder names must never be translated.

import 'dart:io';

import 'package:googleapis/sheets/v4.dart' as sheets;
import 'package:googleapis_auth/auth_io.dart';

const kSheetId = '1FAbQS3nA5czjBBayC3ms-DqkkdskCPLtrh2FDZ1P0lg';

Future<void> main() async {
  final credentials = ServiceAccountCredentials.fromJson(File('credentials.json').readAsStringSync());
  final client = await clientViaServiceAccount(credentials, [sheets.SheetsApi.spreadsheetsScope]);
  try {
    final api = sheets.SheetsApi(client);
    final labels = await api.spreadsheets.values.get(kSheetId, "'app'!A:A");
    final rowIndex = labels.values?.indexWhere((row) => row.firstOrNull == 'samplePlaceholder') ?? -1;
    if (rowIndex < 0) {
      stderr.writeln('samplePlaceholder row not found');
      exit(1);
    }
    final row = rowIndex + 1;
    await api.spreadsheets.values.update(
      sheets.ValueRange(
        values: [
          ['Hello, {name}!', 'Привет, {name}!', '¡Hola, {name}!', 'Hallo, {name}!'],
        ],
      ),
      kSheetId,
      "'app'!D$row:G$row",
      valueInputOption: 'RAW',
    );
    stdout.writeln('Fixed samplePlaceholder (row $row): {name} preserved in all locales.');
  } finally {
    client.close();
  }
}
