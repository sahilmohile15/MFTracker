import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/transaction_repository.dart';
import '../models/transaction.dart';
import '../services/budget_alert_service.dart';
import '../utils/constants.dart';

/// Repository provider
final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  return TransactionRepository();
});

/// Provider to trigger refresh of transaction data
final transactionRefreshProvider = StateProvider.autoDispose<int>((ref) => 0);

/// Provider for all transactions
final transactionListProvider = StreamProvider.autoDispose<List<Transaction>>((ref) async* {
  final repository = ref.watch(transactionRepositoryProvider);
  
  // Watch the refresh trigger to reload data when it changes
  ref.watch(transactionRefreshProvider);
  
  // Load transactions
  final transactions = await repository.getAll(limit: 100);
  yield transactions;
});

/// Provider for transactions grouped by date
final transactionsByDateProvider = Provider.autoDispose<Map<DateTime, List<Transaction>>>((ref) {
  final transactionsAsync = ref.watch(transactionListProvider);
  
  return transactionsAsync.when(
    data: (transactions) {
      final Map<DateTime, List<Transaction>> grouped = {};
      
      for (final transaction in transactions) {
        final date = DateTime(
          transaction.timestamp.year,
          transaction.timestamp.month,
          transaction.timestamp.day,
        );
        
        if (!grouped.containsKey(date)) {
          grouped[date] = [];
        }
        grouped[date]!.add(transaction);
      }
      
      // Sort each day's transactions by time (newest first)
      for (final date in grouped.keys) {
        grouped[date]!.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      }
      
      return grouped;
    },
    loading: () => {},
    error: (_, __) => {},
  );
});

/// Provider for transactions grouped by category
final transactionsByCategoryProvider = Provider.autoDispose<Map<Category, List<Transaction>>>((ref) {
  final transactionsAsync = ref.watch(transactionListProvider);
  
  return transactionsAsync.when(
    data: (transactions) {
      final Map<Category, List<Transaction>> grouped = {};
      
      for (final transaction in transactions) {
        if (!grouped.containsKey(transaction.category)) {
          grouped[transaction.category] = [];
        }
        grouped[transaction.category]!.add(transaction);
      }
      
      return grouped;
    },
    loading: () => {},
    error: (_, __) => {},
  );
});

/// Provider for monthly transactions (current month)
final monthlyTransactionsProvider = Provider.autoDispose<List<Transaction>>((ref) {
  final transactionsAsync = ref.watch(transactionListProvider);
  final now = DateTime.now();
  final startOfMonth = DateTime(now.year, now.month, 1);
  final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
  
  return transactionsAsync.when(
    data: (transactions) {
      return transactions.where((t) {
        return t.timestamp.isAfter(startOfMonth) && 
               t.timestamp.isBefore(endOfMonth);
      }).toList();
    },
    loading: () => [],
    error: (_, __) => [],
  );
});

/// Provider for monthly spending by category
final monthlySpendingByCategoryProvider = Provider.autoDispose<Map<Category, double>>((ref) {
  final monthlyTransactions = ref.watch(monthlyTransactionsProvider);
  final Map<Category, double> spending = {};
  
  for (final transaction in monthlyTransactions) {
    if (transaction.type == TransactionType.debit) {
      spending[transaction.category] = 
        (spending[transaction.category] ?? 0.0) + transaction.amount;
    }
  }
  
  return spending;
});

/// Provider for total income/expenses in current month
final monthlyTotalsProvider = Provider.autoDispose<({double income, double expenses})>((ref) {
  final monthlyTransactions = ref.watch(monthlyTransactionsProvider);
  
  double income = 0.0;
  double expenses = 0.0;
  
  for (final transaction in monthlyTransactions) {
    if (transaction.type == TransactionType.credit) {
      income += transaction.amount;
    } else {
      expenses += transaction.amount;
    }
  }
  
  return (income: income, expenses: expenses);
});

/// Provider for a single transaction by ID
final transactionByIdProvider = FutureProvider.autoDispose.family<Transaction?, String>((ref, id) async {
  final repository = ref.watch(transactionRepositoryProvider);
  return await repository.getById(id);
});

/// Transaction actions notifier for CRUD operations
class TransactionNotifier extends StateNotifier<AsyncValue<void>> {
  TransactionNotifier(this.repository, this.ref) : super(const AsyncValue.data(null));
  
  final TransactionRepository repository;
  final Ref ref;
  final BudgetAlertService _budgetAlertService = BudgetAlertService();
  
  /// Trigger data refresh across all screens
  void _triggerRefresh() {
    ref.read(transactionRefreshProvider.notifier).state++;
  }
  
  /// Add a new transaction
  Future<void> addTransaction(Transaction transaction) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await repository.insert(transaction);
      
      // Check budget alerts for this transaction
      await _budgetAlertService.checkBudgetAlertsForTransaction(transaction);
      
      // Trigger refresh
      _triggerRefresh();
    });
  }
  
  /// Update an existing transaction
  Future<void> updateTransaction(Transaction transaction) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await repository.update(transaction);
      
      // Re-check budget alerts after update
      await _budgetAlertService.checkBudgetAlertsForTransaction(transaction);
      
      // Trigger refresh
      _triggerRefresh();
    });
  }
  
  /// Delete a transaction
  Future<void> deleteTransaction(String id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      // Get transaction before deleting to check affected budgets
      final transaction = await repository.getById(id);
      
      await repository.delete(id);
      
      // Re-check all budgets after deletion
      if (transaction != null) {
        await _budgetAlertService.checkBudgetAlertsForTransaction(transaction);
      }
      
      // Trigger refresh
      _triggerRefresh();
    });
  }
  
  /// Delete multiple transactions
  Future<void> deleteTransactions(List<String> ids) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await repository.deleteBatch(ids);
      
      // Re-check all budgets after bulk delete
      await _budgetAlertService.checkAllBudgetAlerts();
      
      // Trigger refresh
      _triggerRefresh();
    });
  }
  
  /// Add multiple transactions (bulk import)
  Future<void> addTransactions(List<Transaction> transactions) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await repository.insertBatch(transactions);
      
      // Check alerts for all imported transactions
      for (final transaction in transactions) {
        await _budgetAlertService.checkBudgetAlertsForTransaction(transaction);
      }
      
      // Trigger refresh
      _triggerRefresh();
    });
  }
}

/// Provider for transaction actions
final transactionActionsProvider = StateNotifierProvider<TransactionNotifier, AsyncValue<void>>((ref) {
  final repository = ref.watch(transactionRepositoryProvider);
  return TransactionNotifier(repository, ref);
});
