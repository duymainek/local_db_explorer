/// A lightweight in-app database viewer/inspector for debugging local storage.
///
/// This package provides a simple way to inspect and debug databases like
/// Sqflite, Hive, and SharedPreferences during development.
///
/// ## Usage
///
/// 1. Register database adapters:
/// ```dart
/// // For Sqflite
/// DBViewer.registerAdapter(SqfliteAdapter(database));
///
/// // For Hive (when implemented)
/// DBViewer.registerAdapter(HiveAdapter(hive));
///
/// // For SharedPreferences (when implemented)
/// DBViewer.registerAdapter(SharedPreferencesAdapter(prefs));
/// ```
///
/// 2. Open the inspector:
/// ```dart
/// ElevatedButton(
///   onPressed: () {
///     DBViewer.open();
///   },
///   child: Text("Open DB Explorer"),
/// );
/// ```
///
/// ## Security
///
/// The inspector only works in debug mode (`kDebugMode`). In release builds,
/// all DBViewer methods are no-ops to prevent accidental exposure of database
/// contents.
library local_db_explorer;

// Core exports
export 'src/core/db_adapter.dart';
export 'src/core/db_explorer.dart' show DBExplorer;

// Adapter exports
export 'src/adapters/sqflite_adapter.dart';
export 'src/adapters/hive_adapter.dart';
export 'src/adapters/shared_preferences_adapter.dart';

// UI exports (typically not needed by consumers, but available for customization)
export 'src/ui/inspector_screen.dart';
