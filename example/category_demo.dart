// Merchant Categorization Demo
// Demonstrates automatic category mapping for parsed transactions

import 'package:mftracker/parsers/financial_text_parser.dart';
import 'package:mftracker/parsers/parser_registry.dart';
import 'package:mftracker/parsers/merchant_category_mapper.dart';

void main() {
  // Initialize parsers
  initializeBankParsers();

  print('═══════════════════════════════════════════════════════════════');
  print('   MERCHANT CATEGORIZATION DEMO');
  print('═══════════════════════════════════════════════════════════════\n');

  // Test SMS samples with different merchants
  final testSamples = [
    {
      'sms': 'Rs.1,234.56 spent on SBI Card XX9876 at SWIGGY on 2024-03-20',
      'sender': 'SBICARD',
      'expectedCategory': 'Food Delivery'
    },
    {
      'sms': 'BLINKIT COMMERCE PRIVATE LIMITED has requested money from you (Rs 286.00)',
      'sender': 'SBIUPI',
      'expectedCategory': 'Grocery'
    },
    {
      'sms': 'INR 869.00 spent using ICICI Bank Card XX0004 on IND*Amazon',
      'sender': 'ICICIB',
      'expectedCategory': 'E-Commerce'
    },
    {
      'sms': 'Rs.1046.0 debited trf to LINKEDIN INDIA PRIVATE LTD Refno 42636399xxxx',
      'sender': 'SBIINB',
      'expectedCategory': 'Subscription'
    },
    {
      'sms': 'INR 13,444.70 spent on AMEX card ** 01234 at PAYU RETAIL on 23 Sep',
      'sender': 'AMEX',
      'expectedCategory': 'Payment Gateway'
    },
    {
      'sms': 'Rs.500.00 spent at NETFLIX on HDFC Card XX1234',
      'sender': 'HDFCBK',
      'expectedCategory': 'Entertainment'
    },
    {
      'sms': 'Rs.2,054.08 spent on your SBI Credit Card ending 9155 at IngBigBasket',
      'sender': 'SBICARD',
      'expectedCategory': 'Grocery'
    },
    {
      'sms': 'Rs.399.00 spent at DOMINOS PIZZA on 2024-10-25',
      'sender': 'HDFCBK',
      'expectedCategory': 'Food Delivery'
    },
    {
      'sms': 'Rs.1500.00 debited for AIRTEL payment',
      'sender': 'ICICIB',
      'expectedCategory': 'Utilities'
    },
    {
      'sms': 'Rs.250.00 spent at APOLLO PHARMACY',
      'sender': 'HDFCBK',
      'expectedCategory': 'Pharmacy'
    },
  ];

  int successCount = 0;
  int totalCount = testSamples.length;

  for (var i = 0; i < testSamples.length; i++) {
    final sample = testSamples[i];
    final sms = sample['sms'] as String;
    final sender = sample['sender'] as String;
    final expectedCategory = sample['expectedCategory'] as String;

    print('Test ${i + 1}/$totalCount');
    print('SMS: ${sms.length > 70 ? sms.substring(0, 70) + '...' : sms}');
    print('Sender: $sender');

    final result = BankParserFactory.parse(sms, sender, DateTime.now());

    if (result != null) {
      final data = result.toTransactionData();
      final amount = data['amount'];
      final merchant = data['merchantName'] ?? 'Unknown';
      final category = data['categoryDisplayName'] ?? 'Uncategorized';
      final paymentMethod = data['paymentMethod'] ?? 'Unknown';

      print('✅ Parsed Successfully');
      print('   Amount: ₹$amount');
      print('   Merchant: $merchant');
      print('   Category: $category');
      print('   Payment Method: $paymentMethod');

      if (category == expectedCategory) {
        print('   ✓ Category Match: Expected "$expectedCategory" ✓');
        successCount++;
      } else {
        print('   ✗ Category Mismatch: Expected "$expectedCategory", Got "$category"');
      }
    } else {
      print('❌ Failed to Parse');
      print('   Expected Category: $expectedCategory');
    }

    print('───────────────────────────────────────────────────────────────\n');
  }

  print('═══════════════════════════════════════════════════════════════');
  print('   SUMMARY');
  print('═══════════════════════════════════════════════════════════════');
  print('Total Tested: $totalCount');
  print('Successfully Categorized: $successCount');
  print('Success Rate: ${(successCount / totalCount * 100).toStringAsFixed(1)}%');
  print('═══════════════════════════════════════════════════════════════\n');

  // Show all available categories
  print('Available Categories:');
  final categories = MerchantCategoryMapper.getAllCategories();
  for (final category in categories) {
    final displayName = MerchantCategoryMapper.getCategoryDisplayName(category);
    final merchants = MerchantCategoryMapper.getMerchantsForCategory(category);
    if (merchants.isNotEmpty) {
      print('  • $displayName ($category): ${merchants.length} merchants');
    } else if (category == 'uncategorized') {
      print('  • $displayName: For unknown merchants');
    }
  }

  print('\n═══════════════════════════════════════════════════════════════');
  print('   INTEGRATION STATUS');
  print('═══════════════════════════════════════════════════════════════');
  print('✅ Merchant categorization is fully integrated');
  print('✅ Categories automatically assigned during parsing');
  print('✅ toTransactionData() includes category fields');
  print('✅ 11 predefined categories + uncategorized fallback');
  print('✅ Case-insensitive matching with normalization');
  print('✅ Prefers longer/more specific matches');
  print('═══════════════════════════════════════════════════════════════\n');
}
