import 'package:flutter/foundation.dart';
import '../core/db_adapter.dart';

/// Adapter for Hive databases.
///
/// This adapter allows viewing and editing Hive boxes.
/// Requires the hive package to be added as a dependency in the consuming app.
class HiveAdapter extends DBAdapter {
  final String _hiveName;
  final Map<String, dynamic> _boxes;

  /// Creates a new HiveAdapter.
  ///
  /// [boxes] - Map of box names to box instances
  /// [hiveName] - Optional name for this Hive instance (defaults to "Hive")
  HiveAdapter(this._boxes, {String? hiveName}) : _hiveName = hiveName ?? 'Hive';

  /// Creates a HiveAdapter with a single box.
  ///
  /// [boxName] - Name of the box
  /// [box] - The box instance
  /// [hiveName] - Optional name for this Hive instance
  HiveAdapter.singleBox(String boxName, dynamic box, {String? hiveName})
      : _boxes = {boxName: box},
        _hiveName = hiveName ?? 'Hive';

  @override
  String get name => _hiveName;

  @override
  Future<List<String>> listCollections() async {
    try {
      return _boxes.keys.toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error listing Hive collections: $e');
      }
      return [];
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getData(
    String collection, {
    int? limit,
    int? offset,
  }) async {
    try {
      final box = _boxes[collection];
      if (box == null) {
        if (kDebugMode) {
          print('Hive box $collection not found');
        }
        return [];
      }

      final List<Map<String, dynamic>> data = [];

      // Get all keys from the box
      final keys = _getBoxKeys(box);

      // Apply offset and limit
      int startIndex = offset ?? 0;
      int endIndex = limit != null ? startIndex + limit : keys.length;
      endIndex = endIndex > keys.length ? keys.length : endIndex;

      if (startIndex >= keys.length) {
        return [];
      }

      final selectedKeys = keys.sublist(startIndex, endIndex);

      for (final key in selectedKeys) {
        final value = _getBoxValue(box, key);
        if (value != null) {
          // Convert value to Map<String, dynamic>
          Map<String, dynamic> record;
          if (value is Map<String, dynamic>) {
            record = Map<String, dynamic>.from(value);
          } else if (value is Map) {
            record = value.map((k, v) => MapEntry(k.toString(), v));
          } else {
            // For primitive values or custom objects, create a record
            record = _convertValueToRecord(key, value);
          }

          // Ensure key is included in the record
          record['_hive_key'] = key;
          data.add(record);
        }
      }

      return data;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting data from Hive collection $collection: $e');
      }
      return [];
    }
  }

  @override
  Future<void> put(String collection, Map<String, dynamic> record) async {
    try {
      final box = _boxes[collection];
      if (box == null) {
        throw ArgumentError('Hive box $collection not found');
      }

      // Extract the key
      dynamic key = record['_hive_key'] ??
          DateTime.now().millisecondsSinceEpoch.toString();

      // Remove the meta key from the record
      final cleanRecord = Map<String, dynamic>.from(record);
      cleanRecord.remove('_hive_key');

      // Put the value in the box
      await _putBoxValue(box, key, cleanRecord);
    } catch (e) {
      if (kDebugMode) {
        print('Error putting data to Hive collection $collection: $e');
      }
      rethrow;
    }
  }

  @override
  Future<void> delete(String collection, dynamic key) async {
    try {
      final box = _boxes[collection];
      if (box == null) {
        throw ArgumentError('Hive box $collection not found');
      }

      // If key is a record, extract the _hive_key
      if (key is Map<String, dynamic> && key.containsKey('_hive_key')) {
        key = key['_hive_key'];
      }

      await _deleteBoxValue(box, key);
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting from Hive collection $collection: $e');
      }
      rethrow;
    }
  }

  @override
  Future<void> dispose() async {
    // Hive boxes are typically managed by the application
    // We don't close them here to avoid interfering with app logic
  }

  /// Helper method to get keys from a box using reflection
  List<dynamic> _getBoxKeys(dynamic box) {
    try {
      // Try to call keys getter
      final keys = box.keys;
      if (keys is Iterable) {
        return keys.toList();
      }
      return [];
    } catch (e) {
      if (kDebugMode) {
        print('Error getting box keys: $e');
      }
      return [];
    }
  }

  /// Helper method to get value from a box using reflection
  dynamic _getBoxValue(dynamic box, dynamic key) {
    try {
      return box.get(key);
    } catch (e) {
      if (kDebugMode) {
        print('Error getting box value for key $key: $e');
      }
      return null;
    }
  }

  /// Helper method to put value in a box using reflection
  Future<void> _putBoxValue(dynamic box, dynamic key, dynamic value) async {
    try {
      await box.put(key, value);
    } catch (e) {
      if (kDebugMode) {
        print('Error putting box value for key $key: $e');
      }
      rethrow;
    }
  }

  /// Helper method to delete value from a box using reflection
  Future<void> _deleteBoxValue(dynamic box, dynamic key) async {
    try {
      await box.delete(key);
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting box value for key $key: $e');
      }
      rethrow;
    }
  }

  /// Convert any value to a Map<String, dynamic> record
  Map<String, dynamic> _convertValueToRecord(dynamic key, dynamic value) {
    if (value == null) {
      return {'key': key, 'value': null, 'type': 'null'};
    }

    // Handle different value types
    if (value is String || value is num || value is bool) {
      return {
        'key': key,
        'value': value,
        'type': value.runtimeType.toString(),
      };
    }

    if (value is List) {
      return {
        'key': key,
        'value': value,
        'type':
            'List<${value.isNotEmpty ? value.first.runtimeType.toString() : 'dynamic'}>',
      };
    }

    if (value is Map) {
      return {
        'key': key,
        'value': value,
        'type':
            'Map<${value.keys.isNotEmpty ? value.keys.first.runtimeType.toString() : 'dynamic'}, ${value.values.isNotEmpty ? value.values.first.runtimeType.toString() : 'dynamic'}>',
      };
    }

    // For custom objects, try to convert using reflection
    try {
      // If the object has a toJson method, use it
      final valueString = value.toString();
      if (valueString.contains('toJson') || _hasMethod(value, 'toJson')) {
        try {
          final json = value.toJson();
          if (json is Map<String, dynamic>) {
            return json;
          }
        } catch (e) {
          // Continue to next method
        }
      }

      // If the object has a toMap method, use it
      if (valueString.contains('toMap') || _hasMethod(value, 'toMap')) {
        try {
          final map = value.toMap();
          if (map is Map<String, dynamic>) {
            return map;
          }
        } catch (e) {
          // Continue to fallback
        }
      }

      // Fallback: create a simple representation
      return {
        'key': key,
        'value': value.toString(),
        'type': value.runtimeType.toString(),
        '_object': true,
      };
    } catch (e) {
      // Final fallback
      return {
        'key': key,
        'value': value.toString(),
        'type': value.runtimeType.toString(),
        '_conversion_error': e.toString(),
      };
    }
  }

  /// Helper method to check if an object has a specific method
  bool _hasMethod(dynamic object, String methodName) {
    try {
      // Simple check - if the object's type string contains the method name
      return object.runtimeType.toString().contains(methodName);
    } catch (e) {
      return false;
    }
  }
}
