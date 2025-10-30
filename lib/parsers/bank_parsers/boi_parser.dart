import '../financial_text_parser.dart';

/// Parser for Bank of India (BOI) SMS messages
/// 
/// Sender patterns: XX-BOIIND-S/T, XX-BOIBNK-S/T, XX-BOI-S/T, BOIIND, BOIBNK
/// 
/// Sample formats:
/// - "Rs.200.00 debited A/cXX5468 and credited to SAI MISAL via UPI Ref No 315439383341"
class BankOfIndiaParser extends FinancialTextParser {
  @override
  String getBankName() => 'Bank of India';

  @override
  bool canHandle(String sender) {
    final normalizedSender = sender.toUpperCase();
    
    // Direct sender IDs
    if (normalizedSender == 'BOIIND' || normalizedSender == 'BOIBNK') {
      return true;
    }

    // DLT patterns (XX-BOIIND-S/T or XX-BOIBNK-S/T format)
    return RegExp(r'^[A-Z]{2}-BOIIND-[ST]$').hasMatch(normalizedSender) ||
           RegExp(r'^[A-Z]{2}-BOIBNK-[ST]$').hasMatch(normalizedSender) ||
           RegExp(r'^[A-Z]{2}-BOI-[ST]$').hasMatch(normalizedSender) ||
           RegExp(r'^[A-Z]{2}-BOIIND$').hasMatch(normalizedSender) ||
           RegExp(r'^[A-Z]{2}-BOIBNK$').hasMatch(normalizedSender) ||
           RegExp(r'^[A-Z]{2}-BOI$').hasMatch(normalizedSender) ||
           RegExp(r'^BK-BOIIND.*$').hasMatch(normalizedSender) ||
           RegExp(r'^JD-BOIIND.*$').hasMatch(normalizedSender);
  }

  @override
  double? extractAmount(String message) {
    // Pattern 1: Rs.200.00 debited/credited
    final patterns = [
      RegExp(r'Rs\.?\s*(\d+(?:,\d+)*(?:\.\d{2})?)\s+(?:debited|credited)',
          caseSensitive: false),
      RegExp(r'(?:debited|credited)\s+Rs\.?\s*(\d+(?:,\d+)*(?:\.\d{2})?)',
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
    // Pattern 1: "credited to SAI MISAL" or "debited from MERCHANT"
    final patterns = [
      RegExp(r'credited\s+to\s+([^.\n]+?)(?:\s+via|\s+Ref|\s+on|$)',
          caseSensitive: false),
      RegExp(r'debited\s+from\s+([^.\n]+?)(?:\s+via|\s+Ref|\s+on|$)',
          caseSensitive: false),
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

    // Pattern 2: ATM withdrawal
    if (message.contains('ATM') || message.contains('withdrawn')) {
      final atmPattern = RegExp(r'(?:ATM|withdrawn)\s+(?:at\s+)?([^.\n]+?)(?:\s+on|\s+Ref|$)',
          caseSensitive: false);
      final match = atmPattern.firstMatch(message);
      if (match != null) {
        final location = cleanMerchantName(match.group(1)!.trim());
        if (isValidMerchantName(location)) {
          return 'ATM - $location';
        }
      }
      return 'ATM Withdrawal';
    }

    // Pattern 3: "from MERCHANT" (generic)
    final fromPattern = RegExp(r'from\s+([^.\n]+?)(?:\s+via|\s+Ref|\s+on|$)',
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
    // Pattern 1: A/cXX5468 or A/c XX5468 (BOI format)
    final accountPattern = RegExp(r'A/c\s*(?:XX|X\*+)?(\d{4})',
        caseSensitive: false);
    final match = accountPattern.firstMatch(message);
    if (match != null) {
      return match.group(1);
    }

    return super.extractAccountLast4(message);
  }

  @override
  String? extractReference(String message) {
    // Pattern: "Ref No 315439383341"
    final refPattern = RegExp(r'Ref\s+No\s+(\d+)', caseSensitive: false);
    final match = refPattern.firstMatch(message);
    if (match != null) {
      return match.group(1);
    }

    return super.extractReference(message);
  }
}
