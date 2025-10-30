import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../utils/constants.dart';
import '../models/transaction.dart';
import '../models/account.dart';
import '../database/transaction_repository.dart';
import '../database/account_repository.dart';
import '../providers/transaction_provider.dart';
import '../parsers/financial_text_parser.dart' as parser;
import '../parsers/parser_registry.dart';
import '../services/hybrid_parser_service.dart';

/// Screen for importing transactions from SMS messages
class SmsImportScreen extends ConsumerStatefulWidget {
  const SmsImportScreen({super.key});

  @override
  ConsumerState<SmsImportScreen> createState() => _SmsImportScreenState();
}

class _SmsImportScreenState extends ConsumerState<SmsImportScreen> {
  static const platform = MethodChannel('com.mftracker.app/sms');
  
  final HybridParserService _hybridParser = HybridParserService();
  
  bool _isLoading = false;
  bool _hasPermission = false;
  List<_ParsedTransaction> _parsedTransactions = [];
  Set<int> _selectedIndices = {};
  String? _errorMessage;
  
  // Statistics for SMS filtering
  int _totalSmsCount = 0;
  int _financialSmsCount = 0;
  int _transactionSmsCount = 0;

  @override
  void initState() {
    super.initState();
    print('[SMS Import Screen] Initializing...');
    _initializeParser();
    _checkPermissions();
  }
  
  Future<void> _initializeParser() async {
    print('[SMS Import Screen] Starting parser initialization...');
    try {
      await _hybridParser.initialize();
      print('[SMS Import Screen] Parser initialization complete');
    } catch (e) {
      print('[SMS Import Screen] Parser initialization failed: $e');
    }
  }

  Future<void> _checkPermissions() async {
    final status = await Permission.sms.status;
    setState(() {
      _hasPermission = status.isGranted;
    });
    
    if (_hasPermission) {
      _loadSmsMessages();
    }
  }

  Future<void> _requestPermissions() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final status = await Permission.sms.request();
      
      setState(() {
        _hasPermission = status.isGranted;
        _isLoading = false;
      });

      if (_hasPermission) {
        _loadSmsMessages();
      } else {
        setState(() {
          _errorMessage = 'SMS permission is required to import transactions from messages.';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error requesting permissions: $e';
      });
    }
  }

  Future<void> _loadSmsMessages() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _totalSmsCount = 0;
      _financialSmsCount = 0;
      _transactionSmsCount = 0;
    });

    try {
      // Get SMS from last 90 days (3 months)
      final ninetyDaysAgo = DateTime.now().subtract(const Duration(days: 90)).millisecondsSinceEpoch;
      
      final List<dynamic> messages = await platform.invokeMethod('getAllSms', {
        'startDate': ninetyDaysAgo,
      });

      _totalSmsCount = messages.length;
      
      print('[SMS Import] Found $_totalSmsCount SMS messages from last 90 days');

      // Parse messages - let ML classifier do primary filtering
      final parsed = <_ParsedTransaction>[];
      for (var i = 0; i < messages.length; i++) {
        final msg = messages[i] as Map;
        final address = msg['address'] as String? ?? '';
        final body = msg['body'] as String? ?? '';
        final date = msg['date'] as int? ?? 0;
        
        if (i < 5) {
          // Log first 5 SMS for debugging
          print('[SMS Import] Sample ${i + 1}: From=$address, Body=${body.substring(0, body.length > 50 ? 50 : body.length)}...');
        }
        
        // Use hybrid parser with ML classifier for filtering
        final transaction = await _parseTransaction(address, body, date, i);
        if (transaction != null) {
          _financialSmsCount++;
          _transactionSmsCount++;
          parsed.add(transaction);
          print('[SMS Import] ✅ Detected financial SMS from $address: ₹${transaction.amount}');
        }
      }

      setState(() {
        _parsedTransactions = parsed;
        _selectedIndices = Set.from(List.generate(parsed.length, (index) => index));
        _isLoading = false;
      });
      
      print('[SMS Import] Statistics:');
      print('  Total SMS scanned: $_totalSmsCount');
      print('  Financial SMS (ML classifier): $_financialSmsCount');
      print('  Successfully parsed: $_transactionSmsCount');
      print('  Detection rate: ${(_financialSmsCount / _totalSmsCount * 100).toStringAsFixed(1)}%');
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error loading SMS: $e\n\nNote: SMS import feature requires Android device (not available on emulator)';
      });
    }
  }

  Future<_ParsedTransaction?> _parseTransaction(String address, String body, int timestamp, int index) async {
    try {
      final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
      
      // Use hybrid parser (ML + Rule-based)
      final hybridResult = await _hybridParser.parseSMS(body, address);
      
      // Check if SMS was rejected by ML classifier
      if (hybridResult.source == 'rejected') {
        // print('[SMS Import] ❌ SMS rejected by ML classifier: ${body.substring(0, body.length > 40 ? 40 : body.length)}...');
        return null;
      }
      
      print('[SMS Import] 🎯 ML detected financial SMS: source=${hybridResult.source}, confidence=${(hybridResult.confidence * 100).toStringAsFixed(1)}%');
      
      // If hybrid parsing fails, fallback to centralized parser
      if (hybridResult.amount == null || hybridResult.amount == 0) {
        initializeBankParsers();
        final parsed = parser.BankParserFactory.parse(body, address, date);
        
        if (parsed == null) {
          return null; // Not a valid transaction
        }
        
        final data = parsed.toTransactionData();
        
        return _ParsedTransaction(
          index: index,
          amount: data['amount'] as double,
          date: data['smsTimestamp'] as DateTime,
          description: data['description'] as String,
          isDebit: data['type'] == 'debit',
          accountNumber: data['accountNumber'] as String?,
          senderAddress: data['smsSender'] as String,
          originalMessage: data['smsBody'] as String,
          merchant: null,
          bank: null,
          paymentMethod: null,
        );
      }
      
      // Use hybrid parser results
      return _ParsedTransaction(
        index: index,
        amount: hybridResult.amount!,
        date: date,
        description: hybridResult.description,
        isDebit: hybridResult.type == TransactionType.debit,
        accountNumber: hybridResult.accountNumber,
        senderAddress: address,
        originalMessage: body,
        merchant: hybridResult.merchant,
        bank: hybridResult.bank,
        paymentMethod: hybridResult.paymentMethod,
      );
    } catch (e) {
      print('[SMS Import] Error parsing transaction: $e');
      return null;
    }
  }

  void _toggleSelection(int index) {
    setState(() {
      if (_selectedIndices.contains(index)) {
        _selectedIndices.remove(index);
      } else {
        _selectedIndices.add(index);
      }
    });
  }

  void _selectAll() {
    setState(() {
      _selectedIndices = Set.from(List.generate(_parsedTransactions.length, (index) => index));
    });
  }

  void _deselectAll() {
    setState(() {
      _selectedIndices.clear();
    });
  }

  Future<void> _importSelected() async {
    if (_selectedIndices.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No transactions selected')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final transactionRepo = TransactionRepository();
      final accountRepo = AccountRepository();
      
      // Get all accounts to match SMS transactions
      final accounts = await accountRepo.getAll();
      
      if (accounts.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please create at least one account first'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        setState(() => _isLoading = false);
        return;
      }
      
      int successCount = 0;
      int failCount = 0;
      int duplicateCount = 0;
      int newAccountsCreated = 0;
      
      for (final index in _selectedIndices) {
        try {
          final parsed = _parsedTransactions[index];
          
          // Check for duplicate SMS transaction
          final isDuplicate = await transactionRepo.isDuplicateSmsTransaction(
            smsBody: parsed.originalMessage,
            smsTimestamp: parsed.date,
            amount: parsed.amount,
          );
          
          if (isDuplicate) {
            duplicateCount++;
            continue; // Skip this transaction
          }
          
          // Find or create account using bank name
          String accountId;
          
          // Try to match by bank name if ML provided it
          if (parsed.bank != null && parsed.bank!.isNotEmpty) {
            final matchingAccount = _findMatchingAccount(accounts, parsed.bank!);
            
            if (matchingAccount != null) {
              accountId = matchingAccount.id;
            } else {
              // Create new account for this bank
              final newAccount = await _createAccountForBank(accountRepo, parsed.bank!);
              accountId = newAccount.id;
              accounts.add(newAccount); // Add to list for future transactions
              newAccountsCreated++;
              print('[SMS Import] ✨ Created new account: ${newAccount.name}');
            }
          } else {
            // No bank name from ML, use default account
            accountId = accounts.first.id;
          }
          
          final now = DateTime.now();
          
          // Use merchant from ML/hybrid parser, fallback to extraction
          final merchantName = parsed.merchant ?? _extractMerchant(parsed.description);
          
          // Create transaction with ML-enhanced data
          final transaction = Transaction(
            id: 'sms_${now.millisecondsSinceEpoch}_$index',
            amount: parsed.amount,
            description: parsed.description,
            timestamp: parsed.date,
            type: parsed.isDebit ? TransactionType.debit : TransactionType.credit,
            accountId: accountId,
            accountNumber: parsed.accountNumber,
            merchantName: merchantName,
            paymentMethod: parsed.paymentMethod,
            category: _categorizeTransaction(merchantName ?? parsed.description) ?? Category.others,
            categorizationMethod: CategorizationMethod.machineLearning, // Mark as ML-processed
            smsBody: parsed.originalMessage,
            smsSender: parsed.senderAddress,
            smsTimestamp: parsed.date,
            notes: 'Imported from SMS',
            tags: ['imported', 'sms'],
            isRecurring: false,
            isManuallyEdited: false,
            categorizationConfidence: 0.8,
            createdAt: now,
            updatedAt: now,
          );
          
          await transactionRepo.insert(transaction);
          successCount++;
        } catch (e) {
          print('Error importing transaction at index $index: $e');
          failCount++;
        }
      }
      
      // Trigger data refresh across all screens
      ref.read(transactionRefreshProvider.notifier).state++;
      
      if (mounted) {
        final messageList = <String>[];
        if (successCount > 0) {
          messageList.add('Imported $successCount transactions');
        }
        if (newAccountsCreated > 0) {
          messageList.add('$newAccountsCreated new accounts created');
        }
        if (duplicateCount > 0) {
          messageList.add('$duplicateCount duplicates skipped');
        }
        if (failCount > 0) {
          messageList.add('$failCount failed');
        }
        
        final message = messageList.isNotEmpty 
            ? messageList.join(', ')
            : 'No transactions to import';
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: failCount > 0 ? Colors.orange : Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error importing transactions: $e';
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }
  
  /// Find matching account ignoring case and spaces
  Account? _findMatchingAccount(List<Account> accounts, String bankName) {
    // Normalize bank name for comparison (remove spaces, convert to lowercase)
    final normalizedBankName = bankName.replaceAll(' ', '').toLowerCase();
    
    for (final account in accounts) {
      final normalizedAccountName = account.name.replaceAll(' ', '').toLowerCase();
      final normalizedInstitution = account.institution.replaceAll(' ', '').toLowerCase();
      
      // Check if bank name matches account name or institution
      if (normalizedAccountName.contains(normalizedBankName) || 
          normalizedBankName.contains(normalizedAccountName) ||
          normalizedInstitution.contains(normalizedBankName) ||
          normalizedBankName.contains(normalizedInstitution)) {
        return account;
      }
    }
    
    return null; // No match found
  }
  
  /// Create a new account for the given bank name
  Future<Account> _createAccountForBank(AccountRepository accountRepo, String bankName) async {
    final now = DateTime.now();
    final accountId = 'acc_${now.millisecondsSinceEpoch}';
    
    // Clean up bank name (capitalize first letter of each word)
    final cleanedBankName = bankName.split(' ')
        .map((word) => word.isEmpty ? '' : word[0].toUpperCase() + word.substring(1).toLowerCase())
        .join(' ');
    
    final newAccount = Account(
      id: accountId,
      name: '$cleanedBankName Account',
      type: AccountType.savings, // Default to savings account
      institution: cleanedBankName,
      balance: 0.0,
      currency: 'INR',
      icon: 'account_balance',
      color: '#2196F3', // Blue color for bank accounts
      notes: 'Auto-created from SMS import',
      isActive: true,
      createdAt: now,
      updatedAt: now,
    );
    
    await accountRepo.insert(newAccount);
    return newAccount;
  }
  
  String? _extractMerchant(String description) {
    // Extract merchant name from description
    final merchantPatterns = [
      RegExp(r'at\s+([A-Z][A-Z\s]+)', caseSensitive: false),
      RegExp(r'to\s+([A-Z][A-Z\s]+)', caseSensitive: false),
      RegExp(r'from\s+([A-Z][A-Z\s]+)', caseSensitive: false),
    ];
    
    for (final pattern in merchantPatterns) {
      final match = pattern.firstMatch(description);
      if (match != null && match.groupCount > 0) {
        return match.group(1)?.trim();
      }
    }
    
    return null;
  }
  
  Category? _categorizeTransaction(String description) {
    final desc = description.toLowerCase();
    
    // Food & Dining
    if (desc.contains('swiggy') || desc.contains('zomato') || 
        desc.contains('dominos') || desc.contains('mcdonald') ||
        desc.contains('kfc') || desc.contains('restaurant') ||
        desc.contains('food')) {
      return Category.foodDelivery;
    }
    
    // Shopping
    if (desc.contains('amazon') || desc.contains('flipkart') || 
        desc.contains('myntra') || desc.contains('shopping') ||
        desc.contains('mall')) {
      return Category.shopping;
    }
    
    // Groceries
    if (desc.contains('grocery') || desc.contains('bigbasket') ||
        desc.contains('blinkit') || desc.contains('zepto')) {
      return Category.groceries;
    }
    
    // Transport
    if (desc.contains('uber') || desc.contains('ola') || 
        desc.contains('rapido') || desc.contains('taxi') ||
        desc.contains('petrol') || desc.contains('fuel')) {
      return Category.transportation;
    }
    
    // Entertainment
    if (desc.contains('netflix') || desc.contains('prime') || 
        desc.contains('hotstar') || desc.contains('movie') ||
        desc.contains('theatre')) {
      return Category.entertainment;
    }
    
    // Utilities / Bills
    if (desc.contains('electricity') || desc.contains('water') || 
        desc.contains('gas') || desc.contains('broadband') ||
        desc.contains('bill')) {
      return Category.billPayments;
    }
    
    // Recharge
    if (desc.contains('recharge') || desc.contains('prepaid') ||
        desc.contains('dth')) {
      return Category.recharge;
    }
    
    // UPI
    if (desc.contains('upi') || desc.contains('paytm') || 
        desc.contains('gpay') || desc.contains('phonepe')) {
      return Category.upiPayments;
    }
    
    // Card Payments
    if (desc.contains('card') || desc.contains('visa') ||
        desc.contains('mastercard')) {
      return Category.cardPayments;
    }
    
    // ATM
    if (desc.contains('atm') || desc.contains('cash withdraw')) {
      return Category.atmWithdrawals;
    }
    
    // Subscriptions
    if (desc.contains('subscription') || desc.contains('monthly')) {
      return Category.subscriptions;
    }
    
    return null; // Will use Category.others as default
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Import from SMS'),
        actions: [
          if (_parsedTransactions.isNotEmpty)
            TextButton(
              onPressed: _selectedIndices.length == _parsedTransactions.length
                  ? _deselectAll
                  : _selectAll,
              child: Text(
                _selectedIndices.length == _parsedTransactions.length
                    ? 'Deselect All'
                    : 'Select All',
              ),
            ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: _parsedTransactions.isNotEmpty && _selectedIndices.isNotEmpty
          ? FloatingActionButton.extended(
              heroTag: 'import_sms_fab',
              onPressed: _isLoading ? null : _importSelected,
              icon: const Icon(Icons.download),
              label: Text('Import ${_selectedIndices.length}'),
            )
          : null,
    );
  }

  Widget _buildBody() {
    if (!_hasPermission) {
      return _buildPermissionRequest();
    }

    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading SMS messages...'),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _loadSmsMessages,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_parsedTransactions.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.inbox, size: 64, color: Colors.grey.shade300),
              const SizedBox(height: 16),
              Text(
                'No bank transactions found',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'No SMS messages from banks found in the last 30 days',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          color: Theme.of(context).colorScheme.primaryContainer,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.info_outline, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Found ${_parsedTransactions.length} transactions from $_totalSmsCount SMS messages',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              if (_totalSmsCount > 0) ...[
                const SizedBox(height: 8),
                Text(
                  '📊 Filter Stats: $_financialSmsCount financial SMS identified, ${_totalSmsCount - _financialSmsCount} non-financial filtered out (${((_totalSmsCount - _financialSmsCount) / _totalSmsCount * 100).toStringAsFixed(1)}%)',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimaryContainer.withValues(alpha: 0.8),
                    fontSize: 12,
                  ),
                ),
              ],
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _parsedTransactions.length,
            itemBuilder: (context, index) {
              final transaction = _parsedTransactions[index];
              final isSelected = _selectedIndices.contains(index);
              
              return CheckboxListTile(
                value: isSelected,
                onChanged: (_) => _toggleSelection(index),
                title: Text(
                  transaction.description,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(DateFormat('MMM dd, yyyy hh:mm a').format(transaction.date)),
                    if (transaction.accountNumber != null)
                      Text('Account: ${transaction.accountNumber}'),
                    Text(
                      'From: ${transaction.senderAddress}',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    ),
                  ],
                ),
                secondary: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '₹${transaction.amount.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: transaction.isDebit ? Colors.red : Colors.green,
                      ),
                    ),
                    Text(
                      transaction.isDebit ? 'Debit' : 'Credit',
                      style: TextStyle(
                        fontSize: 12,
                        color: transaction.isDebit ? Colors.red : Colors.green,
                      ),
                    ),
                  ],
                ),
                isThreeLine: true,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPermissionRequest() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.sms, size: 80, color: Colors.grey.shade300),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'SMS Permission Required',
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'MFTracker needs SMS access to:\n\n'
              '• Read bank transaction SMS from last 30 days\n'
              '• Auto-detect debits and credits\n'
              '• Extract transaction amounts and merchants\n\n'
              'Your SMS data stays on your device and is never shared.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade700),
            ),
            const SizedBox(height: AppSpacing.lg),
            FilledButton.icon(
              onPressed: _isLoading ? null : _requestPermissions,
              icon: const Icon(Icons.check_circle),
              label: const Text('Grant SMS Permission'),
            ),
            const SizedBox(height: AppSpacing.sm),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Not Now'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ParsedTransaction {
  final int index;
  final double amount;
  final DateTime date;
  final String description;
  final bool isDebit;
  final String? accountNumber;
  final String senderAddress;
  final String originalMessage;
  final String? merchant;
  final String? bank;
  final String? paymentMethod;

  _ParsedTransaction({
    required this.index,
    required this.amount,
    required this.date,
    required this.description,
    required this.isDebit,
    this.accountNumber,
    required this.senderAddress,
    required this.originalMessage,
    this.merchant,
    this.bank,
    this.paymentMethod,
  });
}
