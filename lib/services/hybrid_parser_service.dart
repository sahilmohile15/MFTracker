import '../parsers/financial_text_parser.dart' as parser;
import '../services/platform_ml_service.dart';
import '../utils/constants.dart';

/// Result of hybrid parsing (ML + Rule-based)
class HybridParseResult {
  final double? amount;
  final TransactionType? type;
  final String? merchant;
  final String? bank;
  final String? paymentMethod;
  final String? accountNumber;
  final String? upiId;
  final String description;
  final String source; // 'ml', 'rule-based', 'hybrid', or 'rejected'
  final double confidence;

  HybridParseResult({
    this.amount,
    this.type,
    this.merchant,
    this.bank,
    this.paymentMethod,
    this.accountNumber,
    this.upiId,
    required this.description,
    required this.source,
    this.confidence = 0.0,
  });

  @override
  String toString() {
    return 'HybridParseResult(amount: $amount, type: $type, merchant: $merchant, '
        'bank: $bank, paymentMethod: $paymentMethod, source: $source, '
        'confidence: ${(confidence * 100).toStringAsFixed(1)}%)';
  }
}

/// Hybrid parser combining ML classifier + NER and rule-based parsing
class HybridParserService {
  static final HybridParserService _instance = HybridParserService._internal();
  factory HybridParserService() => _instance;
  HybridParserService._internal();

  final PlatformMLService _mlParser = PlatformMLService();
  bool _mlEnabled = true;

  /// Initialize the hybrid parser
  Future<void> initialize() async {
    try {
      await _mlParser.initialize();
      _mlEnabled = true;
      print('[HybridParser] ML models (classifier + NER) enabled via platform channel');
    } catch (e) {
      print('[HybridParser] ML models not available, using rule-based only: $e');
      _mlEnabled = false;
    }
  }

  /// Parse SMS using hybrid approach (ML Classifier + NER + Rule-based)
  Future<HybridParseResult> parseSMS(String smsText, String sender) async {
    print('[HybridParser] Parsing SMS from $sender');
    
    // FIRST: Use ML classifier to check if SMS is financial
    if (_mlEnabled) {
      try {
        final isFinancial = await _mlParser.isFinancialSMS(smsText);
        if (!isFinancial) {
          print('[HybridParser] SMS rejected by ML classifier (non-financial)');
          return HybridParseResult(
            description: smsText,
            source: 'rejected',
            confidence: 0.0,
          );
        }
        print('[HybridParser] SMS classified as financial by ML');
      } catch (e) {
        print('[HybridParser] ML classifier error: $e, falling back to rule-based');
      }
    }
    
    // Always run rule-based parser as baseline
    final ruleBased = parser.BankParserFactory.parse(smsText, sender, DateTime.now());
    
    // Try ML NER if enabled to extract entities
    Map<String, dynamic>? mlOutput;
    if (_mlEnabled) {
      try {
        mlOutput = await _mlParser.extractEntities(smsText);
      } catch (e) {
        print('[HybridParser] ML NER extraction failed: $e');
      }
    }
    
    // Merge results with ML priority, rule-based fallback
    return _mergeResults(ruleBased, mlOutput, smsText, sender);
  }

  /// Merge ML and rule-based results intelligently
  HybridParseResult _mergeResults(
    parser.ParsedTransaction? ruleBased,
    Map<String, dynamic>? mlOutput,
    String originalText,
    String sender,
  ) {
    String source = 'rule-based';
    double confidence = ruleBased != null ? 0.8 : 0.5;
    
    // Extract amount - prefer ML if available and valid
    double? amount = ruleBased?.amount;
    if (mlOutput != null && mlOutput['amount'] != null) {
      try {
        final mlAmountStr = mlOutput['amount'].toString().replaceAll(',', '');
        final mlAmount = double.parse(mlAmountStr);
        if (mlAmount > 0) {
          amount = mlAmount;
          source = 'hybrid';
          confidence = 0.85; // ML + rule-based confidence
        }
      } catch (e) {
        // Keep rule-based amount
      }
    }
    
    // Extract transaction type - prefer ML if available
    TransactionType? type;
    if (mlOutput != null && mlOutput['transactionType'] != null) {
      final mlType = mlOutput['transactionType'].toString().toLowerCase();
      if (mlType.contains('debit')) {
        type = TransactionType.debit;
        source = 'hybrid';
      } else if (mlType.contains('credit')) {
        type = TransactionType.credit;
        source = 'hybrid';
      }
    }
    
    // Fallback to rule-based type
    if (type == null && ruleBased != null) {
      type = ruleBased.isDebit ? TransactionType.debit : TransactionType.credit;
    }
    
    // Extract merchant - prefer ML, fallback to rule-based
    String? merchant = mlOutput != null && mlOutput['merchant'] != null 
        ? mlOutput['merchant'].toString().trim() 
        : null;
    if (merchant == null || merchant.isEmpty) {
      // Use rule-based merchant if available
      merchant = ruleBased?.merchant?.trim();
    }
    
    // Ensure merchant is populated
    if (merchant == null || merchant.isEmpty) {
      merchant = _extractMerchantFallback(originalText, sender);
    }
    
    // Extract bank - prefer ML
    String? bank = mlOutput != null && mlOutput['bank'] != null 
        ? mlOutput['bank'].toString().trim() 
        : null;
    if (bank == null || bank.isEmpty) {
      // Use rule-based bank name
      bank = ruleBased?.bankName ?? _extractBankFromSender(sender);
    }
    
    // Extract payment method - prefer ML
    String? paymentMethod = mlOutput != null && mlOutput['paymentMethod'] != null 
        ? mlOutput['paymentMethod'].toString().trim() 
        : null;
    if (paymentMethod == null || paymentMethod.isEmpty) {
      paymentMethod = _extractPaymentMethod(originalText);
    }
    
    // Extract account number from rule-based
    String? accountNumber = ruleBased?.accountLast4;
    
    // Extract UPI ID (not in rule-based parser, extract from text)
    String? upiId = _extractUpiId(originalText);
    
    // Build description with merchant name
    String description = ruleBased?.smsBody ?? originalText;
    if (!description.contains(merchant)) {
      description = '$merchant - $description';
    }
    
    print('[HybridParser] Result: amount=$amount, type=$type, merchant=$merchant, '
        'bank=$bank, paymentMethod=$paymentMethod, source=$source');
    
    return HybridParseResult(
      amount: amount,
      type: type,
      merchant: merchant,
      bank: bank,
      paymentMethod: paymentMethod,
      accountNumber: accountNumber,
      upiId: upiId,
      description: description,
      source: source,
      confidence: confidence,
    );
  }
  
  /// Extract UPI ID from text
  String? _extractUpiId(String text) {
    final upiPattern = RegExp(r'([A-Za-z0-9._-]+@[A-Za-z0-9._-]+)', caseSensitive: false);
    final match = upiPattern.firstMatch(text);
    return match?.group(1);
  }

  /// Fallback merchant extraction with PennywiseAI-inspired patterns
  String _extractMerchantFallback(String text, String sender) {
    // Pattern 1: UPI VPA extraction (merchant@bank)
    final upiVpaPattern = RegExp(r'(?:to|at|from|VPA)\s+([A-Za-z0-9._-]+@[A-Za-z]+)', caseSensitive: false);
    var match = upiVpaPattern.firstMatch(text);
    if (match != null) {
      final vpa = match.group(1)!;
      // Extract merchant name from VPA (before @)
      final merchantPart = vpa.split('@')[0];
      return _cleanMerchantName(merchantPart.replaceAll(RegExp(r'[._-]'), ' '));
    }
    
    // Pattern 2: Payment gateway patterns (GPay, PhonePe, Paytm, etc.)
    final paymentGatewayPattern = RegExp(
      r'(?:via|using|through|on)\s+(Google\s*Pay|GPay|PhonePe|Paytm|Amazon\s*Pay|Mobikwik|Freecharge)',
      caseSensitive: false
    );
    match = paymentGatewayPattern.firstMatch(text);
    if (match != null) {
      return match.group(1)!;
    }
    
    // Pattern 3: Merchant name patterns (sent to X, paid to X, at X)
    final merchantPatterns = [
      RegExp(r'(?:sent to|paid to|payment to|transferred to)\s+([A-Z][A-Za-z\s]+?)(?:\s+via|\s+on|\s+Rs|INR|₹|\s+for|$)', caseSensitive: false),
      RegExp(r'(?:at|from)\s+([A-Z][A-Z\s]+?)(?:\s+on|\s+via|Rs|INR|₹|$)', caseSensitive: false),
      RegExp(r'(?:merchant|beneficiary):\s*([A-Za-z0-9\s]+?)(?:\s+|$)', caseSensitive: false),
    ];
    
    for (final pattern in merchantPatterns) {
      match = pattern.firstMatch(text);
      if (match != null) {
        final merchant = match.group(1)?.trim();
        if (merchant != null && merchant.isNotEmpty && merchant.length > 2) {
          return _cleanMerchantName(merchant);
        }
      }
    }
    
    // Pattern 4: Extract any capitalized word sequence (likely merchant name)
    final capitalizedPattern = RegExp(r'\b([A-Z][A-Za-z]*(?:\s+[A-Z][A-Za-z]*)*)\b');
    final capitalizedMatches = capitalizedPattern.allMatches(text);
    for (final match in capitalizedMatches) {
      final word = match.group(1)!;
      if (word.length > 3 && !_isBankingTerm(word)) {
        return _cleanMerchantName(word);
      }
    }
    
    // Last resort: use cleaned sender
    return _cleanMerchantName(sender);
  }

  /// Check if word is a common banking term
  bool _isBankingTerm(String word) {
    final terms = [
      'DEBITED', 'CREDITED', 'ACCOUNT', 'BANK', 'UPI', 'TRANSACTION',
      'PAYMENT', 'TRANSFER', 'BALANCE', 'AVAILABLE', 'INFO', 'SMS',
      'YOUR', 'HAS', 'BEEN', 'THE', 'FOR', 'AND', 'VIA', 'ON',
      'DATE', 'TIME', 'AMOUNT', 'TOTAL', 'CARD', 'ATM', 'WITHDRAW',
    ];
    return terms.contains(word.toUpperCase());
  }

  /// Clean merchant name
  String _cleanMerchantName(String name) {
    return name
        .trim()
        .replaceAll(RegExp(r'[^A-Za-z0-9\s@._-]'), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  /// Extract bank from sender
  String? _extractBankFromSender(String sender) {
    final bankMap = {
      'SBI': ['SBI', 'SBIINB', 'SBIPSG'],
      'HDFC': ['HDFC', 'HDFCBK'],
      'ICICI': ['ICICI', 'ICICIB'],
      'AXIS': ['AXIS', 'AXISBK'],
      'KOTAK': ['KOTAK', 'KOTAKB'],
      'PNB': ['PNB', 'PNBSMS'],
      'BOB': ['BOB', 'BOBCARD'],
      'CANARA': ['CANARA', 'CANBK'],
      'IDBI': ['IDBI'],
      'YES': ['YESBNK'],
      'INDUSIND': ['INDUS'],
    };
    
    final upperSender = sender.toUpperCase();
    for (final entry in bankMap.entries) {
      for (final code in entry.value) {
        if (upperSender.contains(code)) {
          return entry.key;
        }
      }
    }
    
    return null;
  }

  /// Extract payment method from text
  String? _extractPaymentMethod(String text) {
    final upper = text.toUpperCase();
    
    if (upper.contains('UPI')) return 'UPI';
    if (upper.contains('CARD') || upper.contains('DEBIT CARD') || upper.contains('CREDIT CARD')) {
      return 'CARD';
    }
    if (upper.contains('ATM')) return 'ATM';
    if (upper.contains('NEFT') || upper.contains('RTGS') || upper.contains('IMPS')) {
      return upper.contains('NEFT') ? 'NEFT' : (upper.contains('RTGS') ? 'RTGS' : 'IMPS');
    }
    if (upper.contains('NETBANKING') || upper.contains('NET BANKING')) return 'NetBanking';
    
    return null;
  }

  /// Dispose resources
  void dispose() {
    _mlParser.dispose();
  }
}
