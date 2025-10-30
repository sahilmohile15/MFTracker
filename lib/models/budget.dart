/// Budget data model for MFTracker
library;

import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../utils/constants.dart';

part 'budget.freezed.dart';
part 'budget.g.dart';

/// Budget period type
enum BudgetPeriod {
  daily,
  weekly,
  monthly,
  yearly,
  custom;

  String get displayName {
    switch (this) {
      case BudgetPeriod.daily:
        return 'Daily';
      case BudgetPeriod.weekly:
        return 'Weekly';
      case BudgetPeriod.monthly:
        return 'Monthly';
      case BudgetPeriod.yearly:
        return 'Yearly';
      case BudgetPeriod.custom:
        return 'Custom';
    }
  }

  Duration get duration {
    switch (this) {
      case BudgetPeriod.daily:
        return const Duration(days: 1);
      case BudgetPeriod.weekly:
        return const Duration(days: 7);
      case BudgetPeriod.monthly:
        return const Duration(days: 30);
      case BudgetPeriod.yearly:
        return const Duration(days: 365);
      case BudgetPeriod.custom:
        return const Duration(days: 30); // Default
    }
  }
}

/// Represents a budget for a category or overall spending
@freezed
class Budget with _$Budget {
  const factory Budget({
    /// Unique identifier for the budget
    required String id,

    /// Budget name
    required String name,

    /// Budget amount limit
    required double amount,

    /// Budget period
    required BudgetPeriod period,

    /// Category this budget applies to (null for overall budget)
    Category? category,

    /// Account this budget applies to (null for all accounts)
    String? accountId,

    /// Budget start date
    required DateTime startDate,

    /// Budget end date (for custom period)
    DateTime? endDate,

    /// Whether budget is active
    @Default(true) bool isActive,

    /// Whether to send notifications
    @Default(true) bool notificationsEnabled,

    /// Alert threshold percentage (e.g., 80 for 80%)
    @Default(80.0) double alertThreshold,

    /// Budget description/notes
    String? description,

    /// Creation timestamp
    required DateTime createdAt,

    /// Last update timestamp
    required DateTime updatedAt,
  }) = _Budget;

  factory Budget.fromJson(Map<String, dynamic> json) =>
      _$BudgetFromJson(json);

  /// Create Budget from database map
  factory Budget.fromDatabase(Map<String, dynamic> map) {
    return Budget(
      id: map['id'].toString(),
      name: map['name'] as String,
      amount: (map['amount'] as num).toDouble(),
      period: BudgetPeriod.values.firstWhere(
        (e) => e.name == map['period'],
        orElse: () => BudgetPeriod.monthly,
      ),
      category: map['category'] != null
          ? Category.values.firstWhere(
              (c) => c.name == map['category'],
              orElse: () => Category.others,
            )
          : null,
      accountId: map['account_id'] as String?,
      startDate: DateTime.fromMillisecondsSinceEpoch(map['start_date'] as int),
      endDate: map['end_date'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['end_date'] as int)
          : null,
      isActive: (map['is_active'] as int) == 1,
      notificationsEnabled: (map['notifications_enabled'] as int) == 1,
      alertThreshold: (map['alert_threshold'] as num).toDouble(),
      description: map['description'] as String?,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at'] as int),
    );
  }
}

/// Extension methods for Budget
extension BudgetExtension on Budget {
  /// Get the current period start date based on budget period
  DateTime get currentPeriodStart {
    final now = DateTime.now();
    switch (period) {
      case BudgetPeriod.daily:
        return DateTime(now.year, now.month, now.day);
      case BudgetPeriod.weekly:
        final weekday = now.weekday;
        return DateTime(now.year, now.month, now.day)
            .subtract(Duration(days: weekday - 1));
      case BudgetPeriod.monthly:
        return DateTime(now.year, now.month, 1);
      case BudgetPeriod.yearly:
        return DateTime(now.year, 1, 1);
      case BudgetPeriod.custom:
        return startDate;
    }
  }

  /// Get the current period end date based on budget period
  DateTime get currentPeriodEnd {
    switch (period) {
      case BudgetPeriod.daily:
        return currentPeriodStart
            .add(const Duration(days: 1))
            .subtract(const Duration(milliseconds: 1));
      case BudgetPeriod.weekly:
        return currentPeriodStart
            .add(const Duration(days: 7))
            .subtract(const Duration(milliseconds: 1));
      case BudgetPeriod.monthly:
        final start = currentPeriodStart;
        return DateTime(start.year, start.month + 1, 1)
            .subtract(const Duration(milliseconds: 1));
      case BudgetPeriod.yearly:
        return DateTime(currentPeriodStart.year, 12, 31, 23, 59, 59, 999);
      case BudgetPeriod.custom:
        return endDate ?? startDate.add(const Duration(days: 30));
    }
  }

  /// Check if budget is currently active period
  bool get isCurrentPeriod {
    final now = DateTime.now();
    return now.isAfter(currentPeriodStart) && now.isBefore(currentPeriodEnd);
  }

  /// Get display name for budget
  String get displayName {
    if (category != null) {
      return '${category!.name} - ${period.displayName}';
    }
    return '$name - ${period.displayName}';
  }

  /// Get alert amount (threshold)
  double get alertAmount => amount * (alertThreshold / 100);

  /// Calculate spending percentage
  double calculateSpentPercentage(double spent) {
    if (amount == 0) return 0.0;
    return (spent / amount) * 100;
  }

  /// Calculate remaining amount
  double calculateRemaining(double spent) {
    return amount - spent;
  }

  /// Check if budget is exceeded
  bool isExceeded(double spent) {
    return spent > amount;
  }

  /// Check if alert threshold is reached
  bool isAlertThresholdReached(double spent) {
    return spent >= alertAmount;
  }

  /// Get status color based on spending
  Color getStatusColor(double spent) {
    final percentage = calculateSpentPercentage(spent);
    if (percentage >= 100) {
      return AppColors.errorColor; // Over budget
    } else if (percentage >= alertThreshold) {
      return AppColors.warningColor; // Near limit
    } else {
      return AppColors.successColor; // Within budget
    }
  }

  /// Convert to database map
  Map<String, dynamic> toDatabase() {
    return {
      'id': id,
      'name': name,
      'amount': amount,
      'period': period.name,
      'category': category?.name,
      'account_id': accountId,
      'start_date': startDate.millisecondsSinceEpoch,
      'end_date': endDate?.millisecondsSinceEpoch,
      'is_active': isActive ? 1 : 0,
      'notifications_enabled': notificationsEnabled ? 1 : 0,
      'alert_threshold': alertThreshold,
      'description': description,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
    };
  }

  /// Create from database map
  static Budget fromDatabase(Map<String, dynamic> map) {
    return Budget(
      id: map['id'] as String,
      name: map['name'] as String,
      amount: (map['amount'] as num).toDouble(),
      period: BudgetPeriod.values.firstWhere(
        (e) => e.name == map['period'],
        orElse: () => BudgetPeriod.monthly,
      ),
      category: map['category'] != null
          ? Category.values.firstWhere(
              (e) => e.name == map['category'],
              orElse: () => Category.others,
            )
          : null,
      accountId: map['account_id'] as String?,
      startDate: DateTime.fromMillisecondsSinceEpoch(map['start_date'] as int),
      endDate: map['end_date'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['end_date'] as int)
          : null,
      isActive: (map['is_active'] as int) == 1,
      notificationsEnabled: (map['notifications_enabled'] as int) == 1,
      alertThreshold: (map['alert_threshold'] as num).toDouble(),
      description: map['description'] as String?,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at'] as int),
    );
  }
}
