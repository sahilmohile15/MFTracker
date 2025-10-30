import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/budget.dart';
import '../providers/budget_provider.dart';
import '../utils/constants.dart';

/// Screen for adding a new budget
class AddBudgetScreen extends ConsumerStatefulWidget {
  const AddBudgetScreen({super.key});

  @override
  ConsumerState<AddBudgetScreen> createState() => _AddBudgetScreenState();
}

class _AddBudgetScreenState extends ConsumerState<AddBudgetScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();

  BudgetPeriod _period = BudgetPeriod.monthly;
  Category? _category;
  double _alertThreshold = 80.0;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Budget'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveBudget,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('SAVE'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Budget Name
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Budget Name *',
                border: OutlineInputBorder(),
                helperText: 'e.g., "Monthly Food Budget"',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a budget name';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Amount
            TextFormField(
              controller: _amountController,
              decoration: const InputDecoration(
                labelText: 'Amount *',
                prefixText: '₹',
                border: OutlineInputBorder(),
                helperText: 'Maximum spending limit',
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter an amount';
                }
                if (double.tryParse(value) == null) {
                  return 'Please enter a valid number';
                }
                if (double.parse(value) <= 0) {
                  return 'Amount must be greater than 0';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Period
            DropdownButtonFormField<BudgetPeriod>(
              value: _period,
              decoration: const InputDecoration(
                labelText: 'Period *',
                border: OutlineInputBorder(),
              ),
              items: BudgetPeriod.values.map((period) {
                return DropdownMenuItem(
                  value: period,
                  child: Text(period.name),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _period = value;
                  });
                }
              },
            ),

            const SizedBox(height: 16),

            // Category (Optional)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Category (Optional)',
                      style: theme.textTheme.titleSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Leave empty to track all spending',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: Category.values.map((category) {
                        final isSelected = _category == category;
                        return FilterChip(
                          label: Text(category.name),
                          avatar: Icon(
                            category.icon,
                            size: 18,
                            color: isSelected
                                ? category.color
                                : theme.colorScheme.onSurfaceVariant,
                          ),
                          selected: isSelected,
                          selectedColor: category.color.withValues(alpha: 0.3),
                          onSelected: (_) {
                            setState(() {
                              _category = isSelected ? null : category;
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Alert Threshold
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Alert Threshold: ${_alertThreshold.toInt()}%',
                      style: theme.textTheme.titleSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Get notified when spending reaches this percentage',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    Slider(
                      value: _alertThreshold,
                      min: 50,
                      max: 100,
                      divisions: 10,
                      label: '${_alertThreshold.toInt()}%',
                      onChanged: (value) {
                        setState(() {
                          _alertThreshold = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveBudget() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final now = DateTime.now();
      final budget = Budget(
        id: '${now.millisecondsSinceEpoch}',
        name: _nameController.text,
        amount: double.parse(_amountController.text),
        period: _period,
        startDate: now,
        category: _category,
        alertThreshold: _alertThreshold,
        isActive: true,
        createdAt: now,
        updatedAt: now,
      );

      await ref.read(budgetActionsProvider.notifier).addBudget(budget);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Budget created successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
