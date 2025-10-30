import 'package:flutter/material.dart';
import '../database/account_repository.dart';
import '../models/account.dart';
import '../utils/constants.dart';

/// Screen for managing accounts
class ManageAccountsScreen extends StatefulWidget {
  const ManageAccountsScreen({super.key});

  @override
  State<ManageAccountsScreen> createState() => _ManageAccountsScreenState();
}

class _ManageAccountsScreenState extends State<ManageAccountsScreen> {
  final _accountRepo = AccountRepository();
  List<Account> _accounts = [];
  bool _isLoading = true;
  bool _showArchived = false;

  @override
  void initState() {
    super.initState();
    _loadAccounts();
  }

  Future<void> _loadAccounts() async {
    setState(() => _isLoading = true);
    try {
      final accounts = await _accountRepo.getAll(activeOnly: !_showArchived);
      setState(() {
        _accounts = accounts;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading accounts: $e')),
        );
      }
    }
  }

  void _showAddAccountDialog() {
    final nameController = TextEditingController();
    final institutionController = TextEditingController();
    final balanceController = TextEditingController(text: '0');
    AccountType selectedType = AccountType.savings;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Add Account'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Account Name',
                    hintText: 'e.g., HDFC Savings, Cash Wallet',
                  ),
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: institutionController,
                  decoration: const InputDecoration(
                    labelText: 'Institution',
                    hintText: 'e.g., HDFC Bank, ICICI',
                  ),
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<AccountType>(
                  value: selectedType,
                  decoration: const InputDecoration(
                    labelText: 'Account Type',
                  ),
                  items: AccountType.values.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Row(
                        children: [
                          Icon(_getAccountIcon(type), size: 20),
                          const SizedBox(width: 8),
                          Text(_getAccountTypeName(type)),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setDialogState(() {
                        selectedType = value;
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: balanceController,
                  decoration: const InputDecoration(
                    labelText: 'Initial Balance',
                    prefixText: '₹ ',
                  ),
                  keyboardType: TextInputType.number,
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
              onPressed: () async {
                final name = nameController.text.trim();
                final institution = institutionController.text.trim();
                final balance = double.tryParse(balanceController.text) ?? 0;
                
                if (name.isNotEmpty && institution.isNotEmpty) {
                  try {
                    final now = DateTime.now();
                    final account = Account(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      name: name,
                      institution: institution,
                      type: selectedType,
                      balance: balance,
                      isActive: true,
                      createdAt: now,
                      updatedAt: now,
                    );
                    await _accountRepo.insert(account);
                    await _loadAccounts();
                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Added account "$name"')),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error adding account: $e')),
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

  void _showEditTagDialog(Account account) {
    final nameController = TextEditingController(text: account.name);
    final institutionController = TextEditingController(text: account.institution);
    AccountType selectedType = account.type;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Edit Account'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Account Name',
                ),
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: institutionController,
                decoration: const InputDecoration(
                  labelText: 'Institution',
                ),
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<AccountType>(
                value: selectedType,
                decoration: const InputDecoration(
                  labelText: 'Account Type',
                ),
                items: AccountType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Row(
                      children: [
                        Icon(_getAccountIcon(type), size: 20),
                        const SizedBox(width: 8),
                        Text(_getAccountTypeName(type)),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setDialogState(() {
                      selectedType = value;
                    });
                  }
                },
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
                final institution = institutionController.text.trim();
                
                if (name.isNotEmpty && institution.isNotEmpty) {
                  try {
                    final updatedAccount = Account(
                      id: account.id,
                      name: name,
                      institution: institution,
                      type: selectedType,
                      balance: account.balance,
                      isActive: account.isActive,
                      createdAt: account.createdAt,
                      updatedAt: DateTime.now(),
                    );
                    await _accountRepo.update(updatedAccount);
                    await _loadAccounts();
                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Account updated')),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error updating account: $e')),
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

  void _archiveAccount(Account account) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Archive Account?'),
        content: Text('Archive "${account.name}"? You can restore it later from archived accounts.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              try {
                final archivedAccount = Account(
                  id: account.id,
                  name: account.name,
                  institution: account.institution,
                  type: account.type,
                  balance: account.balance,
                  isActive: false,
                  createdAt: account.createdAt,
                  updatedAt: DateTime.now(),
                );
                await _accountRepo.update(archivedAccount);
                await _loadAccounts();
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Archived "${account.name}"')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error archiving account: $e')),
                  );
                }
              }
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text('Archive'),
          ),
        ],
      ),
    );
  }

  IconData _getAccountIcon(AccountType type) {
    switch (type) {
      case AccountType.savings:
        return Icons.account_balance;
      case AccountType.current:
        return Icons.business;
      case AccountType.creditCard:
        return Icons.credit_card;
      case AccountType.wallet:
        return Icons.account_balance_wallet;
    }
  }

  String _getAccountTypeName(AccountType type) {
    switch (type) {
      case AccountType.savings:
        return 'Savings Account';
      case AccountType.current:
        return 'Current Account';
      case AccountType.creditCard:
        return 'Credit Card';
      case AccountType.wallet:
        return 'Wallet';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Accounts'),
        actions: [
          IconButton(
            icon: Icon(_showArchived ? Icons.unarchive : Icons.archive),
            onPressed: () {
              setState(() {
                _showArchived = !_showArchived;
              });
              _loadAccounts();
            },
            tooltip: _showArchived ? 'Show Active' : 'Show Archived',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _accounts.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _showArchived ? Icons.archive : Icons.account_balance_wallet,
                        size: 64,
                        color: Colors.grey.shade300,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _showArchived ? 'No archived accounts' : 'No accounts yet',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Colors.grey,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _showArchived
                            ? 'Archived accounts will appear here'
                            : 'Tap + to create your first account',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: _accounts.length,
                  itemBuilder: (context, index) {
                    final account = _accounts[index];
                    final balance = account.balance ?? 0;
                    final isPositive = balance >= 0;

                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.sm,
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                          child: Icon(
                            _getAccountIcon(account.type),
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        title: Text(account.name),
                        subtitle: Text(_getAccountTypeName(account.type)),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '₹${balance.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: isPositive ? Colors.green : Colors.red,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 8),
                            PopupMenuButton(
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                  value: 'edit',
                                  child: Row(
                                    children: [
                                      Icon(Icons.edit),
                                      SizedBox(width: 8),
                                      Text('Edit'),
                                    ],
                                  ),
                                ),
                                if (account.isActive)
                                  const PopupMenuItem(
                                    value: 'archive',
                                    child: Row(
                                      children: [
                                        Icon(Icons.archive, color: Colors.orange),
                                        SizedBox(width: 8),
                                        Text('Archive'),
                                      ],
                                    ),
                                  ),
                              ],
                              onSelected: (value) {
                                if (value == 'edit') {
                                  _showEditTagDialog(account);
                                } else if (value == 'archive') {
                                  _archiveAccount(account);
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'add_account_fab',
        onPressed: _showAddAccountDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
