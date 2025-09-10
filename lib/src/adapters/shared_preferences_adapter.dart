import 'package:flutter/foundation.dart';
import '../core/db_adapter.dart';

/// Adapter for SharedPreferences.
///
/// This adapter treats SharedPreferences as a single collection with key-value pairs.
/// Requires the shared_preferences package to be added as a dependency in the consuming app.
class SharedPreferencesAdapter extends DBAdapter {
  final dynamic _prefs; // SharedPreferences instance
  final String _prefsName;

  /// Creates a new SharedPreferencesAdapter.
  ///
  /// [prefs] - The SharedPreferences instance
  /// [prefsName] - Optional name for this preferences instance (defaults to "SharedPreferences")
  SharedPreferencesAdapter(this._prefs, {String? prefsName})
      : _prefsName = prefsName ?? 'SharedPreferences';

  @override
  String get name => _prefsName;

  @override
  Future<List<String>> listCollections() async {
    // SharedPreferences is treated as a single collection
    return ['preferences'];
  }

  @override
  Future<List<Map<String, dynamic>>> getData(
    String collection, {
    int? limit,
    int? offset,
  }) async {
    try {
      if (collection != 'preferences') {
        return [];
      }

      final List<Map<String, dynamic>> data = [];

      // Get all keys from SharedPreferences
      final Set<String> keys = _getKeys();
      final keysList = keys.toList()..sort(); // Sort for consistent display

      // Apply pagination
      int startIndex = offset ?? 0;
      int endIndex = limit != null ? startIndex + limit : keysList.length;
      endIndex = endIndex > keysList.length ? keysList.length : endIndex;

      if (startIndex >= keysList.length) {
        return [];
      }

      final selectedKeys = keysList.sublist(startIndex, endIndex);

      for (final key in selectedKeys) {
        final value = _getValue(key);
        final type = _getValueType(key, value);

        data.add({
          'key': key,
          'value': value,
          'type': type,
        });
      }

      return data;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting SharedPreferences data: $e');
      }
      return [];
    }
  }

  @override
  Future<void> put(String collection, Map<String, dynamic> record) async {
    try {
      if (collection != 'preferences') {
        throw ArgumentError(
            'SharedPreferences only supports "preferences" collection');
      }

      final String key = record['key'] as String;
      final dynamic value = record['value'];
      final String? type = record['type'] as String?;

      // Set the value based on its type
      await _setValue(key, value, type);
    } catch (e) {
      if (kDebugMode) {
        print('Error putting SharedPreferences data: $e');
      }
      rethrow;
    }
  }

  @override
  Future<void> delete(String collection, dynamic key) async {
    try {
      if (collection != 'preferences') {
        throw ArgumentError(
            'SharedPreferences only supports "preferences" collection');
      }

      String keyString;
      if (key is Map<String, dynamic> && key.containsKey('key')) {
        keyString = key['key'] as String;
      } else {
        keyString = key.toString();
      }

      await _removeKey(keyString);
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting SharedPreferences key: $e');
      }
      rethrow;
    }
  }

  @override
  bool get supportsPagination => true;

  @override
  Future<void> dispose() async {
    // SharedPreferences doesn't need explicit disposal
  }

  /// Get all keys from SharedPreferences
  Set<String> _getKeys() {
    try {
      return _prefs.getKeys();
    } catch (e) {
      if (kDebugMode) {
        print('Error getting SharedPreferences keys: $e');
      }
      return <String>{};
    }
  }

  /// Get value for a specific key
  dynamic _getValue(String key) {
    try {
      return _prefs.get(key);
    } catch (e) {
      if (kDebugMode) {
        print('Error getting SharedPreferences value for key $key: $e');
      }
      return null;
    }
  }

  /// Get the type of a value
  String _getValueType(String key, dynamic value) {
    if (value == null) return 'null';

    // Check specific SharedPreferences types
    try {
      if (_prefs.getString(key) != null) return 'String';
    } catch (e) {
      // Not a string
    }

    try {
      if (_prefs.getInt(key) != null) return 'int';
    } catch (e) {
      // Not an int
    }

    try {
      if (_prefs.getDouble(key) != null) return 'double';
    } catch (e) {
      // Not a double
    }

    try {
      if (_prefs.getBool(key) != null) return 'bool';
    } catch (e) {
      // Not a bool
    }

    try {
      if (_prefs.getStringList(key) != null) return 'List<String>';
    } catch (e) {
      // Not a string list
    }

    // Fallback to runtime type
    return value.runtimeType.toString();
  }

  /// Set value for a specific key
  Future<void> _setValue(String key, dynamic value, String? type) async {
    try {
      // Determine the type and set accordingly
      final actualType = type ?? value.runtimeType.toString();

      switch (actualType) {
        case 'String':
          await _prefs.setString(key, value as String);
          break;
        case 'int':
          await _prefs.setInt(key, value as int);
          break;
        case 'double':
          await _prefs.setDouble(key, value as double);
          break;
        case 'bool':
          await _prefs.setBool(key, value as bool);
          break;
        case 'List<String>':
          if (value is List) {
            await _prefs.setStringList(key, value.cast<String>());
          } else {
            throw ArgumentError(
                'Value must be a List<String> for type List<String>');
          }
          break;
        default:
          // Try to infer type from value
          if (value is String) {
            await _prefs.setString(key, value);
          } else if (value is int) {
            await _prefs.setInt(key, value);
          } else if (value is double) {
            await _prefs.setDouble(key, value);
          } else if (value is bool) {
            await _prefs.setBool(key, value);
          } else if (value is List<String>) {
            await _prefs.setStringList(key, value);
          } else if (value is List) {
            // Try to convert to List<String>
            final stringList = value.map((e) => e.toString()).toList();
            await _prefs.setStringList(key, stringList);
          } else {
            // Convert to string as fallback
            await _prefs.setString(key, value.toString());
          }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error setting SharedPreferences value for key $key: $e');
      }
      rethrow;
    }
  }

  /// Remove a key from SharedPreferences
  Future<void> _removeKey(String key) async {
    try {
      await _prefs.remove(key);
    } catch (e) {
      if (kDebugMode) {
        print('Error removing SharedPreferences key $key: $e');
      }
      rethrow;
    }
  }
}
