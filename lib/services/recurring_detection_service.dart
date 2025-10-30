import 'dart:math';
import '../database/transaction_repository.dart';
import '../models/transaction.dart';
import '../models/recurring_transaction.dart';
import '../utils/constants.dart';

/// Service for detecting recurring transaction patterns
class RecurringDetectionService {
  static final RecurringDetectionService _instance = RecurringDetectionService._internal();
  factory RecurringDetectionService() => _instance;
  RecurringDetectionService._internal();

  final TransactionRepository _repository = TransactionRepository();

  /// Minimum occurrences needed to detect a pattern
  static const int minOccurrences = 2;

  /// Amount tolerance for matching (5%)
  static const double defaultAmountTolerance = 0.05;

  /// Detect all recurring patterns in transaction history
  Future<List<RecurringPattern>> detectRecurringPatterns({
    DateTime? startDate,
    int? lookbackDays = 180, // Default 6 months
  }) async {
    final now = DateTime.now();
    final effectiveStartDate = startDate ?? 
        now.subtract(Duration(days: lookbackDays!));

    // Get all transactions in the period
    final transactions = await _repository.getByDateRange(
      effectiveStartDate,
      now,
    );

    // Group transactions by merchant
    final merchantGroups = _groupByMerchant(transactions);

    // Detect patterns in each group
    final patterns = <RecurringPattern>[];
    for (final entry in merchantGroups.entries) {
      final merchant = entry.key;
      final merchantTransactions = entry.value;

      // Need at least minOccurrences transactions
      if (merchantTransactions.length < minOccurrences) continue;

      // Try to detect different frequency patterns
      final weeklyPattern = _detectFrequencyPattern(
        merchant,
        merchantTransactions,
        RecurringFrequency.weekly,
      );
      if (weeklyPattern != null && weeklyPattern.isReliable) {
        patterns.add(weeklyPattern);
        continue;
      }

      final biweeklyPattern = _detectFrequencyPattern(
        merchant,
        merchantTransactions,
        RecurringFrequency.biweekly,
      );
      if (biweeklyPattern != null && biweeklyPattern.isReliable) {
        patterns.add(biweeklyPattern);
        continue;
      }

      final monthlyPattern = _detectFrequencyPattern(
        merchant,
        merchantTransactions,
        RecurringFrequency.monthly,
      );
      if (monthlyPattern != null && monthlyPattern.isReliable) {
        patterns.add(monthlyPattern);
        continue;
      }

      final quarterlyPattern = _detectFrequencyPattern(
        merchant,
        merchantTransactions,
        RecurringFrequency.quarterly,
      );
      if (quarterlyPattern != null && quarterlyPattern.isReliable) {
        patterns.add(quarterlyPattern);
        continue;
      }

      final yearlyPattern = _detectFrequencyPattern(
        merchant,
        merchantTransactions,
        RecurringFrequency.yearly,
      );
      if (yearlyPattern != null && yearlyPattern.isReliable) {
        patterns.add(yearlyPattern);
      }
    }

    // Sort by confidence descending
    patterns.sort((a, b) => b.confidence.compareTo(a.confidence));
    
    return patterns;
  }

  /// Group transactions by merchant name
  Map<String, List<Transaction>> _groupByMerchant(List<Transaction> transactions) {
    final groups = <String, List<Transaction>>{};

    for (final transaction in transactions) {
      // Only consider expenses (debits)
      if (transaction.type != TransactionType.debit) continue;

      final merchant = transaction.merchantName ?? transaction.description;
      if (merchant.isEmpty) continue;

      // Normalize merchant name (lowercase, trim)
      final normalizedMerchant = _normalizeMerchantName(merchant);

      groups.putIfAbsent(normalizedMerchant, () => []).add(transaction);
    }

    return groups;
  }

  /// Normalize merchant name for grouping
  String _normalizeMerchantName(String merchant) {
    return merchant.toLowerCase().trim()
      .replaceAll(RegExp(r'\s+'), ' ') // Normalize whitespace
      .replaceAll(RegExp(r'[^\w\s]'), ''); // Remove special chars
  }

  /// Detect a specific frequency pattern in transactions
  RecurringPattern? _detectFrequencyPattern(
    String merchant,
    List<Transaction> transactions,
    RecurringFrequency frequency,
  ) {
    if (transactions.length < minOccurrences) return null;

    // Sort by date
    final sorted = List<Transaction>.from(transactions)
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    // Calculate intervals between transactions
    final intervals = <int>[];
    for (int i = 1; i < sorted.length; i++) {
      final days = sorted[i].timestamp.difference(sorted[i - 1].timestamp).inDays;
      intervals.add(days);
    }

    // Expected interval for this frequency
    final expectedInterval = frequency.duration.inDays;
    final tolerance = (expectedInterval * 0.2).round(); // 20% tolerance

    // Check if intervals match the expected frequency
    int matchingIntervals = 0;
    for (final interval in intervals) {
      if ((interval - expectedInterval).abs() <= tolerance) {
        matchingIntervals++;
      }
    }

    // Calculate confidence based on matching intervals
    final confidence = intervals.isNotEmpty 
        ? matchingIntervals / intervals.length 
        : 0.0;

    // Need at least 70% matching intervals
    if (confidence < 0.7) return null;

    // Calculate average amount
    final amounts = sorted.map((t) => t.amount).toList();
    final avgAmount = amounts.reduce((a, b) => a + b) / amounts.length;

    // Check amount consistency
    final amountVariance = _calculateAmountVariance(amounts, avgAmount);
    final amountConfidence = 1.0 - min(amountVariance, 1.0);

    // Overall confidence is average of interval and amount confidence
    final overallConfidence = (confidence + amountConfidence) / 2;

    // Get most common category
    final categoryMap = <Category, int>{};
    for (final t in sorted) {
      categoryMap[t.category] = (categoryMap[t.category] ?? 0) + 1;
    }
    final mostCommonCategory = categoryMap.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;

    return RecurringPattern(
      merchantPattern: merchant,
      avgAmount: avgAmount,
      frequency: frequency,
      occurrences: sorted.map((t) => t.timestamp).toList(),
      confidence: overallConfidence,
      category: mostCommonCategory.name,
    );
  }

  /// Calculate variance in amounts as a percentage
  double _calculateAmountVariance(List<double> amounts, double avg) {
    if (amounts.length <= 1) return 0.0;

    // Calculate standard deviation
    double sumSquaredDiff = 0.0;
    for (final amount in amounts) {
      final diff = amount - avg;
      sumSquaredDiff += diff * diff;
    }

    final variance = sqrt(sumSquaredDiff / amounts.length);
    return variance / avg; // Coefficient of variation
  }

  /// Predict next occurrence of a recurring pattern
  DateTime predictNextOccurrence(RecurringPattern pattern) {
    if (pattern.occurrences.isEmpty) {
      return DateTime.now().add(pattern.frequency.duration);
    }

    final lastOccurrence = pattern.occurrences.last;
    return lastOccurrence.add(pattern.frequency.duration);
  }

  /// Check if a transaction matches a recurring pattern
  bool matchesPattern(
    Transaction transaction,
    RecurringPattern pattern, {
    double? amountTolerance,
  }) {
    final tolerance = amountTolerance ?? defaultAmountTolerance;

    // Check merchant match
    final normalizedMerchant = _normalizeMerchantName(
      transaction.merchantName ?? transaction.description,
    );
    if (normalizedMerchant != pattern.merchantPattern) {
      return false;
    }

    // Check amount match (within tolerance)
    final amountDiff = (transaction.amount - pattern.avgAmount).abs();
    final maxDiff = pattern.avgAmount * tolerance;
    if (amountDiff > maxDiff) {
      return false;
    }

    // Check category match
    if (transaction.category.name != pattern.category) {
      return false;
    }

    return true;
  }

  /// Get upcoming recurring transactions (predictions for next 30 days)
  Future<List<Map<String, dynamic>>> getUpcomingRecurring() async {
    final patterns = await detectRecurringPatterns();
    final upcoming = <Map<String, dynamic>>[];
    final now = DateTime.now();
    final thirtyDaysLater = now.add(const Duration(days: 30));

    for (final pattern in patterns) {
      if (!pattern.isReliable) continue;

      final nextDate = predictNextOccurrence(pattern);
      if (nextDate.isAfter(now) && nextDate.isBefore(thirtyDaysLater)) {
        upcoming.add({
          'merchant': pattern.merchantPattern,
          'amount': pattern.avgAmount,
          'frequency': pattern.frequency.displayName,
          'nextDate': nextDate,
          'confidence': pattern.confidence,
          'category': pattern.category,
        });
      }
    }

    // Sort by next date
    upcoming.sort((a, b) => 
      (a['nextDate'] as DateTime).compareTo(b['nextDate'] as DateTime));

    return upcoming;
  }
}
