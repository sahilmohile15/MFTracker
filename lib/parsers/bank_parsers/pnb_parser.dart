import '../financial_text_parser.dart';

/// Parser for Punjab National Bank (PNB) SMS messages
/// 
/// Sender patterns: XX-PNBBNK-S, XX-PNB-S, PNBBNK, PUNBN
/// 
/// Sample formats:
/// - Credit: "Your a/c XX1234 is credited with Rs.500.00 on DATE"
/// - Debit: "Your a/c XX1234 is debited with Rs.100.00 on DATE"
class PNBBankParser extends FinancialTextParser {
  @override
  String getBankName() => 'Punjab National Bank';

  @override
  bool canHandle(String sender) {
    final normalizedSender = sender.toUpperCase();
    return normalizedSender.contains('PUNJAB NATIONAL BANK') ||
           normalizedSender.contains('PNBBNK') ||
           normalizedSender.contains('PUNBN') ||
           RegExp(r'^[A-Z]{2}-PNBBNK-S$').hasMatch(normalizedSender) ||
           RegExp(r'^[A-Z]{2}-PNB-S$').hasMatch(normalizedSender) ||
           RegExp(r'^[A-Z]{2}-PNBBNK$').hasMatch(normalizedSender) ||
           normalizedSender == 'PNBSMS' ||
           normalizedSender == 'PNB';
  }

  @override
  double? extractAmount(String message) {
    // PNB patterns: "credited/debited with Rs.500.00"
    final patterns = [
      RegExp(r'(?:credited|debited)\s+with\s+Rs\.?\s*(\d+(?:,\d+)*(?:\.\d{2})?)',
          caseSensitive: false),
      RegExp(r'Rs\.?\s*(\d+(?:,\d+)*(?:\.\d{2})?)\s+(?:credited|debited)',
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
    // Pattern: "a/c XX1234" or "a/c No. XX1234"
    final patterns = [
      RegExp(r'a/c\s+(?:no\.?\s+)?XX(\d{4})', caseSensitive: false),
      RegExp(r'a/c\s+(?:no\.?\s+)?\*+(\d{4})', caseSensitive: false),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(message);
      if (match != null) {
        return match.group(1);
      }
    }

    return super.extractAccountLast4(message);
  }
}
