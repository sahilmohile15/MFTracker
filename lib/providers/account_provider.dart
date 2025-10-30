import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/account_repository.dart';
import '../database/transaction_repository.dart';
import '../models/account.dart';
import '../utils/constants.dart';

/// Repository provider
final accountRepositoryProvider = Provider<AccountRepository>((ref) {
  return AccountRepository();
});

/// Provider for all accounts
final accountListProvider = StreamProvider.autoDispose<List<Account>>((ref) async* {
  final repository = ref.watch(accountRepositoryProvider);
  
  // Initial load
  final accounts = await repository.getAll();
  yield accounts;
  
  // In a real app, you'd use a stream from the database
});

/// Provider for active accounts only
final activeAccountsProvider = Provider.autoDispose<List<Account>>((ref) {
  final accountsAsync = ref.watch(accountListProvider);
  
  return accountsAsync.when(
    data: (accounts) => accounts.where((a) => a.isActive).toList(),
    loading: () => [],
    error: (_, __) => [],
  );
});

/// Provider for accounts by type
final accountsByTypeProvider = Provider.autoDispose.family<List<Account>, AccountType>((ref, type) {
  final accountsAsync = ref.watch(accountListProvider);
  
  return accountsAsync.when(
    data: (accounts) => accounts.where((a) => a.type == type && a.isActive).toList(),
    loading: () => [],
    error: (_, __) => [],
  );
});

/// Provider for a single account by ID
final accountByIdProvider = FutureProvider.autoDispose.family<Account?, String>((ref, id) async {
  final repository = ref.watch(accountRepositoryProvider);
  return await repository.getById(id);
});

/// Provider to calculate account balance from transactions
final accountBalanceProvider = FutureProvider.autoDispose.family<double, String>((ref, accountId) async {
  final transactionRepo = TransactionRepository();
  final transactions = await transactionRepo.getByAccount(accountId);
  
  double balance = 0.0;
  for (final transaction in transactions) {
    if (transaction.type == TransactionType.credit) {
      balance += transaction.amount;
    } else {
      balance -= transaction.amount;
    }
  }
  
  return balance;
});

/// Provider for total balance across all accounts
final totalBalanceProvider = FutureProvider.autoDispose<double>((ref) async {
  final accountsAsync = ref.watch(accountListProvider);
  
  return await accountsAsync.when(
    data: (accounts) async {
      double total = 0.0;
      for (final account in accounts) {
        if (account.includeInTotal && account.isActive) {
          final balance = await ref.read(accountBalanceProvider(account.id).future);
          total += balance;
        }
      }
      return total;
    },
    loading: () => 0.0,
    error: (_, __) => 0.0,
  );
});

/// Provider for account statistics
final accountStatsProvider = FutureProvider.autoDispose.family<AccountStats, String>((ref, accountId) async {
  final transactionRepo = TransactionRepository();
  
  // Get all transactions for this account
  final transactions = await transactionRepo.getByAccount(accountId);
  
  final now = DateTime.now();
  final startOfMonth = DateTime(now.year, now.month, 1);
  
  double totalIncome = 0.0;
  double totalExpenses = 0.0;
  double thisMonthIncome = 0.0;
  double thisMonthExpenses = 0.0;
  int thisMonthCount = 0;
  
  for (final transaction in transactions) {
    if (transaction.type == TransactionType.credit) {
      totalIncome += transaction.amount;
      if (transaction.timestamp.isAfter(startOfMonth)) {
        thisMonthIncome += transaction.amount;
        thisMonthCount++;
      }
    } else {
      totalExpenses += transaction.amount;
      if (transaction.timestamp.isAfter(startOfMonth)) {
        thisMonthExpenses += transaction.amount;
        thisMonthCount++;
      }
    }
  }
  
  return AccountStats(
    totalTransactions: transactions.length,
    thisMonthTransactions: thisMonthCount,
    totalIncome: totalIncome,
    totalExpenses: totalExpenses,
    thisMonthIncome: thisMonthIncome,
    thisMonthExpenses: thisMonthExpenses,
  );
});

/// Account statistics data class
class AccountStats {
  final int totalTransactions;
  final int thisMonthTransactions;
  final double totalIncome;
  final double totalExpenses;
  final double thisMonthIncome;
  final double thisMonthExpenses;
  
  AccountStats({
    required this.totalTransactions,
    required this.thisMonthTransactions,
    required this.totalIncome,
    required this.totalExpenses,
    required this.thisMonthIncome,
    required this.thisMonthExpenses,
  });
  
  double get netBalance => totalIncome - totalExpenses;
  double get thisMonthNet => thisMonthIncome - thisMonthExpenses;
}

/// Account actions notifier for CRUD operations
class AccountNotifier extends StateNotifier<AsyncValue<void>> {
  AccountNotifier(this.repository) : super(const AsyncValue.data(null));
  
  final AccountRepository repository;
  
  /// Add a new account
  Future<void> addAccount(Account account) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await repository.insert(account);
    });
  }
  
  /// Update an existing account
  Future<void> updateAccount(Account account) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await repository.update(account);
    });
  }
  
  /// Delete an account
  Future<void> deleteAccount(String id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await repository.delete(id);
    });
  }
  
  /// Deactivate an account (soft delete)
  Future<void> deactivateAccount(String id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final account = await repository.getById(id);
      if (account != null) {
        await repository.update(account.copyWith(isActive: false));
      }
    });
  }
  
  /// Reactivate an account
  Future<void> reactivateAccount(String id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final account = await repository.getById(id);
      if (account != null) {
        await repository.update(account.copyWith(isActive: true));
      }
    });
  }
  
  /// Update account balance
  Future<void> updateBalance(String id, double balance) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await repository.updateBalance(id, balance);
    });
  }
}

/// Provider for account actions
final accountActionsProvider = StateNotifierProvider.autoDispose<AccountNotifier, AsyncValue<void>>((ref) {
  final repository = ref.watch(accountRepositoryProvider);
  return AccountNotifier(repository);
});

/// Provider to refresh account list
final accountRefreshProvider = StateProvider.autoDispose<int>((ref) => 0);

/// Helper to refresh accounts
void refreshAccounts(WidgetRef ref) {
  ref.read(accountRefreshProvider.notifier).state++;
  ref.invalidate(accountListProvider);
}
