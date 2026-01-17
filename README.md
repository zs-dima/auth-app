# Auth App

A cross-platform Flutter client for authentication and user management via gRPC services.

## Backend Services

Rust gRPC service: [zs-dima/auth-service-rs](https://github.com/zs-dima/auth-service-rs)
Go gRPC service:   [zs-dima/auth-service](https://github.com/zs-dima/auth-service)

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

- [Flutter SDK](https://flutter.dev/docs/get-started/install) (3.38+)
- [Dart SDK](https://dart.dev/get-dart) (3.8+)
- Running backend service (Rust or Go)

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
flutter run -d chrome --dart-define-from-file=config/development.env

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
├── model/              # Data models
├── tool/               # Development tools
└── ui/                 # UI components library
```

## Contributing

Contributions are welcome! Feel free to:

- Report bugs and request features via [Issues](https://github.com/zs-dima/auth-app/issues)
- Submit pull requests for improvements
- Suggest and discuss enhancements

## License

This project is licensed under the terms specified in the [LICENSE](LICENSE) file.


