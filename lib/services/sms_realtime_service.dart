import 'package:flutter/foundation.dart' hide Category;
import 'package:flutter/services.dart';
import '../database/transaction_repository.dart';
import '../models/transaction.dart';
import '../utils/constants.dart';
import 'hybrid_parser_service.dart';

/// Service for handling real-time SMS reception and automatic transaction creation
class SmsRealtimeService {
  static final SmsRealtimeService _instance = SmsRealtimeService._internal();
  factory SmsRealtimeService() => _instance;
  SmsRealtimeService._internal();

  static const platform = MethodChannel('com.mftracker.app/sms');
  
  final _hybridParser = HybridParserService();
  bool _isInitialized = false;
  
  // Callback when a new transaction is detected from SMS
  Function(Transaction)? onTransactionDetected;
  
  /// Initialize the real-time SMS service
  Future<void> initialize() async {
    if (_isInitialized) {
      if (kDebugMode) {
        print('[SmsRealtimeService] Already initialized');
      }
      return;
    }
    
    if (kDebugMode) {
      print('[SmsRealtimeService] Initializing...');
    }
    
    // Initialize parser
    await _hybridParser.initialize();
    
    // Set up method call handler for incoming SMS
    platform.setMethodCallHandler(_handleMethodCall);
    
    _isInitialized = true;
    
    if (kDebugMode) {
      print('[SmsRealtimeService] ✅ Real-time SMS detection active');
    }
  }
  
  /// Handle method calls from Android
  Future<dynamic> _handleMethodCall(MethodCall call) async {
    if (kDebugMode) {
      print('[SmsRealtimeService] Received call: ${call.method}');
    }
    
    switch (call.method) {
      case 'onSmsReceived':
        await _handleIncomingSms(call.arguments);
        break;
      default:
        if (kDebugMode) {
          print('[SmsRealtimeService] Unknown method: ${call.method}');
        }
    }
  }
  
  /// Handle incoming SMS and process it through ML pipeline
  Future<void> _handleIncomingSms(dynamic arguments) async {
    try {
      if (arguments is! Map) {
        if (kDebugMode) {
          print('[SmsRealtimeService] Invalid arguments type');
        }
        return;
      }
      
      final data = Map<String, dynamic>.from(arguments);
      final sender = data['address'] as String;
      final body = data['body'] as String;
      final timestamp = data['date'] as int;
      
      if (kDebugMode) {
        print('[SmsRealtimeService] 📱 New SMS from $sender');
        print('[SmsRealtimeService] Processing through ML pipeline...');
      }
      
      // Parse SMS using hybrid parser (ML classifier + NER + rule-based)
      final result = await _hybridParser.parseSMS(sender, body);
      
      // Check if it's a rejected SMS (not financial)
      if (result.source == 'rejected') {
        if (kDebugMode) {
          print('[SmsRealtimeService] ❌ Not a financial SMS (rejected by classifier)');
        }
        return;
      }
      
      if (kDebugMode) {
        print('[SmsRealtimeService] ✅ Financial SMS detected!');
        print('[SmsRealtimeService] Type: ${result.type}');
        print('[SmsRealtimeService] Amount: ₹${result.amount}');
        print('[SmsRealtimeService] Merchant: ${result.merchant}');
        print('[SmsRealtimeService] Source: ${result.source}');
      }
      
      // Create transaction object
      final now = DateTime.now();
      final transactionId = 'txn_${DateTime.now().millisecondsSinceEpoch}';
      
      final transaction = Transaction(
        id: transactionId,
        amount: result.amount ?? 0.0,
        type: result.type ?? TransactionType.debit,
        category: Category.others, // Default category
        categorizationMethod: CategorizationMethod.machineLearning,
        description: result.merchant ?? 'Transaction',
        timestamp: DateTime.fromMillisecondsSinceEpoch(timestamp),
        accountId: 'default', // Default account
        merchantName: result.merchant,
        accountNumber: result.accountNumber,
        paymentMethod: result.paymentMethod,
        balanceAfter: null, // Not available in HybridParseResult
        upiId: result.upiId,
        smsBody: body,
        smsSender: sender,
        smsTimestamp: DateTime.fromMillisecondsSinceEpoch(timestamp),
        tags: [],
        isRecurring: false,
        createdAt: now,
        updatedAt: now,
      );
      
      // Save to database using repository
      final repository = TransactionRepository();
      await repository.insert(transaction);
      
      if (kDebugMode) {
        print('[SmsRealtimeService] 💾 Transaction saved with ID: $transactionId');
      }
      
      // Notify listeners (update UI)
      onTransactionDetected?.call(transaction);
      
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('[SmsRealtimeService] ❌ Error processing SMS: $e');
        print('[SmsRealtimeService] Stack trace: $stackTrace');
      }
    }
  }
  
  /// Disable real-time SMS detection
  void dispose() {
    _isInitialized = false;
    if (kDebugMode) {
      print('[SmsRealtimeService] Disposed');
    }
  }
}
