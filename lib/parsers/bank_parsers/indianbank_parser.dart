import '../financial_text_parser.dart';

/// Parser for Indian Bank SMS messages
/// 
/// Sender patterns: XX-INDBNK-S, INDBNK, INDIAN, INDIANBANK
/// 
/// Sample formats:
/// - Debit: "debited Rs. 19000.00"
/// - Credit: "Rs.589.00 credited to A/c *1234"
class IndianBankParser extends FinancialTextParser {
  @override
  String getBankName() => 'Indian Bank';

  @override
  bool canHandle(String sender) {
    final normalized = sender.toUpperCase();
    return normalized.contains('INDIAN BANK') ||
           normalized.contains('INDIANBANK') ||
           normalized.contains('INDIANBK') ||
           RegExp(r'^[A-Z]{2}-INDBNK-S$').hasMatch(normalized) ||
           RegExp(r'^[A-Z]{2}-INDBNK-[TPG]$').hasMatch(normalized) ||
           RegExp(r'^[A-Z]{2}-INDBNK$').hasMatch(normalized) ||
           normalized == 'INDBNK' ||
           normalized == 'INDIAN';
  }

  @override
  double? extractAmount(String message) {
    final patterns = [
      // Pattern 1: debited Rs. 19000.00
      RegExp(r'debited\s+Rs\.?\s*(\d+(?:,\d+)*(?:\.\d{2})?)',
          caseSensitive: false),
      // Pattern 2: credited Rs. 5000.00
      RegExp(r'credited\s+Rs\.?\s*(\d+(?:,\d+)*(?:\.\d{2})?)',
          caseSensitive: false),
      // Pattern 2a: Rs.589.00 credited to
      RegExp(r'Rs\.?\s*(\d+(?:,\d+)*(?:\.\d{2})?)\s+credited\s+to',
          caseSensitive: false),
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
  String? extractMerchant(String message, String sender) {
    // Pattern 1: "to Merchant Name"
    final toPattern = RegExp(r'to\s+([^.\n]+?)(?:\.\s*UPI:|UPI:|$)',
        caseSensitive: false);
    final toMatch = toPattern.firstMatch(message);
    if (toMatch != null) {
      final merchant = cleanMerchantName(toMatch.group(1)!.trim());
      if (isValidMerchantName(merchant)) {
        return merchant;
      }
    }

    // Pattern 2: "from Sender Name"
    final fromPattern = RegExp(r'from\s+([^.\n]+?)(?:\.\s*UPI:|UPI:|$)',
        caseSensitive: false);
    final fromMatch = fromPattern.firstMatch(message);
    if (fromMatch != null) {
      final merchant = cleanMerchantName(fromMatch.group(1)!.trim());
      if (isValidMerchantName(merchant)) {
        return merchant;
      }
    }

    return super.extractMerchant(message, sender);
  }

  @override
  String? extractAccountLast4(String message) {
    final patterns = [
      // Pattern 1: A/c *1234
      RegExp(r'A/c\s+\*(\d{4})', caseSensitive: false),
      // Pattern 2: Account XX1234
      RegExp(r'Account\s+X*(\d{4})', caseSensitive: false),
      // Pattern 3: A/c ending 1234
      RegExp(r'A/c\s+ending\s+(\d{4})', caseSensitive: false),
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
  double? extractBalance(String message) {
    final balancePatterns = [
      // Pattern 1: Avl. Bal: Rs.12345.67
      RegExp(r'Avl\.?\s*Bal\s*:\s*Rs\.?\s*(\d+(?:,\d+)*(?:\.\d{2})?)',
          caseSensitive: false),
      // Pattern 2: Available Balance: Rs.12345.67
      RegExp(r'Available\s+Balance\s*:?\s*Rs\.?\s*(\d+(?:,\d+)*(?:\.\d{2})?)',
          caseSensitive: false),
    ];

    for (final pattern in balancePatterns) {
      final match = pattern.firstMatch(message);
      if (match != null) {
        final balanceStr = match.group(1)!.replaceAll(',', '');
        return double.tryParse(balanceStr);
      }
    }

    return super.extractBalance(message);
  }
}
