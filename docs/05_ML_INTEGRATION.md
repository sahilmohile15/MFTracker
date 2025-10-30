# 🤖 Machine Learning Integration Guide

**AI-Powered Transaction Categorization**

**Last Updated**: October 30, 2025

---

## 🎯 ML Strategy Overview

MFTracker uses a **hybrid categorization approach**:

1. **Phase 1 (Current - v1.0.0)**: Rule-based categorization (90%+ accuracy)
2. **Phase 2 (Planned - v1.1)**: ML-enhanced categorization (95%+ accuracy)
3. **Phase 3 (Future)**: Continuous learning from user feedback

---

## 📊 ML Architecture

```text
Notification Text
     │
     ▼
Rule-Based
Categorizer ────► High Confidence? ────Yes────► Category
     │                (>90%)
     No
     │
     ▼
Merchant
Mapper ─────────► Found? ────Yes────► Category
     │
     No
     │
     ▼
Default: "Others" + Flag for Review
```

**Future (v1.1):**

```text
Notification Text
     │
     ▼
Rule-Based ────► Confidence > 90%? ──Yes──► Category
     │
     No
     │
     ▼
ML Model ───────► Confidence > 85%? ──Yes──► Category
     │
     No
     │
     ▼
Merchant
Mapper ─────────► Found? ──Yes──► Category
     │
     No
     │
     ▼
Default: "Others" + Flag for Review
```

---

## 🔧 Phase 1: Rule-Based Categorization (Current - v1.0.0)

### Implementation

```dart
enum Category {
  upiPayments,
  foodDelivery,
  shopping,
  groceries,
  transportation,
  entertainment,
  billPayments,
  recharge,
  cardPayments,
  bankTransfers,
  atmWithdrawals,
  emi,
  subscriptions,
  healthcare,
  income,
  investment,
  others,
}

class RuleBasedCategorizer {
  /// Categorize transaction using rules
  CategoryResult categorize(ParsedTransaction txn) {
    final message = txn.rawMessage.toLowerCase();
    final merchant = (txn.merchant ?? '').toLowerCase();
    
    // UPI Payments
    if (_containsAny(message, ['upi', '@paytm', '@ybl', '@okaxis', '@axisbank'])) {
      return _categor izeUPI(txn, merchant);
    }
    
    // Card Payments
    if (_containsAny(message, ['card', 'pos', 'visa', 'mastercard', 'rupay'])) {
      return CategoryResult(
        category: Category.cardPayments,
        confidence: 0.9,
        method: CategorizationMethod.ruleBased,
      );
    }
    
    // ATM Withdrawals
    if (_containsAny(message, ['atm', 'cash withdrawal'])) {
      return CategoryResult(
        category: Category.atmWithdrawals,
        confidence: 0.95,
        method: CategorizationMethod.ruleBased,
      );
    }
    
    // Bank Transfers
    if (_containsAny(message, ['neft', 'imps', 'rtgs', 'transfer'])) {
      return CategoryResult(
        category: Category.bankTransfers,
        confidence: 0.9,
        method: CategorizationMethod.ruleBased,
      );
    }
    
    // Bill Payments
    if (_containsAny(message, ['bbps', 'bill', 'electricity', 'water', 'gas'])) {
      return CategoryResult(
        category: Category.billPayments,
        confidence: 0.85,
        method: CategorizationMethod.ruleBased,
      );
    }
    
    // Recharge
    if (_containsAny(message, ['recharge', 'prepaid', 'mobile', 'dth'])) {
      return CategoryResult(
        category: Category.recharge,
        confidence: 0.9,
        method: CategorizationMethod.ruleBased,
      );
    }
    
    // Income
    if (txn.type == TransactionType.credit && 
        _containsAny(message, ['salary', 'credited by', 'payment received'])) {
      return CategoryResult(
        category: Category.income,
        confidence: 0.85,
        method: CategorizationMethod.ruleBased,
      );
    }
    
    // Default
    return CategoryResult(
      category: Category.others,
      confidence: 0.3,
      method: CategorizationMethod.ruleBased,
      needsReview: true,
    );
  }
  
  CategoryResult _categorizeUPI(ParsedTransaction txn, String merchant) {
    // Food delivery
    if (_containsAny(merchant, ['swiggy', 'zomato', 'ubereats', 'dunzo'])) {
      return CategoryResult(
        category: Category.foodDelivery,
        confidence: 0.95,
        method: CategorizationMethod.ruleBased,
      );
    }
    
    // Shopping
    if (_containsAny(merchant, ['amazon', 'flipkart', 'myntra', 'ajio', 'meesho'])) {
      return CategoryResult(
        category: Category.shopping,
        confidence: 0.95,
        method: CategorizationMethod.ruleBased,
      );
    }
    
    // Groceries
    if (_containsAny(merchant, ['bigbasket', 'grofers', 'blinkit', 'zepto', 'instamart'])) {
      return CategoryResult(
        category: Category.groceries,
        confidence: 0.95,
        method: CategorizationMethod.ruleBased,
      );
    }
    
    // Transportation
    if (_containsAny(merchant, ['uber', 'ola', 'rapido', 'metro', 'irctc'])) {
      return CategoryResult(
        category: Category.transportation,
        confidence: 0.95,
        method: CategorizationMethod.ruleBased,
      );
    }
    
    // Entertainment
    if (_containsAny(merchant, ['netflix', 'prime', 'hotstar', 'spotify', 'youtube'])) {
      return CategoryResult(
        category: Category.entertainment,
        confidence: 0.95,
        method: CategorizationMethod.ruleBased,
      );
    }
    
    // Default to UPI Payments
    return CategoryResult(
      category: Category.upiPayments,
      confidence: 0.7,
      method: CategorizationMethod.ruleBased,
    );
  }
  
  bool _containsAny(String text, List<String> keywords) {
    return keywords.any((keyword) => text.contains(keyword));
  }
}

@freezed
class CategoryResult with _$CategoryResult {
  const factory CategoryResult({
    required Category category,
    required double confidence,
    required CategorizationMethod method,
    @Default(false) bool needsReview,
    String? reason,
  }) = _CategoryResult;
}

enum CategorizationMethod {
  ruleBased,
  machineLearning,
  merchantDatabase,
  userCorrected,
}
```

---

## 🧠 Phase 2: Machine Learning Model

### Model Architecture

**Approach: Lightweight On-Device ML**

```dart
class MLCategorizer {
  Interpreter? _interpreter;
  TfIdfVectorizer? _vectorizer;
  LabelEncoder? _labelEncoder;
  
  bool _isLoaded = false;
  
  /// Load TFLite model
  Future<void> loadModel() async {
    if (_isLoaded) return;
    
    try {
      // Load TFLite model
      _interpreter = await Interpreter.fromAsset(
        'assets/models/transaction_classifier.tflite',
      );
      
      // Load vectorizer vocabulary
      final vocabJson = await rootBundle.loadString(
        'assets/models/vocabulary.json',
      );
      _vectorizer = TfIdfVectorizer.fromJson(vocabJson);
      
      // Load label mappings
      final labelsJson = await rootBundle.loadString(
        'assets/models/labels.json',
      );
      _labelEncoder = LabelEncoder.fromJson(labelsJson);
      
      _isLoaded = true;
    } catch (e) {
      print('Failed to load ML model: $e');
    }
  }
  
  /// Predict category using ML model
  Future<CategoryResult?> predict(ParsedTransaction txn) async {
    if (!_isLoaded) {
      await loadModel();
    }
    
    if (_interpreter == null) return null;
    
    try {
      // Extract features
      final features = _extractFeatures(txn);
      
      // Prepare input tensor
      final input = _prepareInput(features);
      
      // Run inference
      final output = List.filled(Category.values.length, 0.0)
          .reshape([1, Category.values.length]);
      
      _interpreter!.run(input, output);
      
      // Get prediction
      final probabilities = output[0] as List<double>;
      final maxProb = probabilities.reduce((a, b) => a > b ? a : b);
      final categoryIndex = probabilities.indexOf(maxProb);
      
      final category = _labelEncoder!.decode(categoryIndex);
      
      return CategoryResult(
        category: category,
        confidence: maxProb,
        method: CategorizationMethod.machineLearning,
        needsReview: maxProb < 0.85,
      );
    } catch (e) {
      print('Prediction error: $e');
      return null;
    }
  }
  
  /// Extract features from transaction
  Map<String, dynamic> _extractFeatures(ParsedTransaction txn) {
    return {
      'merchant_text': txn.merchant ?? '',
      'amount': txn.amount,
      'log_amount': math.log(txn.amount + 1),
      'amount_bin': _getAmountBin(txn.amount),
      'hour': txn.date.hour,
      'day_of_week': txn.date.weekday,
      'is_weekend': txn.date.weekday >= 6 ? 1 : 0,
      'type': txn.type == TransactionType.debit ? 0 : 1,
      'message_length': txn.rawMessage.length,
      // TF-IDF features from merchant text
      ..._ vectorizer!.transform(txn.merchant ?? ''),
    };
  }
  
  int _getAmountBin(double amount) {
    if (amount < 100) return 0;
    if (amount < 500) return 1;
    if (amount < 1000) return 2;
    if (amount < 5000) return 3;
    return 4;
  }
  
  List<List<double>> _prepareInput(Map<String, dynamic> features) {
    // Convert features to input tensor format
    // This depends on your model's input shape
    return [[]]; // Placeholder
  }
  
  void dispose() {
    _interpreter?.close();
    _interpreter = null;
    _isLoaded = false;
  }
}
```

---

## 📚 Training the ML Model

### Data Collection

```dart
class TrainingDataCollector {
  final DatabaseService _db;
  
  /// Collect training data from user corrections
  Future<List<TrainingExample>> collectTrainingData() async {
    final transactions = await _db.getAllTransactions();
    
    final trainingData = <TrainingExample>[];
    
    for (final txn in transactions) {
      // Only include manually corrected transactions
      if (txn.categorizationMethod == CategorizationMethod.userCorrected) {
        trainingData.add(TrainingExample(
          features: _extractFeatures(txn),
          label: txn.category.index,
        ));
      }
    }
    
    return trainingData;
  }
  
  /// Export training data to CSV
  Future<void> exportToCSV(String filePath) async {
    final data = await collectTrainingData();
    
    final csv = StringBuffer();
    csv.writeln('merchant,amount,log_amount,hour,day_of_week,category');
    
    for (final example in data) {
      csv.writeln([
        example.features['merchant_text'],
        example.features['amount'],
        example.features['log_amount'],
        example.features['hour'],
        example.features['day_of_week'],
        example.label,
      ].join(','));
    }
    
    await File(filePath).writeAsString(csv.toString());
  }
}

class TrainingExample {
  final Map<String, dynamic> features;
  final int label;
  
  TrainingExample({required this.features, required this.label});
}
```

---

### Python Training Script

```python
# train_model.py
import pandas as pd
import numpy as np
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.preprocessing import StandardScaler, LabelEncoder
from sklearn.linear_model import LogisticRegression
from sklearn.model_selection import train_test_split
from sklearn.metrics import classification_report, f1_score
import tensorflow as tf
import json

# Load training data
df = pd.read_csv('training_data.csv')

# Feature engineering
df['log_amount'] = np.log1p(df['amount'])
df['amount_bin'] = pd.qcut(df['amount'], q=5, labels=False, duplicates='drop')

# TF-IDF vectorization
tfidf = TfidfVectorizer(max_features=1000, ngram_range=(1, 2))
merchant_features = tfidf.fit_transform(df['merchant'].fillna(''))

# Numeric features
numeric_features = df[['log_amount', 'amount_bin', 'hour', 'day_of_week']].values

# Combine features
from scipy.sparse import hstack
X = hstack([merchant_features, numeric_features])

# Labels
label_encoder = LabelEncoder()
y = label_encoder.fit_transform(df['category'])

# Train-test split
X_train, X_test, y_train, y_test = train_test_split(
    X, y, test_size=0.2, stratify=y, random_state=42
)

# Train model
model = LogisticRegression(
    max_iter=1000,
    class_weight='balanced',
    C=0.7,
    solver='lbfgs',
    n_jobs=-1,
)
model.fit(X_train, y_train)

# Evaluate
y_pred = model.predict(X_test)
print(f"F1 Score: {f1_score(y_test, y_pred, average='weighted'):.4f}")
print(classification_report(y_test, y_pred, target_names=label_encoder.classes_))

# Convert to TensorFlow
# Build a simple neural network for TFLite conversion
tf_model = tf.keras.Sequential([
    tf.keras.layers.Input(shape=(X_train.shape[1],)),
    tf.keras.layers.Dense(128, activation='relu'),
    tf.keras.layers.Dropout(0.3),
    tf.keras.layers.Dense(64, activation='relu'),
    tf.keras.layers.Dense(len(label_encoder.classes_), activation='softmax'),
])

tf_model.compile(
    optimizer='adam',
    loss='sparse_categorical_crossentropy',
    metrics=['accuracy'],
)

tf_model.fit(
    X_train.toarray(), y_train,
    epochs=20,
    batch_size=32,
    validation_split=0.2,
    verbose=1,
)

# Convert to TFLite
converter = tf.lite.TFLiteConverter.from_keras_model(tf_model)
converter.optimizations = [tf.lite.Optimize.DEFAULT]
tflite_model = converter.convert()

# Save TFLite model
with open('transaction_classifier.tflite', 'wb') as f:
    f.write(tflite_model)

# Save vocabulary
vocab = {
    'vocabulary': tfidf.vocabulary_,
    'idf': tfidf.idf_.tolist(),
}
with open('vocabulary.json', 'w') as f:
    json.dump(vocab, f)

# Save labels
labels = {
    'classes': label_encoder.classes_.tolist(),
}
with open('labels.json', 'w') as f:
    json.dump(labels, f)

print("Model training complete!")
print(f"Model size: {len(tflite_model) / 1024:.2f} KB")
```

---

## 💾 Merchant Database

### Local Merchant-Category Mapping

```dart
class MerchantDatabase {
  final Map<String, Category> _merchantMap = {};
  
  Future<void> initialize() async {
    // Load from JSON file
    final jsonString = await rootBundle.loadString(
      'assets/data/merchant_mappings.json',
    );
    final data = json.decode(jsonString) as Map<String, dynamic>;
    
    for (final entry in data.entries) {
      _merchantMap[entry.key.toLowerCase()] = 
          Category.values[entry.value as int];
    }
  }
  
  /// Lookup category for merchant
  Category? lookup(String? merchant) {
    if (merchant == null || merchant.isEmpty) return null;
    
    final normalized = merchant.toLowerCase();
    
    // Exact match
    if (_merchantMap.containsKey(normalized)) {
      return _merchantMap[normalized];
    }
    
    // Partial match
    for (final entry in _merchantMap.entries) {
      if (normalized.contains(entry.key) || entry.key.contains(normalized)) {
        return entry.value;
      }
    }
    
    return null;
  }
  
  /// Add new merchant mapping
  Future<void> addMapping(String merchant, Category category) async {
    _merchantMap[merchant.toLowerCase()] = category;
    
    // Persist to file
    await _saveToFile();
  }
  
  Future<void> _saveToFile() async {
    final data = _merchantMap.map((key, value) => 
        MapEntry(key, value.index));
    
    final jsonString = json.encode(data);
    
    // Save to local storage
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('merchant_mappings', jsonString);
  }
}
```

### Pre-populated Merchant Data

```json
{
  "swiggy": 1,
  "zomato": 1,
  "ubereats": 1,
  "amazon": 2,
  "flipkart": 2,
  "myntra": 2,
  "bigbasket": 3,
  "grofers": 3,
  "blinkit": 3,
  "uber": 4,
  "ola": 4,
  "rapido": 4,
  "netflix": 5,
  "prime": 5,
  "hotstar": 5,
  "spotify": 5
}
```

---

## 🔄 User Feedback Loop

### Correction Interface

```dart
class TransactionCorrectionScreen extends ConsumerWidget {
  final Transaction transaction;
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: Text('Correct Category')),
      body: ListView(
        children: [
          TransactionCard(transaction: transaction),
          SizedBox(height: 16),
          Text('Current: ${transaction.category.name}'),
          Text('Confidence: ${transaction.categoryConfidence.toStringAsFixed(2)}%'),
          SizedBox(height: 24),
          ...Category.values.map((category) => ListTile(
            title: Text(category.name),
            leading: Icon(category.icon),
            onTap: () async {
              await _correctCategory(ref, transaction, category);
              Navigator.pop(context);
            },
          )),
        ],
      ),
    );
  }
  
  Future<void> _correctCategory(
    WidgetRef ref,
    Transaction transaction,
    Category newCategory,
  ) async {
    // Update transaction
    final updated = transaction.copyWith(
      category: newCategory,
      categorizationMethod: CategorizationMethod.userCorrected,
      categoryConfidence: 1.0,
    );
    
    await ref.read(transactionProvider.notifier).update(updated);
    
    // Add to merchant database
    if (transaction.merchant != null) {
      await ref.read(merchantDatabaseProvider)
          .addMapping(transaction.merchant!, newCategory);
    }
    
    // Collect for training
    await ref.read(trainingDataCollectorProvider)
        .addExample(updated);
    
    // Check if we should retrain
    await _checkRetraining(ref);
  }
  
  Future<void> _checkRetraining(WidgetRef ref) async {
    final collector = ref.read(trainingDataCollectorProvider);
    final exampleCount = await collector.getExampleCount();
    
    // Retrain after 100 corrections
    if (exampleCount >= 100) {
      // Trigger model retraining (background task)
      ref.read(mlRetrainingProvider).scheduleRetraining();
    }
  }
}
```

---

## 🎯 Hybrid Categorization Service

```dart
class CategorizationService {
  final RuleBasedCategorizer _ruleCategor izer;
  final MLCategorizer _mlCategorizer;
  final MerchantDatabase _merchantDB;
  
  CategorizationService({
    required RuleBasedCategorizer ruleCategorizer,
    required MLCategorizer mlCategorizer,
    required MerchantDatabase merchantDB,
  })  : _ruleCategorizer = ruleCategorizer,
        _mlCategorizer = mlCategorizer,
        _merchantDB = merchantDB;
  
  /// Categorize transaction using hybrid approach
  Future<CategoryResult> categorize(ParsedTransaction txn) async {
    // Step 1: Try ML (if available and enabled)
    if (await _isMLEnabled()) {
      final mlResult = await _mlCategorizer.predict(txn);
      if (mlResult != null && mlResult.confidence > 0.85) {
        return mlResult;
      }
    }
    
    // Step 2: Try rule-based
    final ruleResult = _ruleCategorizer.categorize(txn);
    if (ruleResult.confidence > 0.8) {
      return ruleResult;
    }
    
    // Step 3: Check merchant database
    if (txn.merchant != null) {
      final category = await _merchantDB.lookup(txn.merchant);
      if (category != null) {
        return CategoryResult(
          category: category,
          confidence: 0.9,
          method: CategorizationMethod.merchantDatabase,
        );
      }
    }
    
    // Step 4: Default to "Others" with flag for review
    return CategoryResult(
      category: Category.others,
      confidence: 0.3,
      method: CategorizationMethod.ruleBased,
      needsReview: true,
      reason: 'Low confidence, needs manual review',
    );
  }
  
  Future<bool> _isMLEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('ml_enabled') ?? false;
  }
}
```

---

## 📊 Performance Metrics

### Track Categorization Accuracy

```dart
class CategorizationMetrics {
  final Map<CategorizationMethod, int> _methodCounts = {};
  final Map<CategorizationMethod, int> _correctionCounts = {};
  
  void recordCategorization(CategoryResult result) {
    final method = result.method;
    _methodCounts[method] = (_methodCounts[method] ?? 0) + 1;
  }
  
  void recordCorrection(CategorizationMethod originalMethod) {
    _correctionCounts[originalMethod] = 
        (_correctionCounts[originalMethod] ?? 0) + 1;
  }
  
  double getAccuracy(CategorizationMethod method) {
    final total = _methodCounts[method] ?? 0;
    final corrections = _correctionCounts[method] ?? 0;
    
    if (total == 0) return 0.0;
    return ((total - corrections) / total) * 100;
  }
  
  Map<String, dynamic> getSummary() {
    return {
      'rule_based_accuracy': getAccuracy(CategorizationMethod.ruleBased),
      'ml_accuracy': getAccuracy(CategorizationMethod.machineLearning),
      'merchant_db_accuracy': getAccuracy(CategorizationMethod.merchantDatabase),
      'total_categorizations': _methodCounts.values.fold(0, (a, b) => a + b),
      'total_corrections': _correctionCounts.values.fold(0, (a, b) => a + b),
    };
  }
}
```

---

**Next**: See `06_DATABASE_SCHEMA.md` for database design

**Last Updated**: October 19, 2025
