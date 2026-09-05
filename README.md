# Auth App

A cross-platform Flutter client for authentication and user management via Connect RPC services
(the [Connect protocol](https://connectrpc.com) with binary protobuf on every platform — HTTP/2 with
pinned TLS on native, the browser fetch stack on web; no gRPC-Web translation proxy).

## Backend Services

Rust Connect RPC service: [zs-dima/auth-service-rs](https://github.com/zs-dima/auth-service-rs)
Go gRPC service (legacy): [zs-dima/auth-service](https://github.com/zs-dima/auth-service) — gRPC-only, not compatible with this client's Connect transport

## Overview

Auth App provides a modern, responsive UI for authentication and user management operations. Built with Flutter, it runs on Android, iOS, Web, Windows, macOS, and Linux.

## Features

- [x] JWT authentication
- [x] User management
- [x] User settings & preferences
- [x] Adaptive theming (system/light/dark mode)
- [x] Localization
- [x] Secure storage for credentials
- [x] Environment configuration
- [ ] Local storage
- [ ] Event Bus notifications
- [ ] Test coverage
- [ ] Documentation

## Getting Started

### Prerequisites

- [Flutter SDK](https://flutter.dev/docs/get-started/install) (3.47.2+)
- [Dart SDK](https://dart.dev/get-dart) (3.13+, bundled with Flutter)
- Running Rust Connect RPC backend service ([zs-dima/auth-service-rs](https://github.com/zs-dima/auth-service-rs))

### Installation

1. Clone the repository:

   ```bash
   git clone https://github.com/zs-dima/auth-app.git
   cd auth-app
   ```

2. Install dependencies:

   ```bash
   flutter pub get
   ```

3. Generate code (models, serialization):

   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

4. Configure environment:

   Copy and modify the environment files in `config/` directory as needed.

### Running the App

```bash
# Run on Chrome (Web)
# COOP/COEP headers enable cross-origin isolation (SharedArrayBuffer), so the drift
# database picks an OPFS storage instead of falling back to IndexedDB — same headers
# as production (see firebase.json).
flutter run -d chrome --dart-define-from-file=config/development.env \
  --web-header=Cross-Origin-Opener-Policy=same-origin \
  --web-header=Cross-Origin-Embedder-Policy=require-corp

# Run on Windows
flutter run -d windows --dart-define-from-file=config/development.env

# Run on connected device
flutter run --dart-define-from-file=config/development.env
```

## Project Structure

```
lib/
├── main.dart           # Application entry point
├── _core/              # Core utilities, DI, extensions
├── account/            # Account management
├── authentication/     # Login, logout, JWT handling
├── home/               # Home screen
├── settings/           # App settings
└── users/              # User management

packages/
├── localization/       # Generated l10n (Google Sheets → sheety_localization → gen-l10n)
├── model/auth_model/   # Auth and user contracts, the generated protobuf and Connect clients
├── tool/               # Development tools
└── ui/                 # UI components library
```

The shared kit is not in this repository. It comes from pub.dev, publisher `dmitrii.app`:

| Package | What it is |
|---|---|
| [core_model](https://pub.dev/packages/core_model) | `Lease`, `CancelToken`, `RetryBackoff`, `Guid` |
| [telemetry](https://pub.dev/packages/telemetry) | one event model for logs, crash reporting, analytics |
| [connect_kit](https://pub.dev/packages/connect_kit) | the Connect RPC runtime: transport, interceptors, retry |
| [http_kit](https://pub.dev/packages/http_kit) | the HTTP client and its middleware pipeline |
| [lints_tool](https://pub.dev/packages/lints_tool) | the analyzer and DCM rule set |

Their sources live in `A:\source\_lib\flutter`, one repository each.

## Localization

Source of truth is a [Google Sheet]
(tabs `app` / `errors` / `settings` / `auth` — one generated class + delegate per tab).
Columns: `label | description | meta | en | ru | es | de`. Generation is done by
[sheety_localization](https://pub.dev/packages/sheety_localization), which writes ARB files and
shells out to Flutter's own `gen-l10n` — the generated output in `packages/localization` is
**committed**, so builds and CI never need Google credentials.

- **Edit / translate**: change cells in the sheet (untranslated cells fall back to English),
  then regenerate: `make l10n` (or the "Generate localization" VS Code task). Requires
  `packages/localization/credentials.json` — a GCP service account with the Sheets API enabled
  and the sheet shared to its email; the file is gitignored, never commit it.
- **Add a key**: add a row; `label` becomes the Dart getter on that tab's class
  (`AppLocalization`, `ErrorsLocalization`, `SettingsLocalization`, `AuthLocalization`).
- **Placeholders / ICU**: put the ICU string in the locale cell and the placeholder types in
  `meta`, e.g. `{"placeholders": {"name": {"type": "String"}}}` with `Hello, {name}!` —
  see the `samplePlaceholder` row (the reference example). Plurals/selects work the same way.
- **Add a locale**: add a column, fill it, regenerate — `Locales.values` and the delegates update.
- Consumption: `Localization.of(context)` / `context.l10n` for the `app` tab; the other tabs are
  read via their generated classes. `make l10n` also runs the round-trip verifier
  (`packages/localization/tool/verify_l10n.dart`).

## Contributing

Contributions are welcome! Feel free to:

- Report bugs and request features via [Issues](https://github.com/zs-dima/auth-app/issues)
- Submit pull requests for improvements
- Suggest and discuss enhancements

## License

This project is licensed under the terms specified in the [LICENSE](LICENSE) file.


