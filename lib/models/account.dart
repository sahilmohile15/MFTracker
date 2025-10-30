/// Account data model for MFTracker
library;

import 'package:freezed_annotation/freezed_annotation.dart';
import '../utils/constants.dart';

part 'account.freezed.dart';
part 'account.g.dart';

/// Represents a financial account (bank account, credit card, wallet)
@freezed
class Account with _$Account {
  const factory Account({
    /// Unique identifier for the account
    required String id,

    /// Account name (e.g., "HDFC Savings", "ICICI Credit Card")
    required String name,

    /// Type of account
    required AccountType type,

    /// Bank/institution name
    required String institution,

    /// Last 4 digits of account number
    String? accountNumber,

    /// Current balance (if tracked)
    double? balance,

    /// Credit limit (for credit cards)
    double? creditLimit,

    /// Currency code (default: INR)
    @Default('INR') String currency,

    /// Custom color for the account (hex string)
    String? color,

    /// Custom icon name
    String? icon,

    /// Whether this account is active
    @Default(true) bool isActive,

    /// Whether to include in total balance calculations
    @Default(true) bool includeInTotal,

    /// Default category for transactions from this account
    Category? defaultCategory,

    /// Notes about the account
    String? notes,

    /// Creation timestamp
    required DateTime createdAt,

    /// Last update timestamp
    required DateTime updatedAt,
  }) = _Account;

  factory Account.fromJson(Map<String, dynamic> json) =>
      _$AccountFromJson(json);

  /// Create from database map
  factory Account.fromDatabase(Map<String, dynamic> map) {
    return Account(
      id: map['id'] as String,
      name: map['name'] as String,
      type: AccountType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => AccountType.savings,
      ),
      institution: map['institution'] as String,
      accountNumber: map['account_number'] as String?,
      balance: map['balance'] != null ? (map['balance'] as num).toDouble() : null,
      creditLimit: map['credit_limit'] != null
          ? (map['credit_limit'] as num).toDouble()
          : null,
      currency: map['currency'] as String? ?? 'INR',
      color: map['color'] as String?,
      icon: map['icon'] as String?,
      isActive: (map['is_active'] as int) == 1,
      includeInTotal: (map['include_in_total'] as int) == 1,
      defaultCategory: map['default_category'] != null
          ? Category.values.firstWhere(
              (e) => e.name == map['default_category'],
              orElse: () => Category.others,
            )
          : null,
      notes: map['notes'] as String?,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at'] as int),
    );
  }
}

/// Extension methods for Account
extension AccountExtension on Account {
  /// Get display name with account number
  String get displayName =>
      accountNumber != null ? '$name (••$accountNumber)' : name;

  /// Get available balance (for credit cards: limit - balance)
  double? get availableBalance {
    if (type == AccountType.creditCard && creditLimit != null) {
      return creditLimit! - (balance ?? 0.0);
    }
    return balance;
  }

  /// Check if account has balance information
  bool get hasBalance => balance != null;

  /// Check if account is a credit card
  bool get isCreditCard => type == AccountType.creditCard;

  /// Check if account is over limit (for credit cards)
  bool get isOverLimit {
    if (!isCreditCard || creditLimit == null || balance == null) {
      return false;
    }
    return balance! > creditLimit!;
  }

  /// Get credit utilization percentage (for credit cards)
  double? get creditUtilization {
    if (!isCreditCard || creditLimit == null || balance == null) {
      return null;
    }
    if (creditLimit == 0) return 0.0;
    return (balance! / creditLimit!) * 100;
  }

  /// Convert to database map
  Map<String, dynamic> toDatabase() {
    return {
      'id': id,
      'name': name,
      'type': type.name,
      'institution': institution,
      'account_number': accountNumber,
      'balance': balance,
      'credit_limit': creditLimit,
      'currency': currency,
      'color': color,
      'icon': icon,
      'is_active': isActive ? 1 : 0,
      'include_in_total': includeInTotal ? 1 : 0,
      'default_category': defaultCategory?.name,
      'notes': notes,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
    };
  }
}
