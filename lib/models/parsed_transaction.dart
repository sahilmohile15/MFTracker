/// Parsed transaction model for SMS parsing
library;

import 'package:freezed_annotation/freezed_annotation.dart';
import '../utils/constants.dart';

part 'parsed_transaction.freezed.dart';
part 'parsed_transaction.g.dart';

/// Represents a transaction parsed from SMS (before saving to database)
@freezed
class ParsedTransaction with _$ParsedTransaction {
  const factory ParsedTransaction({
    /// Transaction amount
    required double amount,

    /// Transaction type (debit or credit)
    required TransactionType type,

    /// Transaction description from SMS
    required String description,

    /// SMS sender address
    required String smsSender,

    /// SMS body
    required String smsBody,

    /// SMS timestamp
    required DateTime smsTimestamp,

    /// Last 4 digits of account number (if found)
    String? accountNumber,

    /// Merchant/payee name (if found)
    String? merchantName,

    /// UPI transaction ID (if found)
    String? upiTransactionId,

    /// UPI ID (if found)
    String? upiId,

    /// Payment method (UPI, Card, ATM, etc.)
    String? paymentMethod,

    /// Balance after transaction (if available)
    double? balanceAfter,

    /// Confidence score of parsing (0-1)
    @Default(0.0) double confidence,

    /// Whether parsing was successful
    @Default(true) bool isValid,

    /// Error message if parsing failed
    String? errorMessage,
  }) = _ParsedTransaction;

  factory ParsedTransaction.fromJson(Map<String, dynamic> json) =>
      _$ParsedTransactionFromJson(json);
}

/// Extension methods for ParsedTransaction
extension ParsedTransactionExtension on ParsedTransaction {
  /// Check if transaction has merchant information
  bool get hasMerchant => merchantName != null && merchantName!.isNotEmpty;

  /// Check if transaction has UPI information
  bool get hasUpi => upiId != null || upiTransactionId != null;

  /// Check if transaction has account information
  bool get hasAccount => accountNumber != null && accountNumber!.isNotEmpty;

  /// Check if transaction has balance information
  bool get hasBalance => balanceAfter != null;

  /// Get confidence level (Low, Medium, High)
  String get confidenceLevel {
    if (confidence >= 0.8) return 'High';
    if (confidence >= 0.5) return 'Medium';
    return 'Low';
  }

  /// Get display title for parsed transaction
  String get displayTitle {
    if (hasMerchant) return merchantName!;
    if (hasUpi) return upiId ?? 'UPI Payment';
    return description.split(' ').take(3).join(' ');
  }

  /// Predict category based on keywords (basic rule-based)
  Category predictCategory() {
    final lowerDescription = description.toLowerCase();
    final lowerMerchant = merchantName?.toLowerCase() ?? '';
    final combined = '$lowerDescription $lowerMerchant';

    // UPI Payments
    if (combined.contains('upi') || hasUpi) {
      return Category.upiPayments;
    }

    // Food Delivery
    if (combined.contains('swiggy') ||
        combined.contains('zomato') ||
        combined.contains('domino') ||
        combined.contains('mcdonald') ||
        combined.contains('kfc') ||
        combined.contains('food')) {
      return Category.foodDelivery;
    }

    // Shopping
    if (combined.contains('amazon') ||
        combined.contains('flipkart') ||
        combined.contains('myntra') ||
        combined.contains('ajio') ||
        combined.contains('meesho') ||
        combined.contains('shop')) {
      return Category.shopping;
    }

    // Groceries
    if (combined.contains('bigbasket') ||
        combined.contains('blinkit') ||
        combined.contains('instamart') ||
        combined.contains('zepto') ||
        combined.contains('grofers') ||
        combined.contains('grocery') ||
        combined.contains('fresh') ||
        combined.contains('supermarket')) {
      return Category.groceries;
    }

    // Transportation
    if (combined.contains('uber') ||
        combined.contains('ola') ||
        combined.contains('rapido') ||
        combined.contains('metro') ||
        combined.contains('petrol') ||
        combined.contains('fuel') ||
        combined.contains('parking')) {
      return Category.transportation;
    }

    // Entertainment
    if (combined.contains('netflix') ||
        combined.contains('amazon prime') ||
        combined.contains('hotstar') ||
        combined.contains('spotify') ||
        combined.contains('movie') ||
        combined.contains('bookmyshow') ||
        combined.contains('pvr') ||
        combined.contains('inox')) {
      return Category.entertainment;
    }

    // Bill Payments
    if (combined.contains('electricity') ||
        combined.contains('water') ||
        combined.contains('gas') ||
        combined.contains('bill') ||
        combined.contains('utility')) {
      return Category.billPayments;
    }

    // Recharge
    if (combined.contains('recharge') ||
        combined.contains('prepaid') ||
        combined.contains('mobile') ||
        combined.contains('airtel') ||
        combined.contains('jio') ||
        combined.contains('vi') ||
        combined.contains('vodafone')) {
      return Category.recharge;
    }

    // Card Payments
    if (paymentMethod?.toLowerCase().contains('card') == true ||
        combined.contains('card')) {
      return Category.cardPayments;
    }

    // Bank Transfers
    if (combined.contains('neft') ||
        combined.contains('imps') ||
        combined.contains('rtgs') ||
        combined.contains('transfer')) {
      return Category.bankTransfers;
    }

    // ATM Withdrawals
    if (combined.contains('atm') ||
        combined.contains('withdrawal') ||
        combined.contains('cash')) {
      return Category.atmWithdrawals;
    }

    // EMI
    if (combined.contains('emi') || combined.contains('installment')) {
      return Category.emi;
    }

    // Subscriptions
    if (combined.contains('subscription') ||
        combined.contains('membership') ||
        combined.contains('renewal')) {
      return Category.subscriptions;
    }

    // Healthcare
    if (combined.contains('hospital') ||
        combined.contains('clinic') ||
        combined.contains('medical') ||
        combined.contains('pharmacy') ||
        combined.contains('apollo') ||
        combined.contains('fortis') ||
        combined.contains('doctor')) {
      return Category.healthcare;
    }

    // Income (for credits)
    if (type == TransactionType.credit) {
      if (combined.contains('salary') ||
          combined.contains('income') ||
          combined.contains('credited') ||
          combined.contains('refund') ||
          combined.contains('cashback')) {
        return Category.income;
      }
    }

    // Investment
    if (combined.contains('investment') ||
        combined.contains('mutual fund') ||
        combined.contains('sip') ||
        combined.contains('stock') ||
        combined.contains('zerodha') ||
        combined.contains('groww') ||
        combined.contains('upstox')) {
      return Category.investment;
    }

    // Default
    return Category.others;
  }

  /// Predict categorization method
  CategorizationMethod predictCategorizationMethod() {
    final category = predictCategory();
    if (category != Category.others) {
      return CategorizationMethod.ruleBased;
    }
    return CategorizationMethod.defaultFallback;
  }
}
