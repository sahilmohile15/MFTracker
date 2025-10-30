import 'package:flutter/material.dart';
import 'services/hybrid_parser_service.dart';

/// Test screen for SMS detection with ML classifier
class TestSmsDetectionScreen extends StatefulWidget {
  const TestSmsDetectionScreen({super.key});

  @override
  State<TestSmsDetectionScreen> createState() => _TestSmsDetectionScreenState();
}

class _TestSmsDetectionScreenState extends State<TestSmsDetectionScreen> {
  final HybridParserService _hybridParser = HybridParserService();
  bool _isInitialized = false;
  bool _isLoading = false;
  final List<Map<String, dynamic>> _testResults = [];

  final List<Map<String, String>> _testSamples = [
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
      'sender': 'XX-PAYTM',
      'body': 'Rs.250 debited from Paytm Wallet for mobile recharge',
      'description': 'Paytm wallet debit'
    },
    {
      'sender': 'XX-AXIS',
      'body': 'Your Credit Card XX9876 has been used for Rs.5000 at FLIPKART',
      'description': 'Axis credit card transaction'
    },
    {
      'sender': 'XX-HDFCBK',
      'body': 'Your OTP for login is 123456. Valid for 10 minutes.',
      'description': 'OTP message (should reject)'
    },
    {
      'sender': 'XX-ICICIB-P',
      'body': 'Get 50% cashback on next transaction! Limited time offer.',
      'description': 'Promotional message (should reject)'
    },
    {
      'sender': 'XX-SBI',
      'body': 'Your account has been credited with interest of Rs.145.50',
      'description': 'Interest credit'
    },
  ];

  @override
  void initState() {
    super.initState();
    _initializeParser();
  }

  Future<void> _initializeParser() async {
    setState(() => _isLoading = true);
    try {
      await _hybridParser.initialize();
      setState(() {
        _isInitialized = true;
        _isLoading = false;
      });
      print('[Test] ✅ Parser initialized successfully');
    } catch (e) {
      setState(() {
        _isInitialized = false;
        _isLoading = false;
      });
      print('[Test] ❌ Parser initialization failed: $e');
    }
  }

  Future<void> _runTests() async {
    if (!_isInitialized) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Parser not initialized')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _testResults.clear();
    });

    print('\n=== Running SMS Detection Tests ===\n');

    for (var i = 0; i < _testSamples.length; i++) {
      final sample = _testSamples[i];
      final sender = sample['sender']!;
      final body = sample['body']!;
      final description = sample['description']!;

      print('Test ${i + 1}: $description');
      print('Sender: $sender');
      print('Body: ${body.substring(0, body.length > 60 ? 60 : body.length)}${body.length > 60 ? "..." : ""}');

      try {
        final result = await _hybridParser.parseSMS(body, sender);

        final testResult = <String, dynamic>{
          'description': description,
          'sender': sender,
          'body': body,
          'isFinancial': result.source != 'rejected',
          'source': result.source,
          'confidence': result.confidence,
          'amount': result.amount,
          'type': result.type,
          'merchant': result.merchant,
          'bank': result.bank,
        };

        if (result.source == 'rejected') {
          print('Result: ❌ REJECTED (non-financial)');
        } else {
          print('Result: ✅ FINANCIAL DETECTED');
          print('  Source: ${result.source}');
          print('  Confidence: ${(result.confidence * 100).toStringAsFixed(1)}%');
          if (result.amount != null) {
            print('  Amount: ₹${result.amount}');
            print('  Type: ${result.type}');
            print('  Merchant: ${result.merchant ?? "N/A"}');
          }
        }

        setState(() => _testResults.add(testResult));
      } catch (e) {
        print('Result: ❌ ERROR - $e');
        setState(() => _testResults.add({
          'description': description,
          'sender': sender,
          'body': body,
          'error': e.toString(),
        }));
      }

      print('─' * 80);
    }

    setState(() => _isLoading = false);
    print('\n=== Test Complete ===');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SMS Detection Test'),
      ),
      body: Column(
        children: [
          if (!_isInitialized)
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.orange.shade100,
              child: Row(
                children: [
                  Icon(Icons.warning, color: Colors.orange.shade800),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text('ML models not initialized. Initializing...'),
                  ),
                ],
              ),
            ),
          if (_isInitialized)
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.green.shade100,
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green.shade800),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text('ML models ready. Tap "Run Tests" to start.'),
                  ),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton.icon(
              onPressed: _isInitialized && !_isLoading ? _runTests : null,
              icon: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.play_arrow),
              label: Text(_isLoading ? 'Running Tests...' : 'Run Tests (${_testSamples.length} samples)'),
            ),
          ),
          Expanded(
            child: _testResults.isEmpty
                ? const Center(
                    child: Text('No test results yet. Run tests to see results.'),
                  )
                : ListView.builder(
                    itemCount: _testResults.length,
                    itemBuilder: (context, index) {
                      final result = _testResults[index];
                      final isFinancial = result['isFinancial'] == true;
                      final hasError = result.containsKey('error');

                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: hasError
                                ? Colors.red
                                : isFinancial
                                    ? Colors.green
                                    : Colors.orange,
                            child: Icon(
                              hasError
                                  ? Icons.error
                                  : isFinancial
                                      ? Icons.check
                                      : Icons.block,
                              color: Colors.white,
                            ),
                          ),
                          title: Text(result['description'] ?? 'Unknown'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Sender: ${result['sender']}'),
                              const SizedBox(height: 4),
                              if (hasError)
                                Text(
                                  'Error: ${result['error']}',
                                  style: const TextStyle(color: Colors.red),
                                )
                              else if (isFinancial) ...[
                                Text('✅ Financial SMS (${result['source']})'),
                                Text('Confidence: ${(result['confidence'] * 100).toStringAsFixed(1)}%'),
                                if (result['amount'] != null)
                                  Text('Amount: ₹${result['amount']} (${result['type']})'),
                                if (result['merchant'] != null)
                                  Text('Merchant: ${result['merchant']}'),
                              ] else
                                const Text('❌ Non-financial (Rejected)'),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
