// Centralized Financial Text Parser
// Unified parser for SMS, notifications, and future sources
// Architecture inspired by: https://github.com/sarim2000/pennywiseai-tracker
// 
// Design:
// - Base abstract class with virtual methods
// - Bank-specific parsers extend and override as needed
// - Factory pattern for bank parser registration
// - Hybrid approach ready: Rule-based now, LLM extension points for future

import 'merchant_category_mapper.dart';

/// Transaction types for classification
enum TransactionType {
  expense,  // Money going out (debit, withdrawal, payment)
  income,   // Money coming in (credit, deposit, received)
  credit,   // Credit card transaction
  transfer, // Transfer between accounts
  investment, // Investment transactions (mutual funds, stocks, etc.)
}

/// Account types for classification
enum AccountType {
  bankAccount,
  creditCard,
  wallet,
  unknown,
}

/// Parsed transaction data model
/// Contains all information extracted from financial text
class ParsedTransaction {
  final double amount;
  final TransactionType type;
  final String? merchant;
  final String? reference;
  final String? accountLast4;
  final double? balance;
  final double? creditLimit;
  final String smsBody;
  final String sender;
  final DateTime timestamp;
  final String bankName;
  final bool isFromCard;
  final String currency;
  final String? fromAccount;
  final String? toAccount;
  final String category;
  
  ParsedTransaction({
    required this.amount,
    required this.type,
    this.merchant,
    this.reference,
    this.accountLast4,
    this.balance,
    this.creditLimit,
    required this.smsBody,
    required this.sender,
    required this.timestamp,
    required this.bankName,
    this.isFromCard = false,
    this.currency = 'INR',
    this.fromAccount,
    this.toAccount,
    String? category,
  }) : category = category ?? _determineCategory(merchant);

  /// Determine category from merchant name
  static String _determineCategory(String? merchant) {
    return MerchantCategoryMapper.getCategoryWithNormalization(merchant);
  }

  /// Get human-readable category name
  String get categoryDisplayName => MerchantCategoryMapper.getCategoryDisplayName(category);

  /// Legacy compatibility: convert to old isDebit boolean
  bool get isDebit => type == TransactionType.expense || 
                       type == TransactionType.credit ||
                       type == TransactionType.transfer;

  /// For consistency with old model
  String get senderAddress => sender;
  String get originalMessage => smsBody;
  DateTime get date => timestamp;
  AccountType get accountType => isFromCard ? AccountType.creditCard : AccountType.bankAccount;
  String? get referenceNumber => reference;
  double? get balanceOutstanding => isFromCard ? creditLimit : null;

  /// Convert to app's Transaction model (using constants.TransactionType: debit/credit)
  /// This maps our parser's TransactionType to the app's debit/credit model
  Map<String, dynamic> toTransactionData() {
    // Map parser transaction type to app's debit/credit model
    // expense/credit(card)/transfer → debit (money going out)
    // income → credit (money coming in)
    final bool isDebitTransaction = type == TransactionType.expense || 
                                     type == TransactionType.credit ||
                                     type == TransactionType.transfer;
    
    return {
      'amount': amount,
      'type': isDebitTransaction ? 'debit' : 'credit',
      'description': merchant ?? 'Transaction from $bankName',
      'merchantName': merchant,
      'category': category,
      'categoryDisplayName': categoryDisplayName,
      'accountNumber': accountLast4,
      'balanceAfter': balance,
      'upiTransactionId': reference,
      'paymentMethod': _getPaymentMethod(),
      'smsBody': smsBody,
      'smsSender': sender,
      'smsTimestamp': timestamp,
    };
  }
  
  /// Determine payment method from transaction context
  String? _getPaymentMethod() {
    final lowerBody = smsBody.toLowerCase();
    
    // Check for explicit card usage patterns first
    // "On HDFCBank Card 1111", "spent using ICICI Bank Card", "on SBI Card"
    if (isFromCard && (lowerBody.contains('credit card') || lowerBody.contains('debit card') || 
        RegExp(r'on\s+\w*\s*card\s+\d{4}').hasMatch(lowerBody) ||
        lowerBody.contains('using') && lowerBody.contains('card') ||
        lowerBody.contains('spent on') && lowerBody.contains('card'))) {
      return 'Card';
    }
    
    // Check for UPI (account-to-account, UPI transfers, not card)
    if (lowerBody.contains('upi') || 
        lowerBody.contains('@ybl') || lowerBody.contains('@paytm') || 
        lowerBody.contains('@okaxis') || lowerBody.contains('@icici')) {
      return 'UPI';
    }
    
    // Check for ATM
    if (lowerBody.contains('atm')) {
      return 'ATM';
    }
    
    // Check for bank transfer keywords
    if (lowerBody.contains('neft') || lowerBody.contains('imps') || lowerBody.contains('rtgs')) {
      return 'Bank Transfer';
    }
    
    // Fallback: Check if from card
    if (isFromCard) {
      return 'Card';
    }
    
    return null;
  }

  @override
  String toString() {
    return 'ParsedTransaction(amount: $amount, type: $type, merchant: $merchant, '
           'sender: $sender, bank: $bankName)';
  }
}

/// Abstract base class for financial text parsers
/// Each bank/institution extends this and overrides specific methods
abstract class FinancialTextParser {
  
  /// Returns the name of the bank/institution this parser handles
  String getBankName();
  
  /// Checks if this parser can handle messages from the given sender
  bool canHandle(String sender);
  
  /// Returns the default currency for this bank (default: INR)
  String getCurrency() => 'INR';
  
  /// Main entry point: parses financial text and returns transaction
  /// Returns null if message cannot be parsed
  ParsedTransaction? parse(String messageBody, String sender, DateTime timestamp) {
    // Skip non-transaction messages
    if (!isTransactionMessage(messageBody)) {
      return null;
    }
    
    final amount = extractAmount(messageBody);
    if (amount == null || amount <= 0) {
      return null;
    }
    
    final type = extractTransactionType(messageBody);
    if (type == null) {
      return null;
    }
    
    // Extract available credit limit for credit card transactions
    final availableLimit = (type == TransactionType.credit || type == TransactionType.expense) 
        ? extractAvailableLimit(messageBody)
        : null;
    
    return ParsedTransaction(
      amount: amount,
      type: type,
      merchant: extractMerchant(messageBody, sender),
      reference: extractReference(messageBody),
      accountLast4: extractAccountLast4(messageBody),
      balance: extractBalance(messageBody),
      creditLimit: availableLimit,
      smsBody: messageBody,
      sender: sender,
      timestamp: timestamp,
      bankName: getBankName(),
      isFromCard: detectIsCard(messageBody),
      currency: extractCurrency(messageBody) ?? getCurrency(),
      fromAccount: extractFromAccount(messageBody),
      toAccount: extractToAccount(messageBody),
    );
  }
  
  // ==========================================================================
  // EXTRACTION METHODS (Override in bank-specific parsers)
  // ==========================================================================
  
  /// Extracts transaction amount from message
  /// Override for bank-specific patterns
  double? extractAmount(String message) {
    // Pattern 1: Rs. 1234.56 or Rs 1234.56
    final rsPattern = RegExp(
      r'Rs\.?\s*(\d+(?:,\d+)*(?:\.\d{2})?)',
      caseSensitive: false,
    );
    final rsMatch = rsPattern.firstMatch(message);
    if (rsMatch != null) {
      final amountStr = rsMatch.group(1)!.replaceAll(',', '');
      return double.tryParse(amountStr);
    }
    
    // Pattern 2: INR 1234.56
    final inrPattern = RegExp(
      r'INR\s+(\d+(?:,\d+)*(?:\.\d{2})?)',
      caseSensitive: false,
    );
    final inrMatch = inrPattern.firstMatch(message);
    if (inrMatch != null) {
      final amountStr = inrMatch.group(1)!.replaceAll(',', '');
      return double.tryParse(amountStr);
    }
    
    // Pattern 3: ₹ 1234.56
    final rupeePattern = RegExp(
      r'₹\s*(\d+(?:,\d+)*(?:\.\d{2})?)',
      caseSensitive: false,
    );
    final rupeeMatch = rupeePattern.firstMatch(message);
    if (rupeeMatch != null) {
      final amountStr = rupeeMatch.group(1)!.replaceAll(',', '');
      return double.tryParse(amountStr);
    }
    
    return null;
  }
  
  /// Extracts transaction type (EXPENSE/INCOME/CREDIT/TRANSFER/INVESTMENT)
  /// Override for bank-specific patterns
  TransactionType? extractTransactionType(String message) {
    final lowerMessage = message.toLowerCase();
    
    // Check for investment transactions first (highest priority)
    if (isInvestmentTransaction(lowerMessage)) {
      return TransactionType.investment;
    }
    
    // Expense patterns
    if (lowerMessage.contains('debited') ||
        lowerMessage.contains('withdrawn') ||
        lowerMessage.contains('spent') ||
        lowerMessage.contains('charged') ||
        lowerMessage.contains('paid') ||
        lowerMessage.contains('purchase') ||
        lowerMessage.contains('payment') ||
        lowerMessage.contains('deducted') ||
        lowerMessage.contains('used at')) {
      return TransactionType.expense;
    }
    
    // Income patterns
    if (lowerMessage.contains('credited') ||
        lowerMessage.contains('deposited') ||
        lowerMessage.contains('received') ||
        lowerMessage.contains('refund') ||
        lowerMessage.contains('cashback') ||
        lowerMessage.contains('reversal')) {
      return TransactionType.income;
    }
    
    return null;
  }
  
  /// Extracts merchant/payee name from message
  /// Override for bank-specific patterns
  String? extractMerchant(String message, String sender) {
    // Pattern 1: "at MERCHANT"
    final atPattern = RegExp(
      r'at\s+([^.\n]+?)(?:\s+on|\.|$)',
      caseSensitive: false,
    );
    final atMatch = atPattern.firstMatch(message);
    if (atMatch != null) {
      final merchant = cleanMerchantName(atMatch.group(1)!.trim());
      if (isValidMerchantName(merchant)) {
        return merchant;
      }
    }
    
    // Pattern 2: "to MERCHANT"
    final toPattern = RegExp(
      r'to\s+([^.\n]+?)(?:\s+(?:via|on|ref)|\.| a\/c|$)',
      caseSensitive: false,
    );
    final toMatch = toPattern.firstMatch(message);
    if (toMatch != null) {
      final merchant = cleanMerchantName(toMatch.group(1)!.trim());
      if (isValidMerchantName(merchant)) {
        return merchant;
      }
    }
    
    // Pattern 3: "from MERCHANT"
    final fromPattern = RegExp(
      r'from\s+([^.\n]+?)(?:\s+(?:via|on|ref)|\.| a\/c|$)',
      caseSensitive: false,
    );
    final fromMatch = fromPattern.firstMatch(message);
    if (fromMatch != null) {
      final merchant = cleanMerchantName(fromMatch.group(1)!.trim());
      if (isValidMerchantName(merchant)) {
        return merchant;
      }
    }
    
    return null;
  }
  
  /// Extracts balance from message
  /// Override for bank-specific patterns
  double? extractBalance(String message) {
    final balancePatterns = [
      // Pattern 1: Avl Bal Rs. 1234.56
      RegExp(r'(?:avl|available)\s+bal(?:ance)?[:\s]+(?:Rs\.?|INR)\s*(\d+(?:,\d+)*(?:\.\d{2})?)', caseSensitive: false),
      // Pattern 2: Balance: Rs. 1234.56
      RegExp(r'bal(?:ance)?[:\s]+(?:Rs\.?|INR)\s*(\d+(?:,\d+)*(?:\.\d{2})?)', caseSensitive: false),
      // Pattern 3: Bal Rs. 1234.56
      RegExp(r'bal\s+Rs\.?\s*(\d+(?:,\d+)*(?:\.\d{2})?)', caseSensitive: false),
    ];
    
    for (final pattern in balancePatterns) {
      final match = pattern.firstMatch(message);
      if (match != null) {
        final balanceStr = match.group(1)!.replaceAll(',', '');
        return double.tryParse(balanceStr);
      }
    }
    
    return null;
  }
  
  /// Extracts account last 4 digits from message
  /// Override for bank-specific patterns
  String? extractAccountLast4(String message) {
    // Pattern 1: A/c XX1234 or A/c 1234
    final accountPattern = RegExp(
      r'a\/?c(?:count)?\s+(?:no\.?\s+)?(?:xx|x|\*+)?(\d{4})',
      caseSensitive: false,
    );
    final accountMatch = accountPattern.firstMatch(message);
    if (accountMatch != null) {
      return accountMatch.group(1);
    }
    
    // Pattern 2: Card XX1234 or Card 1234
    final cardPattern = RegExp(
      r'card\s+(?:no\.?\s+)?(?:xx|x|\*+)?(\d{4})',
      caseSensitive: false,
    );
    final cardMatch = cardPattern.firstMatch(message);
    if (cardMatch != null) {
      return cardMatch.group(1);
    }
    
    return null;
  }
  
  /// Extracts transaction reference number
  /// Override for bank-specific patterns
  String? extractReference(String message) {
    // Pattern 1: UPI Ref: 123456789
    final upiRefPattern = RegExp(
      r'upi\s+(?:ref|reference)[:\s]*(\d+)',
      caseSensitive: false,
    );
    final upiMatch = upiRefPattern.firstMatch(message);
    if (upiMatch != null) {
      return upiMatch.group(1);
    }
    
    // Pattern 2: Ref No: ABC123
    final refPattern = RegExp(
      r'ref(?:erence)?(?:\s+no)?[:\s]*([A-Z0-9]+)',
      caseSensitive: false,
    );
    final refMatch = refPattern.firstMatch(message);
    if (refMatch != null) {
      return refMatch.group(1);
    }
    
    return null;
  }
  
  /// Extracts available credit limit for credit cards
  /// Override for bank-specific patterns
  double? extractAvailableLimit(String message) {
    final limitPatterns = [
      // Available limit: Rs.12345.00 or Available limit Rs.12345
      RegExp(r'available\s+limit\s*:?\s*(?:Rs\.?|INR)\s*(\d+(?:,\d+)*(?:\.\d{2})?)', caseSensitive: false),
      // Avl Lmt Rs.12345 or Avl Lmt: Rs.12345
      RegExp(r'avl\s+lmt\s*:?\s*(?:Rs\.?|INR)\s*(\d+(?:,\d+)*(?:\.\d{2})?)', caseSensitive: false),
      // Credit limit patterns
      RegExp(r'(?:credit\s+)?limit\s*:?\s*(?:is\s+)?(?:Rs\.?|INR)\s*(\d+(?:,\d+)*(?:\.\d{2})?)', caseSensitive: false),
    ];
    
    for (final pattern in limitPatterns) {
      final match = pattern.firstMatch(message);
      if (match != null) {
        final limitStr = match.group(1)!.replaceAll(',', '');
        return double.tryParse(limitStr);
      }
    }
    
    return null;
  }
  
  /// Extracts currency from message (defaults to bank's currency)
  /// Override for multi-currency support
  String? extractCurrency(String message) {
    // Try to find 3-letter currency codes
    final currencyPattern = RegExp(
      r'\b([A-Z]{3})\s+[\d,]+',
      caseSensitive: false,
    );
    final match = currencyPattern.firstMatch(message);
    if (match != null) {
      final currency = match.group(1)!.toUpperCase();
      // Common currency codes
      if (['INR', 'USD', 'EUR', 'GBP', 'AED', 'SGD', 'NPR'].contains(currency)) {
        return currency;
      }
    }
    return null;
  }
  
  /// Extracts source account for transfers
  /// Override for bank-specific patterns
  String? extractFromAccount(String message) {
    return null; // Base implementation - override in specific parsers
  }
  
  /// Extracts destination account for transfers
  /// Override for bank-specific patterns
  String? extractToAccount(String message) {
    return null; // Base implementation - override in specific parsers
  }
  
  // ==========================================================================
  // HELPER METHODS (Can be overridden but usually used as-is)
  // ==========================================================================
  
  /// Cleans merchant name by removing common suffixes and noise
  String cleanMerchantName(String merchant) {
    String cleaned = merchant.trim();
    
    // Remove common company suffixes
    cleaned = cleaned.replaceAll(RegExp(r'\s*(Private|Pvt\.?|Ltd\.?|Limited|Inc\.?|LLC|LLP).*$', caseSensitive: false), '');
    
    // Remove trailing numbers
    cleaned = cleaned.replaceAll(RegExp(r'\s*\d+$'), '');
    
    // Remove UPI reference patterns
    cleaned = cleaned.replaceAll(RegExp(r'@\w+'), ''); // Remove @okaxis, @paytm, etc.
    cleaned = cleaned.replaceAll(RegExp(r'\d{10,}'), ''); // Remove phone numbers
    
    // Remove date patterns (DD-MM-YYYY, DD/MM/YYYY)
    cleaned = cleaned.replaceAll(RegExp(r'\d{1,2}[-/]\d{1,2}[-/]\d{2,4}'), '');
    
    // Remove excessive whitespace
    cleaned = cleaned.replaceAll(RegExp(r'\s+'), ' ').trim();
    
    return cleaned;
  }
  
  /// Validates if merchant name is meaningful
  bool isValidMerchantName(String merchant) {
    if (merchant.isEmpty || merchant.length < 3) {
      return false;
    }
    
    // Must contain at least one letter
    if (!RegExp(r'[A-Za-z]').hasMatch(merchant)) {
      return false;
    }
    
    // Skip generic terms
    final genericTerms = ['upi', 'atm', 'a/c', 'account', 'card'];
    final lowerMerchant = merchant.toLowerCase();
    if (genericTerms.any((term) => lowerMerchant == term)) {
      return false;
    }
    
    return true;
  }
  
  /// Detects if transaction is from a credit card
  bool detectIsCard(String message) {
    final lowerMessage = message.toLowerCase();
    return lowerMessage.contains('card') ||
           lowerMessage.contains('credit card') ||
           lowerMessage.contains('debit card');
  }
  
  /// Filters out non-transaction messages (OTP, promotional, statements)
  bool isTransactionMessage(String message) {
    final lowerMessage = message.toLowerCase();
    
    // Skip OTP messages
    if (lowerMessage.contains('otp') ||
        lowerMessage.contains('one time password') ||
        lowerMessage.contains('verification code') ||
        lowerMessage.contains('verify')) {
      return false;
    }
    
    // Skip promotional messages
    if (lowerMessage.contains('offer') ||
        lowerMessage.contains('discount') ||
        lowerMessage.contains('apply now') ||
        lowerMessage.contains('click here') ||
        lowerMessage.contains('download app')) {
      return false;
    }
    
    // Skip statement messages
    if (lowerMessage.contains('statement is ready') ||
        lowerMessage.contains('statement generated') ||
        lowerMessage.contains('bill generated') ||
        lowerMessage.contains('statement available')) {
      return false;
    }
    
    // Skip mandate/autopay setup messages (not actual transactions)
    // But allow mandate creation messages that show amount being set up
    final hasMandateWithAmount = lowerMessage.contains('mandate') && 
        (lowerMessage.contains('mandate for') && lowerMessage.contains('rs') ||
         lowerMessage.contains('successfully created'));
    
    if (lowerMessage.contains('mandate') && 
        !lowerMessage.contains('mandate executed') &&
        !lowerMessage.contains('mandate debited') &&
        !hasMandateWithAmount &&
        !lowerMessage.contains('mandate created')) {
      return false;
    }
    
    // Allow mandates with amount (created or set up)
    if (hasMandateWithAmount) {
      return true;
    }
    
    // Allow money request notifications
    if (lowerMessage.contains('requested money from you')) {
      return true;
    }
    
    // Allow UPI transfer "sent" messages
    if (lowerMessage.contains('amt sent') || lowerMessage.contains('amount sent')) {
      return true;
    }
    
    // Must contain transaction keywords
    final transactionKeywords = [
      'debited', 'credited', 'withdrawn', 'deposited',
      'spent', 'received', 'transferred', 'paid',
      'purchase', 'refund', 'cashback', 'used', 'sent'
    ];
    
    return transactionKeywords.any((keyword) => lowerMessage.contains(keyword));
  }
  
  /// Checks if transaction is investment-related
  bool isInvestmentTransaction(String lowerMessage) {
    final investmentKeywords = [
      'mutual fund', 'mf', 'sip', 'systematic investment',
      'equity', 'stock', 'share', 'securities',
      'zerodha', 'groww', 'kuvera', 'coin', 'et money',
      'paytm money', 'upstox', 'angel one', '5paisa',
      'ipo', 'folio', 'demat', 'nse', 'bse', 'cdsl', 'nsdl'
    ];
    
    return investmentKeywords.any((keyword) => lowerMessage.contains(keyword));
  }
}

/// Factory for managing and routing to bank-specific parsers
class BankParserFactory {
  static final List<FinancialTextParser> _parsers = [];
  
  /// Register a bank parser
  static void registerParser(FinancialTextParser parser) {
    _parsers.add(parser);
  }
  
  /// Find appropriate parser for given sender
  static FinancialTextParser? findParser(String sender) {
    for (final parser in _parsers) {
      if (parser.canHandle(sender)) {
        return parser;
      }
    }
    return null;
  }
  
  /// Parse financial text using appropriate bank parser
  static ParsedTransaction? parse(String messageBody, String sender, DateTime timestamp) {
    final parser = findParser(sender);
    if (parser == null) {
      return null;
    }
    return parser.parse(messageBody, sender, timestamp);
  }
  
  /// Get all registered parsers
  static List<FinancialTextParser> getAllParsers() => List.unmodifiable(_parsers);
  
  /// Clear all registered parsers (for testing)
  static void clearParsers() {
    _parsers.clear();
  }
}
