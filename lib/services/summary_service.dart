import 'package:intl/intl.dart';
import '../models/transaction.dart';
import '../database/transaction_repository.dart';
import '../utils/constants.dart';
import 'notification_manager.dart';

/// Service for calculating and displaying daily spending summaries
class SummaryService {
  static final SummaryService _instance = SummaryService._internal();
  factory SummaryService() => _instance;
  SummaryService._internal();

  final TransactionRepository _repository = TransactionRepository();
  final NotificationManager _notificationManager = NotificationManager();

  /// Calculate and show today's spending summary
  Future<void> showTodaysSummary() async {
    // Check if daily summaries are enabled
    final enabled = await _notificationManager.areDailySummariesEnabled();
    if (!enabled) return;

    final summary = await calculateDailySummary(DateTime.now());
    
    // Only show if there were transactions today
    if (summary.transactionCount > 0) {
      // Convert list to map for notification
      final topCategoriesMap = <String, double>{};
      for (final entry in summary.topCategoriesRaw.entries.take(3)) {
        topCategoriesMap[entry.key] = entry.value;
      }

      await _notificationManager.showDailySummary(
        totalSpent: summary.totalSpent,
        transactionCount: summary.transactionCount,
        topCategories: topCategoriesMap,
      );
    }
  }

  /// Calculate summary for a specific date
  Future<DailySummary> calculateDailySummary(DateTime date) async {
    // Get start and end of day
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    // Get all transactions for the day
    final todaysTransactions = await _repository.getByDateRange(
      startOfDay,
      endOfDay,
    );

    // Calculate total spent (debits/expenses only)
    double totalSpent = 0;
    int transactionCount = 0;
    
    for (final transaction in todaysTransactions) {
      if (transaction.type == TransactionType.debit) {
        totalSpent += transaction.amount;
        transactionCount++;
      }
    }

    // Calculate top categories
    final categoryTotals = <String, double>{};
    for (final transaction in todaysTransactions) {
      if (transaction.type == TransactionType.debit) {
        final categoryName = transaction.category.name;
        categoryTotals[categoryName] =
            (categoryTotals[categoryName] ?? 0) + transaction.amount;
      }
    }

    // Sort categories by total and get top 3
    final sortedCategories = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    final topCategories = sortedCategories
        .take(3)
        .map((e) => '${e.key}: ${_formatCurrency(e.value)}')
        .toList();

    return DailySummary(
      date: date,
      totalSpent: totalSpent,
      transactionCount: transactionCount,
      topCategories: topCategories,
      topCategoriesRaw: categoryTotals,
      transactions: todaysTransactions,
    );
  }

  /// Calculate weekly summary
  Future<WeeklySummary> calculateWeeklySummary(DateTime weekStart) async {
    final weekEnd = weekStart.add(const Duration(days: 7));
    
    final weekTransactions = await _repository.getByDateRange(
      weekStart,
      weekEnd,
    );

    // Calculate daily totals
    final dailyTotals = <DateTime, double>{};
    for (var i = 0; i < 7; i++) {
      final day = weekStart.add(Duration(days: i));
      final dayStart = DateTime(day.year, day.month, day.day);
      final dayEnd = dayStart.add(const Duration(days: 1));
      
      double dayTotal = 0;
      for (final transaction in weekTransactions) {
        if (transaction.type == TransactionType.debit &&
            transaction.timestamp.isAfter(dayStart) &&
            transaction.timestamp.isBefore(dayEnd)) {
          dayTotal += transaction.amount;
        }
      }
      dailyTotals[dayStart] = dayTotal;
    }

    // Calculate total spent
    double totalSpent = 0;
    int transactionCount = 0;
    for (final transaction in weekTransactions) {
      if (transaction.type == TransactionType.debit) {
        totalSpent += transaction.amount;
        transactionCount++;
      }
    }

    // Calculate average daily spending
    final averageDaily = totalSpent / 7;

    // Find highest spending day
    final highestDay = dailyTotals.entries
        .reduce((a, b) => a.value > b.value ? a : b);

    return WeeklySummary(
      weekStart: weekStart,
      weekEnd: weekEnd,
      totalSpent: totalSpent,
      transactionCount: transactionCount,
      averageDaily: averageDaily,
      dailyTotals: dailyTotals,
      highestSpendingDay: highestDay.key,
      highestSpendingAmount: highestDay.value,
    );
  }

  /// Calculate monthly summary
  Future<MonthlySummary> calculateMonthlySummary(int year, int month) async {
    final monthStart = DateTime(year, month, 1);
    final monthEnd = DateTime(year, month + 1, 1);
    
    final monthTransactions = await _repository.getByDateRange(
      monthStart,
      monthEnd,
    );

    // Calculate totals by type
    double totalExpenses = 0;
    double totalIncome = 0;
    int expenseCount = 0;
    int incomeCount = 0;

    for (final transaction in monthTransactions) {
      if (transaction.type == TransactionType.debit) {
        totalExpenses += transaction.amount;
        expenseCount++;
      } else {
        totalIncome += transaction.amount;
        incomeCount++;
      }
    }

    // Calculate category breakdown
    final categoryTotals = <String, double>{};
    for (final transaction in monthTransactions) {
      if (transaction.type == TransactionType.debit) {
        final categoryName = transaction.category.name;
        categoryTotals[categoryName] =
            (categoryTotals[categoryName] ?? 0) + transaction.amount;
      }
    }

    // Calculate daily average
    final daysInMonth = monthEnd.difference(monthStart).inDays;
    final averageDaily = totalExpenses / daysInMonth;

    return MonthlySummary(
      year: year,
      month: month,
      totalExpenses: totalExpenses,
      totalIncome: totalIncome,
      expenseCount: expenseCount,
      incomeCount: incomeCount,
      netBalance: totalIncome - totalExpenses,
      categoryBreakdown: categoryTotals,
      averageDaily: averageDaily,
    );
  }

  /// Get spending trend (comparison with previous period)
  Future<SpendingTrend> getSpendingTrend({
    required DateTime currentStart,
    required DateTime currentEnd,
  }) async {
    final duration = currentEnd.difference(currentStart);
    final previousStart = currentStart.subtract(duration);
    final previousEnd = currentStart;

    // Current period
    final currentTransactions = await _repository.getByDateRange(
      currentStart,
      currentEnd,
    );
    
    double currentTotal = 0;
    for (final t in currentTransactions) {
      if (t.type == TransactionType.debit) {
        currentTotal += t.amount;
      }
    }

    // Previous period
    final previousTransactions = await _repository.getByDateRange(
      previousStart,
      previousEnd,
    );
    
    double previousTotal = 0;
    for (final t in previousTransactions) {
      if (t.type == TransactionType.debit) {
        previousTotal += t.amount;
      }
    }

    // Calculate change
    final difference = currentTotal - previousTotal;
    final percentageChange = previousTotal > 0 
        ? (difference / previousTotal) * 100 
        : 0.0;

    return SpendingTrend(
      currentPeriodTotal: currentTotal,
      previousPeriodTotal: previousTotal,
      difference: difference,
      percentageChange: percentageChange,
      isIncreasing: difference > 0,
    );
  }

  String _formatCurrency(double amount) {
    final formatter = NumberFormat.currency(symbol: '₹', decimalDigits: 0);
    return formatter.format(amount);
  }
}

/// Daily spending summary data
class DailySummary {
  final DateTime date;
  final double totalSpent;
  final int transactionCount;
  final List<String> topCategories;
  final Map<String, double> topCategoriesRaw;
  final List<Transaction> transactions;

  DailySummary({
    required this.date,
    required this.totalSpent,
    required this.transactionCount,
    required this.topCategories,
    required this.topCategoriesRaw,
    required this.transactions,
  });
}

/// Weekly spending summary data
class WeeklySummary {
  final DateTime weekStart;
  final DateTime weekEnd;
  final double totalSpent;
  final int transactionCount;
  final double averageDaily;
  final Map<DateTime, double> dailyTotals;
  final DateTime highestSpendingDay;
  final double highestSpendingAmount;

  WeeklySummary({
    required this.weekStart,
    required this.weekEnd,
    required this.totalSpent,
    required this.transactionCount,
    required this.averageDaily,
    required this.dailyTotals,
    required this.highestSpendingDay,
    required this.highestSpendingAmount,
  });
}

/// Monthly spending summary data
class MonthlySummary {
  final int year;
  final int month;
  final double totalExpenses;
  final double totalIncome;
  final int expenseCount;
  final int incomeCount;
  final double netBalance;
  final Map<String, double> categoryBreakdown;
  final double averageDaily;

  MonthlySummary({
    required this.year,
    required this.month,
    required this.totalExpenses,
    required this.totalIncome,
    required this.expenseCount,
    required this.incomeCount,
    required this.netBalance,
    required this.categoryBreakdown,
    required this.averageDaily,
  });
}

/// Spending trend comparison
class SpendingTrend {
  final double currentPeriodTotal;
  final double previousPeriodTotal;
  final double difference;
  final double percentageChange;
  final bool isIncreasing;

  SpendingTrend({
    required this.currentPeriodTotal,
    required this.previousPeriodTotal,
    required this.difference,
    required this.percentageChange,
    required this.isIncreasing,
  });
}
