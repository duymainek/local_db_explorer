/// Abstract base class for database adapters.
///
/// Each adapter implements this interface to provide a unified way
/// to access different database types (Sqflite, Hive, SharedPreferences, etc.).
abstract class DBAdapter {
  /// The name of this adapter (e.g., "Sqflite", "Hive", "SharedPreferences")
  String get name;

  /// Lists all available collections/tables in this database.
  ///
  /// Returns a list of collection names that can be queried.
  Future<List<String>> listCollections();

  /// Retrieves data from the specified collection.
  ///
  /// [collection] - The name of the collection/table to query
  /// [limit] - Maximum number of records to return (optional)
  /// [offset] - Number of records to skip (optional)
  ///
  /// Returns a list of records as Map<String, dynamic>.
  Future<List<Map<String, dynamic>>> getData(
    String collection, {
    int? limit,
    int? offset,
  });

  /// Inserts or updates a record in the specified collection.
  ///
  /// [collection] - The name of the collection/table
  /// [record] - The data to insert/update
  ///
  /// Throws [UnsupportedError] if the adapter doesn't support write operations.
  Future<void> put(String collection, Map<String, dynamic> record);

  /// Deletes a record from the specified collection.
  ///
  /// [collection] - The name of the collection/table
  /// [key] - The key/id of the record to delete
  ///
  /// Throws [UnsupportedError] if the adapter doesn't support delete operations.
  Future<void> delete(String collection, dynamic key);

  /// Returns true if this adapter supports write operations (put/delete).
  bool get supportsWrite => true;

  /// Returns true if this adapter supports pagination.
  bool get supportsPagination => true;

  /// Closes any resources used by this adapter.
  Future<void> dispose() async {}
}
