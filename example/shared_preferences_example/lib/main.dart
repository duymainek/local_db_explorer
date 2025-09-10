import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:local_db_explorer/local_db_explorer.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DB Explorer - SharedPreferences Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'DB Explorer - SharedPreferences Example'),
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
  SharedPreferences? _prefs;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeSharedPreferences();
  }

  Future<void> _initializeSharedPreferences() async {
    try {
      _prefs = await SharedPreferences.getInstance();

      // Register with DBExplorer using the real SharedPreferencesAdapter
      DBExplorer.registerAdapter(
        SharedPreferencesAdapter(_prefs!),
      );

      // Insert sample data if preferences are empty
      if (_prefs!.getKeys().isEmpty) {
        await _insertSampleData();
      }

      setState(() {
        _isInitialized = true;
      });
    } catch (e) {
      debugPrint('Error initializing SharedPreferences: $e');
    }
  }

  Future<void> _insertSampleData() async {
    if (_prefs == null) return;

    // User preferences
    await _prefs!.setString('user_name', 'John Doe');
    await _prefs!.setString('user_email', 'john@example.com');
    await _prefs!.setInt('user_age', 30);
    await _prefs!.setBool('is_logged_in', true);

    // App settings
    await _prefs!.setString('theme', 'dark');
    await _prefs!.setBool('notifications_enabled', true);
    await _prefs!.setString('language', 'en');
    await _prefs!.setDouble('font_size', 16.0);

    // App data
    await _prefs!.setInt('app_launches', 42);
    await _prefs!.setString('last_sync', DateTime.now().toIso8601String());
    await _prefs!.setStringList('favorite_colors', ['blue', 'green', 'red']);
    await _prefs!.setBool('first_time_user', false);

    // Cache data
    await _prefs!.setString('cached_data',
        '{"version": "1.0", "timestamp": "${DateTime.now().millisecondsSinceEpoch}"}');
    await _prefs!.setInt('cache_size', 1024);
  }

  Future<void> _addRandomPreference() async {
    if (_prefs == null) return;

    final keys = ['setting_${DateTime.now().millisecondsSinceEpoch}'];
    final values = ['value_${DateTime.now().millisecondsSinceEpoch}'];

    final key = keys.first;
    final value = values.first;

    try {
      await _prefs!.setString(key, value);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Added preference: $key')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding preference: $e')),
        );
      }
    }
  }

  Future<void> _clearPreferences() async {
    if (_prefs == null) return;

    try {
      await _prefs!.clear();
      await _insertSampleData();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('SharedPreferences reset with sample data')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error resetting preferences: $e')),
        );
      }
    }
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
                Icons.settings,
                size: 80,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(height: 20),
              Text(
                'DB Explorer - SharedPreferences Example',
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                'This example demonstrates the local_db_explorer package with SharedPreferences.',
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
                      onPressed: _addRandomPreference,
                      icon: const Icon(Icons.add),
                      label: const Text('Add Setting'),
                    ),
                    ElevatedButton.icon(
                      onPressed: _clearPreferences,
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
                          'Sample SharedPreferences Data:',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        const SizedBox(height: 8),
                        const Text('• User preferences (name, email, age)'),
                        const Text('• App settings (theme, notifications)'),
                        const Text('• App data (launches, sync time)'),
                        const Text('• Cache data (JSON strings, sizes)'),
                        const SizedBox(height: 12),
                        Text(
                          'Click "Open DB Explorer" to inspect the preferences!',
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
