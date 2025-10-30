import '../financial_text_parser.dart';

/// Parser for IDFC First Bank SMS messages
/// 
/// Sender patterns: XX-IDFCBK-S, XX-IDFCBK-T, XX-IDFCB-S, IDFCBK, IDFCFB, IDFC
/// 
/// Sample formats:
/// - Debit: "Your A/C XXXXXXXXXXX is debited by INR 68.00 on 06/08/25 17:36. New Bal :INR XXXXX.00"
/// - Credit: "Your A/C XXXXXXXXXXX is credited by INR 500.00 on 06/08/25 17:36. New Bal :INR XXXXX.00"
class IDFCFirstBankParser extends FinancialTextParser {
  @override
  String getBankName() => 'IDFC First Bank';

  @override
  bool canHandle(String sender) {
    final normalizedSender = sender.toUpperCase();
    return normalizedSender.contains('IDFCBK') ||
           normalizedSender.contains('IDFCFB') ||
           normalizedSender.contains('IDFC');
  }

  @override
  double? extractAmount(String message) {
    // IDFC First Bank patterns
    final amountPatterns = [
      // Debit patterns
      RegExp(r'Debit\s+Rs\.?\s*(\d+(?:,\d+)*(?:\.\d{2})?)', caseSensitive: false),
      RegExp(r'debited\s+by\s+Rs\.?\s*(\d+(?:,\d+)*(?:\.\d{2})?)', caseSensitive: false),
      RegExp(r'debited\s+by\s+INR\s*(\d+(?:,\d+)*(?:\.\d{2})?)', caseSensitive: false),
      
      // Credit patterns
      RegExp(r'Credit\s+Rs\.?\s*(\d+(?:,\d+)*(?:\.\d{2})?)', caseSensitive: false),
      RegExp(r'credited\s+by\s+Rs\.?\s*(\d+(?:,\d+)*(?:\.\d{2})?)', caseSensitive: false),
      RegExp(r'credited\s+by\s+INR\s*(\d+(?:,\d+)*(?:\.\d{2})?)', caseSensitive: false),
    ];

    for (final pattern in amountPatterns) {
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
    // Pattern: "A/C XXXXXXXXXXX" where last 4 digits are visible
    final acPattern = RegExp(r'A/C\s+[X]*(\d{3,4})', caseSensitive: false);
    final match = acPattern.firstMatch(message);
    if (match != null) {
      final digits = match.group(1)!;
      return digits.length >= 4 ? digits.substring(digits.length - 4) : digits;
    }

    return super.extractAccountLast4(message);
  }

  @override
  double? extractBalance(String message) {
    // Pattern: "New Bal :INR XXXXX.00" or "New bal: Rs.XXXXX.00"
    final balancePatterns = [
      RegExp(r'New\s+Bal\s*:\s*INR\s*(\d+(?:,\d+)*(?:\.\d{2})?)',
          caseSensitive: false),
      RegExp(r'New\s+bal\s*:\s*Rs\.?\s*(\d+(?:,\d+)*(?:\.\d{2})?)',
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
