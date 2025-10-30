import '../financial_text_parser.dart';

/// Parser for Indian Overseas Bank (IOB) SMS messages
/// 
/// Sender patterns: VA-IOBCHN-S, XX-IOB-S, IOB, IOBCHN
/// 
/// Sample formats:
/// - "Your a/c no. XXXXX92 is credited by Rs.906.00 from SIDDHANT SIN-7737219900@su(UPI Ref no 560699645381)"
class IndianOverseasBankParser extends FinancialTextParser {
  @override
  String getBankName() => 'Indian Overseas Bank';

  @override
  bool canHandle(String sender) {
    final normalizedSender = sender.toUpperCase();
    return normalizedSender.contains('IOB') || 
           normalizedSender.contains('IOBCHN');
  }

  @override
  double? extractAmount(String message) {
    final patterns = [
      // Pattern: "credited by Rs.906.00" or "debited by Rs.XXX"
      RegExp(r'(?:credited|debited)\s+by\s+Rs\.?\s*(\d+(?:,\d+)*(?:\.\d{2})?)',
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
    // UPI transaction with payer details
    // Pattern: "from SIDDHANT SIN-7737219900@su(UPI Ref"
    final upiPayerPattern = RegExp(r'from\s+([^(]+?)(?:\(UPI|$)',
        caseSensitive: false);
    final upiMatch = upiPayerPattern.firstMatch(message);
    if (upiMatch != null) {
      final payer = upiMatch.group(1)!.trim();
      
      // Check if it contains UPI ID
      if (payer.contains('@')) {
        // Extract name and UPI ID
        final parts = payer.split('-');
        if (parts.length >= 2) {
          final name = cleanMerchantName(parts[0].trim());
          final upiId = parts[1].trim();
          return 'UPI - $name ($upiId)';
        } else {
          return 'UPI - ${cleanMerchantName(payer)}';
        }
      } else {
        final cleanedPayer = cleanMerchantName(payer);
        if (isValidMerchantName(cleanedPayer)) {
          return cleanedPayer;
        }
      }
    }

    // Check for payer remark
    final remarkPattern = RegExp(r'Payer\s+Remark\s*-\s*([^-]+)',
        caseSensitive: false);
    final remarkMatch = remarkPattern.firstMatch(message);
    if (remarkMatch != null) {
      final remark = cleanMerchantName(remarkMatch.group(1)!.trim());
      if (isValidMerchantName(remark) && 
          !remark.toLowerCase().contains('paid via')) {
        return remark;
      }
    }

    // Generic patterns for debit transactions
    if (message.contains('debited')) {
      final toPattern = RegExp(r'to\s+([^.\n]+?)(?:\s+via|\s+Ref|\.|$)',
          caseSensitive: false);
      final toMatch = toPattern.firstMatch(message);
      if (toMatch != null) {
        final merchant = cleanMerchantName(toMatch.group(1)!.trim());
        if (isValidMerchantName(merchant)) {
          return merchant;
        }
      }
    }

    return super.extractMerchant(message, sender);
  }

  @override
  String? extractAccountLast4(String message) {
    // Pattern: "a/c no. XXXXX92"
    final accountPattern = RegExp(r'a/c\s+no\.?\s+[X*]*(\d{2,4})',
        caseSensitive: false);
    final match = accountPattern.firstMatch(message);
    if (match != null) {
      final digits = match.group(1)!;
      return digits.length >= 4 ? digits.substring(digits.length - 4) : digits;
    }

    return super.extractAccountLast4(message);
  }

  @override
  String? extractReference(String message) {
    // Pattern: "UPI Ref no 560699645381"
    final refPattern = RegExp(r'UPI\s+Ref\s+no\s+(\d+)', caseSensitive: false);
    final match = refPattern.firstMatch(message);
    if (match != null) {
      return match.group(1);
    }

    return super.extractReference(message);
  }
}
