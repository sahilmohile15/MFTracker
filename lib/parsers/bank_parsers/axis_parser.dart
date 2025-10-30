// Axis Bank Parser
// Handles Axis bank account and credit card transactions

import '../financial_text_parser.dart';

class AxisBankParser extends FinancialTextParser {
  @override
  String getBankName() => 'Axis Bank';

  @override
  bool canHandle(String sender) {
    final upperSender = sender.toUpperCase();
    return upperSender.contains('AXIS') ||
           upperSender.contains('AXISBK') ||
           RegExp(r'^[A-Z]{2}-AXISBK-[ST]$').hasMatch(upperSender) ||
           upperSender == 'AXISBANK';
  }

  @override
  double? extractAmount(String message) {
    final patterns = [
      // used for Rs.3,499.00
      RegExp(r'used\s+for\s+Rs\.?\s*(\d+(?:,\d+)*(?:\.\d{2})?)', caseSensitive: false),
      // INR 1234.56
      RegExp(r'INR\s+(\d+(?:,\d+)*(?:\.\d{2})?)', caseSensitive: false),
      // Rs. 1234.56
      RegExp(r'Rs\.?\s+(\d+(?:,\d+)*(?:\.\d{2})?)', caseSensitive: false),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(message);
      if (match != null) {
        final amountStr = match.group(1)!.replaceAll(',', '');
        return double.tryParse(amountStr);
      }
    }

    return super.extractAmount(message);
  }

  @override
  TransactionType? extractTransactionType(String message) {
    final lowerMessage = message.toLowerCase();

    // Axis-specific: "used for" indicates debit/expense
    if (lowerMessage.contains('used for')) {
      return TransactionType.expense;
    }

    // Fall back to base class
    return super.extractTransactionType(message);
  }

  @override
  String? extractMerchant(String message, String sender) {
    // Pattern 1: "at MERCHANT via"
    final atViaPattern = RegExp(
      r'at\s+([^.\n]+?)\s+via',
      caseSensitive: false,
    );
    final atViaMatch = atViaPattern.firstMatch(message);
    if (atViaMatch != null) {
      final merchant = cleanMerchantName(atViaMatch.group(1)!.trim());
      if (isValidMerchantName(merchant)) {
        return merchant;
      }
    }

    // Pattern 2: "to MERCHANT on"
    final toPattern = RegExp(
      r'to\s+([^.\n]+?)\s+on',
      caseSensitive: false,
    );
    final toMatch = toPattern.firstMatch(message);
    if (toMatch != null) {
      final merchant = cleanMerchantName(toMatch.group(1)!.trim());
      if (isValidMerchantName(merchant)) {
        return merchant;
      }
    }

    // Pattern 3: UPI VPA extraction
    final vpaPattern = RegExp(
      r'(?:to|from)\s+([^\s]+@okaxis)',
      caseSensitive: false,
    );
    final vpaMatch = vpaPattern.firstMatch(message);
    if (vpaMatch != null) {
      final vpa = vpaMatch.group(1)!;
      final merchantName = vpa.split('@')[0];
      final cleaned = cleanMerchantName(merchantName);
      if (isValidMerchantName(cleaned)) {
        return cleaned;
      }
    }

    return super.extractMerchant(message, sender);
  }

  @override
  String? extractReference(String message) {
    // Axis UPI reference
    final upiRefPattern = RegExp(
      r'UPI\s+Ref\s+no\s+(\d+)',
      caseSensitive: false,
    );
    final upiMatch = upiRefPattern.firstMatch(message);
    if (upiMatch != null) {
      return upiMatch.group(1);
    }

    return super.extractReference(message);
  }

  @override
  double? extractBalance(String message) {
    // Axis balance patterns
    final patterns = [
      RegExp(r'Avl\s+Bal\s+INR\s+(\d+(?:,\d+)*(?:\.\d{2})?)', caseSensitive: false),
      RegExp(r'Available\s+Balance\s+INR\s+(\d+(?:,\d+)*(?:\.\d{2})?)', caseSensitive: false),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(message);
      if (match != null) {
        final balanceStr = match.group(1)!.replaceAll(',', '');
        return double.tryParse(balanceStr);
      }
    }

    return super.extractBalance(message);
  }

  @override
  double? extractAvailableLimit(String message) {
    // Axis credit card limit patterns
    final limitPatterns = [
      // Avl Lmt Rs.150000.00
      RegExp(r'avl\s+lmt\s+Rs\.?\s*(\d+(?:,\d+)*(?:\.\d{2})?)', caseSensitive: false),
      // Available Limit INR 12345
      RegExp(r'available\s+limit\s+INR\s+(\d+(?:,\d+)*(?:\.\d{2})?)', caseSensitive: false),
    ];

    for (final pattern in limitPatterns) {
      final match = pattern.firstMatch(message);
      if (match != null) {
        final limitStr = match.group(1)!.replaceAll(',', '');
        return double.tryParse(limitStr);
      }
    }

    return super.extractAvailableLimit(message);
  }
}
