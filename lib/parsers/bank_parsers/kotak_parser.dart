// Kotak Mahindra Bank Parser
// Handles Kotak bank account and credit card transactions

import '../financial_text_parser.dart';

class KotakBankParser extends FinancialTextParser {
  @override
  String getBankName() => 'Kotak Bank';

  @override
  bool canHandle(String sender) {
    final upperSender = sender.toUpperCase();
    return upperSender.contains('KOTAK') ||
           upperSender.contains('KOTAKB') ||
           RegExp(r'^[A-Z]{2}-KOTAKB-[ST]$').hasMatch(upperSender) ||
           upperSender == 'KOTAKBANK';
  }

  @override
  double? extractAmount(String message) {
    final patterns = [
      // Rs.1234.56 or Rs 1234.56
      RegExp(r'Rs\.?\s*(\d+(?:,\d+)*(?:\.\d{2})?)', caseSensitive: false),
      // INR 1234.56
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
    // Pattern 1: "Sent Rs.X from Kotak Bank AC XXXX to merchant@bank on"
    final sentToPattern = RegExp(
      r'to\s+([^@\s]+)@',
      caseSensitive: false,
    );
    final sentMatch = sentToPattern.firstMatch(message);
    if (sentMatch != null) {
      final merchant = cleanMerchantName(sentMatch.group(1)!.trim());
      if (isValidMerchantName(merchant)) {
        return merchant;
      }
    }

    // Pattern 2: "at MERCHANT via"
    final atPattern = RegExp(
      r'at\s+([^.\n]+?)\s+(?:via|on)',
      caseSensitive: false,
    );
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
  String? extractReference(String message) {
    // Kotak UPI reference
    final upiRefPattern = RegExp(
      r'UPI\s+Ref\s+No[:\s]*(\d+)',
      caseSensitive: false,
    );
    final upiMatch = upiRefPattern.firstMatch(message);
    if (upiMatch != null) {
      return upiMatch.group(1);
    }

    return super.extractReference(message);
  }

  @override
  double? extractBalance(String message) {
    // Kotak balance patterns
    final patterns = [
      RegExp(r'Avl\s+Bal\s+Rs\.?\s*(\d+(?:,\d+)*(?:\.\d{2})?)', caseSensitive: false),
      RegExp(r'Available\s+Balance\s+Rs\.?\s*(\d+(?:,\d+)*(?:\.\d{2})?)', caseSensitive: false),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(message);
      if (match != null) {
        final balanceStr = match.group(1)!.replaceAll(',', '');
        return double.tryParse(balanceStr);
      }
    }

    return super.extractBalance(message);
  }
}
