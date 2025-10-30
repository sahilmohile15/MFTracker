import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../utils/constants.dart';

/// Helper class to map icon names to IconData constants
/// This allows tree-shaking to work properly
class IconHelper {
  static const Map<String, IconData> iconMap = {
    'category': Icons.category,
    'shopping_bag': Icons.shopping_bag,
    'restaurant': Icons.restaurant,
    'local_cafe': Icons.local_cafe,
    'directions_car': Icons.directions_car,
    'train': Icons.train,
    'home': Icons.home,
    'medical_services': Icons.medical_services,
    'school': Icons.school,
    'sports_esports': Icons.sports_esports,
    'fitness_center': Icons.fitness_center,
    'pets': Icons.pets,
    'card_giftcard': Icons.card_giftcard,
    'child_care': Icons.child_care,
    'elderly': Icons.elderly,
  };

  static const List<IconData> availableIcons = [
    Icons.category,
    Icons.shopping_bag,
    Icons.restaurant,
    Icons.local_cafe,
    Icons.directions_car,
    Icons.train,
    Icons.home,
    Icons.medical_services,
    Icons.school,
    Icons.sports_esports,
    Icons.fitness_center,
    Icons.pets,
    Icons.card_giftcard,
    Icons.child_care,
    Icons.elderly,
  ];

  static String getIconName(IconData icon) {
    return iconMap.entries
        .firstWhere((entry) => entry.value.codePoint == icon.codePoint,
            orElse: () => const MapEntry('category', Icons.category))
        .key;
  }

  static IconData getIconFromName(String name) {
    return iconMap[name] ?? Icons.category;
  }
}

/// Screen for managing transaction categories
class ManageCategoriesScreen extends StatefulWidget {
  const ManageCategoriesScreen({super.key});

  @override
  State<ManageCategoriesScreen> createState() => _ManageCategoriesScreenState();
}

class _ManageCategoriesScreenState extends State<ManageCategoriesScreen> {
  final _customCategories = <String, Map<String, dynamic>>{};
  final _disabledCategories = <String>{};

  @override
  void initState() {
    super.initState();
    _loadCustomCategories();
  }

  Future<void> _loadCustomCategories() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Load custom categories
    final categoriesJson = prefs.getString('custom_categories');
    if (categoriesJson != null) {
      final decoded = json.decode(categoriesJson) as Map<String, dynamic>;
      setState(() {
        _customCategories.clear();
        decoded.forEach((key, value) {
          _customCategories[key] = Map<String, dynamic>.from(value);
        });
      });
    }
    
    // Load disabled categories
    final disabledList = prefs.getStringList('disabled_categories');
    if (disabledList != null) {
      setState(() {
        _disabledCategories.clear();
        _disabledCategories.addAll(disabledList);
      });
    }
  }

  Future<void> _saveCustomCategories() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Save custom categories
    final categoriesJson = json.encode(_customCategories);
    await prefs.setString('custom_categories', categoriesJson);
    
    // Save disabled categories
    await prefs.setStringList('disabled_categories', _disabledCategories.toList());
  }

  void _showAddCategoryDialog() {
    final nameController = TextEditingController();
    IconData selectedIcon = Icons.category;
    Color selectedColor = Colors.blue;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Add Custom Category'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Category Name',
                    hintText: 'e.g., Gym, Pet Care',
                  ),
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 16),
                const Text('Select Icon:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: IconHelper.availableIcons.map((icon) {
                    final isSelected = icon == selectedIcon;
                    return InkWell(
                      onTap: () {
                        setDialogState(() {
                          selectedIcon = icon;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: isSelected ? selectedColor : Colors.grey.shade300,
                            width: isSelected ? 2 : 1,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(icon, color: isSelected ? selectedColor : Colors.grey),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                const Text('Select Color:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    Colors.blue,
                    Colors.green,
                    Colors.red,
                    Colors.orange,
                    Colors.purple,
                    Colors.pink,
                    Colors.teal,
                    Colors.amber,
                    Colors.indigo,
                    Colors.brown,
                  ].map((color) {
                    final isSelected = color == selectedColor;
                    return InkWell(
                      onTap: () {
                        setDialogState(() {
                          selectedColor = color;
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
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final name = nameController.text.trim();
                if (name.isNotEmpty) {
                  setState(() {
                    _customCategories[name] = {
                      'icon': IconHelper.getIconName(selectedIcon),
                      'color': selectedColor.toARGB32(),
                    };
                  });
                  _saveCustomCategories();
                  Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditCategoryDialog(String name) {
    final nameController = TextEditingController(text: name);
    final categoryData = _customCategories[name]!;
    final iconName = categoryData['icon'] is String 
        ? categoryData['icon'] as String 
        : 'category'; // Fallback for old integer format
    final colorValue = categoryData['color'] as int;
    IconData selectedIcon = IconHelper.getIconFromName(iconName);
    Color selectedColor = Color(colorValue);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Edit Category'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Category Name',
                  ),
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 16),
                const Text('Select Icon:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: IconHelper.availableIcons.map((icon) {
                    final isSelected = icon == selectedIcon;
                    return InkWell(
                      onTap: () {
                        setDialogState(() {
                          selectedIcon = icon;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: isSelected ? selectedColor : Colors.grey.shade300,
                            width: isSelected ? 2 : 1,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(icon, color: isSelected ? selectedColor : Colors.grey),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                const Text('Select Color:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    Colors.blue,
                    Colors.green,
                    Colors.red,
                    Colors.orange,
                    Colors.purple,
                    Colors.pink,
                    Colors.teal,
                    Colors.amber,
                    Colors.indigo,
                    Colors.brown,
                  ].map((color) {
                    final isSelected = color == selectedColor;
                    return InkWell(
                      onTap: () {
                        setDialogState(() {
                          selectedColor = color;
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
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final newName = nameController.text.trim();
                if (newName.isNotEmpty) {
                  setState(() {
                    _customCategories.remove(name);
                    _customCategories[newName] = {
                      'icon': IconHelper.getIconName(selectedIcon),
                      'color': selectedColor.toARGB32(),
                    };
                  });
                  _saveCustomCategories();
                  Navigator.pop(context);
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _deleteCategory(String name) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Category?'),
        content: Text('Are you sure you want to delete "$name"? This category won\'t be available for new transactions.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              setState(() {
                _customCategories.remove(name);
              });
              _saveCustomCategories();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Deleted "$name"')),
              );
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _toggleCategory(String category) {
    setState(() {
      if (_disabledCategories.contains(category)) {
        _disabledCategories.remove(category);
      } else {
        _disabledCategories.add(category);
      }
    });
    _saveCustomCategories();
  }

  @override
  Widget build(BuildContext context) {
    final defaultCategories = [
      'Food & Dining',
      'Shopping',
      'Transportation',
      'Entertainment',
      'Bills & Utilities',
      'Healthcare',
      'Education',
      'Travel',
      'Groceries',
      'Personal Care',
      'Gifts & Donations',
      'Income',
      'Other',
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Categories'),
      ),
      body: ListView(
        children: [
          // Default Categories Section
          const Padding(
            padding: EdgeInsets.all(AppSpacing.md),
            child: Text(
              'DEFAULT CATEGORIES',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          ...defaultCategories.map((category) {
            final isDisabled = _disabledCategories.contains(category);
            return ListTile(
              leading: Icon(
                Icons.category,
                color: isDisabled ? Colors.grey : null,
              ),
              title: Text(
                category,
                style: TextStyle(
                  color: isDisabled ? Colors.grey : null,
                ),
              ),
              trailing: Switch(
                value: !isDisabled,
                onChanged: (value) => _toggleCategory(category),
              ),
              subtitle: isDisabled ? const Text('Disabled') : null,
            );
          }),

          const Divider(height: 32),

          // Custom Categories Section
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'CUSTOM CATEGORIES',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                TextButton.icon(
                  onPressed: _showAddCategoryDialog,
                  icon: const Icon(Icons.add),
                  label: const Text('Add'),
                ),
              ],
            ),
          ),

          if (_customCategories.isEmpty)
            const Padding(
              padding: EdgeInsets.all(AppSpacing.lg),
              child: Center(
                child: Text(
                  'No custom categories yet.\nTap "Add" to create one.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            )
          else
            ..._customCategories.entries.map((entry) {
              final name = entry.key;
              final iconName = entry.value['icon'] is String 
                  ? entry.value['icon'] as String 
                  : 'category'; // Fallback for old integer format
              final colorValue = entry.value['color'] as int;
              final icon = IconHelper.getIconFromName(iconName);
              final color = Color(colorValue);
              final isDisabled = _disabledCategories.contains(name);

              return ListTile(
                leading: Icon(icon, color: isDisabled ? Colors.grey : color),
                title: Text(
                  name,
                  style: TextStyle(
                    color: isDisabled ? Colors.grey : null,
                  ),
                ),
                subtitle: isDisabled ? const Text('Disabled') : null,
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Switch(
                      value: !isDisabled,
                      onChanged: (value) => _toggleCategory(name),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => _showEditCategoryDialog(name),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteCategory(name),
                    ),
                  ],
                ),
              );
            }),

          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
