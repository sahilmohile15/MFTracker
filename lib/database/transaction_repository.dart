/// Repository for Transaction CRUD operations
library;

import 'package:sqflite/sqflite.dart' hide Transaction;
import '../models/transaction.dart';
import '../utils/constants.dart';
import 'database_helper.dart';

/// Repository class for managing transactions in the database
class TransactionRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  /// Insert a new transaction
  Future<void> insert(Transaction transaction) async {
    final db = await _dbHelper.database;
    await db.insert(
      'transactions',
      transaction.toDatabase(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Insert multiple transactions in a batch
  Future<void> insertBatch(List<Transaction> transactions) async {
    final db = await _dbHelper.database;
    final batch = db.batch();

    for (final transaction in transactions) {
      batch.insert(
        'transactions',
        transaction.toDatabase(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit(noResult: true);
  }

  /// Update an existing transaction
  Future<int> update(Transaction transaction) async {
    final db = await _dbHelper.database;
    return await db.update(
      'transactions',
      transaction.toDatabase(),
      where: 'id = ?',
      whereArgs: [transaction.id],
    );
  }

  /// Delete a transaction by ID
  Future<int> delete(String id) async {
    final db = await _dbHelper.database;
    return await db.delete(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Delete multiple transactions
  Future<int> deleteBatch(List<String> ids) async {
    final db = await _dbHelper.database;
    return await db.delete(
      'transactions',
      where: 'id IN (${List.filled(ids.length, '?').join(',')})',
      whereArgs: ids,
    );
  }

  /// Get transaction by ID
  Future<Transaction?> getById(String id) async {
    final db = await _dbHelper.database;
    final results = await db.query(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (results.isEmpty) return null;
    return Transaction.fromDatabase(results.first);
  }

  /// Get all transactions
  Future<List<Transaction>> getAll({
    int? limit,
    int? offset,
    String? orderBy,
  }) async {
    final db = await _dbHelper.database;
    final results = await db.query(
      'transactions',
      orderBy: orderBy ?? 'timestamp DESC',
      limit: limit,
      offset: offset,
    );

    return results.map((map) => Transaction.fromDatabase(map)).toList();
  }

  /// Get transactions by account
  Future<List<Transaction>> getByAccount(
    String accountId, {
    int? limit,
    int? offset,
  }) async {
    final db = await _dbHelper.database;
    final results = await db.query(
      'transactions',
      where: 'account_id = ?',
      whereArgs: [accountId],
      orderBy: 'timestamp DESC',
      limit: limit,
      offset: offset,
    );

    return results.map((map) => Transaction.fromDatabase(map)).toList();
  }

  /// Get transactions by category
  Future<List<Transaction>> getByCategory(
    Category category, {
    int? limit,
    int? offset,
  }) async {
    final db = await _dbHelper.database;
    final results = await db.query(
      'transactions',
      where: 'category = ?',
      whereArgs: [category.name],
      orderBy: 'timestamp DESC',
      limit: limit,
      offset: offset,
    );

    return results.map((map) => Transaction.fromDatabase(map)).toList();
  }

  /// Get transactions by type (debit/credit)
  Future<List<Transaction>> getByType(
    TransactionType type, {
    int? limit,
    int? offset,
  }) async {
    final db = await _dbHelper.database;
    final results = await db.query(
      'transactions',
      where: 'type = ?',
      whereArgs: [type.name],
      orderBy: 'timestamp DESC',
      limit: limit,
      offset: offset,
    );

    return results.map((map) => Transaction.fromDatabase(map)).toList();
  }

  /// Get transactions within a date range
  Future<List<Transaction>> getByDateRange(
    DateTime startDate,
    DateTime endDate, {
    int? limit,
    int? offset,
  }) async {
    final db = await _dbHelper.database;
    final results = await db.query(
      'transactions',
      where: 'timestamp BETWEEN ? AND ?',
      whereArgs: [
        startDate.millisecondsSinceEpoch,
        endDate.millisecondsSinceEpoch,
      ],
      orderBy: 'timestamp DESC',
      limit: limit,
      offset: offset,
    );

    return results.map((map) => Transaction.fromDatabase(map)).toList();
  }

  /// Check if a transaction already exists based on SMS details
  /// (prevents duplicate imports from SMS)
  Future<bool> isDuplicateSmsTransaction({
    required String smsBody,
    required DateTime smsTimestamp,
    required double amount,
  }) async {
    final db = await _dbHelper.database;
    
    // Check for exact SMS body match within 1 hour time window
    final timeStart = smsTimestamp.subtract(const Duration(hours: 1)).millisecondsSinceEpoch;
    final timeEnd = smsTimestamp.add(const Duration(hours: 1)).millisecondsSinceEpoch;
    
    final results = await db.query(
      'transactions',
      where: 'sms_body = ? AND amount = ? AND sms_timestamp BETWEEN ? AND ?',
      whereArgs: [smsBody, amount, timeStart, timeEnd],
      limit: 1,
    );

    return results.isNotEmpty;
  }

  /// Search transactions by description or merchant name
  Future<List<Transaction>> search(
    String query, {
    int? limit,
    int? offset,
  }) async {
    final db = await _dbHelper.database;
    final searchQuery = '%$query%';
    final results = await db.query(
      'transactions',
      where: 'description LIKE ? OR merchant_name LIKE ?',
      whereArgs: [searchQuery, searchQuery],
      orderBy: 'timestamp DESC',
      limit: limit,
      offset: offset,
    );

    return results.map((map) => Transaction.fromDatabase(map)).toList();
  }

  /// Get transaction count
  Future<int> getCount() async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM transactions');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// Get transaction count by category
  Future<Map<Category, int>> getCountByCategory() async {
    final db = await _dbHelper.database;
    final results = await db.rawQuery('''
      SELECT category, COUNT(*) as count 
      FROM transactions 
      GROUP BY category
    ''');

    final Map<Category, int> counts = {};
    for (final row in results) {
      final categoryName = row['category'] as String;
      final count = row['count'] as int;
      final category = Category.values.firstWhere(
        (c) => c.name == categoryName,
        orElse: () => Category.others,
      );
      counts[category] = count;
    }
    return counts;
  }

  /// Get total amount by type within date range
  Future<double> getTotalAmount(
    TransactionType type,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery('''
      SELECT SUM(amount) as total 
      FROM transactions 
      WHERE type = ? AND timestamp BETWEEN ? AND ?
    ''', [
      type.name,
      startDate.millisecondsSinceEpoch,
      endDate.millisecondsSinceEpoch,
    ]);

    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  /// Get spending by category within date range
  Future<Map<Category, double>> getSpendingByCategory(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final db = await _dbHelper.database;
    final results = await db.rawQuery('''
      SELECT category, SUM(amount) as total 
      FROM transactions 
      WHERE type = ? AND timestamp BETWEEN ? AND ?
      GROUP BY category
      ORDER BY total DESC
    ''', [
      TransactionType.debit.name,
      startDate.millisecondsSinceEpoch,
      endDate.millisecondsSinceEpoch,
    ]);

    final Map<Category, double> spending = {};
    for (final row in results) {
      final categoryName = row['category'] as String;
      final total = (row['total'] as num).toDouble();
      final category = Category.values.firstWhere(
        (c) => c.name == categoryName,
        orElse: () => Category.others,
      );
      spending[category] = total;
    }
    return spending;
  }

  /// Get daily spending trend
  Future<Map<DateTime, double>> getDailySpending(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final db = await _dbHelper.database;
    final results = await db.rawQuery('''
      SELECT 
        DATE(timestamp / 1000, 'unixepoch') as date,
        SUM(amount) as total
      FROM transactions
      WHERE type = ? AND timestamp BETWEEN ? AND ?
      GROUP BY date
      ORDER BY date
    ''', [
      TransactionType.debit.name,
      startDate.millisecondsSinceEpoch,
      endDate.millisecondsSinceEpoch,
    ]);

    final Map<DateTime, double> dailySpending = {};
    for (final row in results) {
      final dateStr = row['date'] as String;
      final total = (row['total'] as num).toDouble();
      final date = DateTime.parse(dateStr);
      dailySpending[date] = total;
    }
    return dailySpending;
  }

  /// Get top merchants by spending
  Future<Map<String, double>> getTopMerchants(
    int limit,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final db = await _dbHelper.database;
    final results = await db.rawQuery('''
      SELECT merchant_name, SUM(amount) as total
      FROM transactions
      WHERE merchant_name IS NOT NULL 
        AND type = ?
        AND timestamp BETWEEN ? AND ?
      GROUP BY merchant_name
      ORDER BY total DESC
      LIMIT ?
    ''', [
      TransactionType.debit.name,
      startDate.millisecondsSinceEpoch,
      endDate.millisecondsSinceEpoch,
      limit,
    ]);

    final Map<String, double> topMerchants = {};
    for (final row in results) {
      final merchant = row['merchant_name'] as String;
      final total = (row['total'] as num).toDouble();
      topMerchants[merchant] = total;
    }
    return topMerchants;
  }

  /// Get recent transactions
  Future<List<Transaction>> getRecent(int limit) async {
    return getAll(limit: limit, orderBy: 'timestamp DESC');
  }

  /// Get transactions for today
  Future<List<Transaction>> getToday() async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    return getByDateRange(startOfDay, endOfDay);
  }

  /// Get transactions for current month
  Future<List<Transaction>> getCurrentMonth() async {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
    return getByDateRange(startOfMonth, endOfMonth);
  }

  /// Get recurring transactions
  Future<List<Transaction>> getRecurring() async {
    final db = await _dbHelper.database;
    final results = await db.query(
      'transactions',
      where: 'is_recurring = ?',
      whereArgs: [1],
      orderBy: 'timestamp DESC',
    );

    return results.map((map) => Transaction.fromDatabase(map)).toList();
  }

  /// Delete all transactions (use with caution!)
  Future<int> deleteAll() async {
    final db = await _dbHelper.database;
    return await db.delete('transactions');
  }

  /// Get transactions that need categorization correction (low confidence)
  Future<List<Transaction>> getLowConfidenceTransactions({
    double threshold = 0.5,
    int? limit,
  }) async {
    final db = await _dbHelper.database;
    final results = await db.query(
      'transactions',
      where: 'categorization_confidence < ? AND is_manually_edited = 0',
      whereArgs: [threshold],
      orderBy: 'timestamp DESC',
      limit: limit,
    );

    return results.map((map) => Transaction.fromDatabase(map)).toList();
  }
}
