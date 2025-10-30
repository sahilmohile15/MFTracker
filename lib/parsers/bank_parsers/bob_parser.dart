import '../financial_text_parser.dart';

/// Parser for Bank of Baroda (BOB) SMS messages
/// 
/// Sender patterns: XX-BOBSMS-X, XX-BOBTXN-X, XX-BOB-X, BOBSMS, BOBTXN, BOBCRD
/// 
/// Sample formats:
/// - Debit: "Your A/c XX1234 debited with Rs.100.00 on DATE"
/// - Credit: "Your A/c XX1234 credited with Rs.500.00 on DATE"
class BankOfBarodaParser extends FinancialTextParser {
  @override
  String getBankName() => 'Bank of Baroda';

  @override
  bool canHandle(String sender) {
    final normalizedSender = sender.toUpperCase();
    return normalizedSender.contains('BOB') ||
           normalizedSender.contains('BARODA') ||
           normalizedSender.contains('BOBSMS') ||
           normalizedSender.contains('BOBTXN') ||
           normalizedSender.contains('BOBCRD') ||
           RegExp(r'^[A-Z]{2}-BOBSMS-[A-Z]$').hasMatch(normalizedSender) ||
           RegExp(r'^[A-Z]{2}-BOBTXN-[A-Z]$').hasMatch(normalizedSender) ||
           RegExp(r'^[A-Z]{2}-BOB-[A-Z]$').hasMatch(normalizedSender) ||
           normalizedSender.startsWith('BOBBNK');
  }

  @override
  double? extractAmount(String message) {
    // BOB patterns: "debited/credited with Rs.100.00"
    final patterns = [
      RegExp(r'(?:debited|credited)\s+with\s+Rs\.?\s*(\d+(?:,\d+)*(?:\.\d{2})?)',
          caseSensitive: false),
      RegExp(r'Rs\.?\s*(\d+(?:,\d+)*(?:\.\d{2})?)\s+(?:debited|credited)',
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
    // Pattern: "A/c XX1234" or "A/c No. XX1234"
    final patterns = [
      RegExp(r'A/c\s+(?:no\.?\s+)?XX(\d{4})', caseSensitive: false),
      RegExp(r'A/c\s+(?:no\.?\s+)?\*+(\d{4})', caseSensitive: false),
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
