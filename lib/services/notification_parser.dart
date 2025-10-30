import 'package:flutter/foundation.dart' hide Category;

import '../models/transaction.dart';
import '../services/notification_service.dart';
import '../utils/constants.dart';
import '../parsers/financial_text_parser.dart' as parser;
import '../parsers/parser_registry.dart';

/// Parser to extract transaction data from notifications
class NotificationParser {
  /// Parse a notification into a Transaction
  static ParsedTransaction? parse(NotificationData notification) {
    try {
      // Combine all text fields from notification
      final body = _combineNotificationText(notification);
      
      // Use centralized parser with proper bank registration
      initializeBankParsers();
      final parsed = parser.BankParserFactory.parse(
        body, 
        notification.packageName, 
        notification.timestamp
      );
      
      if (parsed == null) {
        // Fallback to old parsing if centralized parser fails
        return _parseLegacy(body, notification);
      }
      
      // Convert to app's ParsedTransaction model
      final data = parsed.toTransactionData();
      
      return ParsedTransaction(
        amount: data['amount'] as double,
        type: data['type'] == 'debit' ? TransactionType.debit : TransactionType.credit,
        description: data['description'] as String,
        category: _categorizeTransaction(body, (data['merchantName'] as String?) ?? ''),
        accountNumber: data['accountNumber'] as String?,
        balanceAfter: data['balanceAfter'] as double?,
        paymentMethod: data['paymentMethod'] as String?,
        upiId: null, // Will be extracted from description if needed
        upiTransactionId: data['upiTransactionId'] as String?,
        smsBody: body,
        smsSender: notification.packageName,
        smsTimestamp: notification.timestamp,
        timestamp: notification.timestamp,
      );
    } catch (e) {
      return null;
    }
  }
  
  /// Fallback legacy parser for non-bank notifications
  static ParsedTransaction? _parseLegacy(String body, NotificationData notification) {
    try {
      final amount = _extractAmount(body);
      if (amount == null) return null;
      
      final type = _extractType(body);
      final description = _extractDescription(body, notification.packageName);
      final category = _categorizeTransaction(body, description);
      final accountNumber = _extractAccountNumber(body);
      final balance = _extractBalance(body);
      final paymentMethod = _extractPaymentMethod(body);
      final upiId = _extractUPIId(body);
      final upiTxnId = _extractUPITransactionId(body);
      
      return ParsedTransaction(
        amount: amount,
        type: type,
        description: description,
        category: category,
        accountNumber: accountNumber,
        balanceAfter: balance,
        paymentMethod: paymentMethod,
        upiId: upiId,
        upiTransactionId: upiTxnId,
        smsBody: body,
        smsSender: notification.packageName,
        smsTimestamp: notification.timestamp,
        timestamp: notification.timestamp,
      );
    } catch (e) {
      return null;
    }
  }
  
  /// Combine notification text fields into single string for parsing
  static String _combineNotificationText(NotificationData notification) {
    final parts = <String>[];
    
    if (notification.title.isNotEmpty) {
      parts.add(notification.title);
    }
    if (notification.text.isNotEmpty) {
      parts.add(notification.text);
    }
    if (notification.subText.isNotEmpty) {
      parts.add(notification.subText);
    }
    
    return parts.join(' | ');
  }
  
  /// Extract amount from notification text
  static double? _extractAmount(String body) {
    // Patterns: Rs 1,234.56 | INR 1234.56 | ₹1,234.56 | Rs.1234 | Rs 250 sent
    final patterns = [
      // Pattern 1: Rs.1234.56 or Rs 1234.56 or Rs1234 (with or without dot, with or without space, with or without decimals)
      RegExp(r'(?:rs\.?|inr|₹)\s*([0-9,]+\.?[0-9]*)', caseSensitive: false),
      // Pattern 2: 1234.56 Rs or 1234 INR (amount before currency)
      RegExp(r'([0-9,]+\.?[0-9]*)\s*(?:rs\.?|inr|₹)', caseSensitive: false),
    ];
    
    for (final pattern in patterns) {
      final match = pattern.firstMatch(body);
      if (match != null) {
        final amountStr = match.group(1)!.replaceAll(',', '');
        final amount = double.tryParse(amountStr);
        if (amount != null && amount > 0) {
          if (kDebugMode) {
            print('[SMSParser] Extracted amount: $amount from match: ${match.group(0)}');
          }
          return amount;
        } else if (kDebugMode) {
          print('[SMSParser] Failed to parse amount string: $amountStr');
        }
      }
    }
    
    if (kDebugMode) {
      print('[SMSParser] No amount pattern matched in: ${body.substring(0, body.length > 80 ? 80 : body.length)}');
    }
    return null;
  }
  
  /// Extract transaction type (debit/credit)
  static TransactionType _extractType(String body) {
    final bodyLower = body.toLowerCase();
    
    // Credit keywords (receiving money)
    final creditKeywords = [
      'credited',
      'received',
      'refund',
      'cashback',
      'added',
      'salary',
      'deposited',
    ];
    
    // Debit keywords (spending money)  
    final debitKeywords = [
      'debited',
      'debit',
      'spent',
      'sent',
      'paid',
      'payment',
      'withdrawn',
      'purchase',
      'deducted',
    ];
    
    // Check for credit first (more specific)
    if (creditKeywords.any(bodyLower.contains)) {
      return TransactionType.credit;
    }
    
    // Then check for debit
    if (debitKeywords.any(bodyLower.contains)) {
      return TransactionType.debit;
    }
    
    // Default to debit if unclear
    return TransactionType.debit;
  }
  
  /// Extract description/merchant from SMS
  static String _extractDescription(String body, String sender) {
    // Try to extract merchant/description from common patterns
    
    // Pattern: "for <description>"
    var match = RegExp(r'for\s+(.+?)(?:\.|$|avl|info)', caseSensitive: false)
        .firstMatch(body);
    if (match != null) {
      return match.group(1)!.trim();
    }
    
    // Pattern: "Info: <description>"
    match = RegExp(r'info:\s*(.+?)(?:\.|$|avl)', caseSensitive: false)
        .firstMatch(body);
    if (match != null) {
      return match.group(1)!.trim();
    }
    
    // Pattern: UPI merchant name
    match = RegExp(r'upi/[^/]+/[^/]+/(.+?)(?:/|\.)', caseSensitive: false)
        .firstMatch(body);
    if (match != null) {
      return match.group(1)!.trim();
    }
    
    // Default: use sender bank name
    return _extractBankName(sender);
  }
  
  /// Extract bank name from sender
  static String _extractBankName(String sender) {
    final senderUpper = sender.toUpperCase();
    
    if (senderUpper.contains('HDFC')) return 'HDFC Bank';
    if (senderUpper.contains('ICICI')) return 'ICICI Bank';
    if (senderUpper.contains('SBI')) return 'SBI';
    if (senderUpper.contains('AXIS')) return 'Axis Bank';
    if (senderUpper.contains('PAYTM')) return 'Paytm';
    if (senderUpper.contains('GOOGLE')) return 'Google Pay';
    if (senderUpper.contains('PHONEPE')) return 'PhonePe';
    
    return 'Bank Transaction';
  }
  
  /// Categorize transaction based on keywords
  static Category _categorizeTransaction(String body, String description) {
    final text = '${body.toLowerCase()} ${description.toLowerCase()}';
    
    // UPI Payments
    if (text.contains('upi') || text.contains('google pay') || 
        text.contains('phonepe') || text.contains('paytm')) {
      return Category.upiPayments;
    }
    
    // Food Delivery
    if (text.contains('swiggy') || text.contains('zomato') || 
        text.contains('food') || text.contains('restaurant')) {
      return Category.foodDelivery;
    }
    
    // Shopping
    if (text.contains('amazon') || text.contains('flipkart') || 
        text.contains('myntra') || text.contains('shopping')) {
      return Category.shopping;
    }
    
    // Groceries
    if (text.contains('bigbasket') || text.contains('grofers') || 
        text.contains('dmart') || text.contains('grocery')) {
      return Category.groceries;
    }
    
    // Transportation
    if (text.contains('uber') || text.contains('ola') || 
        text.contains('rapido') || text.contains('petrol') || 
        text.contains('fuel')) {
      return Category.transportation;
    }
    
    // Entertainment
    if (text.contains('netflix') || text.contains('prime') || 
        text.contains('hotstar') || text.contains('spotify') || 
        text.contains('movie') || text.contains('bookmyshow')) {
      return Category.entertainment;
    }
    
    // Bill Payments
    if (text.contains('electricity') || text.contains('bill') || 
        text.contains('water') || text.contains('gas')) {
      return Category.billPayments;
    }
    
    // Recharge
    if (text.contains('recharge') || text.contains('mobile') || 
        text.contains('prepaid')) {
      return Category.recharge;
    }
    
    // ATM Withdrawals
    if (text.contains('atm') || text.contains('cash withdrawal')) {
      return Category.atmWithdrawals;
    }
    
    // Subscriptions
    if (text.contains('subscription') || text.contains('renewal')) {
      return Category.subscriptions;
    }
    
    // Income/Salary
    if (text.contains('salary') || text.contains('credited')) {
      return Category.income;
    }
    
    // Default
    return Category.others;
  }
  
  /// Extract account number (last 4 digits)
  static String? _extractAccountNumber(String body) {
    // Pattern 1: A/c XX1234
    var match = RegExp(r'(?:a/c|account|ac)\s*(?:xx)?(\d{4})', 
        caseSensitive: false).firstMatch(body);
    if (match != null) return match.group(1);
    
    // Pattern 2: Card XX1234 or using Card XX1234
    match = RegExp(r'(?:card|using\s+card)\s*(?:xx)?(\d{4})', 
        caseSensitive: false).firstMatch(body);
    if (match != null) return match.group(1);
    
    // Pattern 3: ending 1234
    match = RegExp(r'ending\s+(\d{4})', 
        caseSensitive: false).firstMatch(body);
    if (match != null) return match.group(1);
    
    return null;
  }
  
  /// Extract balance after transaction
  static double? _extractBalance(String body) {
    final match = RegExp(
        r'(?:avl\.?|available)\s*(?:bal\.?|balance)[:\s]*(?:rs\.?|inr|₹)?\s*([0-9,]+\.?[0-9]*)',
        caseSensitive: false)
        .firstMatch(body);
    
    if (match != null) {
      final balanceStr = match.group(1)!.replaceAll(',', '');
      return double.tryParse(balanceStr);
    }
    
    return null;
  }
  
  /// Extract payment method
  static String? _extractPaymentMethod(String body) {
    final bodyLower = body.toLowerCase();
    
    // Check in order of specificity (ATM before Card since ATM withdrawals mention both)
    if (bodyLower.contains('atm')) return 'ATM';
    if (bodyLower.contains('upi')) return 'UPI';
    if (bodyLower.contains('neft')) return 'NEFT';
    if (bodyLower.contains('imps')) return 'IMPS';
    if (bodyLower.contains('rtgs')) return 'RTGS';
    if (bodyLower.contains('net banking')) return 'Net Banking';
    if (bodyLower.contains('card')) return 'Card';
    
    return null;
  }
  
  /// Extract UPI ID
  static String? _extractUPIId(String body) {
    final match = RegExp(r'(\w+@\w+)', caseSensitive: false).firstMatch(body);
    return match?.group(1);
  }
  
  /// Extract UPI transaction ID
  static String? _extractUPITransactionId(String body) {
    final patterns = [
      RegExp(r'(?:txn|transaction)\s*(?:id|no)[:\s]*([a-z0-9]+)', 
          caseSensitive: false),
      RegExp(r'upi/[^/]+/([^/]+)', caseSensitive: false),
    ];
    
    for (final pattern in patterns) {
      final match = pattern.firstMatch(body);
      if (match != null) {
        return match.group(1);
      }
    }
    
    return null;
  }
}

/// Parsed transaction data from SMS
class ParsedTransaction {
  final double amount;
  final TransactionType type;
  final String description;
  final Category category;
  final String? accountNumber;
  final double? balanceAfter;
  final String? paymentMethod;
  final String? upiId;
  final String? upiTransactionId;
  final String smsBody;
  final String smsSender;
  final DateTime smsTimestamp;
  final DateTime timestamp;
  
  ParsedTransaction({
    required this.amount,
    required this.type,
    required this.description,
    required this.category,
    this.accountNumber,
    this.balanceAfter,
    this.paymentMethod,
    this.upiId,
    this.upiTransactionId,
    required this.smsBody,
    required this.smsSender,
    required this.smsTimestamp,
    required this.timestamp,
  });
  
  /// Convert to Transaction model
  Transaction toTransaction({
    required String id,
    required String accountId,
  }) {
    final now = DateTime.now();
    
    return Transaction(
      id: id,
      amount: amount,
      type: type,
      category: category,
      categorizationMethod: CategorizationMethod.ruleBased,
      timestamp: timestamp,
      description: description,
      accountId: accountId,
      accountNumber: accountNumber,
      merchantName: description,
      upiTransactionId: upiTransactionId,
      upiId: upiId,
      paymentMethod: paymentMethod,
      balanceAfter: balanceAfter,
      smsBody: smsBody,
      smsSender: smsSender,
      smsTimestamp: smsTimestamp,
      createdAt: now,
      updatedAt: now,
    );
  }
  
  @override
  String toString() {
    return 'ParsedTransaction(amount: $amount, type: $type, description: $description, category: $category)';
  }
}
