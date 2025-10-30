import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/transaction.dart';
import '../models/budget.dart';
import '../models/account.dart';
import '../database/transaction_repository.dart';
import '../database/budget_repository.dart';
import '../database/account_repository.dart';
import '../services/notification_manager.dart';
import '../services/summary_service.dart';
import '../services/recurring_detection_service.dart';
import '../providers/transaction_provider.dart';
import '../utils/constants.dart';

/// Developer tools screen for testing and demo data generation
class DevToolsScreen extends ConsumerStatefulWidget {
  const DevToolsScreen({super.key});

  @override
  ConsumerState<DevToolsScreen> createState() => _DevToolsScreenState();
}

class _DevToolsScreenState extends ConsumerState<DevToolsScreen> {
  // Lazy-initialized services to prevent blocking on screen load
  TransactionRepository? _transactionRepo;
  BudgetRepository? _budgetRepo;
  AccountRepository? _accountRepo;
  NotificationManager? _notificationManager;
  SummaryService? _summaryService;
  RecurringDetectionService? _recurringService;
  
  bool _isGenerating = false;
  String _lastAction = '';
  
  // Lazy getters for services
  TransactionRepository get transactionRepo => _transactionRepo ??= TransactionRepository();
  BudgetRepository get budgetRepo => _budgetRepo ??= BudgetRepository();
  AccountRepository get accountRepo => _accountRepo ??= AccountRepository();
  NotificationManager get notificationManager => _notificationManager ??= NotificationManager();
  SummaryService get summaryService => _summaryService ??= SummaryService();
  RecurringDetectionService get recurringService => _recurringService ??= RecurringDetectionService();
  
  String _generateId() => 'dev_${DateTime.now().microsecondsSinceEpoch}';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Developer Tools'),
        backgroundColor: theme.colorScheme.errorContainer,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Warning card
          Card(
            color: theme.colorScheme.errorContainer,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.warning, color: theme.colorScheme.error),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Developer Tools - Use for testing only',
                      style: TextStyle(
                        color: theme.colorScheme.onErrorContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          if (_lastAction.isNotEmpty)
            Card(
              color: theme.colorScheme.primaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  _lastAction,
                  style: TextStyle(
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
            ),
          
          const SizedBox(height: 16),
          
          // Sample Data Generation
          _buildSection(
            theme,
            'Sample Data Generation',
            Icons.data_array,
            [
              _buildButton(
                'Generate 10 Transactions',
                Icons.add,
                Colors.blue,
                () => _generateTransactions(10),
              ),
              _buildButton(
                'Generate 50 Transactions',
                Icons.add_circle,
                Colors.blue,
                () => _generateTransactions(50),
              ),
              _buildButton(
                'Generate 100 Transactions (Last 3 Months)',
                Icons.add_circle_outline,
                Colors.blue,
                () => _generateTransactions(100, months: 3),
              ),
              _buildButton(
                'Generate Recurring Transactions',
                Icons.repeat,
                Colors.orange,
                _generateRecurringTransactions,
              ),
            ],
          ),
          
          // Budget Generation
          _buildSection(
            theme,
            'Budget Generation',
            Icons.account_balance_wallet,
            [
              _buildButton(
                'Create Sample Budgets',
                Icons.add_card,
                Colors.green,
                _generateBudgets,
              ),
              _buildButton(
                'Create Over-Budget Scenario',
                Icons.warning,
                Colors.red,
                _generateOverBudgetScenario,
              ),
            ],
          ),
          
          // Notification Testing
          _buildSection(
            theme,
            'Notification Testing',
            Icons.notifications,
            [
              _buildButton(
                'Test Budget Alert (50%)',
                Icons.notifications,
                Colors.blue,
                () => _testBudgetAlert(50),
              ),
              _buildButton(
                'Test Budget Alert (90%)',
                Icons.notifications_active,
                Colors.orange,
                () => _testBudgetAlert(90),
              ),
              _buildButton(
                'Test Budget Exceeded Alert',
                Icons.notification_important,
                Colors.red,
                () => _testBudgetAlert(100),
              ),
              _buildButton(
                'Test Daily Summary',
                Icons.summarize,
                Colors.purple,
                _testDailySummary,
              ),
              _buildButton(
                'Test Bill Reminder',
                Icons.receipt,
                Colors.teal,
                _testBillReminder,
              ),
            ],
          ),
          
          // Recurring Detection
          _buildSection(
            theme,
            'Recurring Detection',
            Icons.pattern,
            [
              _buildButton(
                'Detect Recurring Patterns',
                Icons.search,
                Colors.indigo,
                _detectRecurringPatterns,
              ),
            ],
          ),
          
          // Data Cleanup
          _buildSection(
            theme,
            'Data Cleanup',
            Icons.cleaning_services,
            [
              _buildButton(
                'Delete All Transactions',
                Icons.delete_sweep,
                Colors.red,
                _deleteAllTransactions,
              ),
              _buildButton(
                'Delete All Budgets',
                Icons.delete,
                Colors.red,
                _deleteAllBudgets,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
    ThemeData theme,
    String title,
    IconData icon,
    List<Widget> children,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: _isGenerating ? null : onPressed,
          icon: Icon(icon),
          label: Text(label),
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            foregroundColor: Colors.white,
          ),
        ),
      ),
    );
  }

  Future<void> _generateTransactions(int count, {int months = 1}) async {
    setState(() {
      _isGenerating = true;
      _lastAction = 'Generating $count transactions...';
    });

    try {
      final random = Random();
      final now = DateTime.now();
      final transactions = <Transaction>[];

      // Get existing accounts or create test accounts
      List<Account> accounts = await accountRepo.getAll();
      
      // If no accounts exist, create test accounts
      if (accounts.isEmpty) {
        final testAccounts = [
          Account(
            id: 'test_account_0',
            name: 'HDFC Bank',
            type: AccountType.savings,
            institution: 'HDFC Bank',
            accountNumber: '1234',
            balance: 50000.0,
            isActive: true,
            createdAt: now,
            updatedAt: now,
          ),
          Account(
            id: 'test_account_1',
            name: 'ICICI Credit Card',
            type: AccountType.creditCard,
            institution: 'ICICI Bank',
            accountNumber: '5678',
            balance: 0.0,
            creditLimit: 100000.0,
            isActive: true,
            createdAt: now,
            updatedAt: now,
          ),
          Account(
            id: 'test_account_2',
            name: 'Paytm Wallet',
            type: AccountType.wallet,
            institution: 'Paytm',
            balance: 2000.0,
            isActive: true,
            createdAt: now,
            updatedAt: now,
          ),
        ];
        
        for (var account in testAccounts) {
          await accountRepo.insert(account);
        }
        
        accounts = testAccounts;
      }

      final merchants = [
        'Amazon', 'Flipkart', 'Swiggy', 'Zomato', 'Uber',
        'Ola', 'DMart', 'Big Bazaar', 'McDonald\'s', 'KFC',
        'BookMyShow', 'Netflix', 'Spotify', 'Gym', 'Salon',
      ];

      final categories = Category.values.where((c) => c != Category.income).toList();

      for (int i = 0; i < count; i++) {
        final daysAgo = random.nextInt(months * 30);
        final date = now.subtract(Duration(days: daysAgo));
        final selectedAccount = accounts[random.nextInt(accounts.length)];
        
        final transaction = Transaction(
          id: _generateId(),
          amount: random.nextDouble() * 5000 + 100,
          type: TransactionType.debit,
          category: categories[random.nextInt(categories.length)],
          categorizationMethod: CategorizationMethod.userCorrected,
          timestamp: date,
          description: '${merchants[random.nextInt(merchants.length)]} Payment',
          accountId: selectedAccount.id,
          merchantName: merchants[random.nextInt(merchants.length)],
          paymentMethod: 'UPI',
          createdAt: date,
          updatedAt: date,
        );
        
        transactions.add(transaction);
      }

      await transactionRepo.insertBatch(transactions);
      
      // Trigger data refresh
      ref.read(transactionRefreshProvider.notifier).state++;

      setState(() {
        _isGenerating = false;
        _lastAction = '✅ Generated $count transactions successfully!';
      });
    } catch (e) {
      setState(() {
        _isGenerating = false;
        _lastAction = '❌ Error: $e';
      });
    }
  }

  Future<void> _generateRecurringTransactions() async {
    setState(() {
      _isGenerating = true;
      _lastAction = 'Generating recurring transactions...';
    });

    try {
      final now = DateTime.now();
      final transactions = <Transaction>[];

      // Netflix subscription - monthly for 6 months
      for (int i = 0; i < 6; i++) {
        final date = DateTime(now.year, now.month - i, 15);
        transactions.add(Transaction(
          id: _generateId(),
          amount: 649.0,
          type: TransactionType.debit,
          category: Category.entertainment,
          categorizationMethod: CategorizationMethod.userCorrected,
          timestamp: date,
          description: 'Netflix Subscription',
          accountId: 'test_account_0',
          merchantName: 'Netflix',
          paymentMethod: 'UPI',
          createdAt: date,
          updatedAt: date,
        ));
      }

      // Electricity bill - monthly for 6 months (variable)
      for (int i = 0; i < 6; i++) {
        final date = DateTime(now.year, now.month - i, 5);
        final amount = 1500 + Random().nextDouble() * 200;
        transactions.add(Transaction(
          id: _generateId(),
          amount: amount,
          type: TransactionType.debit,
          category: Category.billPayments,
          categorizationMethod: CategorizationMethod.userCorrected,
          timestamp: date,
          description: 'Electricity Bill',
          accountId: 'test_account_0',
          merchantName: 'Electricity Board',
          paymentMethod: 'UPI',
          createdAt: date,
          updatedAt: date,
        ));
      }

      // Gym membership - monthly for 6 months
      for (int i = 0; i < 6; i++) {
        final date = DateTime(now.year, now.month - i, 1);
        transactions.add(Transaction(
          id: _generateId(),
          amount: 1500.0,
          type: TransactionType.debit,
          category: Category.healthcare,
          categorizationMethod: CategorizationMethod.userCorrected,
          timestamp: date,
          description: 'Gym Membership',
          accountId: 'test_account_0',
          merchantName: 'Fitness First',
          paymentMethod: 'UPI',
          createdAt: date,
          updatedAt: date,
        ));
      }

      // Monthly salary - income
      for (int i = 0; i < 6; i++) {
        final date = DateTime(now.year, now.month - i, 28);
        transactions.add(Transaction(
          id: _generateId(),
          amount: 50000.0,
          type: TransactionType.credit,
          category: Category.income,
          categorizationMethod: CategorizationMethod.userCorrected,
          timestamp: date,
          description: 'Salary Credit',
          accountId: 'test_account_0',
          merchantName: 'Company XYZ',
          paymentMethod: 'Bank Transfer',
          createdAt: date,
          updatedAt: date,
        ));
      }

      await transactionRepo.insertBatch(transactions);
      
      // Trigger data refresh
      ref.read(transactionRefreshProvider.notifier).state++;

      setState(() {
        _isGenerating = false;
        _lastAction = '✅ Generated ${transactions.length} recurring transactions!\nNetflix (6), Electricity (6), Gym (6), Salary (6)';
      });
    } catch (e) {
      setState(() {
        _isGenerating = false;
        _lastAction = '❌ Error: $e';
      });
    }
  }

  Future<void> _generateBudgets() async {
    setState(() {
      _isGenerating = true;
      _lastAction = 'Creating sample budgets...';
    });

    try {
      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);
      
      final budgets = [
        Budget(
          id: _generateId(),
          name: 'Food Budget',
          amount: 5000,
          period: BudgetPeriod.monthly,
          category: Category.foodDelivery,
          startDate: startOfMonth,
          createdAt: now,
          updatedAt: now,
        ),
        Budget(
          id: _generateId(),
          name: 'Shopping Budget',
          amount: 10000,
          period: BudgetPeriod.monthly,
          category: Category.shopping,
          startDate: startOfMonth,
          createdAt: now,
          updatedAt: now,
        ),
        Budget(
          id: _generateId(),
          name: 'Entertainment',
          amount: 3000,
          period: BudgetPeriod.monthly,
          category: Category.entertainment,
          startDate: startOfMonth,
          createdAt: now,
          updatedAt: now,
        ),
      ];

      for (final budget in budgets) {
        await budgetRepo.insert(budget);
      }

      setState(() {
        _isGenerating = false;
        _lastAction = '✅ Created ${budgets.length} budgets successfully!';
      });
    } catch (e) {
      setState(() {
        _isGenerating = false;
        _lastAction = '❌ Error: $e';
      });
    }
  }

  Future<void> _generateOverBudgetScenario() async {
    setState(() {
      _isGenerating = true;
      _lastAction = 'Creating over-budget scenario...';
    });

    try {
      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);
      
      // Create a small budget
      final budget = Budget(
        id: _generateId(),
        name: 'Test Budget',
        amount: 1000,
        period: BudgetPeriod.monthly,
        category: Category.shopping,
        startDate: startOfMonth,
        createdAt: now,
        updatedAt: now,
      );
      await budgetRepo.insert(budget);

      // Create transactions exceeding the budget
      final transactions = <Transaction>[];
      
      for (int i = 0; i < 5; i++) {
        final txnDate = now.subtract(Duration(days: i));
        transactions.add(Transaction(
          id: _generateId(),
          amount: 300.0,
          type: TransactionType.debit,
          category: Category.shopping,
          categorizationMethod: CategorizationMethod.userCorrected,
          timestamp: txnDate,
          description: 'Shopping Item ${i + 1}',
          accountId: 'test_account_0',
          merchantName: 'Amazon',
          paymentMethod: 'UPI',
          createdAt: txnDate,
          updatedAt: txnDate,
        ));
      }

      await transactionRepo.insertBatch(transactions);

      setState(() {
        _isGenerating = false;
        _lastAction = '✅ Created over-budget scenario!\nBudget: ₹1000, Spent: ₹1500';
      });
    } catch (e) {
      setState(() {
        _isGenerating = false;
        _lastAction = '❌ Error: $e';
      });
    }
  }

  Future<void> _testBudgetAlert(int threshold) async {
    setState(() {
      _lastAction = 'Testing budget alert ($threshold%)...';
    });

    try {
      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);
      
      // Create a mock budget for testing
      final testBudget = Budget(
        id: 'test_budget_$threshold',
        name: 'Test Budget $threshold%',
        amount: 100.0,
        period: BudgetPeriod.monthly,
        category: Category.shopping,
        startDate: startOfMonth,
        createdAt: now,
        updatedAt: now,
      );
      
      await notificationManager.showBudgetAlert(
        budget: testBudget,
        percentage: threshold.toDouble(),
        spentAmount: threshold.toDouble(),
      );

      setState(() {
        _lastAction = '✅ Budget alert notification sent! ($threshold%)';
      });
    } catch (e) {
      setState(() {
        _lastAction = '❌ Error: $e';
      });
    }
  }

  Future<void> _testDailySummary() async {
    setState(() {
      _lastAction = 'Testing daily summary notification...';
    });

    try {
      await summaryService.showTodaysSummary();

      setState(() {
        _lastAction = '✅ Daily summary notification sent!';
      });
    } catch (e) {
      setState(() {
        _lastAction = '❌ Error: $e';
      });
    }
  }

  Future<void> _testBillReminder() async {
    setState(() {
      _lastAction = 'Testing bill reminder notification...';
    });

    try {
      await notificationManager.showBillReminder(
        billName: 'Electricity Bill',
        amount: 1500.0,
        dueDate: DateTime.now().add(const Duration(days: 3)),
        recurringId: 'test_recurring_bill',
      );

      setState(() {
        _lastAction = '✅ Bill reminder notification sent!';
      });
    } catch (e) {
      setState(() {
        _lastAction = '❌ Error: $e';
      });
    }
  }

  Future<void> _detectRecurringPatterns() async {
    setState(() {
      _isGenerating = true;
      _lastAction = 'Detecting recurring patterns...';
    });

    try {
      final patterns = await recurringService.detectRecurringPatterns();

      setState(() {
        _isGenerating = false;
        _lastAction = '✅ Found ${patterns.length} recurring patterns!';
      });
    } catch (e) {
      setState(() {
        _isGenerating = false;
        _lastAction = '❌ Error: $e';
      });
    }
  }

  Future<void> _deleteAllTransactions() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete All Transactions?'),
        content: const Text('This will delete all transactions. This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Delete All'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _isGenerating = true;
      _lastAction = 'Deleting all transactions...';
    });

    try {
      final transactions = await transactionRepo.getAll();
      final ids = transactions.map((t) => t.id).toList();
      await transactionRepo.deleteBatch(ids);
      
      // Trigger data refresh
      ref.read(transactionRefreshProvider.notifier).state++;

      setState(() {
        _isGenerating = false;
        _lastAction = '✅ Deleted ${transactions.length} transactions';
      });
    } catch (e) {
      setState(() {
        _isGenerating = false;
        _lastAction = '❌ Error: $e';
      });
    }
  }

  Future<void> _deleteAllBudgets() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete All Budgets?'),
        content: const Text('This will delete all budgets. This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Delete All'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _isGenerating = true;
      _lastAction = 'Deleting all budgets...';
    });

    try {
      final budgets = await budgetRepo.getAll();
      for (final budget in budgets) {
        await budgetRepo.delete(budget.id);
      }

      setState(() {
        _isGenerating = false;
        _lastAction = '✅ Deleted ${budgets.length} budgets';
      });
    } catch (e) {
      setState(() {
        _isGenerating = false;
        _lastAction = '❌ Error: $e';
      });
    }
  }
}
