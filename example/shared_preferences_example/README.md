# DB Explorer - SharedPreferences Example

This example demonstrates how to use the `local_db_explorer` package with SharedPreferences.

## Features Demonstrated

- Creating and populating SharedPreferences with various data types
- Registering SharedPreferences with DBViewer
- Opening the inspector panel to view preferences data
- Adding new preferences dynamically
- Resetting the preferences

## SharedPreferences Data Types

The example demonstrates all supported SharedPreferences types:

### String Values
- User name, email, theme settings
- JSON strings for complex data
- Timestamps and identifiers

### Integer Values
- User age, app launch count
- Cache sizes and counters

### Double Values
- Font sizes, measurements
- Calculated values

### Boolean Values
- Feature flags, user preferences
- State indicators

### String Lists
- Arrays of favorite items
- Configuration lists

## Running the Example

1. Make sure you have Flutter installed
2. Navigate to the shared_preferences_example directory:
   ```bash
   cd examples/shared_preferences_example
   ```
3. Get dependencies:
   ```bash
   flutter pub get
   ```
4. Run the app:
   ```bash
   flutter run
   ```

## Using the DB Explorer

1. Tap the "Open DB Explorer" button
2. View the "preferences" collection in the left sidebar
3. Browse all key-value pairs in the main table
4. See the data type for each preference
5. Use the search box to filter preferences
6. Click on records to view details
7. Edit or delete preferences using the action buttons
8. Add new preferences with the "Add Setting" button
9. Reset data with the "Reset Data" button

## Code Highlights

### Initializing SharedPreferences
```dart
final prefs = await SharedPreferences.getInstance();
```

### Setting Different Data Types
```dart
await prefs.setString('user_name', 'John Doe');
await prefs.setInt('user_age', 30);
await prefs.setBool('is_logged_in', true);
await prefs.setDouble('font_size', 16.0);
await prefs.setStringList('favorite_colors', ['blue', 'green', 'red']);
```

### Registering with DBViewer
```dart
DBViewer.registerAdapter(
  MockSharedPreferencesAdapter(prefs),
);
```

### Opening the Inspector
```dart
ElevatedButton(
  onPressed: () {
    DBViewer.open();
  },
  child: Text('Open DB Explorer'),
);
```

## Data Structure

In the DB Explorer, SharedPreferences data is displayed as a single "preferences" collection with the following structure:

| Column | Description |
|--------|-------------|
| key    | The preference key |
| value  | The stored value |
| type   | The data type (String, int, bool, etc.) |

## Note

This example uses a mock SharedPreferencesAdapter implementation since the actual SharedPreferencesAdapter is still a stub. The mock adapter demonstrates how the real implementation would work:

- Lists "preferences" as the single collection
- Converts all preference types to a consistent format
- Handles CRUD operations on preferences
- Supports all SharedPreferences data types
- Maintains type information for proper serialization

The inspector will only open in debug mode for security.