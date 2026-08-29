// One-off: fills the `de` cell of the rpcErrorMessages row. sheety localize's validator
// kept rejecting the model output for German (broken ICU braces), so the cell is written
// manually with a hand-checked ICU select.

import 'dart:io';

import 'package:googleapis/sheets/v4.dart' as sheets;
import 'package:googleapis_auth/auth_io.dart';

const kSheetId = '1FAbQS3nA5czjBBayC3ms-DqkkdskCPLtrh2FDZ1P0lg';

const kDeSelect =
    '{code, select, '
    'unavailable{Backend nicht erreichbar. Bitte kontaktieren Sie den Support} '
    'deadlineExceeded{Backend-Fehler. Bitte kontaktieren Sie den Support} '
    'permissionDenied{Zugriff verweigert} '
    'aborted{Netzwerkanfrage abgebrochen} '
    'dataLoss{Netzwerkdatenverlust} '
    'canceled{Netzwerkanfrage abgebrochen} '
    'failedPrecondition{Vorbedingung der Netzwerkanfrage nicht erfüllt} '
    'cors{CORS-Fehler} '
    'other{Netzwerkfehler}}';

Future<void> main() async {
  final credentials = ServiceAccountCredentials.fromJson(File('credentials.json').readAsStringSync());
  final client = await clientViaServiceAccount(credentials, [sheets.SheetsApi.spreadsheetsScope]);
  try {
    final api = sheets.SheetsApi(client);
    final labels = await api.spreadsheets.values.get(kSheetId, "'errors'!A:A");
    final rowIndex = labels.values?.indexWhere((row) => row.firstOrNull == 'rpcErrorMessages') ?? -1;
    if (rowIndex < 0) {
      stderr.writeln('rpcErrorMessages row not found');
      exit(1);
    }
    final row = rowIndex + 1;
    await api.spreadsheets.values.update(
      sheets.ValueRange(
        values: [
          [kDeSelect],
        ],
      ),
      kSheetId,
      "'errors'!G$row",
      valueInputOption: 'RAW',
    );
    stdout.writeln('Filled de cell of rpcErrorMessages (row $row).');
  } finally {
    client.close();
  }
}
