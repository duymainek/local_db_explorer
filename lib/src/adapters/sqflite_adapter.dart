import 'package:flutter/foundation.dart';
import '../core/db_adapter.dart';

/// Adapter for Sqflite databases.
///
/// This adapter allows viewing and editing SQLite databases managed by the sqflite package.
/// Note: This is a stub implementation that requires the sqflite package to be added
/// as a dependency in the consuming app.
class SqfliteAdapter extends DBAdapter {
  final dynamic _database;
  final String _databaseName;

  /// Creates a new SqfliteAdapter.
  ///
  /// [database] - The sqflite Database instance
  /// [databaseName] - Optional name for this database (defaults to "SQLite")
  SqfliteAdapter(this._database, {String? databaseName})
      : _databaseName = databaseName ?? 'SQLite';

  @override
  String get name => _databaseName;

  @override
  Future<List<String>> listCollections() async {
    try {
      // Query sqlite_master table to get all table names
      final List<Map<String, dynamic>> tables = await _database.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%'",
      );

      return tables.map((table) => table['name'] as String).toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error listing collections: $e');
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
      String query = 'SELECT * FROM $collection';
      List<dynamic> arguments = [];

      if (limit != null) {
        query += ' LIMIT ?';
        arguments.add(limit);

        if (offset != null) {
          query += ' OFFSET ?';
          arguments.add(offset);
        }
      }

      final List<Map<String, dynamic>> results = await _database.rawQuery(
        query,
        arguments.isEmpty ? null : arguments,
      );

      return results;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting data from $collection: $e');
      }
      return [];
    }
  }

  @override
  Future<void> put(String collection, Map<String, dynamic> record) async {
    try {
      // First, try to get the table schema to understand the primary key
      final List<Map<String, dynamic>> tableInfo = await _database.rawQuery(
        'PRAGMA table_info($collection)',
      );

      // Find primary key column(s)
      final primaryKeys = tableInfo
          .where((column) => column['pk'] == 1)
          .map((column) => column['name'] as String)
          .toList();

      if (primaryKeys.isEmpty) {
        // No primary key, just insert
        await _database.insert(collection, record);
      } else {
        // Check if record with this primary key exists
        String whereClause = primaryKeys.map((key) => '$key = ?').join(' AND ');
        List<dynamic> whereArgs =
            primaryKeys.map((key) => record[key]).toList();

        final existing = await _database.query(
          collection,
          where: whereClause,
          whereArgs: whereArgs,
          limit: 1,
        );

        if (existing.isEmpty) {
          // Insert new record
          await _database.insert(collection, record);
        } else {
          // Update existing record
          await _database.update(
            collection,
            record,
            where: whereClause,
            whereArgs: whereArgs,
          );
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error putting data to $collection: $e');
      }
      rethrow;
    }
  }

  @override
  Future<void> delete(String collection, dynamic key) async {
    try {
      // Get table schema to find primary key
      final List<Map<String, dynamic>> tableInfo = await _database.rawQuery(
        'PRAGMA table_info($collection)',
      );

      final primaryKeys = tableInfo
          .where((column) => column['pk'] == 1)
          .map((column) => column['name'] as String)
          .toList();

      if (primaryKeys.isEmpty) {
        throw Exception('Cannot delete from table without primary key');
      }

      String whereClause;
      List<dynamic> whereArgs;

      if (primaryKeys.length == 1) {
        // Single primary key
        whereClause = '${primaryKeys.first} = ?';
        whereArgs = [key];
      } else {
        // Composite primary key - key should be a Map
        if (key is! Map<String, dynamic>) {
          throw ArgumentError('For composite primary key, key must be a Map');
        }
        whereClause = primaryKeys.map((k) => '$k = ?').join(' AND ');
        whereArgs = primaryKeys.map((k) => key[k]).toList();
      }

      await _database.delete(
        collection,
        where: whereClause,
        whereArgs: whereArgs,
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting from $collection: $e');
      }
      rethrow;
    }
  }

  @override
  Future<void> dispose() async {
    // Note: We don't close the database here as it might be used elsewhere
    // The consuming app is responsible for managing the database lifecycle
  }
}
