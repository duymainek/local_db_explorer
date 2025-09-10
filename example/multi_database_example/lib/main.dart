import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart';
import 'package:local_db_explorer/local_db_explorer.dart';
import 'models/user.dart';
import 'models/task.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();
  Hive.registerAdapter(UserAdapter());
  Hive.registerAdapter(TaskAdapter());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DB Explorer - Multi Database Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.purple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'DB Explorer - Multi Database Example'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // SQLite
  Database? _database;

  // Hive
  Box<User>? _userBox;
  Box<Task>? _taskBox;

  // SharedPreferences
  SharedPreferences? _prefs;

  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeDatabases();
  }

  Future<void> _initializeDatabases() async {
    try {
      // Initialize SQLite
      await _initializeSQLite();

      // Initialize Hive
      await _initializeHive();

      // Initialize SharedPreferences
      await _initializeSharedPreferences();

      // Register all adapters with DBViewer
      if (_database != null) {
        DBExplorer.registerAdapter(
          SqfliteAdapter(_database!, databaseName: 'SQLite DB'),
        );
      }

      if (_userBox != null && _taskBox != null) {
        DBExplorer.registerAdapter(
          HiveAdapter({
            'users': _userBox!,
            'tasks': _taskBox!,
          }),
        );
      }

      if (_prefs != null) {
        DBExplorer.registerAdapter(
          SharedPreferencesAdapter(_prefs!),
        );
      }

      setState(() {
        _isInitialized = true;
      });
    } catch (e) {
      debugPrint('Error initializing databases: $e');
    }
  }

  Future<void> _initializeSQLite() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'multi_example.db');

    _database = await openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int version) async {
        await db.execute('''
          CREATE TABLE products (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            price REAL NOT NULL,
            category TEXT,
            in_stock INTEGER DEFAULT 1,
            created_at TEXT DEFAULT CURRENT_TIMESTAMP
          )
        ''');

        await db.execute('''
          CREATE TABLE orders (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            product_id INTEGER NOT NULL,
            quantity INTEGER NOT NULL,
            total_price REAL NOT NULL,
            order_date TEXT DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (product_id) REFERENCES products (id)
          )
        ''');

        // Insert sample data
        await _insertSQLiteData(db);
      },
    );
  }

  Future<void> _insertSQLiteData(Database db) async {
    final products = [
      {'name': 'Laptop', 'price': 999.99, 'category': 'Electronics'},
      {'name': 'Mouse', 'price': 29.99, 'category': 'Electronics'},
      {'name': 'Keyboard', 'price': 79.99, 'category': 'Electronics'},
      {'name': 'Monitor', 'price': 299.99, 'category': 'Electronics'},
    ];

    for (final product in products) {
      await db.insert('products', product);
    }

    final orders = [
      {'product_id': 1, 'quantity': 1, 'total_price': 999.99},
      {'product_id': 2, 'quantity': 2, 'total_price': 59.98},
      {'product_id': 3, 'quantity': 1, 'total_price': 79.99},
    ];

    for (final order in orders) {
      await db.insert('orders', order);
    }
  }

  Future<void> _initializeHive() async {
    _userBox = await Hive.openBox<User>('users');
    _taskBox = await Hive.openBox<Task>('tasks');

    if (_userBox!.isEmpty) {
      await _insertHiveData();
    }
  }

  Future<void> _insertHiveData() async {
    final users = [
      User(
          id: 1,
          name: 'Alice Johnson',
          email: 'alice@company.com',
          role: 'Manager'),
      User(
          id: 2,
          name: 'Bob Smith',
          email: 'bob@company.com',
          role: 'Developer'),
      User(
          id: 3,
          name: 'Carol Davis',
          email: 'carol@company.com',
          role: 'Designer'),
    ];

    for (final user in users) {
      await _userBox!.put(user.id, user);
    }

    final tasks = [
      Task(
          id: 1,
          title: 'Design UI',
          assignedTo: 3,
          priority: 'High',
          completed: false),
      Task(
          id: 2,
          title: 'Implement API',
          assignedTo: 2,
          priority: 'Medium',
          completed: true),
      Task(
          id: 3,
          title: 'Review Code',
          assignedTo: 1,
          priority: 'Low',
          completed: false),
      Task(
          id: 4,
          title: 'Write Tests',
          assignedTo: 2,
          priority: 'High',
          completed: false),
    ];

    for (final task in tasks) {
      await _taskBox!.put(task.id, task);
    }
  }

  Future<void> _initializeSharedPreferences() async {
    _prefs = await SharedPreferences.getInstance();

    if (_prefs!.getKeys().isEmpty) {
      await _insertPreferencesData();
    }
  }

  Future<void> _insertPreferencesData() async {
    // App settings
    await _prefs!.setString('app_theme', 'light');
    await _prefs!.setBool('push_notifications', true);
    await _prefs!.setString('default_language', 'en');
    await _prefs!.setDouble('ui_scale', 1.0);

    // User preferences
    await _prefs!.setString('current_user', 'alice@company.com');
    await _prefs!.setBool('remember_login', true);
    await _prefs!.setInt('session_timeout', 3600);

    // App state
    await _prefs!.setInt('app_version', 100);
    await _prefs!.setString('last_backup', DateTime.now().toIso8601String());
    await _prefs!
        .setStringList('recent_searches', ['laptop', 'mouse', 'keyboard']);
  }

  Future<void> _addSampleData() async {
    // Add to SQLite
    if (_database != null) {
      await _database!.insert('products', {
        'name': 'Webcam',
        'price': 89.99,
        'category': 'Electronics',
      });
    }

    // Add to Hive
    if (_userBox != null) {
      final newId = _userBox!.length + 1;
      await _userBox!.put(
          newId,
          User(
            id: newId,
            name: 'New User',
            email: 'newuser@company.com',
            role: 'Intern',
          ));
    }

    // Add to SharedPreferences
    if (_prefs != null) {
      await _prefs!.setString(
          'new_setting_${DateTime.now().millisecondsSinceEpoch}', 'new_value');
    }
  }

  Future<void> _clearAllData() async {
    try {
      // Clear SQLite
      if (_database != null) {
        await _database!.delete('orders');
        await _database!.delete('products');
        await _insertSQLiteData(_database!);
      }

      // Clear Hive
      if (_userBox != null && _taskBox != null) {
        await _userBox!.clear();
        await _taskBox!.clear();
        await _insertHiveData();
      }

      // Clear SharedPreferences
      if (_prefs != null) {
        await _prefs!.clear();
        await _insertPreferencesData();
      }
    } catch (e) {
      // Ignore initialization errors for demo purposes
      debugPrint('SharedPreferences initialization error: $e');
    }
  }

  @override
  void dispose() {
    _database?.close();
    Hive.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(
                Icons.dashboard,
                size: 80,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(height: 20),
              Text(
                'Multi Database Example',
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                'This example demonstrates the local_db_explorer package with multiple database types simultaneously.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 40),
              if (!_isInitialized)
                const CircularProgressIndicator()
              else ...[
                ElevatedButton.icon(
                  onPressed: () {
                    DBExplorer.open(context);
                  },
                  icon: const Icon(Icons.visibility),
                  label: const Text('Open DB Explorer'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _addSampleData,
                      icon: const Icon(Icons.add),
                      label: const Text('Add Data'),
                    ),
                    ElevatedButton.icon(
                      onPressed: _clearAllData,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Reset All'),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        _buildDatabaseCard(
                          'SQLite Database',
                          Icons.storage,
                          Colors.blue,
                          [
                            'Products table (e-commerce items)',
                            'Orders table (purchase records)',
                            'Foreign key relationships',
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildDatabaseCard(
                          'Hive Boxes',
                          Icons.inventory,
                          Colors.green,
                          [
                            'Users box (employee data)',
                            'Tasks box (project management)',
                            'Typed object storage',
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildDatabaseCard(
                          'SharedPreferences',
                          Icons.settings,
                          Colors.orange,
                          [
                            'App settings (theme, notifications)',
                            'User preferences (login, timeout)',
                            'App state (version, backups)',
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDatabaseCard(
      String title, IconData icon, Color color, List<String> features) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color),
                const SizedBox(width: 8),
                Text(
                  title,
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...features.map((feature) => Text('• $feature')),
          ],
        ),
      ),
    );
  }
}
