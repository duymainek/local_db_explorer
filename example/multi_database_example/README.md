# DB Explorer - Multi Database Example

This example demonstrates how to use the `local_db_explorer` package with multiple database types simultaneously, showcasing the power of the adapter-based architecture.

## Features Demonstrated

- **Multiple database types** running concurrently
- **Tabbed interface** in DB Explorer for switching between databases
- **Different data models** for each database type
- **Unified inspection experience** across all database types
- **Cross-database operations** and management

## Database Types & Data

### 1. SQLite Database (Sqflite)
**Tables:**
- **Products**: E-commerce product catalog
  - id, name, price, category, in_stock, created_at
- **Orders**: Purchase records with foreign keys
  - id, product_id, quantity, total_price, order_date

**Use Case:** Transactional data, complex queries, relationships

### 2. Hive Boxes
**Boxes:**
- **Users**: Employee management system
  - id, name, email, role (typed objects)
- **Tasks**: Project management tasks
  - id, title, assigned_to, priority, completed (typed objects)

**Use Case:** Fast local storage, typed objects, offline-first

### 3. SharedPreferences
**Categories:**
- **App Settings**: theme, notifications, language, ui_scale
- **User Preferences**: current_user, remember_login, session_timeout
- **App State**: app_version, last_backup, recent_searches

**Use Case:** Simple key-value storage, app configuration

## Running the Example

1. Make sure you have Flutter installed
2. Navigate to the multi_database_example directory:
   ```bash
   cd examples/multi_database_example
   ```
3. Get dependencies:
   ```bash
   flutter pub get
   ```
4. Generate Hive adapters (if needed):
   ```bash
   flutter packages pub run build_runner build
   ```
5. Run the app:
   ```bash
   flutter run
   ```

## Using the DB Explorer

1. **Open Inspector**: Tap "Open DB Explorer" button
2. **Switch Databases**: Use tabs at the top to switch between:
   - SQLite DB (blue icon)
   - Hive (green icon)  
   - SharedPreferences (orange icon)
3. **Browse Collections**: Each database shows its collections/tables/boxes
4. **View Data**: See different data structures and types
5. **Search & Filter**: Use search across all database types
6. **Edit Records**: Modify data in supported databases
7. **Add Sample Data**: Use "Add Data" to insert into all databases
8. **Reset All**: Use "Reset All" to restore sample data

## Code Highlights

### Registering Multiple Adapters
```dart
// SQLite
DBViewer.registerAdapter(
  SqfliteAdapter(database, databaseName: 'SQLite DB'),
);

// Hive
DBViewer.registerAdapter(
  MockHiveAdapter(userBox, taskBox),
);

// SharedPreferences
DBViewer.registerAdapter(
  MockSharedPreferencesAdapter(prefs),
);
```

### Opening the Inspector
```dart
ElevatedButton(
  onPressed: () {
    DBViewer.open(); // Shows tabbed interface
  },
  child: Text('Open DB Explorer'),
);
```

### Cross-Database Operations
```dart
Future<void> _addSampleData() async {
  // Add to SQLite
  await database.insert('products', productData);
  
  // Add to Hive
  await userBox.put(newId, newUser);
  
  // Add to SharedPreferences
  await prefs.setString('new_setting', 'value');
}
```

## Architecture Benefits

### Unified Interface
- **Same UI** for all database types
- **Consistent operations** (view, edit, delete)
- **Unified search** across different data structures

### Adapter Pattern
- **Pluggable architecture** - easy to add new database types
- **Standardized interface** - same methods for all adapters
- **Type safety** - each adapter handles its own data types

### Development Benefits
- **Single tool** for multiple databases
- **Consistent debugging** experience
- **Easy comparison** between database types
- **Rapid prototyping** with different storage options

## Real-World Use Cases

This multi-database approach is common in Flutter apps:

1. **SQLite**: User data, complex relationships, transactions
2. **Hive**: App state, cached data, offline storage
3. **SharedPreferences**: Settings, simple flags, user preferences

The DB Explorer makes it easy to inspect and debug all these storage layers from a single interface.

## Note

This example uses mock implementations for Hive and SharedPreferences adapters since the actual implementations are still stubs. The mock adapters demonstrate how the real implementations would work and provide a fully functional preview of the multi-database experience.

The inspector will only open in debug mode for security.