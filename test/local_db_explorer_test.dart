import 'package:flutter_test/flutter_test.dart';
import 'package:local_db_explorer/local_db_explorer.dart';

void main() {
  group('DBExplorer', () {
    tearDown(() {
      // Clean up after each test
      DBExplorer.clearAdapters();
    });

    test('should start with no adapters registered', () {
      expect(DBExplorer.instance.adapters, isEmpty);
    });

    test('should register and unregister adapters', () {
      final adapter = MockAdapter();

      DBExplorer.registerAdapter(adapter);
      expect(DBExplorer.instance.adapters, contains(adapter));
      expect(DBExplorer.instance.adapters.length, equals(1));

      DBExplorer.unregisterAdapter(adapter);
      expect(DBExplorer.instance.adapters, isEmpty);
    });

    test('should clear all adapters', () {
      final adapter1 = MockAdapter();
      final adapter2 = MockAdapter();

      DBExplorer.registerAdapter(adapter1);
      DBExplorer.registerAdapter(adapter2);
      expect(DBExplorer.instance.adapters.length, equals(2));

      DBExplorer.clearAdapters();
      expect(DBExplorer.instance.adapters, isEmpty);
    });

    test('should accept optional context parameter', () {
      // This test just verifies the API accepts the parameter
      // In a real widget test, we would test with actual context
      expect(() => DBExplorer.open(null), returnsNormally);
    });
  });

  group('DBAdapter', () {
    test('should have default implementations', () {
      final adapter = MockAdapter();

      expect(adapter.supportsWrite, isTrue);
      expect(adapter.supportsPagination, isTrue);
      expect(adapter.name, equals('Mock'));
    });
  });
}

/// Mock adapter for testing
class MockAdapter extends DBAdapter {
  @override
  String get name => 'Mock';

  @override
  Future<List<String>> listCollections() async {
    return ['collection1', 'collection2'];
  }

  @override
  Future<List<Map<String, dynamic>>> getData(
    String collection, {
    int? limit,
    int? offset,
  }) async {
    return [
      {'id': 1, 'name': 'Test 1'},
      {'id': 2, 'name': 'Test 2'},
    ];
  }

  @override
  Future<void> put(String collection, Map<String, dynamic> record) async {
    // Mock implementation
  }

  @override
  Future<void> delete(String collection, dynamic key) async {
    // Mock implementation
  }
}
