/// Repository for Account CRUD operations
library;

import 'package:sqflite/sqflite.dart';
import '../models/account.dart';
import 'database_helper.dart';

/// Repository class for managing accounts in the database
class AccountRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  /// Insert a new account
  Future<void> insert(Account account) async {
    final db = await _dbHelper.database;
    await db.insert(
      'accounts',
      account.toDatabase(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Update an existing account
  Future<int> update(Account account) async {
    final db = await _dbHelper.database;
    return await db.update(
      'accounts',
      account.toDatabase(),
      where: 'id = ?',
      whereArgs: [account.id],
    );
  }

  /// Delete an account by ID
  Future<int> delete(String id) async {
    final db = await _dbHelper.database;
    return await db.delete(
      'accounts',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Get account by ID
  Future<Account?> getById(String id) async {
    final db = await _dbHelper.database;
    final results = await db.query(
      'accounts',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (results.isEmpty) return null;
    return Account.fromDatabase(results.first);
  }

  /// Get all accounts
  Future<List<Account>> getAll({bool activeOnly = false}) async {
    final db = await _dbHelper.database;
    final results = await db.query(
      'accounts',
      where: activeOnly ? 'is_active = ?' : null,
      whereArgs: activeOnly ? [1] : null,
      orderBy: 'name ASC',
    );

    return results.map((map) => Account.fromDatabase(map)).toList();
  }

  /// Get active accounts
  Future<List<Account>> getActive() async {
    return getAll(activeOnly: true);
  }

  /// Get account count
  Future<int> getCount() async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM accounts');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// Update account balance
  Future<int> updateBalance(String id, double newBalance) async {
    final db = await _dbHelper.database;
    return await db.update(
      'accounts',
      {
        'balance': newBalance,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Get total balance across all accounts
  Future<double> getTotalBalance({bool includeOnlyActive = true}) async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery('''
      SELECT SUM(balance) as total 
      FROM accounts 
      WHERE balance IS NOT NULL 
        AND include_in_total = 1
        ${includeOnlyActive ? 'AND is_active = 1' : ''}
    ''');

    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  /// Delete all accounts (use with caution!)
  Future<int> deleteAll() async {
    final db = await _dbHelper.database;
    return await db.delete('accounts');
  }
}
