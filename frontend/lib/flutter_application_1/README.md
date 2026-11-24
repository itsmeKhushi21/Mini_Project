# flutter_application_1

A new Flutter project.

## Source organization

The application code is split into Dart part files under `lib/` while keeping
one shared library for the existing in-memory demo state:

- `main.dart` - imports, part declarations, and app entry point
- `models.dart` - shared records, enums, and data helpers
- `core.dart` - application state, authentication, and role selection
- `admin.dart` - Admin dashboard and management screens
- `manager.dart` - Manager dashboard and management screens
- `citizen.dart` - Citizen screens and feedback flows
- `driver.dart` - Driver dashboard, tasks, issues, and profile screens

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
