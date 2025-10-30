// American Express (AMEX) Credit Card Parser
// Handles AMEX credit card transactions

import '../financial_text_parser.dart';

class AMEXParser extends FinancialTextParser {
  @override
  String getBankName() => 'American Express';

  @override
  bool canHandle(String sender) {
    final upperSender = sender.toUpperCase();
    return upperSender.contains('AMEX') ||
           upperSender.contains('AMERICANEXPRESS') ||
           upperSender.contains('AMEXPR');
  }

  @override
  double? extractAmount(String message) {
    // AMEX uses "INR 1234.56" format
    final amexPattern = RegExp(
      r'INR\s+(\d+(?:,\d+)*(?:\.\d{2})?)',
      caseSensitive: false,
    );
    final match = amexPattern.firstMatch(message);
    if (match != null) {
      final amountStr = match.group(1)!.replaceAll(',', '');
      return double.tryParse(amountStr);
    }

    return super.extractAmount(message);
  }

  @override
  TransactionType? extractTransactionType(String message) {
    final lowerMessage = message.toLowerCase();

    // AMEX is credit card only - all transactions are credit card type
    if (lowerMessage.contains('spent') || 
        lowerMessage.contains('charged') ||
        lowerMessage.contains('card')) {
      return TransactionType.credit; // Credit card transaction
    }

    // Refunds/credits
    if (lowerMessage.contains('credited') || lowerMessage.contains('refund')) {
      return TransactionType.income;
    }

    return TransactionType.credit; // Default to credit card transaction
  }

  @override
  String? extractMerchant(String message, String sender) {
    // Pattern: "at MERCHANT on"
    final atPattern = RegExp(
      r'at\s+([^.\n]+?)\s+on',
      caseSensitive: false,
    );
    final atMatch = atPattern.firstMatch(message);
    if (atMatch != null) {
      final merchant = cleanMerchantName(atMatch.group(1)!.trim());
      if (isValidMerchantName(merchant)) {
        return merchant;
      }
    }

    return super.extractMerchant(message, sender);
  }

  @override
  String? extractAccountLast4(String message) {
    // AMEX uses "** 01234" or "**01234" format
    final patterns = [
      RegExp(r'\*\*\s*0?(\d{4})'),  // ** 01234 or **01234
      RegExp(r'card\s+[*\s]*(\d{4})'), // card ****1234
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(message);
      if (match != null) {
        return match.group(1);
      }
    }

    return super.extractAccountLast4(message);
  }

  @override
  bool detectIsCard(String message) {
    return true; // AMEX is always a credit card
  }
}
