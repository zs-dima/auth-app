# localization

Generated localization for auth-app: **Google Sheets → ARB → Flutter gen-l10n**, bridged by
[sheety_localization](https://pub.dev/packages/sheety_localization). The generated output
(`lib/src/l10n/**` ARBs + `lib/src/generated/**` Dart classes + the `lib/localization.dart`
barrel) is **committed** — builds and CI never touch Google APIs.

## Source of truth

One Google Spreadsheet, tab per bucket → one generated class + delegate each:

| Tab        | Class                  | Contents                                    |
| ---------- | ---------------------- | ------------------------------------------- |
| `app`      | `AppLocalization`      | General UI strings                          |
| `errors`   | `ErrorsLocalization`   | Error texts incl. `rpcErrorMessages` select |
| `settings` | `SettingsLocalization` | Settings screen, language/locale names      |
| `auth`     | `AuthLocalization`     | Sign-in/out, credentials fields             |

Columns: `label | description | meta | en | ru | es | de`.

- `label` — becomes the Dart getter/method name (camelCase).
- `meta` — JSON merged into the ARB `@label` block; used for ICU placeholders, e.g.
  `{"placeholders": {"name": {"type": "String"}}}` (see the `samplePlaceholder` reference row).
- Locale cells hold the text — ICU syntax goes **verbatim into the cell**
  (`Hello, {name}!`, or a full `{code, select, …}` — see `rpcErrorMessages` in `errors`).
- An empty cell = the key falls back to the English (template) text for that locale.

## Regenerate

Requires `credentials.json` in this directory — a GCP **service account** key with the
Google Sheets API enabled, the sheet shared to the account's email. The file is gitignored;
**never commit it** (it is also excluded from the Docker context via the root `.dockerignore`).

```bash
# from the repo root — generate + round-trip verification:
make l10n
# or the VS Code task "Generate localization"
```

Missing translations can be AI-filled (writes only empty cells, validates that ICU
placeholders survive):

```bash
dart run sheety_localization:localize -c credentials.json -s <SHEET_ID> -f <openai-key-file> --model=gpt-5
```

## ⚠ Pitfalls

- **Never translate placeholder names**: `{name}` must stay `{name}` in every locale —
  Sheets' built-in auto-translate WILL rename them (`{имя}`) and break gen-l10n
  (`tool/fix_probe.dart` is the recorded repair example). Use `sheety_localization:localize`
  instead — it validates placeholders.
- ICU `select` keys (e.g. `permissionDenied` in `rpcErrorMessages`) are code identifiers,
  not text — never translate them either.
- `--include-empty` is required on generate (already wired into `make l10n`): without it a
  row with blank trailing locale cells is dropped entirely, English included.

## Tools (`tool/`)

- `verify_l10n.dart` — round-trip gate (run by `make l10n`): every legacy key present,
  values not drifted, all bucket×locale ARBs exist, ICU probe intact.
- `seed_sheet.dart` — the original one-off seeder. **Destructive**: clears and rewrites all
  tabs from `tool/legacy_baseline/` — re-running it discards sheet edits/translations.
- `add_rpc_errors_row.dart`, `fix_probe.dart`, `fix_rpc_errors_de.dart` — one-off targeted
  sheet edits, kept as reference examples for safe (append/single-cell) API writes.
- `legacy_baseline/` — frozen pre-migration ARB catalog; the verifier's comparison baseline.

## Consumption

The app talks to this package through the facade
[`lib/_core/localization/localization.dart`](../../lib/_core/localization/localization.dart):
delegates list, `supportedLocales` (`Locales.values`), `Localization.of(context)` /
`context.l10n` for the `app` bucket, `Localization.currentErrors` for context-free error
texts. Other buckets are read directly: `SettingsLocalization.of(context)`, etc.
