import '../financial_text_parser.dart';

/// Parser for Federal Bank SMS messages
/// 
/// Sender patterns: AD-FEDBNK-S, JM-FEDBNK-S, FEDBNK, FEDERAL, FEDFIB
/// 
/// Sample formats:
/// - UPI: "Rs 34.51 debited via UPI on 08-05-2025 13:48:03 to VPA merchant@bank"
/// - Card transactions
/// - NEFT/IMPS transfers
class FederalBankParser extends FinancialTextParser {
  @override
  String getBankName() => 'Federal Bank';

  @override
  bool canHandle(String sender) {
    final normalizedSender = sender.toUpperCase();
    return normalizedSender.contains('FEDBNK') ||
           normalizedSender.contains('FEDERAL') ||
           normalizedSender.contains('FEDFIB') ||
           RegExp(r'^[A-Z]{2}-FEDBNK-[ST]$').hasMatch(normalizedSender);
  }

  @override
  double? extractAmount(String message) {
    // Federal Bank patterns
    final patterns = [
      RegExp(r'Rs\.?\s*(\d+(?:,\d+)*(?:\.\d{2})?)\s+(?:debited|credited)',
          caseSensitive: false),
      RegExp(r'(?:debited|credited)\s+Rs\.?\s*(\d+(?:,\d+)*(?:\.\d{2})?)',
          caseSensitive: false),
      RegExp(r'INR\s+(\d+(?:,\d+)*(?:\.\d{2})?)', caseSensitive: false),
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
    // Priority 1: VPA pattern "to VPA merchant@bank"
    final vpaPattern = RegExp(r'to\s+VPA\s+([^\s]+@[^\s]+)',
        caseSensitive: false);
    final vpaMatch = vpaPattern.firstMatch(message);
    if (vpaMatch != null) {
      final vpa = vpaMatch.group(1)!;
      // Extract merchant from VPA (part before @)
      final merchantPart = vpa.split('@')[0];
      return cleanMerchantName(merchantPart);
    }

    // Priority 2: "from <sender name>"
    final fromPattern = RegExp(r'from\s+([^.\n]+?)(?:\.\s*|$)',
        caseSensitive: false);
    final fromMatch = fromPattern.firstMatch(message);
    if (fromMatch != null) {
      final merchant = cleanMerchantName(fromMatch.group(1)!.trim());
      if (isValidMerchantName(merchant)) {
        return merchant;
      }
    }

    // Priority 3: "to <merchant>"
    final toPattern = RegExp(r'to\s+([^.\n]+?)(?:\s+via|\s+on|\.|\s+UPI|$)',
        caseSensitive: false);
    final toMatch = toPattern.firstMatch(message);
    if (toMatch != null) {
      final merchant = cleanMerchantName(toMatch.group(1)!.trim());
      if (isValidMerchantName(merchant)) {
        return merchant;
      }
    }

    // Priority 4: ATM transactions
    if (message.contains('ATM') || message.contains('withdrawn')) {
      return 'ATM Withdrawal';
    }

    return super.extractMerchant(message, sender);
  }

  @override
  String? extractAccountLast4(String message) {
    // Pattern: "A/c XX1234" or "a/c *1234"
    final patterns = [
      RegExp(r'A/c\s+XX(\d{4})', caseSensitive: false),
      RegExp(r'a/c\s+\*(\d{4})', caseSensitive: false),
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
