import '../financial_text_parser.dart';

/// Parser for Central Bank of India (CBoI) SMS messages
/// 
/// Sender patterns: XX-CENTBK-X, XX-CBOI-X, CENTBK, CBOI, CENTRALBANK, CENTRAL
/// 
/// Sample formats:
/// - "Credited by Rs.50.00"
/// - "Debited by Rs.100.50"
class CentralBankOfIndiaParser extends FinancialTextParser {
  @override
  String getBankName() => 'Central Bank of India';

  @override
  bool canHandle(String sender) {
    final normalizedSender = sender.toUpperCase();
    return normalizedSender.contains('CENTBK') ||
           normalizedSender.contains('CBOI') ||
           normalizedSender.contains('CENTRALBANK') ||
           normalizedSender.contains('CENTRAL') ||
           RegExp(r'^[A-Z]{2}-CENTBK-[A-Z]$').hasMatch(normalizedSender) ||
           RegExp(r'^[A-Z]{2}-CBOI-[A-Z]$').hasMatch(normalizedSender);
  }

  @override
  double? extractAmount(String message) {
    // Pattern 1: Credited by Rs.50.00 / Debited by Rs.100.50
    final patterns = [
      RegExp(r'(?:Credited|Debited)\s+by\s+Rs\.?\s*(\d+(?:,\d+)*(?:\.\d{2})?)',
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
    // Pattern 1: "from [NAME]" for credits
    final fromPattern = RegExp(r'from\s+([A-Z0-9]+|[^\s]+?)(?:\s+via|\s+Ref|\s+\.|$)',
        caseSensitive: false);
    final fromMatch = fromPattern.firstMatch(message);
    if (fromMatch != null) {
      final merchant = fromMatch.group(1)!.trim();
      // Handle masked UPI IDs
      if (merchant.contains('X')) {
        return 'UPI Transfer';
      }
      return cleanMerchantName(merchant);
    }

    // Pattern 2: "to [NAME]" for debits
    final toPattern = RegExp(r'to\s+([^\s]+?)(?:\s+via|\s+Ref|\s+\.|$)',
        caseSensitive: false);
    final toMatch = toPattern.firstMatch(message);
    if (toMatch != null) {
      final merchant = cleanMerchantName(toMatch.group(1)!.trim());
      if (isValidMerchantName(merchant)) {
        return merchant;
      }
    }

    // Pattern 3: via UPI
    if (message.contains('via UPI')) {
      if (message.contains('Credited')) {
        return 'UPI Credit';
      } else if (message.contains('Debited')) {
        return 'UPI Payment';
      }
    }

    return super.extractMerchant(message, sender);
  }

  @override
  String? extractAccountLast4(String message) {
    final patterns = [
      // Pattern 1: account XX3113 (last 4 visible)
      RegExp(r'account\s+[X*]*(\d{4})', caseSensitive: false),
      // Pattern 2: A/C ending XXXX
      RegExp(r'A/C\s+ending\s+(\d{4})', caseSensitive: false),
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
