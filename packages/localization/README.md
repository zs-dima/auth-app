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
# from the repo root
make l10n-translate
```

## ⚠ Pitfalls

- **Never translate placeholder names**: `{name}` must stay `{name}` in every locale —
  Sheets' built-in auto-translate WILL rename them (`{имя}`) and break gen-l10n
  (the repair is a single-cell `values.update` with `valueInputOption: 'RAW'`; `tool/seed_sheet.dart`
  shows the shape). Use `sheety_localization:localize`
  instead — it validates placeholders.
- ICU `select` keys (e.g. `permissionDenied` in `rpcErrorMessages`) are code identifiers,
  not text — never translate them either.
- `--include-empty` is required on generate (already wired into `make l10n`): without it a
  row with blank trailing locale cells is dropped entirely, English included.

## The shape, in one file

`l10n_tool.json` holds the sheet id, the locale order, the buckets, the factual labels and the ARB
paths. Every command and the offline gate read it, so a change lands in one place.

## Tools (`tool/`)

- `generate.dart` — the pipeline `make l10n` runs: sheet to ARBs to generated Dart, then the
  round-trip gate. `--translate` AI-fills empty cells first.
- `verify_l10n.dart` — round-trip gate: every legacy key present, values not drifted, all
  bucket by locale ARBs exist, ICU placeholders intact in every locale.
- `seed_sheet.dart` — the original one-off seeder. **Destructive**: clears and rewrites all
  tabs from `tool/legacy_baseline/` — re-running it discards sheet edits and translations.
- `migration.dart` — what the 2026 sheet migration renamed and added; it goes away with the
  legacy baseline.
- `legacy_baseline/` — frozen pre-migration ARB catalog; the verifier's comparison baseline.

The offline gate (`test/l10n_consistency_test.dart`) is `package:l10n_tool/testing.dart`. The rest
of that package (`l10n_tool:generate`, `verify`, `seed_sheet`, `pull_baseline`) needs a per-bucket
baseline authored from the sheet, and `pull_baseline` refuses a row without a description: this
catalog has 4 across 115 keys. Write the descriptions, then the local scripts here go away and
`requireDescriptions` in the gate turns on.

## Consumption

The app talks to this package through the facade
[`lib/_core/localization/localization.dart`](../../lib/_core/localization/localization.dart):
delegates list, `supportedLocales` (`Locales.values`), `Localization.of(context)` /
`context.l10n` for the `app` bucket, `Localization.currentErrors` for context-free error
texts. Other buckets are read directly: `SettingsLocalization.of(context)`, etc.
