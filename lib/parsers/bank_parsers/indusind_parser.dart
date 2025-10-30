import '../financial_text_parser.dart';

/// Parser for IndusInd Bank SMS messages
/// 
/// Sender patterns: JD-INDUSB-S, XX-INDUSB-S, INDUSB, INDUSIND
/// 
/// Sample formats:
/// - Credit: "A/C *XX0000 credited by Rs 890.00 from abcd@upiid. RRN:123456789098. Avl Bal:00.00"
/// - Debit: "A/C XX1234 debited Rs 100.00 towards merchant"
class IndusIndBankParser extends FinancialTextParser {
  @override
  String getBankName() => 'IndusInd Bank';

  @override
  bool canHandle(String sender) {
    final s = sender.toUpperCase();
    
    // Common short/long forms
    if (s == 'INDUSB' || s == 'INDUSIND' || s.contains('INDUSIND BANK')) {
      return true;
    }
    
    // DLT/route patterns (XX-INDUSB-S format)
    if (RegExp(r'^[A-Z]{2}-INDUSB(?:-S)?$').hasMatch(s)) {
      return true;
    }
    
    return false;
  }

  @override
  double? extractAmount(String message) {
    // Pattern: "credited by Rs 890.00" or "debited Rs 100.00"
    final patterns = [
      RegExp(r'(?:credited|debited)\s+(?:by\s+)?Rs\.?\s*(\d+(?:,\d+)*(?:\.\d{2})?)',
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
    // Credit: "from <vpa or merchant>"
    final fromPattern = RegExp(r'from\s+(\S+)', caseSensitive: false);
    final fromMatch = fromPattern.firstMatch(message);
    if (fromMatch != null) {
      var token = fromMatch.group(1)!.trim().replaceAll(RegExp(r'[.,;]$'), '');
      if (token.contains('@')) {
        // Extract VPA part before @
        token = token.split('@')[0];
      }
      if (token.isNotEmpty) {
        return cleanMerchantName(token);
      }
    }

    // Debit: "towards <merchant>"
    final towardsPattern = RegExp(r'towards\s+(\S+)', caseSensitive: false);
    final towardsMatch = towardsPattern.firstMatch(message);
    if (towardsMatch != null) {
      var m = towardsMatch.group(1)!.trim().replaceAll(RegExp(r'[.,;]$'), '');
      if (m.contains('@')) {
        m = m.split('@')[0];
      }
      if (m.isNotEmpty) {
        return cleanMerchantName(m);
      }
    }

    // Card/POS: "at <merchant>"
    final atPattern = RegExp(r'at\s+([^.\n]+?)(?:\s+on|\.|$)', caseSensitive: false);
    final atMatch = atPattern.firstMatch(message);
    if (atMatch != null) {
      final merchant = cleanMerchantName(atMatch.group(1)!.trim());
      if (isValidMerchantName(merchant)) {
        return merchant;
      }
    }

    return super.extractMerchant(message, sender);
  }

  @override
  String? extractAccountLast4(String message) {
    // Pattern: "A/C *XX0000" or "A/C XX1234"
    final patterns = [
      RegExp(r'A/C\s+\*?XX(\d{4})', caseSensitive: false),
      RegExp(r'A/C\s+\*(\d{4})', caseSensitive: false),
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
    // Pattern: "Avl Bal:00.00" or "Avl Bal Rs.1234.56"
    final balancePattern = RegExp(
      r'Avl\s+Bal\s*:?\s*(?:Rs\.?)?\s*(\d+(?:,\d+)*(?:\.\d{2})?)',
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
    // Pattern: "RRN:123456789098"
    final rrnPattern = RegExp(r'RRN\s*:\s*(\d+)', caseSensitive: false);
    final match = rrnPattern.firstMatch(message);
    if (match != null) {
      return match.group(1);
    }

    return super.extractReference(message);
  }
}
