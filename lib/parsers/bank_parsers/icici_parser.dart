// ICICI Bank Parser
// Handles ICICI bank account and credit card transactions

import '../financial_text_parser.dart';

class ICICIBankParser extends FinancialTextParser {
  @override
  String getBankName() => 'ICICI Bank';

  @override
  bool canHandle(String sender) {
    final upperSender = sender.toUpperCase();
    return upperSender.contains('ICICI') ||
           upperSender.contains('ICICIB') ||
           RegExp(r'^[A-Z]{2}-ICICIB-[ST]$').hasMatch(upperSender) ||
           upperSender == 'ICICIB';
  }

  @override
  double? extractAmount(String message) {
    final patterns = [
      // INR 1234.56 (prioritize INR pattern for ICICI)
      RegExp(r'INR\s+(\d+(?:,\d+)*(?:\.\d{2})?)', caseSensitive: false),
      // Rs 1234.56
      RegExp(r'Rs\.?\s*(\d+(?:,\d+)*(?:\.\d{2})?)', caseSensitive: false),
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

    // ICICI credit card transactions - check for card patterns first
    if (lowerMessage.contains('card') && 
        (lowerMessage.contains('spent') || lowerMessage.contains('used'))) {
      return TransactionType.credit; // Credit card transaction
    }

    // ICICI debit patterns
    if (lowerMessage.contains('debited') || 
        lowerMessage.contains('withdrawn') ||
        lowerMessage.contains('atm')) {
      return TransactionType.expense;
    }

    // Fall back to base class
    return super.extractTransactionType(message);
  }

  @override
  String? extractMerchant(String message, String sender) {
    // Pattern 1: "on IND*MERCHANT" (ICICI specific for international/online merchants)
    final indPattern = RegExp(
      r'on\s+IND\*([^.\s]+)',
      caseSensitive: false,
    );
    final indMatch = indPattern.firstMatch(message);
    if (indMatch != null) {
      final merchant = cleanMerchantName(indMatch.group(1)!.trim());
      if (isValidMerchantName(merchant)) {
        return merchant;
      }
    }

    // Pattern 2: "at MERCHANT on"
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

    // Pattern 3: "to VPA" for UPI
    final vpaPattern = RegExp(
      r'to\s+([^\s]+@[^\s]+)',
      caseSensitive: false,
    );
    final vpaMatch = vpaPattern.firstMatch(message);
    if (vpaMatch != null) {
      final vpa = vpaMatch.group(1)!;
      // Extract merchant from VPA (e.g., merchant@okaxis)
      final merchantName = vpa.split('@')[0];
      final cleaned = cleanMerchantName(merchantName);
      if (isValidMerchantName(cleaned)) {
        return cleaned;
      }
    }

    // Pattern 4: ATM withdrawal
    if (message.toLowerCase().contains('atm')) {
      return 'ATM';
    }

    return super.extractMerchant(message, sender);
  }

  @override
  String? extractReference(String message) {
    // ICICI UPI reference
    final upiRefPattern = RegExp(
      r'UPI[:\s]*(\d+)',
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
    // ICICI balance patterns
    final patterns = [
      RegExp(r'Avl\s+Bal\s+(?:is\s+)?Rs\.?\s*(\d+(?:,\d+)*(?:\.\d{2})?)', caseSensitive: false),
      RegExp(r'Available\s+Balance\s+Rs\.?\s*(\d+(?:,\d+)*(?:\.\d{2})?)', caseSensitive: false),
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
    // ICICI credit card limit patterns
    final patterns = [
      RegExp(r'Avl\s+Limit:\s+INR\s+(\d+(?:,\d+)*(?:\.\d{2})?)', caseSensitive: false),
      RegExp(r'Available\s+(?:Credit\s+)?Limit\s+Rs\.?\s*(\d+(?:,\d+)*(?:\.\d{2})?)', caseSensitive: false),
    ];
    
    for (final pattern in patterns) {
      final match = pattern.firstMatch(message);
      if (match != null) {
        final limitStr = match.group(1)!.replaceAll(',', '');
        return double.tryParse(limitStr);
      }
    }

    return super.extractAvailableLimit(message);
  }
}
