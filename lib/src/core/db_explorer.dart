import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../ui/inspector_screen.dart';
import 'db_adapter.dart';

/// The main controller for the DBViewer package.
///
/// This class manages the registration of adapters and handles navigation
/// to the database inspector screen.
class DBExplorer {
  static final DBExplorer _instance = DBExplorer._internal();
  factory DBExplorer() => _instance;
  DBExplorer._internal();

  static DBExplorer get instance => _instance;

  final List<DBAdapter> _adapters = [];

  /// Returns a copy of the registered adapters.
  List<DBAdapter> get adapters => List.unmodifiable(_adapters);

  /// Registers a database adapter.
  ///
  /// [adapter] - The adapter to register
  ///
  /// Multiple adapters can be registered and will be shown as separate tabs
  /// in the inspector panel.
  static void registerAdapter(DBAdapter adapter) {
    instance._adapters.add(adapter);
    if (kDebugMode) {
      print('DBViewer: Registered adapter "${adapter.name}"');
    }
  }

  /// Removes a registered adapter.
  ///
  /// [adapter] - The adapter to remove
  static void unregisterAdapter(DBAdapter adapter) {
    instance._adapters.remove(adapter);
    if (kDebugMode) {
      print('DBViewer: Unregistered adapter "${adapter.name}"');
    }
  }

  /// Removes all registered adapters.
  static void clearAdapters() {
    for (final adapter in instance._adapters) {
      adapter.dispose();
    }
    instance._adapters.clear();
    if (kDebugMode) {
      print('DBViewer: Cleared all adapters');
    }
  }

  /// Opens the inspector panel.
  ///
  /// In debug mode, this will navigate to a full-screen database inspector.
  /// In release mode, this is a no-op for security.
  ///
  /// If no adapters are registered, this will show a message to the user.
  static void open([BuildContext? context]) {
    if (!kDebugMode) {
      // No-op in release mode for security
      return;
    }

    // Use provided context or try to find one
    final BuildContext? targetContext = context ?? _findContext();
    if (targetContext == null) {
      if (kDebugMode) {
        print(
            'DBViewer: Cannot open - no valid context found. Try calling DBViewer.open(context) with a valid BuildContext.');
      }
      return;
    }

    if (instance._adapters.isEmpty) {
      // Show a snackbar indicating no adapters are registered
      ScaffoldMessenger.of(targetContext).showSnackBar(
        const SnackBar(
          content: Text(
              'No database adapters registered. Use DBViewer.registerAdapter() first.'),
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    instance._navigateToInspector(targetContext);
  }

  /// Closes the inspector panel.
  static void close() {
    // Navigation-based approach doesn't need explicit close
    // The back button or navigation will handle it
  }

  /// Toggles the inspector panel open/closed state.
  static void toggle([BuildContext? context]) {
    // For navigation-based approach, just open (close is handled by navigation)
    open(context);
  }

  void _navigateToInspector(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => InspectorScreen(adapters: _adapters),
        settings: const RouteSettings(name: '/local_db_explorer'),
      ),
    );

    if (kDebugMode) {
      print('DBViewer: Navigated to inspector screen');
    }
  }

  /// Finds a valid BuildContext to use for navigation.
  static BuildContext? _findContext() {
    try {
      // Try to get context from the current focus
      final focusContext =
          WidgetsBinding.instance.focusManager.primaryFocus?.context;
      if (focusContext != null) {
        return focusContext;
      }

      // Try to get context from the root element
      final rootElement = WidgetsBinding.instance.rootElement;
      if (rootElement != null) {
        return rootElement;
      }

      return null;
    } catch (e) {
      if (kDebugMode) {
        print('DBViewer: Error finding context: $e');
      }
      return null;
    }
  }

  /// Disposes all resources.
  ///
  /// This should be called when the app is shutting down.
  static Future<void> dispose() async {
    close();
    for (final adapter in instance._adapters) {
      await adapter.dispose();
    }
    instance._adapters.clear();
  }
}
