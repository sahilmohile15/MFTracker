import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/budget.dart';
import '../providers/budget_provider.dart';

/// Screen for editing an existing budget
class EditBudgetScreen extends ConsumerStatefulWidget {
  final Budget budget;

  const EditBudgetScreen({
    super.key,
    required this.budget,
  });

  @override
  ConsumerState<EditBudgetScreen> createState() => _EditBudgetScreenState();
}

class _EditBudgetScreenState extends ConsumerState<EditBudgetScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _amountController;

  late double _alertThreshold;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.budget.name);
    _amountController =
        TextEditingController(text: widget.budget.amount.toString());
    _alertThreshold = widget.budget.alertThreshold;
  }

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
        title: const Text('Edit Budget'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _deleteBudget,
          ),
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
      final updatedBudget = widget.budget.copyWith(
        name: _nameController.text,
        amount: double.parse(_amountController.text),
        alertThreshold: _alertThreshold,
        updatedAt: DateTime.now(),
      );

      await ref
          .read(budgetActionsProvider.notifier)
          .updateBudget(updatedBudget);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Budget updated successfully'),
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

  Future<void> _deleteBudget() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Budget'),
        content: const Text('Are you sure you want to delete this budget?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      try {
        await ref
            .read(budgetActionsProvider.notifier)
            .deleteBudget(widget.budget.id);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Budget deleted'),
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
      }
    }
  }
}
