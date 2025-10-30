// State Bank of India (SBI) Parser
// Handles SBI bank account and credit card transactions

import '../financial_text_parser.dart';

class SBIBankParser extends FinancialTextParser {
  @override
  String getBankName() => 'State Bank of India';

  @override
  bool canHandle(String sender) {
    final upperSender = sender.toUpperCase();
    return upperSender.contains('SBI') ||
           upperSender.contains('SBIBNK') ||
           upperSender.contains('SBMSMS') ||
           upperSender.contains('SBIINB') ||
           upperSender.contains('SBICARD') ||
           RegExp(r'^[A-Z]{2}-SBIBNK-[ST]$').hasMatch(upperSender);
  }

  @override
  double? extractAmount(String message) {
    // SBI specific patterns
    final patterns = [
      // "Rs.1234.56" (with period after Rs)
      RegExp(r'Rs\.(\d+(?:,\d+)*(?:\.\d{2})?)', caseSensitive: false),
      // "debited by 1046.0" - UPI pattern without Rs prefix
      RegExp(r'debited\s+by\s+(\d+(?:,\d+)*(?:\.\d+)?)', caseSensitive: false),
      // "Rs 1234.56" - with space
      RegExp(r'Rs\s+(\d+(?:,\d+)*(?:\.\d{2})?)', caseSensitive: false),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(message);
      if (match != null) {
        final amountStr = match.group(1)!.replaceAll(',', '');
        return double.tryParse(amountStr);
      }
    }

    // Fall back to base class patterns
    return super.extractAmount(message);
  }

  @override
  TransactionType? extractTransactionType(String message) {
    final lowerMessage = message.toLowerCase();

    // Money request notifications
    if (lowerMessage.contains('requested money from you')) {
      return TransactionType.expense; // Money request (potential debit)
    }

    // UPI Mandate creation
    if (lowerMessage.contains('upi-mandate for') || lowerMessage.contains('upi mandate for')) {
      return TransactionType.transfer; // Mandate setup
    }

    // SBI credit card specific patterns - check card first
    if (lowerMessage.contains('credit card') && 
        (lowerMessage.contains('spent') || lowerMessage.contains('charged'))) {
      return TransactionType.credit; // Credit card transaction
    }

    // SBI UPI/account debit patterns
    if (lowerMessage.contains('debited') ||
        lowerMessage.contains('withdrawn') ||
        lowerMessage.contains('transferred') ||
        lowerMessage.contains('paid to') ||
        lowerMessage.contains('atm withdrawal') ||
        lowerMessage.contains('by sbi debit card')) {
      return TransactionType.expense;
    }

    // Fall back to base class
    return super.extractTransactionType(message);
  }

  @override
  String? extractMerchant(String message, String sender) {
    // Pattern 1: "has requested money from you" - Blinkit, Swiggy, etc.
    final requestPattern = RegExp(
      r'([A-Z][A-Z\s]+(?:PRIVATE\s+LIMITED|LIMITED|COMMERCE\s+PRIVATE\s+LIMITED))\s+has\s+requested',
      caseSensitive: false,
    );
    final requestMatch = requestPattern.firstMatch(message);
    if (requestMatch != null) {
      final merchant = cleanMerchantName(requestMatch.group(1)!.trim());
      if (isValidMerchantName(merchant)) {
        return merchant;
      }
    }

    // Pattern 2: "towards MERCHANT from A/c" - UPI mandate
    final towardsPattern = RegExp(
      r'towards\s+([A-Za-z]+)\s+from\s+A/c',
      caseSensitive: false,
    );
    final towardsMatch = towardsPattern.firstMatch(message);
    if (towardsMatch != null) {
      final merchant = cleanMerchantName(towardsMatch.group(1)!.trim());
      if (isValidMerchantName(merchant)) {
        return merchant;
      }
    }

    // Pattern 3: "trf to MERCHANT Refno" (UPI transfers)
    final trfPattern = RegExp(
      r'trf\s+to\s+([^.\n]+?)\s+Refno',
      caseSensitive: false,
    );
    final trfMatch = trfPattern.firstMatch(message);
    if (trfMatch != null) {
      final merchant = cleanMerchantName(trfMatch.group(1)!.trim());
      if (isValidMerchantName(merchant)) {
        return merchant;
      }
    }

    // Pattern 4: "at MERCHANT on" (credit card)
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

    // Pattern 5: "at MERCHANT via"
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

    // Pattern 6: "to MERCHANT Ref"
    final toRefPattern = RegExp(
      r'to\s+([^.\n]+?)\s+Ref',
      caseSensitive: false,
    );
    final toRefMatch = toRefPattern.firstMatch(message);
    if (toRefMatch != null) {
      final merchant = cleanMerchantName(toRefMatch.group(1)!.trim());
      if (isValidMerchantName(merchant)) {
        return merchant;
      }
    }

    // ATM withdrawal
    if (message.toLowerCase().contains('atm')) {
      return 'ATM';
    }

    // Fall back to base class
    return super.extractMerchant(message, sender);
  }

  @override
  String? extractAccountLast4(String message) {
    // Pattern 1: "A/C X9115" or "A/C XX1234" or "A/c No: XXXXXX6763"
    final patterns = [
      RegExp(r'A/[Cc]\s+[X*]*(\d{4})'), // "A/C X9115"
      RegExp(r'A/[Cc]\s+No:\s+[X*]+(\d{4})'), // "A/c No: XXXXXX6763"
      RegExp(r'ending\s+(\d{4})'), // "ending 1234"
      RegExp(r'card\s+ending\s+(\d{4})'),
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
  String? extractReference(String message) {
    // Pattern 1: "Refno 42636399xxxx"
    final refnoPattern = RegExp(
      r'Refno\s+([A-Z0-9x]+)',
      caseSensitive: false,
    );
    final refnoMatch = refnoPattern.firstMatch(message);
    if (refnoMatch != null) {
      return refnoMatch.group(1);
    }

    // Pattern 2: "UPI:123456789"
    final upiRefPattern = RegExp(
      r'UPI:\s*(\d+)',
      caseSensitive: false,
    );
    final upiMatch = upiRefPattern.firstMatch(message);
    if (upiMatch != null) {
      return upiMatch.group(1);
    }

    // Pattern 3: "Ref No:123456"
    final refPattern = RegExp(
      r'Ref(?:\s+No)?[:.]?\s*([A-Z0-9]+)',
      caseSensitive: false,
    );
    final refMatch = refPattern.firstMatch(message);
    if (refMatch != null) {
      return refMatch.group(1);
    }

    return super.extractReference(message);
  }

  @override
  double? extractBalance(String message) {
    // SBI pattern: "Bal Rs.1234.56"
    final sbiBalPattern = RegExp(
      r'Bal\s+Rs\.(\d+(?:,\d+)*(?:\.\d{2})?)',
      caseSensitive: false,
    );
    final match = sbiBalPattern.firstMatch(message);
    if (match != null) {
      final balanceStr = match.group(1)!.replaceAll(',', '');
      return double.tryParse(balanceStr);
    }

    return super.extractBalance(message);
  }

  @override
  double? extractAvailableLimit(String message) {
    // SBI credit card pattern: "available limit is Rs.12345.00"
    final limitPattern = RegExp(
      r'available\s+limit\s+is\s+Rs\.(\d+(?:,\d+)*(?:\.\d{2})?)',
      caseSensitive: false,
    );
    final match = limitPattern.firstMatch(message);
    if (match != null) {
      final limitStr = match.group(1)!.replaceAll(',', '');
      return double.tryParse(limitStr);
    }

    return super.extractAvailableLimit(message);
  }

  @override
  bool detectIsCard(String message) {
    final lowerMessage = message.toLowerCase();
    return lowerMessage.contains('sbi card') ||
           lowerMessage.contains('credit card') ||
           lowerMessage.contains('spent on your sbi card') ||
           super.detectIsCard(message);
  }
}
