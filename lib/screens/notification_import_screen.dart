import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../providers/account_provider.dart';
import '../providers/transaction_provider.dart';
import '../services/notification_parser.dart';
import '../services/notification_service.dart';

/// Screen for importing transactions from notifications
class NotificationImportScreen extends ConsumerStatefulWidget {
  const NotificationImportScreen({super.key});

  @override
  ConsumerState<NotificationImportScreen> createState() => _NotificationImportScreenState();
}

class _NotificationImportScreenState extends ConsumerState<NotificationImportScreen> {
  final NotificationService _notificationService = NotificationService();
  
  bool _isLoading = false;
  bool _hasPermission = false;
  final List<ParsedTransaction> _parsedTransactions = [];
  Set<int> _selectedIndices = {};
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    final hasPermission = await _notificationService.checkPermission();
    setState(() {
      _hasPermission = hasPermission;
    });
  }

  Future<void> _requestPermissions() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Opens system settings - user needs to manually enable
      await _notificationService.requestPermission();
      
      // Check if permission was granted
      await Future.delayed(const Duration(milliseconds: 500));
      final hasPermission = await _notificationService.checkPermission();
      
      setState(() {
        _hasPermission = hasPermission;
        _isLoading = false;
      });

      if (!hasPermission) {
        setState(() {
          _errorMessage = 'Notification access is required. Please enable it in Settings.';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error requesting permissions: $e';
      });
    }
  }

  void _startListening() async {
    setState(() {
      _errorMessage = null;
    });

    // Set up notification listener
    _notificationService.onNotificationReceived = (notification) async {
      // Parse notification
      final transaction = NotificationParser.parse(notification);
      if (transaction != null && mounted) {
        setState(() {
          _parsedTransactions.insert(0, transaction); // Add to top
          _selectedIndices.add(0); // Auto-select new transactions
          
          // Shift existing indices
          final newIndices = <int>{};
          for (final idx in _selectedIndices) {
            if (idx >= 0) newIndices.add(idx + 1);
          }
          _selectedIndices = newIndices..add(0);
        });
      }
    };

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Now listening for transaction notifications'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _importSelected() async {
    if (_selectedIndices.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select transactions to import')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Get default account or first account
      final accounts = ref.read(activeAccountsProvider);
      if (accounts.isEmpty) {
        throw Exception('Please create an account first');
      }
      final defaultAccount = accounts.first;

      // Import selected transactions
      int successCount = 0;
      for (final index in _selectedIndices) {
        final parsed = _parsedTransactions[index];
        final transaction = parsed.toTransaction(
          id: '${DateTime.now().millisecondsSinceEpoch}_$index',
          accountId: defaultAccount.id.toString(),
        );

        await ref
            .read(transactionActionsProvider.notifier)
            .addTransaction(transaction);
        successCount++;
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Successfully imported $successCount transactions'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error importing: $e'),
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Import from Notifications'),
        actions: [
          if (_parsedTransactions.isNotEmpty)
            TextButton(
              onPressed: _isLoading ? null : _importSelected,
              child: const Text('IMPORT'),
            ),
        ],
      ),
      body: Column(
        children: [
          // Permission status card
          if (!_hasPermission)
            Card(
              margin: const EdgeInsets.all(16),
              color: theme.colorScheme.errorContainer,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Icon(
                      Icons.security,
                      size: 48,
                      color: theme.colorScheme.error,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Notification Access Required',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'To automatically capture transaction notifications from banking apps, we need notification access.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: _isLoading ? null : _requestPermissions,
                      icon: const Icon(Icons.settings),
                      label: const Text('Open Settings'),
                    ),
                  ],
                ),
              ),
            ),

          // Start listening button
          if (_hasPermission && _parsedTransactions.isEmpty && !_isLoading)
            Padding(
              padding: const EdgeInsets.all(16),
              child: FilledButton.icon(
                onPressed: _startListening,
                icon: const Icon(Icons.notifications_active),
                label: const Text('Start Listening for Notifications'),
                style: FilledButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                ),
              ),
            ),

          // Error message
          if (_errorMessage != null)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Card(
                color: theme.colorScheme.errorContainer.withValues(alpha: 0.3),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: theme.colorScheme.error,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(color: theme.colorScheme.error),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Selection controls
          if (_parsedTransactions.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                border: Border(
                  bottom: BorderSide(
                    color: theme.colorScheme.outlineVariant,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Text(
                    '${_selectedIndices.length} of ${_parsedTransactions.length} selected',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        if (_selectedIndices.length ==
                            _parsedTransactions.length) {
                          _selectedIndices.clear();
                        } else {
                          _selectedIndices = Set.from(
                            List.generate(
                              _parsedTransactions.length,
                              (index) => index,
                            ),
                          );
                        }
                      });
                    },
                    child: Text(
                      _selectedIndices.length == _parsedTransactions.length
                          ? 'Deselect All'
                          : 'Select All',
                    ),
                  ),
                ],
              ),
            ),

          // Transaction list
          if (_parsedTransactions.isNotEmpty)
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.only(bottom: 80),
                itemCount: _parsedTransactions.length,
                itemBuilder: (context, index) {
                  final parsed = _parsedTransactions[index];
                  final isSelected = _selectedIndices.contains(index);

                  return CheckboxListTile(
                    value: isSelected,
                    onChanged: (value) {
                      setState(() {
                        if (value == true) {
                          _selectedIndices.add(index);
                        } else {
                          _selectedIndices.remove(index);
                        }
                      });
                    },
                    title: Text(
                      parsed.description,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              parsed.category.icon,
                              size: 14,
                              color: parsed.category.color,
                            ),
                            const SizedBox(width: 4),
                            Text(parsed.category.name),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          DateFormat('MMM d, h:mm a').format(parsed.timestamp),
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                    secondary: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${parsed.type.name == 'credit' ? '+' : '-'}₹${NumberFormat('#,##0').format(parsed.amount)}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: parsed.type.name == 'credit'
                                ? Colors.green[700]
                                : Colors.red[700],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

          // Loading indicator
          if (_isLoading)
            const Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Checking notification access...'),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
