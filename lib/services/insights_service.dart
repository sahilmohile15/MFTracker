import '../models/transaction.dart';
import '../models/budget.dart';
import '../utils/constants.dart';

/// Simple date range class
class DateRange {
  final DateTime start;
  final DateTime end;
  
  DateRange({required this.start, required this.end});
}

/// Service for calculating financial insights and analytics
class InsightsService {
  static final InsightsService _instance = InsightsService._internal();
  factory InsightsService() => _instance;
  InsightsService._internal();

  /// Calculate spending trend over time
  SpendingTrend calculateSpendingTrend({
    required List<Transaction> transactions,
    required DateTime startDate,
    required DateTime endDate,
  }) {
    final currentPeriodTransactions = transactions.where((t) {
      return t.timestamp.isAfter(startDate) &&
             t.timestamp.isBefore(endDate.add(const Duration(days: 1)));
    }).toList();
    
    final duration = endDate.difference(startDate);
    final previousStart = startDate.subtract(duration);
    final previousEnd = startDate;
    
    final previousPeriodTransactions = transactions.where((t) {
      return t.timestamp.isAfter(previousStart) &&
             t.timestamp.isBefore(previousEnd);
    }).toList();
    
    final currentSpending = currentPeriodTransactions
        .where((t) => t.type == TransactionType.debit)
        .fold(0.0, (sum, t) => sum + t.amount);
    
    final previousSpending = previousPeriodTransactions
        .where((t) => t.type == TransactionType.debit)
        .fold(0.0, (sum, t) => sum + t.amount);
    
    final change = currentSpending - previousSpending;
    final percentChange = previousSpending > 0
        ? (change / previousSpending) * 100
        : 0.0;
    
    return SpendingTrend(
      currentPeriodSpending: currentSpending,
      previousPeriodSpending: previousSpending,
      change: change,
      percentChange: percentChange,
      transactionCount: currentPeriodTransactions.length,
    );
  }

  /// Calculate category comparison data
  List<CategoryInsight> calculateCategoryInsights({
    required List<Transaction> transactions,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    final filteredTransactions = transactions.where((t) {
      if (t.type != TransactionType.debit) return false;
      if (startDate != null && t.timestamp.isBefore(startDate)) return false;
      if (endDate != null && t.timestamp.isAfter(endDate.add(const Duration(days: 1)))) return false;
      return true;
    }).toList();
    
    final categoryTotals = <Category, double>{};
    final categoryCount = <Category, int>{};
    
    for (final transaction in filteredTransactions) {
      categoryTotals[transaction.category] = 
          (categoryTotals[transaction.category] ?? 0) + transaction.amount;
      categoryCount[transaction.category] = 
          (categoryCount[transaction.category] ?? 0) + 1;
    }
    
    final totalSpending = categoryTotals.values.fold(0.0, (sum, value) => sum + value);
    
    final insights = categoryTotals.entries.map((entry) {
      final percentage = totalSpending > 0 ? (entry.value / totalSpending) * 100 : 0.0;
      return CategoryInsight(
        category: entry.key,
        amount: entry.value,
        percentage: percentage,
        transactionCount: categoryCount[entry.key] ?? 0,
      );
    }).toList();
    
    insights.sort((a, b) => b.amount.compareTo(a.amount));
    
    return insights;
  }

  /// Calculate budget performance metrics
  List<BudgetPerformance> calculateBudgetPerformance({
    required List<Budget> budgets,
    required List<Transaction> transactions,
  }) {
    final performance = <BudgetPerformance>[];
    final now = DateTime.now();
    
    for (final budget in budgets) {
      // Skip budgets without a category (overall budgets)
      if (budget.category == null) continue;
      
      final dateRange = _getBudgetDateRange(budget, now);
      
      final relevantTransactions = transactions.where((t) {
        return t.type == TransactionType.debit &&
               t.category == budget.category &&
               t.timestamp.isAfter(dateRange.start) &&
               t.timestamp.isBefore(dateRange.end.add(const Duration(days: 1)));
      }).toList();
      
      final spent = relevantTransactions.fold(0.0, (sum, t) => sum + t.amount);
      final percentUsed = (spent / budget.amount) * 100;
      final remaining = budget.amount - spent;
      
      // Calculate days remaining
      final daysRemaining = dateRange.end.difference(now).inDays;
      final totalDays = dateRange.end.difference(dateRange.start).inDays;
      
      // Calculate projected spending
      final daysElapsed = now.difference(dateRange.start).inDays;
      final projectedSpending = daysElapsed > 0
          ? (spent / daysElapsed) * totalDays
          : spent;
      
      performance.add(BudgetPerformance(
        budget: budget,
        spent: spent,
        remaining: remaining,
        percentUsed: percentUsed,
        daysRemaining: daysRemaining,
        totalDays: totalDays,
        projectedSpending: projectedSpending,
        isOnTrack: projectedSpending <= budget.amount,
      ));
    }
    
    return performance;
  }

  /// Predict next month's spending based on historical data
  SpendingForecast predictNextMonthSpending({
    required List<Transaction> transactions,
  }) {
    final now = DateTime.now();
    final sixMonthsAgo = DateTime(now.year, now.month - 6, now.day);
    
    final recentTransactions = transactions.where((t) {
      return t.timestamp.isAfter(sixMonthsAgo) && t.timestamp.isBefore(now);
    }).toList();
    
    // Calculate monthly averages
    final monthlyTotals = <int, double>{};
    
    for (final transaction in recentTransactions) {
      if (transaction.type == TransactionType.debit) {
        final monthKey = transaction.timestamp.year * 12 + transaction.timestamp.month;
        monthlyTotals[monthKey] = (monthlyTotals[monthKey] ?? 0) + transaction.amount;
      }
    }
    
    if (monthlyTotals.isEmpty) {
      return SpendingForecast(
        predictedAmount: 0,
        confidence: 0,
        trend: ForecastTrend.stable,
      );
    }
    
    // Calculate average and trend
    final average = monthlyTotals.values.reduce((a, b) => a + b) / monthlyTotals.length;
    
    // Calculate trend (last 3 months vs previous 3 months)
    final sortedMonths = monthlyTotals.keys.toList()..sort();
    
    ForecastTrend trend = ForecastTrend.stable;
    if (sortedMonths.length >= 6) {
      final recentAvg = sortedMonths.sublist(sortedMonths.length - 3)
          .map((m) => monthlyTotals[m]!)
          .reduce((a, b) => a + b) / 3;
      
      final oldAvg = sortedMonths.sublist(sortedMonths.length - 6, sortedMonths.length - 3)
          .map((m) => monthlyTotals[m]!)
          .reduce((a, b) => a + b) / 3;
      
      if (recentAvg > oldAvg * 1.1) {
        trend = ForecastTrend.increasing;
      } else if (recentAvg < oldAvg * 0.9) {
        trend = ForecastTrend.decreasing;
      }
    }
    
    // Calculate confidence based on data consistency
    final variance = monthlyTotals.values
        .map((v) => (v - average) * (v - average))
        .reduce((a, b) => a + b) / monthlyTotals.length;
    final stdDev = variance > 0 ? variance : 0.0;
    final cv = average > 0 ? (stdDev / average) : 1.0; // Coefficient of variation
    
    final confidence = (1 - cv.clamp(0.0, 1.0)) * 100;
    
    return SpendingForecast(
      predictedAmount: average,
      confidence: confidence,
      trend: trend,
    );
  }

  /// Calculate daily spending pattern
  Map<int, double> calculateDailySpendingPattern({
    required List<Transaction> transactions,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    final filteredTransactions = transactions.where((t) {
      if (t.type != TransactionType.debit) return false;
      if (startDate != null && t.timestamp.isBefore(startDate)) return false;
      if (endDate != null && t.timestamp.isAfter(endDate.add(const Duration(days: 1)))) return false;
      return true;
    }).toList();
    
    final dailyTotals = <int, double>{};
    
    for (final transaction in filteredTransactions) {
      final day = transaction.timestamp.day;
      dailyTotals[day] = (dailyTotals[day] ?? 0) + transaction.amount;
    }
    
    return dailyTotals;
  }

  /// Calculate monthly comparison
  List<MonthlyComparison> calculateMonthlyComparison({
    required List<Transaction> transactions,
    required int monthCount,
  }) {
    final now = DateTime.now();
    final comparisons = <MonthlyComparison>[];
    
    for (int i = 0; i < monthCount; i++) {
      final month = DateTime(now.year, now.month - i, 1);
      final nextMonth = DateTime(now.year, now.month - i + 1, 1);
      
      final monthTransactions = transactions.where((t) {
        return t.timestamp.isAfter(month) && t.timestamp.isBefore(nextMonth);
      }).toList();
      
      final income = monthTransactions
          .where((t) => t.type == TransactionType.credit)
          .fold(0.0, (sum, t) => sum + t.amount);
      
      final expense = monthTransactions
          .where((t) => t.type == TransactionType.debit)
          .fold(0.0, (sum, t) => sum + t.amount);
      
      comparisons.add(MonthlyComparison(
        month: month,
        income: income,
        expense: expense,
        net: income - expense,
        transactionCount: monthTransactions.length,
      ));
    }
    
    return comparisons.reversed.toList();
  }

  DateRange _getBudgetDateRange(Budget budget, DateTime now) {
    switch (budget.period) {
      case BudgetPeriod.daily:
        return DateRange(
          start: DateTime(now.year, now.month, now.day),
          end: DateTime(now.year, now.month, now.day, 23, 59, 59),
        );
      
      case BudgetPeriod.weekly:
        final weekStart = now.subtract(Duration(days: now.weekday - 1));
        return DateRange(
          start: DateTime(weekStart.year, weekStart.month, weekStart.day),
          end: DateTime(weekStart.year, weekStart.month, weekStart.day + 6, 23, 59, 59),
        );
      
      case BudgetPeriod.monthly:
        return DateRange(
          start: DateTime(now.year, now.month, 1),
          end: DateTime(now.year, now.month + 1, 0, 23, 59, 59),
        );
      
      case BudgetPeriod.yearly:
        return DateRange(
          start: DateTime(now.year, 1, 1),
          end: DateTime(now.year, 12, 31, 23, 59, 59),
        );
      
      case BudgetPeriod.custom:
        return DateRange(
          start: DateTime(now.year, now.month, 1),
          end: DateTime(now.year, now.month + 1, 0, 23, 59, 59),
        );
    }
  }
}

/// Spending trend data
class SpendingTrend {
  final double currentPeriodSpending;
  final double previousPeriodSpending;
  final double change;
  final double percentChange;
  final int transactionCount;

  SpendingTrend({
    required this.currentPeriodSpending,
    required this.previousPeriodSpending,
    required this.change,
    required this.percentChange,
    required this.transactionCount,
  });
}

/// Category insight data
class CategoryInsight {
  final Category category;
  final double amount;
  final double percentage;
  final int transactionCount;

  CategoryInsight({
    required this.category,
    required this.amount,
    required this.percentage,
    required this.transactionCount,
  });
}

/// Budget performance data
class BudgetPerformance {
  final Budget budget;
  final double spent;
  final double remaining;
  final double percentUsed;
  final int daysRemaining;
  final int totalDays;
  final double projectedSpending;
  final bool isOnTrack;

  BudgetPerformance({
    required this.budget,
    required this.spent,
    required this.remaining,
    required this.percentUsed,
    required this.daysRemaining,
    required this.totalDays,
    required this.projectedSpending,
    required this.isOnTrack,
  });
}

/// Spending forecast data
class SpendingForecast {
  final double predictedAmount;
  final double confidence;
  final ForecastTrend trend;

  SpendingForecast({
    required this.predictedAmount,
    required this.confidence,
    required this.trend,
  });
}

enum ForecastTrend {
  increasing,
  stable,
  decreasing,
}

/// Monthly comparison data
class MonthlyComparison {
  final DateTime month;
  final double income;
  final double expense;
  final double net;
  final int transactionCount;

  MonthlyComparison({
    required this.month,
    required this.income,
    required this.expense,
    required this.net,
    required this.transactionCount,
  });
}
