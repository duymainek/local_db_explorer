# DB Explorer Examples

This directory contains comprehensive examples demonstrating the `local_db_explorer` package with different database types and use cases.

## Available Examples

### 1. 📱 [Basic Sqflite Example](../example/)
**Location**: `example/`  
**Database**: SQLite (Sqflite)  
**Complexity**: Basic  

Demonstrates the core functionality with a simple SQLite database:
- Users and Posts tables with relationships
- Basic CRUD operations
- Single database adapter

**Perfect for**: Getting started with DB Explorer

---

### 2. 📦 [Hive Example](hive_example/)
**Location**: `examples/hive_example/`  
**Database**: Hive  
**Complexity**: Intermediate  

Shows how to inspect Hive boxes with typed objects:
- User and Post objects with Hive adapters
- Settings box with key-value pairs
- Mock HiveAdapter implementation

**Perfect for**: Hive users, NoSQL storage patterns

---

### 3. ⚙️ [SharedPreferences Example](shared_preferences_example/)
**Location**: `examples/shared_preferences_example/`  
**Database**: SharedPreferences  
**Complexity**: Basic  

Demonstrates preference inspection and management:
- All SharedPreferences data types
- App settings and user preferences
- Mock SharedPreferencesAdapter implementation

**Perfect for**: App configuration debugging

---

### 4. 🎛️ [Multi-Database Example](multi_database_example/)
**Location**: `examples/multi_database_example/`  
**Database**: SQLite + Hive + SharedPreferences  
**Complexity**: Advanced  

Showcases the full power of the adapter architecture:
- Three databases running simultaneously
- Tabbed interface in DB Explorer
- Cross-database operations
- Real-world data models

**Perfect for**: Complex apps, architecture demonstration

## Quick Start

Choose the example that matches your use case:

```bash
# Basic SQLite example
cd example
flutter run

# Hive example
cd examples/hive_example
flutter pub get
flutter run

# SharedPreferences example
cd examples/shared_preferences_example
flutter pub get
flutter run

# Multi-database example
cd examples/multi_database_example
flutter pub get
flutter run
```

## Example Comparison

| Example | Databases | Adapters | Use Case |
|---------|-----------|----------|----------|
| Basic | SQLite | 1 (Real) | Learning, simple apps |
| Hive | Hive | 1 (Mock) | NoSQL, typed objects |
| SharedPreferences | Preferences | 1 (Mock) | App settings |
| Multi-Database | All 3 | 3 (1 Real, 2 Mock) | Complex apps, demos |

## Development Status

- ✅ **SqfliteAdapter**: Fully implemented and functional
- 🚧 **HiveAdapter**: Stub implementation (examples use mock)
- 🚧 **SharedPreferencesAdapter**: Stub implementation (examples use mock)

The mock implementations in the examples demonstrate exactly how the real adapters will work once implemented.

## Contributing

Want to help complete the adapter implementations? Check out:

1. `lib/src/adapters/hive_adapter.dart` - Needs full Hive integration
2. `lib/src/adapters/shared_preferences_adapter.dart` - Needs full SharedPreferences integration

The examples provide perfect test cases and expected behavior for these implementations.

## Example Features

All examples include:

- 🔍 **DB Explorer Integration** - Open inspector with a button
- 📊 **Sample Data** - Pre-populated realistic data
- ➕ **Add Data** - Dynamic data insertion
- 🔄 **Reset Data** - Restore sample data
- 📱 **Material Design** - Beautiful, responsive UI
- 🔒 **Debug Mode Only** - Secure by default

## Architecture Insights

The examples demonstrate key architectural patterns:

### Single Responsibility
Each adapter handles one database type with a consistent interface.

### Adapter Pattern
Different storage mechanisms unified under a common API.

### Overlay UI
Non-intrusive inspection that doesn't affect app navigation.

### Type Safety
Each adapter handles its own data types and serialization.

### Debug Security
All functionality disabled in release builds.

## Next Steps

1. **Try the examples** to understand DB Explorer capabilities
2. **Integrate into your app** using the pattern that fits your needs
3. **Contribute** by helping implement the remaining adapters
4. **Extend** by creating adapters for other database types (Isar, ObjectBox, etc.)

Happy debugging! 🐛🔍