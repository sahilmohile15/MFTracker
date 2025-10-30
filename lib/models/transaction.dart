/// Transaction data model for MFTracker
library;

import 'package:freezed_annotation/freezed_annotation.dart';
import '../utils/constants.dart';

part 'transaction.freezed.dart';
part 'transaction.g.dart';

/// Represents a financial transaction parsed from notifications or manually added
@freezed
class Transaction with _$Transaction {
  const factory Transaction({
    /// Unique identifier for the transaction
    required String id,

    /// Transaction amount (always positive, type determines debit/credit)
    required double amount,

    /// Transaction type (debit or credit)
    required TransactionType type,

    /// Category of the transaction
    required Category category,

    /// How the category was determined
    required CategorizationMethod categorizationMethod,

    /// Transaction date and time
    required DateTime timestamp,

    /// Description/narration of the transaction
    required String description,

    /// Account ID this transaction belongs to
    required String accountId,

    /// Last 4 digits of account number (from SMS)
    String? accountNumber,

    /// Merchant/payee name
    String? merchantName,

    /// UPI transaction ID if applicable
    String? upiTransactionId,

    /// UPI ID used for payment
    String? upiId,

    /// Payment method (UPI, Card, ATM, etc.)
    String? paymentMethod,

    /// Balance after transaction (if available in notification)
    double? balanceAfter,

    /// Original notification body/text
    String? smsBody,

    /// Notification sender (package name or title)
    String? smsSender,

    /// Notification timestamp
    DateTime? smsTimestamp,

    /// Whether this is a recurring transaction
    @Default(false) bool isRecurring,

    /// Recurring transaction parent ID
    String? recurringParentId,

    /// Tags associated with the transaction
    @Default([]) List<String> tags,

    /// Notes added by user
    String? notes,

    /// Confidence score of categorization (0-1)
    @Default(0.0) double categorizationConfidence,

    /// Whether transaction was manually edited by user
    @Default(false) bool isManuallyEdited,

    /// Creation timestamp
    required DateTime createdAt,

    /// Last update timestamp
    required DateTime updatedAt,
  }) = _Transaction;

  factory Transaction.fromJson(Map<String, dynamic> json) =>
      _$TransactionFromJson(json);

  /// Create from database map
  factory Transaction.fromDatabase(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'] as String,
      amount: (map['amount'] as num).toDouble(),
      type: TransactionType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => TransactionType.debit,
      ),
      category: Category.values.firstWhere(
        (e) => e.name == map['category'],
        orElse: () => Category.others,
      ),
      categorizationMethod: CategorizationMethod.values.firstWhere(
        (e) => e.name == map['categorization_method'],
        orElse: () => CategorizationMethod.ruleBased,
      ),
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] as int),
      description: map['description'] as String,
      accountId: map['account_id'] as String,
      accountNumber: map['account_number'] as String?,
      merchantName: map['merchant_name'] as String?,
      upiTransactionId: map['upi_transaction_id'] as String?,
      upiId: map['upi_id'] as String?,
      paymentMethod: map['payment_method'] as String?,
      balanceAfter: map['balance_after'] != null
          ? (map['balance_after'] as num).toDouble()
          : null,
      smsBody: map['sms_body'] as String?,
      smsSender: map['sms_sender'] as String?,
      smsTimestamp: map['sms_timestamp'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['sms_timestamp'] as int)
          : null,
      isRecurring: (map['is_recurring'] as int) == 1,
      recurringParentId: map['recurring_parent_id'] as String?,
      tags: _parseTagsFromDatabase(map['tags']),
      notes: map['notes'] as String?,
      categorizationConfidence:
          (map['categorization_confidence'] as num).toDouble(),
      isManuallyEdited: (map['is_manually_edited'] as int) == 1,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at'] as int),
    );
  }

  /// Parse tags from database (handles both String and null)
  static List<String> _parseTagsFromDatabase(dynamic tagsValue) {
    if (tagsValue == null) return [];
    if (tagsValue is String) {
      return tagsValue.isEmpty ? [] : tagsValue.split(',');
    }
    return [];
  }
}

/// Extension methods for Transaction
extension TransactionExtension on Transaction {
  /// Get signed amount (negative for debit, positive for credit)
  double get signedAmount => type == TransactionType.debit ? -amount : amount;

  /// Check if transaction is today
  bool get isToday {
    final now = DateTime.now();
    return timestamp.year == now.year &&
        timestamp.month == now.month &&
        timestamp.day == now.day;
  }

  /// Check if transaction is this month
  bool get isThisMonth {
    final now = DateTime.now();
    return timestamp.year == now.year && timestamp.month == now.month;
  }

  /// Check if transaction is this year
  bool get isThisYear {
    return timestamp.year == DateTime.now().year;
  }

  /// Get formatted amount with currency symbol
  String get formattedAmount => amount.toStringAsFixed(2);

  /// Get display title for transaction
  String get displayTitle =>
      merchantName ?? description.split(' ').take(3).join(' ');

  /// Check if transaction was imported from notification
  bool get isFromNotification => smsBody != null && smsBody!.isNotEmpty;

  /// Check if category was auto-assigned
  bool get isAutoCategerized =>
      categorizationMethod != CategorizationMethod.userCorrected;

  /// Get category confidence level (Low, Medium, High)
  String get confidenceLevel {
    if (categorizationConfidence >= 0.8) return 'High';
    if (categorizationConfidence >= 0.5) return 'Medium';
    return 'Low';
  }

  /// Create a copy with updated category and mark as user corrected
  Transaction correctCategory(Category newCategory) {
    return copyWith(
      category: newCategory,
      categorizationMethod: CategorizationMethod.userCorrected,
      categorizationConfidence: 1.0,
      isManuallyEdited: true,
      updatedAt: DateTime.now(),
    );
  }

  /// Convert to database map
  Map<String, dynamic> toDatabase() {
    return {
      'id': id,
      'amount': amount,
      'type': type.name,
      'category': category.name,
      'categorization_method': categorizationMethod.name,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'description': description,
      'account_id': accountId,
      'account_number': accountNumber,
      'merchant_name': merchantName,
      'upi_transaction_id': upiTransactionId,
      'upi_id': upiId,
      'payment_method': paymentMethod,
      'balance_after': balanceAfter,
      'sms_body': smsBody,
      'sms_sender': smsSender,
      'sms_timestamp': smsTimestamp?.millisecondsSinceEpoch,
      'is_recurring': isRecurring ? 1 : 0,
      'recurring_parent_id': recurringParentId,
      'tags': tags.join(','),
      'notes': notes,
      'categorization_confidence': categorizationConfidence,
      'is_manually_edited': isManuallyEdited ? 1 : 0,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
    };
  }
}
