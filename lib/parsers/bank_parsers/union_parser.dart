import '../financial_text_parser.dart';

/// Parser for Union Bank of India SMS messages
/// 
/// Sender patterns: XX-UNIONB-S/T, UNIONB, UNIONBANK, UBOI
/// 
/// Sample formats:
/// - Debit: "A/c *1234 Debited for Rs:100.00 on 11-08-2025 18:28:02 by Mob Bk ref no 123456789000 Avl Bal Rs:12345.67"
/// - Credit: "A/c *1234 Credited for Rs:500.00 on DATE"
class UnionBankParser extends FinancialTextParser {
  @override
  String getBankName() => 'Union Bank of India';

  @override
  bool canHandle(String sender) {
    final normalizedSender = sender.toUpperCase();
    return normalizedSender.contains('UNIONB') ||
           normalizedSender.contains('UNIONBANK') ||
           normalizedSender.contains('UBOI') ||
           RegExp(r'^[A-Z]{2}-UNIONB-[ST]$').hasMatch(normalizedSender) ||
           normalizedSender.startsWith('UNIONBNK');
  }

  @override
  double? extractAmount(String message) {
    // Union Bank patterns: "Debited/Credited for Rs:100.00"
    final patterns = [
      RegExp(r'(?:Debited|Credited)\s+for\s+Rs\s*:\s*(\d+(?:,\d+)*(?:\.\d{2})?)',
          caseSensitive: false),
      RegExp(r'Rs\s*:\s*(\d+(?:,\d+)*(?:\.\d{2})?)\s+(?:debited|credited)',
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
    // Pattern: "to/from <merchant>" or "at <merchant>"
    final patterns = [
      RegExp(r'(?:to|from)\s+([^.\n]+?)(?:\s+via|\s+Ref|\s+on|\.|\s+UPI|$)',
          caseSensitive: false),
      RegExp(r'at\s+([^.\n]+?)(?:\s+on|\.|\s+Ref|$)', caseSensitive: false),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(message);
      if (match != null) {
        final merchant = cleanMerchantName(match.group(1)!.trim());
        if (isValidMerchantName(merchant)) {
          return merchant;
        }
      }
    }

    return super.extractMerchant(message, sender);
  }

  @override
  String? extractAccountLast4(String message) {
    // Pattern: "A/c *1234"
    final patterns = [
      RegExp(r'A/c\s+\*(\d{4})', caseSensitive: false),
      RegExp(r'A/c\s+XX(\d{4})', caseSensitive: false),
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
    // Pattern: "Avl Bal Rs:12345.67"
    final balancePattern = RegExp(
      r'Avl\s+Bal\s+Rs\s*:\s*(\d+(?:,\d+)*(?:\.\d{2})?)',
      caseSensitive: false,
    );
    final match = balancePattern.firstMatch(message);
    if (match != null) {
      final balanceStr = match.group(1)!.replaceAll(',', '');
      return double.tryParse(balanceStr);
    }

    return super.extractBalance(message);
  }

  @override
  String? extractReference(String message) {
    // Pattern: "ref no 123456789000"
    final refPattern = RegExp(r'ref\s+no\s+(\d+)', caseSensitive: false);
    final match = refPattern.firstMatch(message);
    if (match != null) {
      return match.group(1);
    }

    return super.extractReference(message);
  }
}
