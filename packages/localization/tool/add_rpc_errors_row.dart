// One-off: appends the `rpcErrorMessages` ICU-select row to the `errors` tab
// (localized Connect RPC error texts by code). Targeted append — the rest of the
// sheet (including existing translations) is untouched. Idempotent: skips when
// the label already exists.

import 'dart:convert';
import 'dart:io';

import 'package:googleapis/sheets/v4.dart' as sheets;
import 'package:googleapis_auth/auth_io.dart';

const kSheetId = '1FAbQS3nA5czjBBayC3ms-DqkkdskCPLtrh2FDZ1P0lg';

const kLabel = 'rpcErrorMessages';

const kDescription =
    'Connect RPC error text by code (ICU select); unauthenticated/internal compose the '
    'server-provided message in Dart and are not listed here';

const kEnSelect =
    '{code, select, '
    'unavailable{Backend unavailable. Please contact support} '
    'deadlineExceeded{Backend error. Please contact support} '
    'permissionDenied{Permission denied} '
    'aborted{Network request aborted} '
    'dataLoss{Network data loss} '
    'canceled{Network request cancelled} '
    'failedPrecondition{Network request failed precondition} '
    'cors{CORS error} '
    'other{Network error}}';

Future<void> main() async {
  final credentials = ServiceAccountCredentials.fromJson(File('credentials.json').readAsStringSync());
  final client = await clientViaServiceAccount(credentials, [sheets.SheetsApi.spreadsheetsScope]);
  try {
    final api = sheets.SheetsApi(client);

    final labels = await api.spreadsheets.values.get(kSheetId, "'errors'!A:A");
    if (labels.values?.any((row) => row.firstOrNull == kLabel) ?? false) {
      stdout.writeln('$kLabel already present in the errors tab — nothing to do.');
      return;
    }

    await api.spreadsheets.values.append(
      sheets.ValueRange(
        values: [
          [
            kLabel,
            kDescription,
            jsonEncode({
              'placeholders': {
                'code': {'type': 'String'},
              },
            }),
            kEnSelect,
            '', // ru — filled by sheety localize
            '', // es
            '', // de
          ],
        ],
      ),
      kSheetId,
      "'errors'!A:G",
      // RAW: the ICU braces must never be parsed as a formula.
      valueInputOption: 'RAW',
    );
    stdout.writeln('Appended $kLabel to the errors tab (en filled, ru/es/de left for localize).');
  } finally {
    client.close();
  }
}
