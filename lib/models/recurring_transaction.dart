import 'package:freezed_annotation/freezed_annotation.dart';

part 'recurring_transaction.freezed.dart';
part 'recurring_transaction.g.dart';

/// Frequency of recurring transactions
enum RecurringFrequency {
  weekly,
  biweekly,
  monthly,
  quarterly,
  yearly;

  String get displayName {
    switch (this) {
      case RecurringFrequency.weekly:
        return 'Weekly';
      case RecurringFrequency.biweekly:
        return 'Bi-weekly';
      case RecurringFrequency.monthly:
        return 'Monthly';
      case RecurringFrequency.quarterly:
        return 'Quarterly';
      case RecurringFrequency.yearly:
        return 'Yearly';
    }
  }

  Duration get duration {
    switch (this) {
      case RecurringFrequency.weekly:
        return const Duration(days: 7);
      case RecurringFrequency.biweekly:
        return const Duration(days: 14);
      case RecurringFrequency.monthly:
        return const Duration(days: 30);
      case RecurringFrequency.quarterly:
        return const Duration(days: 91);
      case RecurringFrequency.yearly:
        return const Duration(days: 365);
    }
  }
}

/// Represents a detected recurring transaction pattern
@freezed
class RecurringTransaction with _$RecurringTransaction {
  const factory RecurringTransaction({
    /// Unique identifier
    required String id,

    /// Merchant/payee name pattern
    required String merchantPattern,

    /// Expected amount (may vary slightly)
    required double amount,

    /// Amount tolerance for matching (e.g., ±5%)
    @Default(0.05) double amountTolerance,

    /// Frequency of recurrence
    required RecurringFrequency frequency,

    /// Category of the recurring transaction
    required String category,

    /// List of transaction IDs that match this pattern
    required List<String> matchedTransactionIds,

    /// Confidence score (0-1) of the pattern detection
    required double confidence,

    /// Whether this pattern is confirmed by user
    @Default(false) bool isConfirmed,

    /// Whether to send reminder notifications
    @Default(true) bool notificationsEnabled,

    /// Days before expected date to send reminder
    @Default(3) int reminderDaysBefore,

    /// Next expected transaction date
    required DateTime nextExpectedDate,

    /// Last detected transaction date
    required DateTime lastDetectedDate,

    /// Date when pattern was first detected
    required DateTime createdAt,

    /// Last update timestamp
    required DateTime updatedAt,

    /// Optional notes/description
    String? notes,
  }) = _RecurringTransaction;

  factory RecurringTransaction.fromJson(Map<String, dynamic> json) =>
      _$RecurringTransactionFromJson(json);
}

/// Pattern match result for a potential recurring transaction
class RecurringPattern {
  final String merchantPattern;
  final double avgAmount;
  final RecurringFrequency frequency;
  final List<DateTime> occurrences;
  final double confidence;
  final String category;

  RecurringPattern({
    required this.merchantPattern,
    required this.avgAmount,
    required this.frequency,
    required this.occurrences,
    required this.confidence,
    required this.category,
  });

  /// Check if this pattern has enough occurrences to be reliable
  bool get isReliable => occurrences.length >= 2 && confidence >= 0.7;
}
