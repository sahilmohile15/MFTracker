import 'package:sqflite/sqflite.dart';

import '../models/budget.dart';
import '../utils/constants.dart';
import 'database_helper.dart';

/// Repository for managing budgets
class BudgetRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  /// Insert a new budget
  Future<int> insert(Budget budget) async {
    final db = await _dbHelper.database;
    return await db.insert(
      'budgets',
      budget.toDatabase(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Update an existing budget
  Future<int> update(Budget budget) async {
    final db = await _dbHelper.database;
    return await db.update(
      'budgets',
      budget.toDatabase(),
      where: 'id = ?',
      whereArgs: [budget.id],
    );
  }

  /// Delete a budget
  Future<int> delete(String id) async {
    final db = await _dbHelper.database;
    return await db.delete(
      'budgets',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Get budget by ID
  Future<Budget?> getById(String id) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'budgets',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;
    return Budget.fromDatabase(maps.first);
  }

  /// Get all budgets
  Future<List<Budget>> getAll({
    bool activeOnly = false,
    int? limit,
    int? offset,
  }) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'budgets',
      where: activeOnly ? 'is_active = ?' : null,
      whereArgs: activeOnly ? [1] : null,
      orderBy: 'created_at DESC',
      limit: limit,
      offset: offset,
    );

    return maps.map((map) => Budget.fromDatabase(map)).toList();
  }

  /// Get budgets by category
  Future<List<Budget>> getByCategory(Category category, {bool activeOnly = true}) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'budgets',
      where: activeOnly 
          ? 'category = ? AND is_active = ?' 
          : 'category = ?',
      whereArgs: activeOnly 
          ? [category.name, 1] 
          : [category.name],
      orderBy: 'created_at DESC',
    );

    return maps.map((map) => Budget.fromDatabase(map)).toList();
  }

  /// Get budgets by account
  Future<List<Budget>> getByAccount(int accountId, {bool activeOnly = true}) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'budgets',
      where: activeOnly 
          ? 'account_id = ? AND is_active = ?' 
          : 'account_id = ?',
      whereArgs: activeOnly 
          ? [accountId, 1] 
          : [accountId],
      orderBy: 'created_at DESC',
    );

    return maps.map((map) => Budget.fromDatabase(map)).toList();
  }

  /// Get budgets by period
  Future<List<Budget>> getByPeriod(BudgetPeriod period, {bool activeOnly = true}) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'budgets',
      where: activeOnly 
          ? 'period = ? AND is_active = ?' 
          : 'period = ?',
      whereArgs: activeOnly 
          ? [period.name, 1] 
          : [period.name],
      orderBy: 'created_at DESC',
    );

    return maps.map((map) => Budget.fromDatabase(map)).toList();
  }

  /// Get active budgets (convenience method)
  Future<List<Budget>> getActive() async {
    return getAll(activeOnly: true);
  }

  /// Get count of budgets
  Future<int> getCount({bool activeOnly = false}) async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery(
      activeOnly 
          ? 'SELECT COUNT(*) as count FROM budgets WHERE is_active = 1'
          : 'SELECT COUNT(*) as count FROM budgets',
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// Update spent amount for a budget
  Future<int> updateSpentAmount(String budgetId, double spentAmount) async {
    final db = await _dbHelper.database;
    return await db.update(
      'budgets',
      {'spent_amount': spentAmount},
      where: 'id = ?',
      whereArgs: [budgetId],
    );
  }

  /// Increment spent amount for a budget
  Future<void> incrementSpentAmount(String budgetId, double amount) async {
    final db = await _dbHelper.database;
    await db.rawUpdate(
      'UPDATE budgets SET spent_amount = spent_amount + ? WHERE id = ?',
      [amount, budgetId],
    );
  }

  /// Decrement spent amount for a budget
  Future<void> decrementSpentAmount(String budgetId, double amount) async {
    final db = await _dbHelper.database;
    await db.rawUpdate(
      'UPDATE budgets SET spent_amount = spent_amount - ? WHERE id = ?',
      [amount, budgetId],
    );
  }

  /// Reset spent amount for a budget (for new period)
  Future<int> resetSpentAmount(String budgetId) async {
    return updateSpentAmount(budgetId, 0.0);
  }

  /// Get budgets that need alert (spent >= alert threshold)
  Future<List<Budget>> getBudgetsNeedingAlert() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT * FROM budgets 
      WHERE is_active = 1 
      AND (spent_amount / amount) >= (alert_threshold / 100.0)
      AND last_alert_at IS NULL OR last_alert_at < datetime('now', '-1 day')
      ORDER BY (spent_amount / amount) DESC
    ''');

    return maps.map((map) => Budget.fromDatabase(map)).toList();
  }

  /// Get budgets exceeding limit
  Future<List<Budget>> getOverBudget() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT * FROM budgets 
      WHERE is_active = 1 
      AND spent_amount > amount
      ORDER BY (spent_amount - amount) DESC
    ''');

    return maps.map((map) => Budget.fromDatabase(map)).toList();
  }

  /// Update last alert timestamp
  Future<int> updateLastAlert(int budgetId, DateTime alertTime) async {
    final db = await _dbHelper.database;
    return await db.update(
      'budgets',
      {'last_alert_at': alertTime.toIso8601String()},
      where: 'id = ?',
      whereArgs: [budgetId],
    );
  }

  /// Get budget summary (total allocated vs spent)
  Future<Map<String, double>> getBudgetSummary({bool activeOnly = true}) async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery(
      activeOnly
          ? 'SELECT SUM(amount) as total_budget, SUM(spent_amount) as total_spent FROM budgets WHERE is_active = 1'
          : 'SELECT SUM(amount) as total_budget, SUM(spent_amount) as total_spent FROM budgets',
    );

    if (result.isEmpty) {
      return {'totalBudget': 0.0, 'totalSpent': 0.0};
    }

    return {
      'totalBudget': (result.first['total_budget'] as num?)?.toDouble() ?? 0.0,
      'totalSpent': (result.first['total_spent'] as num?)?.toDouble() ?? 0.0,
    };
  }

  /// Get budgets by category with spending percentage
  Future<List<Map<String, dynamic>>> getBudgetsByCategory() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT 
        category,
        SUM(amount) as total_budget,
        SUM(spent_amount) as total_spent,
        (SUM(spent_amount) / SUM(amount) * 100) as percentage
      FROM budgets
      WHERE is_active = 1
      GROUP BY category
      ORDER BY percentage DESC
    ''');

    return maps;
  }

  /// Deactivate (soft delete) a budget
  Future<int> deactivate(int budgetId) async {
    final db = await _dbHelper.database;
    return await db.update(
      'budgets',
      {'is_active': 0},
      where: 'id = ?',
      whereArgs: [budgetId],
    );
  }

  /// Reactivate a budget
  Future<int> reactivate(int budgetId) async {
    final db = await _dbHelper.database;
    return await db.update(
      'budgets',
      {'is_active': 1},
      where: 'id = ?',
      whereArgs: [budgetId],
    );
  }

  /// Delete all budgets (for testing/reset)
  Future<int> deleteAll() async {
    final db = await _dbHelper.database;
    return await db.delete('budgets');
  }
}
