import 'package:sqflite/sqflite.dart' hide Transaction;

import '../models/transaction.dart';
import '../utils/constants.dart';
import 'database_helper.dart';

/// Repository for managing recurring transactions
class RecurringTransactionRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  /// Insert a new recurring transaction template
  Future<int> insert(Transaction recurringTransaction) async {
    final db = await _dbHelper.database;
    return await db.insert(
      'recurring_transactions',
      recurringTransaction.toDatabase(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Update an existing recurring transaction
  Future<int> update(Transaction recurringTransaction) async {
    final db = await _dbHelper.database;
    return await db.update(
      'recurring_transactions',
      recurringTransaction.toDatabase(),
      where: 'id = ?',
      whereArgs: [recurringTransaction.id],
    );
  }

  /// Delete a recurring transaction
  Future<int> delete(int id) async {
    final db = await _dbHelper.database;
    return await db.delete(
      'recurring_transactions',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Get recurring transaction by ID
  Future<Transaction?> getById(int id) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'recurring_transactions',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;
    return Transaction.fromDatabase(maps.first);
  }

  /// Get all recurring transactions
  Future<List<Transaction>> getAll({
    bool activeOnly = false,
    int? limit,
    int? offset,
  }) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'recurring_transactions',
      where: activeOnly ? 'is_active = ?' : null,
      whereArgs: activeOnly ? [1] : null,
      orderBy: 'next_occurrence_date ASC',
      limit: limit,
      offset: offset,
    );

    return maps.map((map) => Transaction.fromDatabase(map)).toList();
  }

  /// Get active recurring transactions (not ended)
  Future<List<Transaction>> getActive() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'recurring_transactions',
      where: 'is_active = ? AND (end_date IS NULL OR end_date > ?)',
      whereArgs: [1, DateTime.now().toIso8601String()],
      orderBy: 'next_occurrence_date ASC',
    );

    return maps.map((map) => Transaction.fromDatabase(map)).toList();
  }

  /// Get recurring transactions by account
  Future<List<Transaction>> getByAccount(int accountId, {bool activeOnly = true}) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'recurring_transactions',
      where: activeOnly 
          ? 'account_id = ? AND is_active = ?' 
          : 'account_id = ?',
      whereArgs: activeOnly 
          ? [accountId, 1] 
          : [accountId],
      orderBy: 'next_occurrence_date ASC',
    );

    return maps.map((map) => Transaction.fromDatabase(map)).toList();
  }

  /// Get recurring transactions by category
  Future<List<Transaction>> getByCategory(Category category, {bool activeOnly = true}) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'recurring_transactions',
      where: activeOnly 
          ? 'category = ? AND is_active = ?' 
          : 'category = ?',
      whereArgs: activeOnly 
          ? [category.name, 1] 
          : [category.name],
      orderBy: 'next_occurrence_date ASC',
    );

    return maps.map((map) => Transaction.fromDatabase(map)).toList();
  }

  /// Get recurring transactions by type (debit/credit)
  Future<List<Transaction>> getByType(TransactionType type, {bool activeOnly = true}) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'recurring_transactions',
      where: activeOnly 
          ? 'type = ? AND is_active = ?' 
          : 'type = ?',
      whereArgs: activeOnly 
          ? [type.name, 1] 
          : [type.name],
      orderBy: 'next_occurrence_date ASC',
    );

    return maps.map((map) => Transaction.fromDatabase(map)).toList();
  }

  /// Get recurring transactions due for processing (next occurrence <= today)
  Future<List<Transaction>> getDueForProcessing() async {
    final db = await _dbHelper.database;
    final now = DateTime.now();
    final List<Map<String, dynamic>> maps = await db.query(
      'recurring_transactions',
      where: 'is_active = ? AND next_occurrence_date <= ? AND (end_date IS NULL OR end_date > ?)',
      whereArgs: [1, now.toIso8601String(), now.toIso8601String()],
      orderBy: 'next_occurrence_date ASC',
    );

    return maps.map((map) => Transaction.fromDatabase(map)).toList();
  }

  /// Update next occurrence date for a recurring transaction
  Future<int> updateNextOccurrence(int id, DateTime nextDate) async {
    final db = await _dbHelper.database;
    return await db.update(
      'recurring_transactions',
      {'next_occurrence_date': nextDate.toIso8601String()},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Increment occurrence count
  Future<void> incrementOccurrenceCount(int id) async {
    final db = await _dbHelper.database;
    await db.rawUpdate(
      'UPDATE recurring_transactions SET occurrence_count = occurrence_count + 1 WHERE id = ?',
      [id],
    );
  }

  /// Update last processed date
  Future<int> updateLastProcessed(int id, DateTime lastProcessed) async {
    final db = await _dbHelper.database;
    return await db.update(
      'recurring_transactions',
      {'last_occurrence_date': lastProcessed.toIso8601String()},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Get count of recurring transactions
  Future<int> getCount({bool activeOnly = false}) async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery(
      activeOnly 
          ? 'SELECT COUNT(*) as count FROM recurring_transactions WHERE is_active = 1'
          : 'SELECT COUNT(*) as count FROM recurring_transactions',
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// Get total monthly recurring amount by type
  Future<double> getMonthlyRecurringTotal(TransactionType type) async {
    final db = await _dbHelper.database;
    
    // This is a simplified calculation - actual implementation would need
    // to convert different frequencies to monthly equivalents
    final result = await db.rawQuery('''
      SELECT SUM(amount) as total 
      FROM recurring_transactions 
      WHERE is_active = 1 
      AND type = ?
      AND frequency = 'monthly'
      AND (end_date IS NULL OR end_date > ?)
    ''', [type.name, DateTime.now().toIso8601String()]);

    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  /// Get recurring transactions by frequency
  Future<List<Transaction>> getByFrequency(String frequency, {bool activeOnly = true}) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'recurring_transactions',
      where: activeOnly 
          ? 'frequency = ? AND is_active = ?' 
          : 'frequency = ?',
      whereArgs: activeOnly 
          ? [frequency, 1] 
          : [frequency],
      orderBy: 'next_occurrence_date ASC',
    );

    return maps.map((map) => Transaction.fromDatabase(map)).toList();
  }

  /// Get recurring transactions ending soon (within next 30 days)
  Future<List<Transaction>> getEndingSoon() async {
    final db = await _dbHelper.database;
    final now = DateTime.now();
    final thirtyDaysLater = now.add(const Duration(days: 30));
    
    final List<Map<String, dynamic>> maps = await db.query(
      'recurring_transactions',
      where: 'is_active = ? AND end_date IS NOT NULL AND end_date BETWEEN ? AND ?',
      whereArgs: [1, now.toIso8601String(), thirtyDaysLater.toIso8601String()],
      orderBy: 'end_date ASC',
    );

    return maps.map((map) => Transaction.fromDatabase(map)).toList();
  }

  /// Deactivate (soft delete) a recurring transaction
  Future<int> deactivate(int id) async {
    final db = await _dbHelper.database;
    return await db.update(
      'recurring_transactions',
      {'is_active': 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Reactivate a recurring transaction
  Future<int> reactivate(int id) async {
    final db = await _dbHelper.database;
    return await db.update(
      'recurring_transactions',
      {'is_active': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Update end date for a recurring transaction
  Future<int> updateEndDate(int id, DateTime? endDate) async {
    final db = await _dbHelper.database;
    return await db.update(
      'recurring_transactions',
      {'end_date': endDate?.toIso8601String()},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Delete all recurring transactions (for testing/reset)
  Future<int> deleteAll() async {
    final db = await _dbHelper.database;
    return await db.delete('recurring_transactions');
  }
}
