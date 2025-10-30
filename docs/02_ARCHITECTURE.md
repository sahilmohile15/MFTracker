# 🏗️ System Architecture

**MFTracker - Technical Architecture Document**

**Last Updated**: October 30, 2025

---

## 📐 Architecture Overview

MFTracker follows a **clean architecture** pattern with clear separation of concerns. The app is designed for optimal performance, maintainability, and scalability.

```
┌─────────────────────────────────────────────────────────────┐
│                         UI Layer                            │
│  (Screens, Widgets, Navigation)                             │
└─────────────────────┬───────────────────────────────────────┘
                      │
┌─────────────────────▼───────────────────────────────────────┐
│                    Provider Layer                           │
│  (Riverpod State Management)                                │
└─────────────────────┬───────────────────────────────────────┘
                      │
┌─────────────────────▼───────────────────────────────────────┐
│                    Service Layer                            │
│  (Business Logic, SMS Parser, Categorizer)                  │
└─────────────────────┬───────────────────────────────────────┘
                      │
┌─────────────────────▼───────────────────────────────────────┐
│                 Repository Layer                            │
│  (Database Access, Data Management)                         │
└─────────────────────┬───────────────────────────────────────┘
                      │
┌─────────────────────▼───────────────────────────────────────┐
│                   Data Layer                                │
│  (SQLite Database, SharedPreferences)                       │
└─────────────────────────────────────────────────────────────┘
```

---

## 🎯 Layer Responsibilities

### 1. UI Layer (Presentation)

**Screens:**
- `HomeScreen`: Dashboard with summary cards
- `TransactionsScreen`: List of all transactions
- `TransactionDetailScreen`: Individual transaction view
- `CategoriesScreen`: Category management
- `AnalyticsScreen`: Charts and insights
- `SettingsScreen`: App configuration

**Widgets:**
- Reusable components (cards, charts, buttons)
- No business logic
- Pure presentation

```dart
// Example: HomeScreen
class HomeScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(monthlySummaryProvider);
    
    return summaryAsync.when(
      data: (summary) => DashboardContent(summary: summary),
      loading: () => LoadingIndicator(),
      error: (error, stack) => ErrorWidget(error),
    );
  }
}
```

---

### 2. Provider Layer (State Management)

Using **Riverpod** for reactive state management.

**Key Providers:**

```dart
// Transaction provider
final transactionProvider = StateNotifierProvider<TransactionNotifier, AsyncValue<List<Transaction>>>((ref) {
  return TransactionNotifier(ref.read(transactionServiceProvider));
});

// Category provider
final categoryProvider = StateNotifierProvider<CategoryNotifier, AsyncValue<List<Category>>>((ref) {
  return CategoryNotifier(ref.read(categoryServiceProvider));
});

// Monthly summary provider
final monthlySummaryProvider = FutureProvider.family<MonthlySummary, DateTime>((ref, month) async {
  final service = ref.read(analyticsServiceProvider);
  return service.getMonthlySummary(month);
});

// SMS sync provider
final smsSyncProvider = StateNotifierProvider<SMSSyncNotifier, SMSSyncState>((ref) {
  return SMSSyncNotifier(ref.read(smsServiceProvider));
});
```

**Benefits:**
- Reactive UI updates
- Automatic cache management
- Easy testing
- No boilerplate

---

### 3. Service Layer (Business Logic)

**Core Services:**

#### NotificationParserService

```dart
class NotificationParserService {
  final BankParserFactory _parserFactory;
  final CategorizationService _categorizer;
  
  /// Parse a notification and extract transaction data
  ParsedTransaction? parseNotification(
    String title,
    String body,
    String packageName,
  ) {
    // Validate if financial notification
    if (!_isFinancialNotification(packageName, body)) return null;
    
    // Get appropriate parser for the bank
    final parser = _parserFactory.getParser(packageName);
    
    // Parse and extract transaction
    final parsed = parser.parse(body);
    
    // Categorize transaction
    if (parsed != null) {
      parsed = _categorizer.categorize(parsed);
    }
    
    return parsed;
  }
  
  /// Check if notification is financial
  bool _isFinancialNotification(String packageName, String body) {
    // Check package name against known financial apps
    // Check body for transaction keywords
    return true; // Implementation details
  }
}
```

#### CategorizationService

```dart
class CategorizationService {
  final RuleBasedCategorizer _ruleCategorizer;
  final MerchantCategoryMapper _merchantMapper;
  
  /// Categorize a transaction using rules and merchant database
  ParsedTransaction categorize(ParsedTransaction txn) {
    // Try rule-based categorization
    final category = _ruleCategorizer.categorize(txn);
    
    // Enhance with merchant mapping
    if (txn.merchant != null) {
      final merchantCategory = _merchantMapper.getCategory(txn.merchant!);
      if (merchantCategory != null) {
        return txn.copyWith(category: merchantCategory);
      }
    }
    
    return txn.copyWith(category: category);
  }
}
```

#### TransactionRepository

```dart
class TransactionRepository {
  final Database _database;
  
  /// Insert transaction with duplicate check
  Future<void> insertTransaction(Transaction txn) async {
    // Check for duplicate
    final isDuplicate = await _isDuplicate(txn);
    if (isDuplicate) {
      throw DuplicateTransactionException();
    }
    
    await _database.insert('transactions', txn.toMap());
  }
  
  /// Check if a transaction already exists
  Future<bool> _isDuplicate(Transaction txn) async {
    final result = await _database.query(
      'transactions',
      where: 'amount = ? AND date = ? AND merchant = ?',
      whereArgs: [txn.amount, txn.date.toIso8601String(), txn.merchant],
    );
    return result.isNotEmpty;
  }
  
  /// Get transactions with filters
  Future<List<Transaction>> getTransactions({
    DateTime? startDate,
    DateTime? endDate,
    Category? category,
    String? accountId,
  }) async {
    // Build query with filters
    // Return list of transactions
  }
}
```
    }
    
    await db.insert('transactions', txn.toMap());
  }
  
  /// Get transactions with pagination
  Future<List<Transaction>> getTransactions({
    int? limit,
    int? offset,
    DateTime? startDate,
    DateTime? endDate,
    TransactionType? type,
    Category? category,
  }) async {
    // Implementation with query builder
  }
}
```

#### AnalyticsService
```dart
class AnalyticsService {
  final DatabaseService _db;
  
  /// Get monthly summary
  Future<MonthlySummary> getMonthlySummary(DateTime month) async {
    final transactions = await _db.getTransactionsByMonth(month);
    
    final income = transactions
        .where((t) => t.type == TransactionType.credit)
        .fold(0.0, (sum, t) => sum + t.amount);
    
    final expense = transactions
        .where((t) => t.type == TransactionType.debit)
        .fold(0.0, (sum, t) => sum + t.amount);
    
    final categoryBreakdown = _groupByCategory(transactions);
    
    return MonthlySummary(
      month: month,
      totalIncome: income,
      totalExpense: expense,
      categoryWiseExpense: categoryBreakdown,
      transactionCount: transactions.length,
      savingsRate: (income - expense) / income,
    );
  }
  
  /// Get spending trends
  Future<List<TrendData>> getSpendingTrends({
    required DateTime start,
    required DateTime end,
    required TrendPeriod period,
  }) async {
    // Implementation
  }
}
```

---

### 4. Repository Layer

Abstracts data access for easier testing and maintenance.

```dart
abstract class TransactionRepository {
  Future<List<Transaction>> getAll();
  Future<Transaction?> getById(String id);
  Future<void> insert(Transaction transaction);
  Future<void> update(Transaction transaction);
  Future<void> delete(String id);
  Stream<List<Transaction>> watchAll();
}

class TransactionRepositoryImpl implements TransactionRepository {
  final DatabaseService _db;
  
  @override
  Future<List<Transaction>> getAll() async {
    return _db.getTransactions();
  }
  
  // ... other implementations
}
```

---

### 5. Data Layer

#### Database Schema

See `06_DATABASE_SCHEMA.md` for detailed schema.

#### Models

```dart
@freezed
class Transaction with _$Transaction {
  const factory Transaction({
    required String id,
    required double amount,
    required TransactionType type,
    required DateTime date,
    required Category category,
    String? merchant,
    String? description,
    String? accountNumber,
    double? balance,
    required String rawMessage,
    @Default(false) bool isManualEntry,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _Transaction;
  
  factory Transaction.fromJson(Map<String, dynamic> json) => _$TransactionFromJson(json);
}

@freezed
class Category with _$Category {
  const factory Category({
    required String id,
    required String name,
    required IconData icon,
    required Color color,
    @Default([]) List<String> subcategories,
  }) = _Category;
}
```

---

## 🔄 Data Flow

### SMS Parsing Flow

```
┌──────────────┐
│  New SMS     │
│  Received    │
└──────┬───────┘
       │
       ▼
┌──────────────────┐
│  SMS Broadcast   │
│  Receiver        │
└──────┬───────────┘
       │
       ▼
┌──────────────────┐
│  SMS Service     │
│  - Validate      │
│  - Parse         │
└──────┬───────────┘
       │
       ▼
┌──────────────────┐
│  Categorization  │
│  Service         │
└──────┬───────────┘
       │
       ▼
┌──────────────────┐
│  Database        │
│  - Save          │
│  - Notify UI     │
└──────────────────┘
```

### User Action Flow

```
User Action (UI)
       │
       ▼
Provider (State Management)
       │
       ▼
Service (Business Logic)
       │
       ▼
Repository (Data Access)
       │
       ▼
Database (Persistence)
       │
       ▼
Provider (State Update)
       │
       ▼
UI (Re-render)
```

---

## 🧩 Component Interactions

### SMS Parsing Component

```dart
// Parser Factory Pattern
abstract class SMSParser {
  ParsedTransaction? parse(String message);
  bool canParse(String senderAddress);
}

class SMSParserFactory {
  final List<SMSParser> _parsers = [
    HDFCParser(),
    ICICIParser(),
    SBIParser(),
    AxisParser(),
    PaytmParser(),
    GenericParser(), // Fallback
  ];
  
  SMSParser getParser(String senderAddress) {
    return _parsers.firstWhere(
      (parser) => parser.canParse(senderAddress),
      orElse: () => GenericParser(),
    );
  }
}

// Individual bank parser
class HDFCParser extends SMSParser {
  @override
  bool canParse(String senderAddress) {
    return senderAddress.toUpperCase().contains('HDFC');
  }
  
  @override
  ParsedTransaction? parse(String message) {
    // HDFC-specific parsing logic
    final amountMatch = RegExp(r'Rs\.?\s*([\d,]+\.?\d*)').firstMatch(message);
    final typeMatch = RegExp(r'(debited|credited)', caseSensitive: false).firstMatch(message);
    // ... more parsing
    
    if (amountMatch == null || typeMatch == null) return null;
    
    return ParsedTransaction(
      amount: _parseAmount(amountMatch.group(1)!),
      type: _parseType(typeMatch.group(1)!),
      // ... other fields
    );
  }
}
```

---

## 🔐 Security Architecture

### Data Encryption

```dart
class EncryptionService {
  final FlutterSecureStorage _secureStorage;
  
  /// Encrypt sensitive data before storing
  Future<String> encrypt(String plainText) async {
    final key = await _getOrCreateKey();
    final encrypter = Encrypter(AES(key));
    final iv = IV.fromLength(16);
    
    final encrypted = encrypter.encrypt(plainText, iv: iv);
    return encrypted.base64;
  }
  
  /// Decrypt when reading
  Future<String> decrypt(String encryptedText) async {
    final key = await _getKey();
    final encrypter = Encrypter(AES(key));
    final iv = IV.fromLength(16);
    
    return encrypter.decrypt64(encryptedText, iv: iv);
  }
}
```

### Permission Handling

```dart
class PermissionService {
  /// Request SMS permissions with rationale
  Future<bool> requestSMSPermission() async {
    final status = await Permission.sms.status;
    
    if (status.isGranted) return true;
    
    if (status.isDenied) {
      // Show rationale dialog
      final shouldRequest = await _showPermissionRationale();
      if (!shouldRequest) return false;
      
      final result = await Permission.sms.request();
      return result.isGranted;
    }
    
    if (status.isPermanentlyDenied) {
      // Redirect to app settings
      await openAppSettings();
      return false;
    }
    
    return false;
  }
}
```

---

## 🚀 Performance Optimization

### Lazy Loading

```dart
class LazyTransactionLoader {
  final TransactionRepository _repo;
  final StreamController<List<Transaction>> _controller;
  
  int _currentPage = 0;
  static const int _pageSize = 50;
  
  Stream<List<Transaction>> get stream => _controller.stream;
  
  Future<void> loadMore() async {
    final transactions = await _repo.getTransactions(
      limit: _pageSize,
      offset: _currentPage * _pageSize,
    );
    
    if (transactions.isNotEmpty) {
      _controller.add(transactions);
      _currentPage++;
    }
  }
}
```

### Caching Strategy

```dart
class CachedAnalyticsService {
  final AnalyticsService _service;
  final Map<String, CacheEntry> _cache = {};
  
  static const Duration _cacheDuration = Duration(hours: 1);
  
  Future<MonthlySummary> getMonthlySummary(DateTime month) async {
    final cacheKey = 'summary_${month.year}_${month.month}';
    
    // Check cache
    if (_cache.containsKey(cacheKey)) {
      final entry = _cache[cacheKey]!;
      if (!entry.isExpired) {
        return entry.data as MonthlySummary;
      }
    }
    
    // Fetch and cache
    final summary = await _service.getMonthlySummary(month);
    _cache[cacheKey] = CacheEntry(
      data: summary,
      expiresAt: DateTime.now().add(_cacheDuration),
    );
    
    return summary;
  }
}
```

---

## 🧪 Testing Architecture

### Unit Tests
```dart
void main() {
  group('SMSParser', () {
    late HDFCParser parser;
    
    setUp(() {
      parser = HDFCParser();
    });
    
    test('should parse HDFC debit SMS correctly', () {
      const sms = 'Rs 500 debited from A/c XX1234 on 19-Oct-25';
      final result = parser.parse(sms);
      
      expect(result, isNotNull);
      expect(result!.amount, 500.0);
      expect(result.type, TransactionType.debit);
    });
  });
}
```

### Widget Tests
```dart
void main() {
  testWidgets('TransactionCard displays correct information', (tester) async {
    final transaction = Transaction(
      id: '1',
      amount: 500.0,
      type: TransactionType.debit,
      date: DateTime.now(),
      category: Category.food,
    );
    
    await tester.pumpWidget(
      MaterialApp(
        home: TransactionCard(transaction: transaction),
      ),
    );
    
    expect(find.text('₹500.00'), findsOneWidget);
    expect(find.byIcon(Icons.food_bank), findsOneWidget);
  });
}
```

### Integration Tests
```dart
void main() {
  testWidgets('Full SMS to UI flow', (tester) async {
    // Start app
    await tester.pumpWidget(MyApp());
    
    // Simulate SMS receipt
    await simulateSMSReceipt('Rs 500 debited from A/c XX1234');
    
    // Wait for parsing and UI update
    await tester.pumpAndSettle();
    
    // Verify transaction appears in list
    expect(find.text('₹500.00'), findsOneWidget);
  });
}
```

---

## 📱 Platform-Specific Architecture

### Android

```kotlin
// MainActivity.kt
class MainActivity: FlutterActivity() {
    private val SMS_CHANNEL = "com.finance_tracker/sms"
    
    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, SMS_CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "getAllSMS" -> getAllSMS(result)
                    "getNewSMS" -> getNewSMS(call.arguments as Long, result)
                    else -> result.notImplemented()
                }
            }
    }
}
```

### iOS (Future)

```swift
// Manual entry only (iOS doesn't allow SMS reading)
// Focus on data visualization and manual transaction management
```

---

## 🔄 State Management Flow

```dart
// Example: Adding a manual transaction

// 1. UI triggers action
onPressed: () => ref.read(transactionProvider.notifier).addTransaction(newTxn);

// 2. Provider receives action
class TransactionNotifier extends StateNotifier<AsyncValue<List<Transaction>>> {
  Future<void> addTransaction(Transaction txn) async {
    state = AsyncValue.loading();
    
    try {
      // 3. Call service
      await _service.addTransaction(txn);
      
      // 4. Reload data
      final transactions = await _service.getAll();
      
      // 5. Update state
      state = AsyncValue.data(transactions);
    } catch (error, stack) {
      state = AsyncValue.error(error, stack);
    }
  }
}

// 6. UI rebuilds automatically
```

---

## 📊 Architecture Decision Records (ADR)

### ADR-001: Use Riverpod over Bloc
**Decision**: Use Riverpod for state management  
**Rationale**:
- Less boilerplate than Bloc
- Better performance with fine-grained reactivity
- Easier testing with provider overrides
- Strong compile-time safety

### ADR-002: SQLite over Hive
**Decision**: Use SQLite (sqflite) instead of Hive  
**Rationale**:
- Complex queries needed (filters, aggregations)
- Better indexing support
- More mature and stable
- Better for relational data

### ADR-003: Rule-based categorization first, ML second
**Decision**: Start with rule-based, add ML in Phase 2  
**Rationale**:
- Faster MVP development
- No training data initially
- Lower memory footprint
- Easier to debug and maintain

---

**Next**: See `03_PERFORMANCE_OPTIMIZATION.md` for optimization strategies

**Last Updated**: October 19, 2025
