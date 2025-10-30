// HDFC Bank Parser
// Handles HDFC bank account and credit card transactions

import '../financial_text_parser.dart';

class HDFCBankParser extends FinancialTextParser {
  @override
  String getBankName() => 'HDFC Bank';

  @override
  bool canHandle(String sender) {
    final upperSender = sender.toUpperCase();
    return upperSender.contains('HDFC') ||
           upperSender.contains('HDFCBK') ||
           RegExp(r'^[A-Z]{2}-HDFCBK-[ST]$').hasMatch(upperSender) ||
           upperSender == 'HDFCBANK';
  }

  @override
  double? extractAmount(String message) {
    // HDFC specific patterns
    final patterns = [
      // "Amt Sent Rs.166.50" - UPI transfer pattern
      RegExp(r'Amt\s+Sent\s+Rs\.?(\d+(?:,\d+)*(?:\.\d{2})?)', caseSensitive: false),
      // INR 1234.56
      RegExp(r'INR\s+(\d+(?:,\d+)*(?:\.\d{2})?)', caseSensitive: false),
      // Rs 1234.56 or Rs.1234.56
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

    // HDFC credit card transactions - check for card patterns first
    if (lowerMessage.contains('card') && 
        (lowerMessage.contains('spent') || 
         lowerMessage.contains('used') ||
         lowerMessage.contains('charged'))) {
      return TransactionType.credit; // Credit card transaction
    }

    // HDFC UPI/Account debit patterns
    if (lowerMessage.contains('amt sent') || 
        lowerMessage.contains('debited') || 
        lowerMessage.contains('dr.')) {
      return TransactionType.expense;
    }
    
    if (lowerMessage.contains('credited') || lowerMessage.contains('cr.')) {
      return TransactionType.income;
    }

    return super.extractTransactionType(message);
  }

  @override
  String? extractMerchant(String message, String sender) {
    // Priority 1: "At VPA@ybl by UPI" or "At merchant@bank by UPI"
    final atVpaPattern = RegExp(
      r'At\s+([^\s]+@[^\s]+)\s+by\s+UPI',
      caseSensitive: false,
    );
    final atVpaMatch = atVpaPattern.firstMatch(message);
    if (atVpaMatch != null) {
      final vpa = atVpaMatch.group(1)!;
      final merchantName = vpa.split('@')[0];
      final cleaned = cleanMerchantName(merchantName);
      if (isValidMerchantName(cleaned)) {
        return cleaned + ' by UPI';
      }
    }

    // Priority 2: UPI transactions - "to MERCHANT(name@bank)"
    final upiPattern1 = RegExp(
      r'to\s+([^(]+)\([^@]+@[^)]+\)',
      caseSensitive: false,
    );
    final upiMatch1 = upiPattern1.firstMatch(message);
    if (upiMatch1 != null) {
      final merchant = cleanMerchantName(upiMatch1.group(1)!.trim());
      if (isValidMerchantName(merchant)) {
        return merchant;
      }
    }

    // Priority 3: "To MERCHANT On" or "To MERCHANT Ref" - for UPI transfers
    final toRefPattern = RegExp(
      r'To\s+([A-Z][A-Za-z0-9\s]+?)\s+(?:On|Ref)',
      caseSensitive: false,
    );
    final toRefMatch = toRefPattern.firstMatch(message);
    if (toRefMatch != null) {
      final merchant = cleanMerchantName(toRefMatch.group(1)!.trim());
      if (isValidMerchantName(merchant)) {
        return merchant;
      }
    }

    // Priority 4: "at MERCHANT on"
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

    // Priority 5: "towards MERCHANT for"
    final towardsPattern = RegExp(
      r'towards\s+([^.\n]+?)\s+for',
      caseSensitive: false,
    );
    final towardsMatch = towardsPattern.firstMatch(message);
    if (towardsMatch != null) {
      final merchant = cleanMerchantName(towardsMatch.group(1)!.trim());
      if (isValidMerchantName(merchant)) {
        return merchant;
      }
    }

    // Priority 6: ATM withdrawal
    if (message.toLowerCase().contains('atm') ||
        message.toLowerCase().contains('cash withdrawal')) {
      return 'ATM';
    }

    return super.extractMerchant(message, sender);
  }

  @override
  @override
  String? extractReference(String message) {
    // Pattern 1: "by UPI 487713330175"
    final byUpiPattern = RegExp(
      r'by\s+UPI\s+(\d+)',
      caseSensitive: false,
    );
    final byUpiMatch = byUpiPattern.firstMatch(message);
    if (byUpiMatch != null) {
      return byUpiMatch.group(1);
    }

    // Pattern 2: "Ref 12345XXXX"
    final refPatterns = [
      RegExp(r'Ref\s+([A-Z0-9x]+)', caseSensitive: false),
      RegExp(r'UPI[:\s]+(\d+)', caseSensitive: false),
      RegExp(r'Ref\s+No[:\s]*([A-Z0-9]+)', caseSensitive: false),
    ];

    for (final pattern in refPatterns) {
      final match = pattern.firstMatch(message);
      if (match != null) {
        return match.group(1);
      }
    }

    return super.extractReference(message);
  }

  @override
  double? extractBalance(String message) {
    // HDFC patterns
    final patterns = [
      // Avl bal INR 1234.56
      RegExp(r'Avl\s+bal\s+INR\s+(\d+(?:,\d+)*(?:\.\d{2})?)', caseSensitive: false),
      // Balance INR 1234.56
      RegExp(r'Balance\s+INR\s+(\d+(?:,\d+)*(?:\.\d{2})?)', caseSensitive: false),
      // Bal Rs 1234.56
      RegExp(r'Bal\s+Rs\.?\s+(\d+(?:,\d+)*(?:\.\d{2})?)', caseSensitive: false),
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
    // HDFC credit card limit pattern
    final limitPatterns = [
      RegExp(r'Available\s+(?:Credit\s+)?Limit\s+(?:is\s+)?INR\s+(\d+(?:,\d+)*(?:\.\d{2})?)', caseSensitive: false),
      RegExp(r'Avl\s+Lmt\s+INR\s+(\d+(?:,\d+)*(?:\.\d{2})?)', caseSensitive: false),
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

  @override
  bool isTransactionMessage(String message) {
    final lowerMessage = message.toLowerCase();
    
    // Skip E-Mandate setup messages (not actual transactions)
    if (lowerMessage.contains('e-mandate') && 
        !lowerMessage.contains('executed')) {
      return false;
    }

    return super.isTransactionMessage(message);
  }
}
