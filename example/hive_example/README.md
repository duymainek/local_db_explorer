# DB Explorer - Hive Example

This example demonstrates how to use the `local_db_explorer` package with Hive boxes.

## Features Demonstrated

- Creating and populating Hive boxes with typed objects
- Using Hive type adapters for custom objects
- Registering Hive boxes with DBViewer
- Opening the inspector panel to view Hive data
- Adding new records dynamically
- Resetting the boxes

## Hive Boxes

The example creates three boxes:

### Users Box
- Type: `Box<User>`
- Contains User objects with fields: id, name, email, age, createdAt
- Uses HiveType adapter for serialization

### Posts Box
- Type: `Box<Post>`
- Contains Post objects with fields: id, userId, title, content, createdAt
- Uses HiveType adapter for serialization

### Settings Box
- Type: `Box` (dynamic)
- Contains key-value pairs for app settings
- Stores primitive types: String, bool, etc.

## Running the Example

1. Make sure you have Flutter installed
2. Navigate to the hive_example directory:
   ```bash
   cd examples/hive_example
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

1. Tap the "Open DB Explorer" button
2. Browse the boxes (users, posts, settings) in the left sidebar
3. View data in the main table
4. Use the search box to filter records
5. Click on records to view details
6. Edit or delete records using the action buttons
7. Add new users with the "Add User" button
8. Reset data with the "Reset Data" button

## Code Highlights

### Initializing Hive
```dart
await Hive.initFlutter();
Hive.registerAdapter(UserAdapter());
Hive.registerAdapter(PostAdapter());
```

### Opening Boxes
```dart
final userBox = await Hive.openBox<User>('users');
final postBox = await Hive.openBox<Post>('posts');
final settingsBox = await Hive.openBox('settings');
```

### Registering with DBViewer
```dart
DBViewer.registerAdapter(
  MockHiveAdapter(userBox, postBox, settingsBox),
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

## Note

This example uses a mock HiveAdapter implementation since the actual HiveAdapter is still a stub. The mock adapter demonstrates how the real implementation would work:

- Lists available boxes as collections
- Converts Hive objects to JSON for display
- Handles CRUD operations on Hive boxes
- Supports both typed boxes (User, Post) and dynamic boxes (settings)

The inspector will only open in debug mode for security.