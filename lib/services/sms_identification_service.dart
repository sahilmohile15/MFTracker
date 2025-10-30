/// SMS Identification Service
/// Identifies financial SMS messages BEFORE parsing
/// Based on PennywiseAI's two-stage filtering approach
class SmsIdentificationService {
  static final SmsIdentificationService _instance =
      SmsIdentificationService._internal();
  factory SmsIdentificationService() => _instance;
  SmsIdentificationService._internal();

  /// Check if sender ID matches financial service patterns
  /// Indian banks use DLT (Distributed Ledger Technology) patterns:
  /// - XX-BANKNAME-S: Service/Transaction SMS
  /// - XX-BANKNAME-T: Transactional SMS
  /// - XX-BANKNAME-P: Promotional (should be excluded)
  /// - XX-BANKNAME-G: Government (should be excluded)
  bool isFinancialSender(String sender) {
    final upperSender = sender.toUpperCase();

    // Skip promotional and government messages
    if (upperSender.endsWith('-P') || upperSender.endsWith('-G')) {
      return false;
    }

    // DLT pattern for transactions/service
    if (upperSender.endsWith('-S') || upperSender.endsWith('-T')) {
      return true;
    }

    // Common Indian bank sender patterns
    final bankKeywords = [
      'HDFC',
      'ICICI',
      'SBI',
      'AXIS',
      'KOTAK',
      'IDFC',
      'YES',
      'INDUS',
      'BOI',
      'PNB',
      'CANARA',
      'BOB',
      'UNION',
      'BANK',
      'PAYTM',
      'GPAY',
      'PHONEPE',
      'UPI',
      'VISA',
      'MASTER',
    ];

    return bankKeywords.any((keyword) => upperSender.contains(keyword));
  }

  /// Check if SMS message is a transaction message
  /// Excludes: OTPs, promotional offers, verification codes
  /// Requires: Transaction keywords like debited, credited, spent
  bool isTransactionMessage(String message) {
    final lowerMessage = message.toLowerCase();

    // STAGE 1: EXCLUDE non-transaction messages

    // OTP and verification messages
    if (lowerMessage.contains('otp') ||
        lowerMessage.contains('one time password') ||
        lowerMessage.contains('verification code') ||
        lowerMessage.contains('verify your')) {
      return false;
    }

    // Promotional messages
    if (lowerMessage.contains('offer') ||
        lowerMessage.contains('discount') ||
        lowerMessage.contains('cashback offer') ||
        lowerMessage.contains('win ') ||
        lowerMessage.contains('congratulations') ||
        lowerMessage.contains('hurry') ||
        lowerMessage.contains('limited time')) {
      return false;
    }

    // Payment requests (not actual transactions)
    if (lowerMessage.contains('has requested') ||
        lowerMessage.contains('payment request') ||
        lowerMessage.contains('collect request') ||
        lowerMessage.contains('requesting payment') ||
        lowerMessage.contains('requests rs') ||
        lowerMessage.contains('ignore if already paid')) {
      return false;
    }

    // Account alerts and notifications (not transactions)
    if (lowerMessage.contains('account has been activated') ||
        lowerMessage.contains('card has been activated') ||
        lowerMessage.contains('has been blocked') ||
        lowerMessage.contains('pin change') ||
        lowerMessage.contains('statement is ready') ||
        lowerMessage.contains('bill generated') ||
        lowerMessage.contains('is due on') ||
        lowerMessage.contains('is due for') ||
        lowerMessage.contains('payment reminder')) {
      return false;
    }

    // STAGE 2: REQUIRE transaction keywords

    final transactionKeywords = [
      'debited',
      'credited',
      'withdrawn',
      'spent',
      'paid',
      'received',
      'transferred',
      'deposited',
      'purchase',
      'charged',
      'payment of',
      'amount of',
      'sent rs',
      'sent inr',
      'sent via',
    ];

    // Must contain at least one transaction keyword
    if (!transactionKeywords.any((keyword) => lowerMessage.contains(keyword))) {
      return false;
    }

    // STAGE 3: REQUIRE currency/amount patterns
    // Transaction messages should have amount information
    final amountPatterns = [
      RegExp(r'rs\.?\s*\d+', caseSensitive: false),
      RegExp(r'inr\s+\d+', caseSensitive: false),
      RegExp(r'₹\s*\d+', caseSensitive: false),
      RegExp(r'\d+\.\d{2}', caseSensitive: false), // Decimal amounts
    ];

    if (!amountPatterns.any((pattern) => pattern.hasMatch(message))) {
      return false;
    }

    return true;
  }

  /// Comprehensive SMS identification check
  /// Returns true only if SMS is from a financial sender AND contains transaction
  bool identifySMS(String sender, String message) {
    // Check sender first (fast filter)
    if (!isFinancialSender(sender)) {
      return false;
    }

    // Then check message content (slower but accurate)
    return isTransactionMessage(message);
  }

  /// Extract sender bank name from sender ID
  String? extractBankName(String sender) {
    final upperSender = sender.toUpperCase();

    // Remove DLT prefix pattern (XX-BANKNAME-X)
    String cleanSender = upperSender;
    final dltPattern = RegExp(r'^[A-Z]{2}-([A-Z]+)-[A-Z]$');
    final match = dltPattern.firstMatch(upperSender);
    if (match != null) {
      cleanSender = match.group(1)!;
    }

    // Map common sender IDs to bank names
    final bankMapping = {
      'HDFCBK': 'HDFC Bank',
      'ICICIB': 'ICICI Bank',
      'SBIINB': 'State Bank of India',
      'SBIBK': 'State Bank of India',
      'AXISBK': 'Axis Bank',
      'KOTAKB': 'Kotak Bank',
      'IDFCBK': 'IDFC First Bank',
      'YESBNK': 'Yes Bank',
      'INDUSL': 'IndusInd Bank',
      'BOIIND': 'Bank of India',
      'PNBBNK': 'Punjab National Bank',
      'CANBNK': 'Canara Bank',
      'BOBSMS': 'Bank of Baroda',
      'UNIONB': 'Union Bank',
    };

    // Check for exact matches
    for (final entry in bankMapping.entries) {
      if (cleanSender.contains(entry.key)) {
        return entry.value;
      }
    }

    // Check if cleanSender itself matches a key
    if (bankMapping.containsKey(cleanSender)) {
      return bankMapping[cleanSender];
    }

    // Return cleaned sender with spaces if no mapping found
    if (cleanSender.contains('BANK') && !cleanSender.contains(' ')) {
      // Convert HDFCBANK -> HDFC BANK
      final parts = cleanSender.split('BANK');
      if (parts.length == 2 && parts[0].isNotEmpty) {
        return '${parts[0]} Bank';
      }
    }

    return cleanSender;
  }

  /// Get statistics about SMS filtering
  Map<String, dynamic> getFilterStats(
      List<Map<String, String>> smsList) {
    int total = smsList.length;
    int financialSenders = 0;
    int transactionMessages = 0;
    int identified = 0;

    for (final sms in smsList) {
      final sender = sms['sender'] ?? '';
      final body = sms['body'] ?? '';

      if (isFinancialSender(sender)) {
        financialSenders++;
      }

      if (isTransactionMessage(body)) {
        transactionMessages++;
      }

      if (identifySMS(sender, body)) {
        identified++;
      }
    }

    return {
      'total': total,
      'financialSenders': financialSenders,
      'transactionMessages': transactionMessages,
      'identified': identified,
      'filterRate': total > 0 ? (identified / total * 100).toStringAsFixed(1) : '0.0',
    };
  }
}
