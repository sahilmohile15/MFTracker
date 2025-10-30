import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/budget_repository.dart';
import '../models/budget.dart';
import 'transaction_provider.dart';

/// Repository provider
final budgetRepositoryProvider = Provider<BudgetRepository>((ref) {
  return BudgetRepository();
});

/// Provider for all budgets
final budgetListProvider = StreamProvider.autoDispose<List<Budget>>((ref) async* {
  final repository = ref.watch(budgetRepositoryProvider);
  
  // Initial load
  final budgets = await repository.getAll();
  yield budgets;
});

/// Provider for active budgets only
final activeBudgetsProvider = Provider.autoDispose<List<Budget>>((ref) {
  final budgetsAsync = ref.watch(budgetListProvider);
  
  return budgetsAsync.when(
    data: (budgets) => budgets.where((b) => b.isActive).toList(),
    loading: () => [],
    error: (_, __) => [],
  );
});

/// Provider for budgets by period
final budgetsByPeriodProvider = Provider.autoDispose.family<List<Budget>, BudgetPeriod>((ref, period) {
  final budgetsAsync = ref.watch(budgetListProvider);
  
  return budgetsAsync.when(
    data: (budgets) => budgets
        .where((b) => b.period == period && b.isActive)
        .toList(),
    loading: () => [],
    error: (_, __) => [],
  );
});

/// Provider for a single budget by ID
final budgetByIdProvider = FutureProvider.autoDispose.family<Budget?, String>((ref, id) async {
  final repository = ref.watch(budgetRepositoryProvider);
  return await repository.getById(id);
});

/// Provider for budget progress (spent vs limit)
final budgetProgressProvider = FutureProvider.autoDispose.family<BudgetProgress, String>((ref, budgetId) async {
  final budget = await ref.watch(budgetByIdProvider(budgetId).future);
  if (budget == null) {
    return BudgetProgress(
      budget: null,
      spent: 0.0,
      remaining: 0.0,
      percentage: 0.0,
      isOverBudget: false,
      needsAlert: false,
    );
  }
  
  // Get transactions for this budget's category and time period
  final monthlyTransactions = ref.watch(monthlyTransactionsProvider);
  
  double spent = 0.0;
  for (final transaction in monthlyTransactions) {
    if (budget.category != null && transaction.category == budget.category) {
      spent += transaction.amount;
    }
  }
  
  final remaining = budget.amount - spent;
  final percentage = (spent / budget.amount) * 100;
  final isOverBudget = spent > budget.amount;
  final needsAlert = percentage >= budget.alertThreshold;
  
  return BudgetProgress(
    budget: budget,
    spent: spent,
    remaining: remaining,
    percentage: percentage,
    isOverBudget: isOverBudget,
    needsAlert: needsAlert,
  );
});

/// Provider for all budget progress
final allBudgetProgressProvider = FutureProvider.autoDispose<List<BudgetProgress>>((ref) async {
  final budgetsAsync = ref.watch(budgetListProvider);
  
  return await budgetsAsync.when(
    data: (budgets) async {
      final List<BudgetProgress> progressList = [];
      for (final budget in budgets) {
        if (budget.isActive) {
          final progress = await ref.watch(
            budgetProgressProvider(budget.id.toString()).future,
          );
          progressList.add(progress);
        }
      }
      return progressList;
    },
    loading: () => [],
    error: (_, __) => [],
  );
});

/// Provider for budgets needing alerts
final budgetsNeedingAlertProvider = Provider.autoDispose<List<BudgetProgress>>((ref) {
  final progressAsync = ref.watch(allBudgetProgressProvider);
  
  return progressAsync.when(
    data: (progressList) =>
        progressList.where((p) => p.needsAlert).toList(),
    loading: () => [],
    error: (_, __) => [],
  );
});

/// Provider for over-budget items
final overBudgetProvider = Provider.autoDispose<List<BudgetProgress>>((ref) {
  final progressAsync = ref.watch(allBudgetProgressProvider);
  
  return progressAsync.when(
    data: (progressList) =>
        progressList.where((p) => p.isOverBudget).toList(),
    loading: () => [],
    error: (_, __) => [],
  );
});

/// Budget progress data class
class BudgetProgress {
  final Budget? budget;
  final double spent;
  final double remaining;
  final double percentage;
  final bool isOverBudget;
  final bool needsAlert;
  
  BudgetProgress({
    required this.budget,
    required this.spent,
    required this.remaining,
    required this.percentage,
    required this.isOverBudget,
    required this.needsAlert,
  });
  
  /// Get alert level (none, warning, danger)
  AlertLevel get alertLevel {
    if (isOverBudget) return AlertLevel.danger;
    if (needsAlert) return AlertLevel.warning;
    return AlertLevel.none;
  }
}

/// Alert level enum
enum AlertLevel {
  none,
  warning,
  danger,
}

/// Budget actions notifier for CRUD operations
class BudgetNotifier extends StateNotifier<AsyncValue<void>> {
  BudgetNotifier(this.repository) : super(const AsyncValue.data(null));
  
  final BudgetRepository repository;
  
  /// Add a new budget
  Future<void> addBudget(Budget budget) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await repository.insert(budget);
    });
  }
  
  /// Update an existing budget
  Future<void> updateBudget(Budget budget) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await repository.update(budget);
    });
  }
  
  /// Delete a budget
  Future<void> deleteBudget(String id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await repository.delete(id);
    });
  }
  
  /// Deactivate a budget (soft delete)
  Future<void> deactivateBudget(String id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final budget = await repository.getById(id);
      if (budget != null) {
        await repository.update(budget.copyWith(isActive: false));
      }
    });
  }
  
  /// Reactivate a budget
  Future<void> reactivateBudget(String id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final budget = await repository.getById(id);
      if (budget != null) {
        await repository.update(budget.copyWith(isActive: true));
      }
    });
  }
  
  /// Update spent amount (called when transactions change)
  Future<void> updateSpentAmount(String id, double amount) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await repository.updateSpentAmount(id, amount);
    });
  }
}

/// Provider for budget actions
final budgetActionsProvider = StateNotifierProvider<BudgetNotifier, AsyncValue<void>>((ref) {
  final repository = ref.watch(budgetRepositoryProvider);
  return BudgetNotifier(repository);
});

/// Provider to refresh budget list
final budgetRefreshProvider = StateProvider.autoDispose<int>((ref) => 0);

/// Helper to refresh budgets
void refreshBudgets(WidgetRef ref) {
  ref.read(budgetRefreshProvider.notifier).state++;
  ref.invalidate(budgetListProvider);
}
