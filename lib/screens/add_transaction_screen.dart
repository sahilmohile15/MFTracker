import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../models/transaction.dart';
import '../providers/account_provider.dart';
import '../providers/transaction_provider.dart';
import '../utils/constants.dart';

/// Screen for adding a new transaction
class AddTransactionScreen extends ConsumerStatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  ConsumerState<AddTransactionScreen> createState() =>
      _AddTransactionScreenState();
}

class _AddTransactionScreenState extends ConsumerState<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _merchantController = TextEditingController();

  TransactionType _type = TransactionType.debit;
  Category _category = Category.others;
  DateTime _timestamp = DateTime.now();
  String? _selectedAccountId;
  String? _paymentMethod;

  bool _isLoading = false;

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    _merchantController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accountsAsync = ref.watch(activeAccountsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Transaction'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveTransaction,
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
            // Transaction Type Selector
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Transaction Type',
                      style: theme.textTheme.titleSmall,
                    ),
                    const SizedBox(height: 12),
                    SegmentedButton<TransactionType>(
                      segments: const [
                        ButtonSegment(
                          value: TransactionType.debit,
                          label: Text('Debit'),
                          icon: Icon(Icons.arrow_upward),
                        ),
                        ButtonSegment(
                          value: TransactionType.credit,
                          label: Text('Credit'),
                          icon: Icon(Icons.arrow_downward),
                        ),
                      ],
                      selected: {_type},
                      onSelectionChanged: (Set<TransactionType> newSelection) {
                        setState(() {
                          _type = newSelection.first;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Amount Field
            TextFormField(
              controller: _amountController,
              decoration: InputDecoration(
                labelText: 'Amount *',
                prefixText: '₹',
                border: const OutlineInputBorder(),
                helperText: 'Enter the transaction amount',
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

            // Description Field
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description *',
                border: OutlineInputBorder(),
                helperText: 'Brief description of the transaction',
              ),
              maxLength: 100,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a description';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Category Selector
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Category *',
                      style: theme.textTheme.titleSmall,
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
                              _category = category;
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

            // Account Selector
            DropdownButtonFormField<String>(
              value: _selectedAccountId,
              decoration: const InputDecoration(
                labelText: 'Account *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.account_balance_wallet),
              ),
              items: accountsAsync.map((account) {
                return DropdownMenuItem(
                  value: account.id.toString(),
                  child: Text(account.name),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedAccountId = value;
                });
              },
              validator: (value) {
                if (value == null) {
                  return 'Please select an account';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Date & Time Picker
            InkWell(
              onTap: () => _selectDateTime(context),
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Date & Time',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                child: Text(
                  DateFormat('MMM d, yyyy - h:mm a').format(_timestamp),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Merchant Name (Optional)
            TextFormField(
              controller: _merchantController,
              decoration: const InputDecoration(
                labelText: 'Merchant Name (Optional)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.store),
              ),
              maxLength: 50,
            ),

            const SizedBox(height: 16),

            // Payment Method (Optional)
            DropdownButtonFormField<String>(
              value: _paymentMethod,
              decoration: const InputDecoration(
                labelText: 'Payment Method (Optional)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.payment),
              ),
              items: const [
                DropdownMenuItem(value: 'UPI', child: Text('UPI')),
                DropdownMenuItem(value: 'Card', child: Text('Card')),
                DropdownMenuItem(value: 'Cash', child: Text('Cash')),
                DropdownMenuItem(value: 'Net Banking', child: Text('Net Banking')),
                DropdownMenuItem(value: 'ATM', child: Text('ATM')),
              ],
              onChanged: (value) {
                setState(() {
                  _paymentMethod = value;
                });
              },
            ),

            const SizedBox(height: 24),

            // Help text
            Card(
              color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 20,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Fields marked with * are required',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
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

  Future<void> _selectDateTime(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: _timestamp,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (date != null) {
      if (!mounted) return;
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_timestamp),
      );

      if (time != null && mounted) {
        setState(() {
          _timestamp = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  Future<void> _saveTransaction() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final now = DateTime.now();
      final transaction = Transaction(
        id: '${now.millisecondsSinceEpoch}_$_selectedAccountId',
        amount: double.parse(_amountController.text),
        type: _type,
        category: _category,
        categorizationMethod: CategorizationMethod.userCorrected,
        timestamp: _timestamp,
        description: _descriptionController.text,
        accountId: _selectedAccountId!,
        merchantName: _merchantController.text.isEmpty
            ? null
            : _merchantController.text,
        paymentMethod: _paymentMethod,
        smsBody: null,
        smsSender: null,
        createdAt: now,
        updatedAt: now,
      );

      await ref
          .read(transactionActionsProvider.notifier)
          .addTransaction(transaction);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Transaction added successfully'),
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
