import 'lib/services/hybrid_parser_service.dart';
import 'lib/services/sms_identification_service.dart';

void main() async {
  print('=== SMS Detection Test ===\n');
  
  final hybridParser = HybridParserService();
  final smsIdentification = SmsIdentificationService();
  
  // Initialize ML models
  print('Initializing ML models...');
  try {
    await hybridParser.initialize();
    print('✅ ML models initialized\n');
  } catch (e) {
    print('❌ ML initialization failed: $e\n');
  }
  
  // Test SMS samples
  final testSamples = [
    {
      'sender': 'XX-HDFCBK',
      'body': 'Rs 1,499.00 debited from A/c XX1234 on 15-Jan-25 for Amazon. Avbl Bal: Rs 5,000.00',
      'description': 'HDFC debit transaction'
    },
    {
      'sender': 'XX-ICICIB',
      'body': 'INR 2500.00 credited to A/c XX5678 on 20-Jan-25. Available Balance: INR 15000.00',
      'description': 'ICICI credit transaction'
    },
    {
      'sender': 'GPAY',
      'body': 'You paid Rs.399 to Swiggy using Google Pay UPI',
      'description': 'Google Pay UPI payment'
    },
    {
      'sender': 'XX-HDFCBK',
      'body': 'Your OTP for login is 123456. Valid for 10 minutes.',
      'description': 'OTP message (should be rejected)'
    },
    {
      'sender': 'XX-ICICIB-P',
      'body': 'Get 50% cashback on next transaction! Limited time offer.',
      'description': 'Promotional message (should be rejected)'
    },
  ];
  
  print('Testing ${testSamples.length} SMS samples:\n');
  print('=' * 80);
  
  for (var i = 0; i < testSamples.length; i++) {
    final sample = testSamples[i];
    final sender = sample['sender'] as String;
    final body = sample['body'] as String;
    final description = sample['description'] as String;
    
    print('\nTest ${i + 1}: $description');
    print('Sender: $sender');
    print('Body: ${body.substring(0, body.length > 60 ? 60 : body.length)}${body.length > 60 ? "..." : ""}');
    print('-' * 80);
    
    // Test 1: SMS Identification Service (rule-based)
    final isFinancial = smsIdentification.identifySMS(sender, body);
    print('SMS Identification (rule-based): ${isFinancial ? "✅ PASS" : "❌ REJECT"}');
    
    // Test 2: Hybrid Parser (ML classifier + NER)
    try {
      final result = await hybridParser.parseSMS(body, sender);
      
      if (result.source == 'rejected') {
        print('Hybrid Parser (ML classifier): ❌ REJECT (non-financial)');
      } else {
        print('Hybrid Parser (ML classifier): ✅ PASS (financial)');
        print('  Source: ${result.source}');
        print('  Confidence: ${(result.confidence * 100).toStringAsFixed(1)}%');
        if (result.amount != null) {
          print('  Amount: ₹${result.amount}');
          print('  Type: ${result.type}');
          print('  Merchant: ${result.merchant ?? "N/A"}');
        }
      }
    } catch (e) {
      print('Hybrid Parser: ❌ ERROR - $e');
    }
    
    print('=' * 80);
  }
  
  print('\n=== Test Complete ===');
}
