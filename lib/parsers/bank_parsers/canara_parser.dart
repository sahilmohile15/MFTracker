import '../financial_text_parser.dart';

/// Parser for Canara Bank SMS messages
/// 
/// Sender patterns: XX-CANBNK-X, CANBNK, CANARA
/// 
/// Sample formats:
/// - UPI Debit: "Rs.23.00 paid thru A/C XX1234 on 08-8-25 16:41:00 to BMTC BUS KA57F6, UPI-Canara Bank"
/// - Credit: "INR 50.00 has been DEBITED from A/c XX1234 on DATE"
class CanaraBankParser extends FinancialTextParser {
  @override
  String getBankName() => 'Canara Bank';

  @override
  bool canHandle(String sender) {
    final normalizedSender = sender.toUpperCase();
    return normalizedSender.contains('CANBNK') || 
           normalizedSender.contains('CANARA');
  }

  @override
  double? extractAmount(String message) {
    // Canara Bank patterns
    final patterns = [
      // Pattern: Rs.23.00 paid thru
      RegExp(r'Rs\.?\s*(\d+(?:,\d+)*(?:\.\d{2})?)\s+paid',
          caseSensitive: false),
      // Pattern: INR 50.00 has been DEBITED
      RegExp(r'INR\s+(\d+(?:,\d+)*(?:\.\d{2})?)\s+has\s+been\s+(?:DEBITED|CREDITED)',
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
    // Pattern: "paid thru A/C XX1234 on 08-8-25 16:41:00 to BMTC BUS KA57F6"
    final upiMerchantPattern = RegExp(
      r'\sto\s+([^,]+?)(?:,\s*UPI|\.|-Canara)',
      caseSensitive: false,
    );
    final match = upiMerchantPattern.firstMatch(message);
    if (match != null) {
      final merchant = cleanMerchantName(match.group(1)!.trim());
      if (isValidMerchantName(merchant)) {
        return merchant;
      }
    }

    // Generic patterns
    final patterns = [
      RegExp(r'(?:to|from)\s+([^.\n]+?)(?:\s+via|\s+Ref|\s+on|\.|\s+UPI|,|$)',
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
    // Pattern: "A/C XX1234"
    final patterns = [
      RegExp(r'A/C\s+XX(\d{4})', caseSensitive: false),
      RegExp(r'A/c\s+(?:no\.?\s+)?XX(\d{4})', caseSensitive: false),
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
