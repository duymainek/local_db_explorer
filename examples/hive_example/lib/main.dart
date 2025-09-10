import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:local_db_explorer/local_db_explorer.dart';
import 'models/user.dart';
import 'models/post.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();

  // Register adapters
  Hive.registerAdapter(UserAdapter());
  Hive.registerAdapter(PostAdapter());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DB Explorer - Hive Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'DB Explorer - Hive Example'),
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
  Box<User>? _userBox;
  Box<Post>? _postBox;
  Box? _settingsBox;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeHive();
  }

  Future<void> _initializeHive() async {
    try {
      // Open boxes
      _userBox = await Hive.openBox<User>('users');
      _postBox = await Hive.openBox<Post>('posts');
      _settingsBox = await Hive.openBox('settings');

      // Register with DBExplorer using the real HiveAdapter
      DBExplorer.registerAdapter(
        HiveAdapter({
          'users': _userBox!,
          'posts': _postBox!,
          'settings': _settingsBox!,
        }),
      );

      // Insert sample data if boxes are empty
      if (_userBox!.isEmpty) {
        await _insertSampleData();
      }

      setState(() {
        _isInitialized = true;
      });
    } catch (e) {
      debugPrint('Error initializing Hive: $e');
    }
  }

  Future<void> _insertSampleData() async {
    // Insert sample users
    final users = [
      User(
        id: 1,
        name: 'John Doe',
        email: 'john@example.com',
        age: 30,
        createdAt: DateTime.now(),
      ),
      User(
        id: 2,
        name: 'Jane Smith',
        email: 'jane@example.com',
        age: 25,
        createdAt: DateTime.now(),
      ),
      User(
        id: 3,
        name: 'Bob Johnson',
        email: 'bob@example.com',
        age: 35,
        createdAt: DateTime.now(),
      ),
    ];

    for (final user in users) {
      await _userBox!.put(user.id, user);
    }

    // Insert sample posts
    final posts = [
      Post(
        id: 1,
        userId: 1,
        title: 'First Post',
        content: 'This is my first post!',
        createdAt: DateTime.now(),
      ),
      Post(
        id: 2,
        userId: 1,
        title: 'Another Post',
        content: 'Here is another post with some content.',
        createdAt: DateTime.now(),
      ),
      Post(
        id: 3,
        userId: 2,
        title: 'Jane\'s Post',
        content: 'Hello from Jane!',
        createdAt: DateTime.now(),
      ),
      Post(
        id: 4,
        userId: 3,
        title: 'Bob\'s Thoughts',
        content: 'Some thoughts from Bob...',
        createdAt: DateTime.now(),
      ),
    ];

    for (final post in posts) {
      await _postBox!.put(post.id, post);
    }

    // Insert sample settings
    await _settingsBox!.put('theme', 'dark');
    await _settingsBox!.put('notifications', true);
    await _settingsBox!.put('language', 'en');
    await _settingsBox!.put('version', '1.0.0');
  }

  Future<void> _addRandomUser() async {
    if (_userBox == null) return;

    final names = ['Alice', 'Charlie', 'David', 'Eva', 'Frank', 'Grace'];
    final domains = ['example.com', 'test.com', 'demo.com'];

    final name = names[DateTime.now().millisecondsSinceEpoch % names.length];
    final email =
        '${name.toLowerCase()}${DateTime.now().millisecondsSinceEpoch}@${domains[DateTime.now().millisecondsSinceEpoch % domains.length]}';
    final age = 20 + (DateTime.now().millisecondsSinceEpoch % 40);
    final id = _userBox!.length + 1;

    try {
      final user = User(
        id: id,
        name: name,
        email: email,
        age: age,
        createdAt: DateTime.now(),
      );

      await _userBox!.put(id, user);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Added user: $name')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding user: $e')),
        );
      }
    }
  }

  Future<void> _clearDatabase() async {
    if (_userBox == null || _postBox == null || _settingsBox == null) return;

    try {
      await _userBox!.clear();
      await _postBox!.clear();
      await _settingsBox!.clear();
      await _insertSampleData();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Hive boxes reset with sample data')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error resetting boxes: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
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
                Icons.inventory,
                size: 80,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(height: 20),
              Text(
                'DB Explorer - Hive Example',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 10),
              Text(
                'This example demonstrates the local_db_explorer package with Hive boxes.',
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
                      onPressed: _addRandomUser,
                      icon: const Icon(Icons.person_add),
                      label: const Text('Add User'),
                    ),
                    ElevatedButton.icon(
                      onPressed: _clearDatabase,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Reset Data'),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Sample Hive Boxes:',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        const SizedBox(height: 8),
                        const Text('• Users box with User objects'),
                        const Text('• Posts box with Post objects'),
                        const Text('• Settings box with key-value pairs'),
                        const SizedBox(height: 12),
                        Text(
                          'Click "Open DB Explorer" to inspect the Hive boxes!',
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.w500,
                          ),
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
}
