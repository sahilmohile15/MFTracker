import '../financial_text_parser.dart';

/// Parser for Yes Bank SMS messages
/// 
/// Sender patterns: CP-YESBNK-S, VM-YESBNK-S, JX-YESBNK-S, YESBNK, YESBANK
/// 
/// Sample formats:
/// - Credit Card UPI: "INR XXX.XX spent on YES BANK Card XXXXX @UPI_MERCHANT 12-01-2025 10:30:45. Avl Lmt INR XXX,XXX.XX"
class YesBankParser extends FinancialTextParser {
  @override
  String getBankName() => 'Yes Bank';

  @override
  bool canHandle(String sender) {
    final normalizedSender = sender.toUpperCase();
    
    // DLT patterns for Yes Bank (XX-YESBNK-S format)
    return RegExp(r'^[A-Z]{2}-YESBNK-S$').hasMatch(normalizedSender) ||
           RegExp(r'^[A-Z]{2}-YESBNK$').hasMatch(normalizedSender) ||
           normalizedSender == 'YESBNK' ||
           normalizedSender == 'YESBANK';
  }

  @override
  double? extractAmount(String message) {
    // Pattern: "INR XXX.XX spent"
    final inrSpentPattern = RegExp(
      r'INR\s+(\d+(?:,\d+)*(?:\.\d{2})?)\s+spent',
      caseSensitive: false,
    );
    final match = inrSpentPattern.firstMatch(message);
    if (match != null) {
      final amountStr = match.group(1)!.replaceAll(',', '');
      return double.tryParse(amountStr);
    }

    return super.extractAmount(message);
  }

  @override
  String? extractMerchant(String message, String sender) {
    // Pattern: "@UPI_MERCHANT NAME" format
    // Matches everything after @UPI_ until the date pattern (DD-MM-YYYY)
    final upiMerchantPattern = RegExp(
      r'@UPI_([^\s]+)',
      caseSensitive: false,
    );
    final match = upiMerchantPattern.firstMatch(message);
    if (match != null) {
      final merchant = match.group(1)!;
      return cleanMerchantName(merchant.replaceAll('_', ' '));
    }

    return super.extractMerchant(message, sender);
  }

  @override
  double? extractAvailableLimit(String message) {
    // Pattern: "Avl Lmt INR XXX,XXX.XX"
    final limitPattern = RegExp(
      r'Avl\s+Lmt\s+INR\s+(\d+(?:,\d+)*(?:\.\d{2})?)',
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
  String? extractAccountLast4(String message) {
    // Pattern: "Card XXXXX" or "Card ending XXXXX"
    final patterns = [
      RegExp(r'Card\s+\*?X*(\d{4,5})', caseSensitive: false),
      RegExp(r'Card\s+ending\s+(\d{4,5})', caseSensitive: false),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(message);
      if (match != null) {
        final digits = match.group(1)!;
        return digits.length >= 4 ? digits.substring(digits.length - 4) : digits;
      }
    }

    return super.extractAccountLast4(message);
  }
}
