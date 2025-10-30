import '../financial_text_parser.dart';

/// Parser for IDBI Bank SMS messages
/// 
/// Sender patterns: XX-IDBIBK-S, XX-IDBI-S, IDBIBK, IDBIBANK, IDBI
/// 
/// Sample formats:
/// - "Your account has been successfully debited with Rs 59.00"
/// - "IDBI Bank Acct XX1234 debited for Rs 1040.00"
class IDBIBankParser extends FinancialTextParser {
  @override
  String getBankName() => 'IDBI Bank';

  @override
  bool canHandle(String sender) {
    final normalizedSender = sender.toUpperCase();
    return normalizedSender.contains('IDBIBK') ||
           normalizedSender.contains('IDBIBANK') ||
           normalizedSender.contains('IDBI') ||
           RegExp(r'^[A-Z]{2}-IDBIBK-S$').hasMatch(normalizedSender) ||
           RegExp(r'^[A-Z]{2}-IDBI-S$').hasMatch(normalizedSender) ||
           RegExp(r'^[A-Z]{2}-IDBIBK$').hasMatch(normalizedSender) ||
           RegExp(r'^[A-Z]{2}-IDBI$').hasMatch(normalizedSender) ||
           normalizedSender == 'IDBIBK' ||
           normalizedSender == 'IDBIBANK';
  }

  @override
  double? extractAmount(String message) {
    final patterns = [
      // Pattern 1: "debited with Rs 59.00"
      RegExp(r'debited\s+with\s+Rs\.?\s*(\d+(?:,\d+)*(?:\.\d{2})?)',
          caseSensitive: false),
      // Pattern 2: "debited for Rs 1040.00"
      RegExp(r'debited\s+for\s+Rs\.?\s*(\d+(?:,\d+)*(?:\.\d{2})?)',
          caseSensitive: false),
      // Pattern 3: "credited with Rs.XXX"
      RegExp(r'credited\s+(?:with|for)\s+Rs\.?\s*(\d+(?:,\d+)*(?:\.\d{2})?)',
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
    // Pattern 1: "towards <merchant> for"
    final towardsPattern = RegExp(r'towards\s+([^.\n]+?)\s+for',
        caseSensitive: false);
    final towardsMatch = towardsPattern.firstMatch(message);
    if (towardsMatch != null) {
      final merchant = cleanMerchantName(towardsMatch.group(1)!.trim());
      if (isValidMerchantName(merchant)) {
        return merchant;
      }
    }

    // Pattern 2: "; <merchant> credited."
    final creditedMerchantPattern = RegExp(r';\s*([^.\n]+?)\s+credited\.',
        caseSensitive: false);
    final creditedMatch = creditedMerchantPattern.firstMatch(message);
    if (creditedMatch != null) {
      final merchant = cleanMerchantName(creditedMatch.group(1)!.trim());
      if (isValidMerchantName(merchant)) {
        return merchant;
      }
    }

    return super.extractMerchant(message, sender);
  }

  @override
  String? extractAccountLast4(String message) {
    final patterns = [
      // Pattern 1: "Acct XX1234"
      RegExp(r'Acct\s+(?:XX|X\*+)?(\d{3,4})', caseSensitive: false),
      // Pattern 2: "IDBI Bank Acct XX1234"
      RegExp(r'IDBI\s+Bank\s+Acct\s+(?:XX|X\*+)?(\d{3,4})',
          caseSensitive: false),
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
    // Pattern 1: "RRN 519766155631"
    final rrnPattern = RegExp(r'RRN\s+([A-Za-z0-9]+)', caseSensitive: false);
    final match = rrnPattern.firstMatch(message);
    if (match != null) {
      return match.group(1);
    }

    return super.extractReference(message);
  }
}
