import 'package:flutter/material.dart';
import '../database/tag_repository.dart';
import '../utils/constants.dart';

/// Screen for managing transaction tags
class ManageTagsScreen extends StatefulWidget {
  const ManageTagsScreen({super.key});

  @override
  State<ManageTagsScreen> createState() => _ManageTagsScreenState();
}

class _ManageTagsScreenState extends State<ManageTagsScreen> {
  final _tagRepo = TagRepository();
  List<Map<String, dynamic>> _tags = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadTags();
  }

  Future<void> _loadTags() async {
    setState(() => _isLoading = true);
    try {
      final tags = await _tagRepo.getAllTags();
      setState(() {
        _tags = tags;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading tags: $e')),
        );
      }
    }
  }

  void _showAddTagDialog() {
    final nameController = TextEditingController();
    String selectedColor = 'blue';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Add Tag'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Tag Name',
                  hintText: 'e.g., urgent, work, personal',
                ),
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 16),
              const Text('Select Color:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  'blue',
                  'green',
                  'red',
                  'orange',
                  'purple',
                  'pink',
                  'teal',
                  'amber',
                ].map((colorName) {
                  final isSelected = colorName == selectedColor;
                  final color = _getColorFromName(colorName);
                  return InkWell(
                    onTap: () {
                      setDialogState(() {
                        selectedColor = colorName;
                      });
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected ? Colors.black : Colors.transparent,
                          width: 2,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                final name = nameController.text.trim();
                if (name.isNotEmpty) {
                  try {
                    await _tagRepo.insertTag(
                      name: name,
                      color: selectedColor,
                    );
                    await _loadTags();
                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Added tag "$name"')),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error adding tag: $e')),
                      );
                    }
                  }
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditTagDialog(Map<String, dynamic> tag) {
    final nameController = TextEditingController(text: tag['name']);
    String selectedColor = tag['color'] ?? 'blue';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Edit Tag'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Tag Name',
                ),
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 16),
              const Text('Select Color:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  'blue',
                  'green',
                  'red',
                  'orange',
                  'purple',
                  'pink',
                  'teal',
                  'amber',
                ].map((colorName) {
                  final isSelected = colorName == selectedColor;
                  final color = _getColorFromName(colorName);
                  return InkWell(
                    onTap: () {
                      setDialogState(() {
                        selectedColor = colorName;
                      });
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected ? Colors.black : Colors.transparent,
                          width: 2,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                final name = nameController.text.trim();
                if (name.isNotEmpty) {
                  try {
                    await _tagRepo.updateTag(
                      id: tag['id'],
                      name: name,
                      color: selectedColor,
                    );
                    await _loadTags();
                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Tag updated')),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error updating tag: $e')),
                      );
                    }
                  }
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _deleteTag(Map<String, dynamic> tag) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Tag?'),
        content: Text('Are you sure you want to delete "${tag['name']}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              try {
                await _tagRepo.deleteTag(tag['id']);
                await _loadTags();
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Deleted "${tag['name']}"')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error deleting tag: $e')),
                  );
                }
              }
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Color _getColorFromName(String name) {
    switch (name) {
      case 'blue':
        return Colors.blue;
      case 'green':
        return Colors.green;
      case 'red':
        return Colors.red;
      case 'orange':
        return Colors.orange;
      case 'purple':
        return Colors.purple;
      case 'pink':
        return Colors.pink;
      case 'teal':
        return Colors.teal;
      case 'amber':
        return Colors.amber;
      default:
        return Colors.blue;
    }
  }

  List<Map<String, dynamic>> get _filteredTags {
    if (_searchQuery.isEmpty) return _tags;
    return _tags
        .where((tag) => tag['name'].toString().toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Tags'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.sm),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search tags...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              onChanged: (value) {
                setState(() => _searchQuery = value);
              },
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _filteredTags.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.label_outline, size: 64, color: Colors.grey.shade300),
                      const SizedBox(height: 16),
                      Text(
                        _searchQuery.isEmpty ? 'No tags yet' : 'No tags found',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Colors.grey,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _searchQuery.isEmpty
                            ? 'Tap + to create your first tag'
                            : 'Try a different search',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: _filteredTags.length,
                  itemBuilder: (context, index) {
                    final tag = _filteredTags[index];
                    final colorName = tag['color'] ?? 'blue';
                    final color = _getColorFromName(colorName);

                    return ListTile(
                      leading: Chip(
                        label: Text(
                          tag['name'],
                          style: const TextStyle(color: Colors.white),
                        ),
                        backgroundColor: color,
                      ),
                      title: Text(tag['name']),
                      subtitle: const Text('Tap to edit'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => _showEditTagDialog(tag),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteTag(tag),
                          ),
                        ],
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'add_tag_fab',
        onPressed: _showAddTagDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
