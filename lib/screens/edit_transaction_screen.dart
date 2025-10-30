import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../models/transaction.dart';
import '../providers/account_provider.dart';
import '../providers/transaction_provider.dart';
import '../utils/constants.dart';

/// Screen for editing an existing transaction
class EditTransactionScreen extends ConsumerStatefulWidget {
  final Transaction transaction;

  const EditTransactionScreen({
    super.key,
    required this.transaction,
  });

  @override
  ConsumerState<EditTransactionScreen> createState() =>
      _EditTransactionScreenState();
}

class _EditTransactionScreenState
    extends ConsumerState<EditTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _amountController;
  late TextEditingController _descriptionController;
  late TextEditingController _merchantController;
  late TextEditingController _notesController;

  late TransactionType _type;
  late Category _category;
  late DateTime _timestamp;
  late String _selectedAccountId;
  String? _paymentMethod;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _amountController =
        TextEditingController(text: widget.transaction.amount.toString());
    _descriptionController =
        TextEditingController(text: widget.transaction.description);
    _merchantController =
        TextEditingController(text: widget.transaction.merchantName ?? '');
    _notesController =
        TextEditingController(text: widget.transaction.notes ?? '');

    _type = widget.transaction.type;
    _category = widget.transaction.category;
    _timestamp = widget.transaction.timestamp;
    _selectedAccountId = widget.transaction.accountId;
    // Normalize payment method to match dropdown values
    _paymentMethod = _normalizePaymentMethod(widget.transaction.paymentMethod);
  }

  /// Normalize payment method to match dropdown values
  String? _normalizePaymentMethod(String? value) {
    if (value == null) return null;
    
    final normalized = value.trim();
    
    // Map common variations to dropdown values
    switch (normalized.toUpperCase()) {
      case 'UPI':
        return 'UPI';
      case 'CARD':
      case 'CARDS':
        return 'Card';
      case 'CASH':
        return 'Cash';
      case 'NET BANKING':
      case 'NETBANKING':
      case 'NEFT':
      case 'IMPS':
      case 'RTGS':
        return 'Net Banking';
      case 'ATM':
        return 'ATM';
      default:
        // If it's not a recognized value, return null to avoid dropdown error
        return null;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    _merchantController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accountsAsync = ref.watch(activeAccountsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Transaction'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: _deleteTransaction,
            tooltip: 'Delete transaction',
          ),
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
            // SMS Info Card (if transaction was from SMS)
            if (widget.transaction.smsBody != null) _buildSMSInfoCard(theme),

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
                if (value != null) {
                  setState(() {
                    _selectedAccountId = value;
                  });
                }
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
                DropdownMenuItem(value: null, child: Text('None')),
                DropdownMenuItem(value: 'UPI', child: Text('UPI')),
                DropdownMenuItem(value: 'Card', child: Text('Card')),
                DropdownMenuItem(value: 'Cash', child: Text('Cash')),
                DropdownMenuItem(
                    value: 'Net Banking', child: Text('Net Banking')),
                DropdownMenuItem(value: 'ATM', child: Text('ATM')),
              ],
              onChanged: (value) {
                setState(() {
                  _paymentMethod = value;
                });
              },
            ),

            const SizedBox(height: 16),

            // Notes Field
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes (Optional)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.note),
                alignLabelWithHint: true,
              ),
              maxLines: 3,
              maxLength: 200,
            ),

            const SizedBox(height: 24),

            // Metadata Card
            _buildMetadataCard(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildSMSInfoCard(ThemeData theme) {
    return Card(
      color: theme.colorScheme.tertiaryContainer.withValues(alpha: 0.3),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.sms,
                  size: 20,
                  color: theme.colorScheme.tertiary,
                ),
                const SizedBox(width: 8),
                Text(
                  'SMS Transaction',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: theme.colorScheme.tertiary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Sender: ${widget.transaction.smsSender ?? 'Unknown'}',
              style: theme.textTheme.bodySmall,
            ),
            if (widget.transaction.smsTimestamp != null) ...[
              const SizedBox(height: 4),
              Text(
                'Received: ${DateFormat('MMM d, yyyy h:mm a').format(widget.transaction.smsTimestamp!)}',
                style: theme.textTheme.bodySmall,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMetadataCard(ThemeData theme) {
    return Card(
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Transaction Info',
              style: theme.textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
              theme,
              'ID',
              widget.transaction.id,
            ),
            _buildInfoRow(
              theme,
              'Created',
              DateFormat('MMM d, yyyy h:mm a')
                  .format(widget.transaction.createdAt),
            ),
            _buildInfoRow(
              theme,
              'Last Modified',
              DateFormat('MMM d, yyyy h:mm a')
                  .format(widget.transaction.updatedAt),
            ),
            _buildInfoRow(
              theme,
              'Categorization',
              widget.transaction.categorizationMethod.name,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(ThemeData theme, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodySmall,
            ),
          ),
        ],
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
      final updatedTransaction = widget.transaction.copyWith(
        amount: double.parse(_amountController.text),
        type: _type,
        category: _category,
        timestamp: _timestamp,
        description: _descriptionController.text,
        accountId: _selectedAccountId,
        merchantName: _merchantController.text.isEmpty
            ? null
            : _merchantController.text,
        paymentMethod: _paymentMethod,
        notes: _notesController.text.isEmpty ? null : _notesController.text,
        isManuallyEdited: true,
        updatedAt: DateTime.now(),
      );

      await ref
          .read(transactionActionsProvider.notifier)
          .updateTransaction(updatedTransaction);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Transaction updated successfully'),
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

  Future<void> _deleteTransaction() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Transaction'),
        content: const Text(
            'Are you sure you want to delete this transaction? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await ref
          .read(transactionActionsProvider.notifier)
          .deleteTransaction(widget.transaction.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Transaction deleted successfully'),
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
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
