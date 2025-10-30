// Enhanced SMS Parser for Indian Bank Transactions
// Based on: https://github.com/saurabhgupta050890/transaction-sms-parser
// Supports 20+ banks, credit cards, wallets, and UPI transactions

enum AccountType { bank, card, wallet }

enum TransactionTypeEnum { debit, credit }

class ParsedTransaction {
  final double? amount;
  final bool isDebit;
  final String? merchant;
  final String? accountNumber;
  final DateTime date;
  final double? balance;
  final double? balanceOutstanding; // For credit cards
  final String senderAddress;
  final String originalMessage;
  final AccountType? accountType;
  final String? accountName;
  final String? referenceNumber; // UPI ref, transaction ID
  final double confidence;

  ParsedTransaction({
    this.amount,
    required this.isDebit,
    this.merchant,
    this.accountNumber,
    required this.date,
    this.balance,
    this.balanceOutstanding,
    required this.senderAddress,
    required this.originalMessage,
    this.accountType,
    this.accountName,
    this.referenceNumber,
    this.confidence = 0.85,
  });

  bool get isValid => amount != null && amount! > 0;
}

class EnhancedSmsParser {
  // Currency patterns
  static final RegExp _rsPattern = RegExp(
    r'(?:rs\.?|inr)\s*(\d+(?:[,]\d+)*(?:\.\d+)?)',
    caseSensitive: false,
  );

  // Transaction type keywords
  static final List<String> _debitKeywords = [
    'debited',
    'debit',
    'deducted',
    'withdrawn',
    'spent',
    'paid',
    'used at',
    'charged',
    'purchase',
    'sent to',
    'dr',
    'payment',
    'booked',
  ];

  static final List<String> _creditKeywords = [
    'credited',
    'credit',
    'deposited',
    'added',
    'received',
    'refund',
    'repayment',
    'cr',
    'cashback',
    'reversal',
  ];

  // Account number patterns
  static final RegExp _accountPattern = RegExp(
    r'a/?c(?:\s+no\.?)?[\s:]*(xx|x|\*+)?(\d{3,6})',
    caseSensitive: false,
  );

  static final RegExp _cardPattern = RegExp(
    r'card\s+(?:xx|x|\*+)?(\d{4})',
    caseSensitive: false,
  );

  // Balance keywords
  static final List<String> _balanceKeywords = [
    'avbl bal',
    'available balance',
    'available limit',
    'available credit limit',
    'available credit',
    'avbl. credit limit',
    'limit available',
    'a/c bal',
    'ac bal',
    'available bal',
    'avl bal',
    'updated balance',
    'total balance',
    'new balance',
    'avl lmt',
    'balance',
    'bal',
  ];

  static final List<String> _outstandingKeywords = [
    'outstanding',
    'total due',
    'amount due',
  ];

  // UPI handles (30+ Indian banks and wallets)
  static final List<String> _upiHandles = [
    '@paytm',
    '@ybl',
    '@okaxis',
    '@oksbi',
    '@okicici',
    '@axisbank',
    '@hdfcbank',
    '@okhdfcbank',
    '@ikwik',
    '@upi',
    '@ibl',
    '@axl',
    '@aubank',
    '@bandhan',
    '@federal',
    '@sbi',
    '@kotak',
    '@indianbank',
    '@allbank',
    '@unionbank',
    '@uboi',
    '@pnb',
    '@boi',
    '@citi',
    '@hsbc',
    '@idbi',
    '@yesg',
    '@yespay',
    '@icici',
    '@freecharge',
    '@dbs',
    '@rbl',
  ];

  // Wallet names
  static final List<String> _wallets = [
    'paytm',
    'amazon pay',
    'phone pe',
    'phonepe',
    'google pay',
    'gpay',
    'lazypay',
    'simpl',
    'mobikwik',
    'freecharge',
    'airtel money',
  ];

  // Known banks/institutions
  static final List<String> _knownBanks = [
    'hdfc',
    'icici',
    'sbi',
    'state bank of india',
    'state bank',
    'axis',
    'kotak',
    'idfc',
    'yes bank',
    'indusind',
    'standard chartered',
    'sc bank',
    'citi',
    'citibank',
    'hsbc',
    'pnb',
    'punjab national bank',
    'bob',
    'bank of baroda',
    'canara',
    'canara bank',
    'union bank',
    'federal',
    'federal bank',
    'rbl',
    'idbi',
    'indian bank',
  ];

  // Card names
  static final List<String> _knownCards = [
    'uni card',
    'slice card',
    'one card',
    'onecard',
    'niyo',
    'credit card',
    'debit card',
  ];

  /// Main parsing method
  static ParsedTransaction parse(String smsBody, String senderAddress) {
    final message = _preprocessMessage(smsBody);
    final messageLower = message.toLowerCase();

    // Filter out non-transaction messages early
    if (messageLower.contains('statement is ready') || 
        messageLower.contains('statement generated') ||
        (messageLower.contains('statement') && !messageLower.contains('credited') && !messageLower.contains('debited'))) {
      // Return invalid transaction for statements
      return ParsedTransaction(
        amount: null,
        isDebit: true,
        senderAddress: senderAddress,
        originalMessage: smsBody,
        date: DateTime.now(),
        confidence: 0.0,
      );
    }

    // Extract components
    final amount = _extractAmount(message, messageLower);
    final isDebit = _detectTransactionType(messageLower);
    final merchant = _extractMerchant(message, messageLower);
    final accountInfo = _extractAccount(message, messageLower);
    final balance = _extractBalance(message, messageLower, isAvailable: true);
    final outstanding =
        _extractBalance(message, messageLower, isAvailable: false);
    final refNumber = _extractReferenceNumber(message, messageLower);

    return ParsedTransaction(
      amount: amount,
      isDebit: isDebit,
      merchant: merchant,
      accountNumber: accountInfo['number'] as String?,
      accountType: accountInfo['type'] as AccountType?,
      accountName: accountInfo['name'] as String?,
      date: DateTime.now(), // SMS import screen will use actual SMS timestamp
      balance: balance,
      balanceOutstanding: outstanding,
      senderAddress: senderAddress,
      originalMessage: smsBody,
      referenceNumber: refNumber,
      confidence: _calculateConfidence(
        amount: amount,
        accountNumber: accountInfo['number'] as String?,
        merchant: merchant,
      ),
    );
  }

  /// Preprocess message - clean and normalize
  static String _preprocessMessage(String message) {
    String processed = message;

    // Normalize whitespace
    processed = processed.replaceAll(RegExp(r'\s+'), ' ');
    processed = processed.replaceAll('\n', ' ');
    processed = processed.replaceAll('\r', ' ');

    // Normalize currency
    processed = processed.replaceAllMapped(
      RegExp(r'rs\.?(?=\w)', caseSensitive: false),
      (match) => 'Rs. ',
    );
    processed = processed.replaceAllMapped(
      RegExp(r'inr\s*', caseSensitive: false),
      (match) => 'Rs. ',
    );

    // Normalize account abbreviations
    processed = processed.replaceAllMapped(
      RegExp(r'\b(acct|account)\b', caseSensitive: false),
      (match) => 'A/C',
    );

    return processed.trim();
  }

  /// Extract transaction amount
  static double? _extractAmount(String message, String messageLower) {
    final matches = _rsPattern.allMatches(message);

    if (matches.isEmpty) return null;

    // If multiple amounts, prefer the first one
    // (usually transaction amount, later ones are often balance)
    for (final match in matches) {
      final amountStr = match.group(1)?.replaceAll(',', '');
      if (amountStr != null) {
        final amount = double.tryParse(amountStr);
        if (amount != null && amount > 0) {
          return amount;
        }
      }
    }

    return null;
  }

  /// Detect if transaction is debit or credit
  static bool _detectTransactionType(String messageLower) {
    // Special cases first (edge cases - most specific patterns)
    if (messageLower.contains('credited to your') &&
        (messageLower.contains('card') || messageLower.contains('account'))) {
      return false; // Credit - "credited to your card/account" is a credit/payment TO the card
    }
    
    if (messageLower.contains('credited from card') ||
        messageLower.contains('credited from')) {
      return true; // Debit - money moved FROM card/account
    }
    
    if (messageLower.contains('credited to card') ||
        messageLower.contains('credited to a/c') ||
        messageLower.contains('credited to account')) {
      return false; // Credit - money received TO card/account
    }

    if (messageLower.contains('debited to')) {
      return true; // Still debit - "debited to" means debit
    }

    // Check for explicit debit keywords
    for (final keyword in _debitKeywords) {
      if (messageLower.contains(keyword)) {
        if (keyword != 'credit') {
          return true; // Debit
        }
      }
    }

    // Check for credit keywords
    for (final keyword in _creditKeywords) {
      if (messageLower.contains(keyword)) {
        if (keyword != 'debit') {
          return false; // Credit
        }
      }
    }

    // Default to debit if unsure
    return true;
  }

  /// Extract merchant name from various patterns
  static String? _extractMerchant(String message, String messageLower) {
    // Pattern 1: "for MERCHANT" (higher priority for wallet payments)
    final forPattern = RegExp(
      r'for\s+([A-Z][A-Z0-9\s&\.]{2,30})',
      caseSensitive: true,
    );
    final forMatch = forPattern.firstMatch(message);
    if (forMatch != null) {
      final merchant = forMatch.group(1)?.trim();
      if (merchant != null && !_isBalanceKeyword(merchant.toLowerCase())) {
        final cleanedMerchant = _cleanMerchantName(merchant);
        // Don't return wallet names as merchant - they are accounts
        if (!_wallets.any((w) => cleanedMerchant.toLowerCase().contains(w))) {
          return cleanedMerchant;
        }
      }
    }
    
    // Pattern 2: "at MERCHANT" or "from MERCHANT" or "to MERCHANT"
    final atPattern = RegExp(
      r'(?:at|from|to|on)\s+([A-Z][A-Z0-9\s&\.]{2,30})',
      caseSensitive: true,
    );
    final atMatch = atPattern.firstMatch(message);
    if (atMatch != null) {
      final merchant = atMatch.group(1)?.trim();
      if (merchant != null && !_isBalanceKeyword(merchant.toLowerCase())) {
        final cleanedMerchant = _cleanMerchantName(merchant);
        // Don't return wallet names as merchant
        if (!_wallets.any((w) => cleanedMerchant.toLowerCase().contains(w))) {
          return cleanedMerchant;
        }
      }
    }

    // Pattern 3: UPI VPA (merchant@bank)
    for (final handle in _upiHandles) {
      final upiPattern = RegExp(
        r'([a-z0-9_.-]+)' + RegExp.escape(handle),
        caseSensitive: false,
      );
      final upiMatch = upiPattern.firstMatch(messageLower);
      if (upiMatch != null) {
        final merchantId = upiMatch.group(1);
        if (merchantId != null && merchantId.length > 2) {
          return _cleanMerchantName(merchantId);
        }
      }
    }

    // Pattern 4: VPA keyword
    if (messageLower.contains('vpa')) {
      final vpaPattern = RegExp(r'vpa\s+([a-z0-9@._-]+)', caseSensitive: false);
      final vpaMatch = vpaPattern.firstMatch(messageLower);
      if (vpaMatch != null) {
        final vpa = vpaMatch.group(1);
        if (vpa != null) {
          return _cleanMerchantName(vpa.split('@').first);
        }
      }
    }

    // Pattern 5: Check for wallet names (last resort - no specific merchant found)
    for (final wallet in _wallets) {
      if (messageLower.contains(wallet)) {
        return _formatMerchantName(wallet);
      }
    }

    return null;
  }

  /// Extract account information
  static Map<String, dynamic> _extractAccount(
      String message, String messageLower) {
    // Try account number pattern
    final accountMatch = _accountPattern.firstMatch(message);
    if (accountMatch != null) {
      final accountNo = accountMatch.group(2);
      if (accountNo != null) {
        return {
          'type': AccountType.bank,
          'number': accountNo.length > 4
              ? accountNo.substring(accountNo.length - 4)
              : accountNo,
          'name': _detectBankName(message, messageLower),
        };
      }
    }

    // Try card pattern
    final cardMatch = _cardPattern.firstMatch(message);
    if (cardMatch != null) {
      final cardNo = cardMatch.group(1);
      if (cardNo != null) {
        return {
          'type': AccountType.card,
          'number': cardNo,
          'name': _detectCardName(message, messageLower),
        };
      }
    }

    // Check for wallet
    for (final wallet in _wallets) {
      if (messageLower.contains(wallet)) {
        return {
          'type': AccountType.wallet,
          'number': null,
          'name': _formatMerchantName(wallet),
        };
      }
    }

    return {
      'type': null,
      'number': null,
      'name': null,
    };
  }

  /// Detect bank name from message
  static String? _detectBankName(String message, String messageLower) {
    for (final bank in _knownBanks) {
      if (messageLower.contains(bank)) {
        // Normalize common bank names to abbreviations
        if (bank == 'state bank of india' || bank == 'state bank') {
          return 'SBI';
        } else if (bank == 'punjab national bank') {
          return 'PNB';
        } else if (bank == 'bank of baroda') {
          return 'BOB';
        } else if (bank == 'standard chartered' || bank == 'sc bank') {
          return 'SC';
        } else if (bank == 'citibank') {
          return 'Citi';
        }
        return _formatMerchantName(bank);
      }
    }
    return null;
  }

  /// Detect card name from message
  static String? _detectCardName(String message, String messageLower) {
    for (final card in _knownCards) {
      if (messageLower.contains(card)) {
        return _formatMerchantName(card);
      }
    }
    return _detectBankName(message, messageLower);
  }

  /// Extract balance (available or outstanding)
  static double? _extractBalance(String message, String messageLower,
      {required bool isAvailable}) {
    final keywords = isAvailable ? _balanceKeywords : _outstandingKeywords;

    for (final keyword in keywords) {
      final keywordIndex = messageLower.indexOf(keyword);
      if (keywordIndex == -1) continue;

      // Look for amount after keyword
      final afterKeyword = message.substring(keywordIndex);
      final balanceMatch = _rsPattern.firstMatch(afterKeyword);

      if (balanceMatch != null) {
        final balanceStr = balanceMatch.group(1)?.replaceAll(',', '');
        if (balanceStr != null) {
          return double.tryParse(balanceStr);
        }
      }

      // Try without "Rs." - pattern: "balance 1000.00"
      final numPattern = RegExp(r'(\d+(?:[,]\d+)*(?:\.\d+)?)');
      final numMatch = numPattern.firstMatch(afterKeyword);
      if (numMatch != null) {
        final balanceStr = numMatch.group(1)?.replaceAll(',', '');
        if (balanceStr != null) {
          final balance = double.tryParse(balanceStr);
          if (balance != null && balance > 0) {
            return balance;
          }
        }
      }
    }

    return null;
  }

  /// Extract UPI reference number or transaction ID
  static String? _extractReferenceNumber(String message, String messageLower) {
    // UPI ref patterns
    final upiRefPatterns = [
      RegExp(r'upi[:\s]*ref[:\s]*no?[:\s]*(\d{12,})', caseSensitive: false),
      RegExp(r'ref[:\s]*no?\.?[:\s]*(\d{12,})', caseSensitive: false),
      RegExp(r'ref:\s*(\d{12,})', caseSensitive: false),
      RegExp(r'upi[:\s]*(\d{12,})', caseSensitive: false),
      RegExp(r'transaction[:\s]*id[:\s]*([a-z0-9]{10,})', caseSensitive: false),
      RegExp(r'txn[:\s]*id[:\s]*([a-z0-9]{10,})', caseSensitive: false),
    ];

    for (final pattern in upiRefPatterns) {
      final match = pattern.firstMatch(messageLower);
      if (match != null) {
        return match.group(1);
      }
    }

    return null;
  }

  /// Clean and normalize merchant name
  static String _cleanMerchantName(String merchant) {
    String cleaned = merchant.trim();

    // Remove common suffixes
    cleaned = cleaned.replaceAll(RegExp(r'\s+(pvt|ltd|inc|llc)\.?$',
        caseSensitive: false), '');

    // Remove special characters but keep spaces
    cleaned = cleaned.replaceAll(RegExp(r'[^a-zA-Z0-9\s&]'), '');

    // Normalize spaces
    cleaned = cleaned.replaceAll(RegExp(r'\s+'), ' ').trim();

    return _formatMerchantName(cleaned);
  }

  /// Format merchant/bank/wallet name (title case)
  static String _formatMerchantName(String name) {
    return name
        .split(' ')
        .map((word) => word.isEmpty
            ? ''
            : word[0].toUpperCase() + word.substring(1).toLowerCase())
        .join(' ');
  }

  /// Check if a word is a balance keyword
  static bool _isBalanceKeyword(String word) {
    return _balanceKeywords.any((kw) => word.contains(kw)) ||
        _outstandingKeywords.any((kw) => word.contains(kw));
  }

  /// Calculate parsing confidence score
  static double _calculateConfidence({
    required double? amount,
    required String? accountNumber,
    required String? merchant,
  }) {
    double confidence = 0.4; // Base confidence (reduced from 0.5)

    if (amount != null && amount > 0) confidence += 0.25; // Reduced from 0.3
    if (accountNumber != null && accountNumber.isNotEmpty) confidence += 0.2; // Increased from 0.15
    if (merchant != null && merchant.isNotEmpty) confidence += 0.1; // Increased from 0.05

    return confidence.clamp(0.0, 1.0);
  }

  /// Check if message is likely a transaction SMS
  static bool isTransactionSMS(String message, String senderAddress) {
    final messageLower = message.toLowerCase();

    // Filter out non-transaction messages
    if (messageLower.contains('statement') || 
        messageLower.contains('bill generated') ||
        messageLower.contains('payment due')) {
      return false; // These are notifications, not transactions
    }

    // Must contain amount
    if (!_rsPattern.hasMatch(message)) return false;

    // Must contain transaction keywords
    final hasTransactionKeyword = _debitKeywords.any((kw) => messageLower.contains(kw)) ||
        _creditKeywords.any((kw) => messageLower.contains(kw));

    if (!hasTransactionKeyword) return false;

    // Must contain account or card reference
    final hasAccountRef = _accountPattern.hasMatch(message) ||
        _cardPattern.hasMatch(message) ||
        _wallets.any((w) => messageLower.contains(w));

    return hasAccountRef;
  }
}
