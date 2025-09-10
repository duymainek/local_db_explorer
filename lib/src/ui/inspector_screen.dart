import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import '../core/db_adapter.dart';

/// Full-screen database inspector with mobile-optimized design.
class InspectorScreen extends StatefulWidget {
  final List<DBAdapter> adapters;

  const InspectorScreen({
    super.key,
    required this.adapters,
  });

  @override
  State<InspectorScreen> createState() => _InspectorScreenState();
}

class _InspectorScreenState extends State<InspectorScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: widget.adapters.length,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Database Inspector'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        bottom: widget.adapters.length > 1
            ? TabBar(
                controller: _tabController,
                tabs: widget.adapters
                    .map((adapter) => Tab(text: adapter.name))
                    .toList(),
                isScrollable: widget.adapters.length > 3,
              )
            : null,
      ),
      body: widget.adapters.length == 1
          ? _DatabaseView(adapter: widget.adapters.first)
          : TabBarView(
              controller: _tabController,
              children: widget.adapters
                  .map((adapter) => _DatabaseView(adapter: adapter))
                  .toList(),
            ),
    );
  }
}

/// Mobile-optimized database view widget.
class _DatabaseView extends StatefulWidget {
  final DBAdapter adapter;

  const _DatabaseView({required this.adapter});

  @override
  State<_DatabaseView> createState() => _DatabaseViewState();
}

class _DatabaseViewState extends State<_DatabaseView> {
  String? _selectedCollection;
  List<String> _collections = [];
  List<Map<String, dynamic>> _data = [];
  bool _isLoading = false;
  String _searchQuery = '';
  int _currentPage = 0;
  static const int _pageSize = 20; // Smaller page size for mobile

  @override
  void initState() {
    super.initState();
    _loadCollections();
  }

  Future<void> _loadCollections() async {
    setState(() => _isLoading = true);
    try {
      final collections = await widget.adapter.listCollections();
      setState(() {
        _collections = collections;
        if (collections.isNotEmpty && _selectedCollection == null) {
          _selectedCollection = collections.first;
          _loadData();
        }
      });
    } catch (e) {
      _showError('Failed to load collections: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadData() async {
    if (_selectedCollection == null) return;

    setState(() => _isLoading = true);
    try {
      final data = await widget.adapter.getData(
        _selectedCollection!,
        limit: _pageSize,
        offset: _currentPage * _pageSize,
      );
      setState(() => _data = data);
    } catch (e) {
      _showError('Failed to load data: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }


  @override
  Widget build(BuildContext context) {
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;

    if (isPortrait) {
      return _buildMobileLayout();
    } else {
      return _buildTabletLayout();
    }
  }

  Widget _buildMobileLayout() {
    return Column(
      children: [
        // Collection selector and search
        _buildMobileHeader(),
        // Data view
        Expanded(
          child: _buildDataView(),
        ),
      ],
    );
  }

  Widget _buildTabletLayout() {
    return Row(
      children: [
        // Collections sidebar
        SizedBox(
          width: 250,
          child: _buildCollectionsList(),
        ),
        const VerticalDivider(width: 1),
        // Data view
        Expanded(
          child: Column(
            children: [
              _buildSearchHeader(),
              Expanded(child: _buildDataView()),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMobileHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor,
          ),
        ),
      ),
      child: Column(
        children: [
          // Collection dropdown
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: _selectedCollection,
                  decoration: const InputDecoration(
                    labelText: 'Collection',
                    border: OutlineInputBorder(),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: _collections
                      .map((collection) => DropdownMenuItem(
                            value: collection,
                            child: Text(collection),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCollection = value;
                      _currentPage = 0;
                    });
                    _loadData();
                  },
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: _loadCollections,
                icon: const Icon(Icons.refresh),
                tooltip: 'Refresh Collections',
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Search bar
          TextField(
            decoration: const InputDecoration(
              hintText: 'Search records...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            onChanged: (value) {
              setState(() => _searchQuery = value);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSearchHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Text(
            _selectedCollection ?? 'No Collection',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const Spacer(),
          SizedBox(
            width: 300,
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search records...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              onChanged: (value) {
                setState(() => _searchQuery = value);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCollectionsList() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          right: BorderSide(
            color: Theme.of(context).dividerColor,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Text(
                  'Collections',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: _loadCollections,
                  icon: const Icon(Icons.refresh, size: 20),
                  tooltip: 'Refresh',
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: _collections.length,
                    itemBuilder: (context, index) {
                      final collection = _collections[index];
                      final isSelected = collection == _selectedCollection;
                      return ListTile(
                        title: Text(collection),
                        selected: isSelected,
                        onTap: () {
                          setState(() {
                            _selectedCollection = collection;
                            _currentPage = 0;
                          });
                          _loadData();
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataView() {
    if (_selectedCollection == null) {
      return const Center(
        child: Text('Select a collection to view its data'),
      );
    }

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_data.isEmpty) {
      return const Center(
        child: Text('No data found'),
      );
    }

    // Filter data based on search query
    final filteredData = _searchQuery.isEmpty
        ? _data
        : _data.where((row) {
            return row.values.any((value) => value
                .toString()
                .toLowerCase()
                .contains(_searchQuery.toLowerCase()));
          }).toList();

    if (filteredData.isEmpty) {
      return const Center(
        child: Text('No data matches your search'),
      );
    }

    return Column(
      children: [
        // Data list for mobile
        Expanded(
          child: _buildMobileDataList(filteredData),
        ),
        // Pagination
        if (widget.adapter.supportsPagination) _buildPagination(),
      ],
    );
  }

  Widget _buildMobileDataList(List<Map<String, dynamic>> data) {
    return ListView.builder(
      itemCount: data.length,
      itemBuilder: (context, index) {
        final record = data[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: ListTile(
            title: Text(_getRecordTitle(record)),
            subtitle: Text(_getRecordSubtitle(record)),
            trailing: PopupMenuButton(
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'view',
                  child: Row(
                    children: [
                      Icon(Icons.visibility, size: 16),
                      SizedBox(width: 8),
                      Text('View Details'),
                    ],
                  ),
                ),
                if (widget.adapter.supportsWrite) ...[
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit, size: 16),
                        SizedBox(width: 8),
                        Text('Edit'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, size: 16),
                        SizedBox(width: 8),
                        Text('Delete'),
                      ],
                    ),
                  ),
                ],
              ],
              onSelected: (value) {
                switch (value) {
                  case 'view':
                    _showRecordDetail(record);
                    break;
                  case 'edit':
                    _editRecord(record);
                    break;
                  case 'delete':
                    _deleteRecord(record);
                    break;
                }
              },
            ),
            onTap: () => _showRecordDetail(record),
          ),
        );
      },
    );
  }

  String _getRecordTitle(Map<String, dynamic> record) {
    // Try common title fields
    for (final key in ['name', 'title', 'key', 'id']) {
      if (record.containsKey(key)) {
        return '${record[key]}';
      }
    }
    // Fallback to first field
    if (record.isNotEmpty) {
      final firstKey = record.keys.first;
      return '$firstKey: ${record[firstKey]}';
    }
    return 'Record';
  }

  String _getRecordSubtitle(Map<String, dynamic> record) {
    final entries =
        record.entries.take(3).map((e) => '${e.key}: ${_formatValue(e.value)}');
    return entries.join(', ');
  }

  Widget _buildPagination() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).dividerColor,
          ),
        ),
      ),
      child: Row(
        children: [
          Text('Page ${_currentPage + 1}'),
          const Spacer(),
          IconButton(
            onPressed: _currentPage > 0
                ? () {
                    setState(() => _currentPage--);
                    _loadData();
                  }
                : null,
            icon: const Icon(Icons.chevron_left),
          ),
          IconButton(
            onPressed: _data.length >= _pageSize
                ? () {
                    setState(() => _currentPage++);
                    _loadData();
                  }
                : null,
            icon: const Icon(Icons.chevron_right),
          ),
        ],
      ),
    );
  }

  String _formatValue(dynamic value) {
    if (value == null) return 'null';
    if (value is String) {
      return value.length > 30 ? '${value.substring(0, 30)}...' : value;
    }
    if (value is Map || value is List) {
      final jsonStr = jsonEncode(value);
      return jsonStr.length > 30 ? '${jsonStr.substring(0, 30)}...' : jsonStr;
    }
    return value.toString();
  }

  void _showRecordDetail(Map<String, dynamic> record) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => _RecordDetailScreen(record: record),
      ),
    );
  }

  void _editRecord(Map<String, dynamic> record) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => _EditRecordScreen(
          record: record,
          onSave: (updatedRecord) async {
            try {
              await widget.adapter.put(_selectedCollection!, updatedRecord);
              _loadData(); // Refresh data
              if (mounted) {
                _showMessage('Record updated successfully');
              }
            } catch (e) {
              if (mounted) {
                _showError('Failed to update record: $e');
              }
            }
          },
        ),
      ),
    );
  }

  void _deleteRecord(Map<String, dynamic> record) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Record'),
        content: const Text('Are you sure you want to delete this record?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              try {
                // Try to find a primary key or use the entire record
                final key = record['id'] ?? record['_id'] ?? record;
                await widget.adapter.delete(_selectedCollection!, key);
                _loadData(); // Refresh data
                if (mounted) {
                  _showMessage('Record deleted successfully');
                }
              } catch (e) {
                if (mounted) {
                  _showError('Failed to delete record: $e');
                }
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

/// Full-screen record detail view.
class _RecordDetailScreen extends StatelessWidget {
  final Map<String, dynamic> record;

  const _RecordDetailScreen({required this.record});

  @override
  Widget build(BuildContext context) {
    final jsonString = const JsonEncoder.withIndent('  ').convert(record);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Record Details'),
        actions: [
          IconButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: jsonString));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Copied to clipboard')),
              );
            },
            icon: const Icon(Icons.copy),
            tooltip: 'Copy to Clipboard',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: SelectableText(
          jsonString,
          style: const TextStyle(fontFamily: 'monospace'),
        ),
      ),
    );
  }
}

/// Full-screen record edit view.
class _EditRecordScreen extends StatefulWidget {
  final Map<String, dynamic> record;
  final Function(Map<String, dynamic>) onSave;

  const _EditRecordScreen({
    required this.record,
    required this.onSave,
  });

  @override
  State<_EditRecordScreen> createState() => _EditRecordScreenState();
}

class _EditRecordScreenState extends State<_EditRecordScreen> {
  late TextEditingController _controller;
  String? _error;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: const JsonEncoder.withIndent('  ').convert(widget.record),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Record'),
        actions: [
          TextButton(
            onPressed: () {
              try {
                final updatedRecord =
                    jsonDecode(_controller.text) as Map<String, dynamic>;
                widget.onSave(updatedRecord);
                Navigator.of(context).pop();
              } catch (e) {
                setState(() {
                  _error = 'Invalid JSON: $e';
                });
              }
            },
            child: const Text('SAVE'),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (_error != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _error!,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onErrorContainer,
                  ),
                ),
              ),
            Expanded(
              child: TextField(
                controller: _controller,
                maxLines: null,
                expands: true,
                style: const TextStyle(fontFamily: 'monospace'),
                decoration: const InputDecoration(
                  hintText: 'Edit JSON...',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  if (_error != null) {
                    setState(() {
                      _error = null;
                    });
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
