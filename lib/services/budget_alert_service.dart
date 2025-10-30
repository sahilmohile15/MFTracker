import 'package:shared_preferences/shared_preferences.dart';
import '../database/budget_repository.dart';
import '../database/transaction_repository.dart';
import '../models/budget.dart';
import '../models/transaction.dart';
import '../utils/constants.dart';
import 'notification_manager.dart';

/// Service for monitoring budgets and triggering alerts when thresholds are crossed
class BudgetAlertService {
  static final BudgetAlertService _instance = BudgetAlertService._internal();
  factory BudgetAlertService() => _instance;
  BudgetAlertService._internal();

  final BudgetRepository _budgetRepository = BudgetRepository();
  final TransactionRepository _transactionRepository = TransactionRepository();
  final NotificationManager _notificationManager = NotificationManager();

  /// Check budget alerts after a transaction is added or updated
  Future<void> checkBudgetAlertsForTransaction(Transaction transaction) async {
    // Only check for debits (expenses)
    if (transaction.type != TransactionType.debit) return;

    // Get all active budgets
    final budgets = await _budgetRepository.getAll();
    final activeBudgets = budgets.where((b) => b.isActive && b.notificationsEnabled).toList();

    for (final budget in activeBudgets) {
      // Check if budget applies to this transaction
      if (!_budgetAppliesToTransaction(budget, transaction)) continue;

      // Calculate current spending for this budget
      final spending = await _calculateBudgetSpending(budget);
      
      // Check thresholds and trigger alerts
      await _checkThresholdsAndNotify(budget, spending);
    }
  }

  /// Check all budget alerts (useful for periodic checks or bulk operations)
  Future<void> checkAllBudgetAlerts() async {
    final budgets = await _budgetRepository.getAll();
    final activeBudgets = budgets.where((b) => b.isActive && b.notificationsEnabled).toList();

    for (final budget in activeBudgets) {
      final spending = await _calculateBudgetSpending(budget);
      await _checkThresholdsAndNotify(budget, spending);
    }
  }

  /// Check if a budget applies to a transaction
  bool _budgetAppliesToTransaction(Budget budget, Transaction transaction) {
    // Check category match
    if (budget.category != null && budget.category != transaction.category) {
      return false;
    }

    // Check account match
    if (budget.accountId != null && budget.accountId != transaction.accountId) {
      return false;
    }

    // Check if transaction is within budget period
    final (startDate, endDate) = _getBudgetDateRange(budget, DateTime.now());
    return transaction.timestamp.isAfter(startDate) && 
           transaction.timestamp.isBefore(endDate);
  }

  /// Calculate current spending for a budget
  Future<double> _calculateBudgetSpending(Budget budget) async {
    final (startDate, endDate) = _getBudgetDateRange(budget, DateTime.now());

    // Get all transactions in the budget period
    final transactions = await _transactionRepository.getByDateRange(
      startDate,
      endDate,
    );

    // Filter by budget criteria and calculate total
    double total = 0.0;
    for (final transaction in transactions) {
      // Only count debits (expenses)
      if (transaction.type != TransactionType.debit) continue;

      // Check category match
      if (budget.category != null && budget.category != transaction.category) {
        continue;
      }

      // Check account match
      if (budget.accountId != null && budget.accountId != transaction.accountId) {
        continue;
      }

      total += transaction.amount;
    }

    return total;
  }

  /// Get the date range for a budget period
  (DateTime, DateTime) _getBudgetDateRange(Budget budget, DateTime referenceDate) {
    final DateTime startDate;
    final DateTime endDate;

    switch (budget.period) {
      case BudgetPeriod.daily:
        startDate = DateTime(referenceDate.year, referenceDate.month, referenceDate.day);
        endDate = startDate.add(const Duration(days: 1));
        break;

      case BudgetPeriod.weekly:
        // Start from beginning of week (Monday)
        final weekday = referenceDate.weekday;
        startDate = referenceDate.subtract(Duration(days: weekday - 1));
        final weekStart = DateTime(startDate.year, startDate.month, startDate.day);
        endDate = weekStart.add(const Duration(days: 7));
        break;

      case BudgetPeriod.monthly:
        startDate = DateTime(referenceDate.year, referenceDate.month, 1);
        endDate = DateTime(referenceDate.year, referenceDate.month + 1, 1);
        break;

      case BudgetPeriod.yearly:
        startDate = DateTime(referenceDate.year, 1, 1);
        endDate = DateTime(referenceDate.year + 1, 1, 1);
        break;

      case BudgetPeriod.custom:
        startDate = budget.startDate;
        endDate = budget.endDate ?? DateTime.now().add(const Duration(days: 365));
        break;
    }

    return (startDate, endDate);
  }

  /// Check thresholds and send notifications if needed
  Future<void> _checkThresholdsAndNotify(Budget budget, double spending) async {
    final percentage = (spending / budget.amount) * 100;

    // Define thresholds in order
    const thresholds = [50.0, 75.0, 90.0, 100.0];

    for (final threshold in thresholds) {
      if (percentage >= threshold) {
        // Check if already notified for this threshold
        final alreadyNotified = await _notificationManager.hasBeenNotified(
          budget.id,
          threshold,
        );

        if (!alreadyNotified) {
          // Send notification
          await _notificationManager.showBudgetAlert(
            budget: budget,
            spentAmount: spending,
            percentage: percentage,
          );

          // Mark as notified
          await _notificationManager.markAsNotified(budget.id, threshold);
          
          // Only notify for the first unnotified threshold
          break;
        }
      }
    }
  }

  /// Update budget spending and check alerts (called when budget is modified)
  Future<void> updateBudgetSpending(String budgetId) async {
    final budget = await _budgetRepository.getById(budgetId);
    if (budget == null || !budget.isActive || !budget.notificationsEnabled) {
      return;
    }

    final spending = await _calculateBudgetSpending(budget);
    await _checkThresholdsAndNotify(budget, spending);
  }

  /// Reset all notification flags for a budget (useful when budget resets or is modified)
  Future<void> resetBudgetNotifications(String budgetId) async {
    final prefs = await SharedPreferences.getInstance();
    const thresholds = [50, 75, 90, 100];
    
    for (final threshold in thresholds) {
      final key = 'notified_${budgetId}_$threshold';
      await prefs.remove(key);
    }
  }

  /// Get list of budgets that need attention (for debugging/testing)
  Future<List<(Budget, double, double)>> getBudgetsNeedingAlerts() async {
    final budgets = await _budgetRepository.getAll();
    final results = <(Budget, double, double)>[];

    for (final budget in budgets) {
      if (!budget.isActive || !budget.notificationsEnabled) continue;

      final spending = await _calculateBudgetSpending(budget);
      final percentage = (spending / budget.amount) * 100;

      if (percentage >= 50.0) {
        results.add((budget, spending, percentage));
      }
    }

    // Sort by percentage descending
    results.sort((a, b) => b.$3.compareTo(a.$3));
    return results;
  }
}
