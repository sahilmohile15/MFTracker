import 'package:sqflite/sqflite.dart';

import 'database_helper.dart';

/// Repository for managing tags and transaction-tag associations
class TagRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // ========== Tag Management ==========

  /// Insert a new tag
  Future<int> insertTag({
    required String name,
    String? color,
    String? icon,
  }) async {
    final db = await _dbHelper.database;
    return await db.insert(
      'tags',
      {
        'name': name,
        'color': color,
        'icon': icon,
        'created_at': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  /// Update a tag
  Future<int> updateTag({
    required int id,
    required String name,
    String? color,
    String? icon,
  }) async {
    final db = await _dbHelper.database;
    return await db.update(
      'tags',
      {
        'name': name,
        'color': color,
        'icon': icon,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Delete a tag (also removes all associations)
  Future<int> deleteTag(int id) async {
    final db = await _dbHelper.database;
    // Foreign key CASCADE will automatically delete associations
    return await db.delete(
      'tags',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Get tag by ID
  Future<Map<String, dynamic>?> getTagById(int id) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'tags',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;
    return maps.first;
  }

  /// Get tag by name
  Future<Map<String, dynamic>?> getTagByName(String name) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'tags',
      where: 'name = ?',
      whereArgs: [name],
    );

    if (maps.isEmpty) return null;
    return maps.first;
  }

  /// Get all tags
  Future<List<Map<String, dynamic>>> getAllTags() async {
    final db = await _dbHelper.database;
    return await db.query(
      'tags',
      orderBy: 'name ASC',
    );
  }

  /// Get tags with usage count
  Future<List<Map<String, dynamic>>> getTagsWithUsageCount() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT 
        t.id,
        t.name,
        t.color,
        t.icon,
        t.created_at,
        COUNT(tt.transaction_id) as usage_count
      FROM tags t
      LEFT JOIN transaction_tags tt ON t.id = tt.tag_id
      GROUP BY t.id
      ORDER BY usage_count DESC, t.name ASC
    ''');

    return maps;
  }

  /// Get most used tags (top N)
  Future<List<Map<String, dynamic>>> getMostUsedTags({int limit = 10}) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT 
        t.id,
        t.name,
        t.color,
        t.icon,
        COUNT(tt.transaction_id) as usage_count
      FROM tags t
      INNER JOIN transaction_tags tt ON t.id = tt.tag_id
      GROUP BY t.id
      ORDER BY usage_count DESC
      LIMIT ?
    ''', [limit]);

    return maps;
  }

  /// Get unused tags (tags with no transactions)
  Future<List<Map<String, dynamic>>> getUnusedTags() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT t.*
      FROM tags t
      LEFT JOIN transaction_tags tt ON t.id = tt.tag_id
      WHERE tt.transaction_id IS NULL
      ORDER BY t.name ASC
    ''');

    return maps;
  }

  /// Search tags by name
  Future<List<Map<String, dynamic>>> searchTags(String query) async {
    final db = await _dbHelper.database;
    return await db.query(
      'tags',
      where: 'name LIKE ?',
      whereArgs: ['%$query%'],
      orderBy: 'name ASC',
    );
  }

  /// Get count of tags
  Future<int> getTagCount() async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM tags');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // ========== Transaction-Tag Association Management ==========

  /// Add tag to transaction
  Future<int> addTagToTransaction(int transactionId, int tagId) async {
    final db = await _dbHelper.database;
    return await db.insert(
      'transaction_tags',
      {
        'transaction_id': transactionId,
        'tag_id': tagId,
        'created_at': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  /// Add multiple tags to transaction
  Future<void> addTagsToTransaction(int transactionId, List<int> tagIds) async {
    final db = await _dbHelper.database;
    final batch = db.batch();
    final now = DateTime.now().toIso8601String();

    for (final tagId in tagIds) {
      batch.insert(
        'transaction_tags',
        {
          'transaction_id': transactionId,
          'tag_id': tagId,
          'created_at': now,
        },
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }

    await batch.commit(noResult: true);
  }

  /// Remove tag from transaction
  Future<int> removeTagFromTransaction(int transactionId, int tagId) async {
    final db = await _dbHelper.database;
    return await db.delete(
      'transaction_tags',
      where: 'transaction_id = ? AND tag_id = ?',
      whereArgs: [transactionId, tagId],
    );
  }

  /// Remove all tags from transaction
  Future<int> removeAllTagsFromTransaction(int transactionId) async {
    final db = await _dbHelper.database;
    return await db.delete(
      'transaction_tags',
      where: 'transaction_id = ?',
      whereArgs: [transactionId],
    );
  }

  /// Replace transaction tags (remove old, add new)
  Future<void> replaceTransactionTags(int transactionId, List<int> tagIds) async {
    final db = await _dbHelper.database;
    await db.transaction((txn) async {
      // Remove existing tags
      await txn.delete(
        'transaction_tags',
        where: 'transaction_id = ?',
        whereArgs: [transactionId],
      );

      // Add new tags
      final now = DateTime.now().toIso8601String();
      final batch = txn.batch();
      for (final tagId in tagIds) {
        batch.insert(
          'transaction_tags',
          {
            'transaction_id': transactionId,
            'tag_id': tagId,
            'created_at': now,
          },
        );
      }
      await batch.commit(noResult: true);
    });
  }

  /// Get tags for a transaction
  Future<List<Map<String, dynamic>>> getTagsForTransaction(int transactionId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT t.*
      FROM tags t
      INNER JOIN transaction_tags tt ON t.id = tt.tag_id
      WHERE tt.transaction_id = ?
      ORDER BY t.name ASC
    ''', [transactionId]);

    return maps;
  }

  /// Get transactions for a tag
  Future<List<Map<String, dynamic>>> getTransactionsForTag(int tagId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT trans.*
      FROM transactions trans
      INNER JOIN transaction_tags tt ON trans.id = tt.transaction_id
      WHERE tt.tag_id = ?
      ORDER BY trans.timestamp DESC
    ''', [tagId]);

    return maps;
  }

  /// Get transaction count for a tag
  Future<int> getTransactionCountForTag(int tagId) async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM transaction_tags WHERE tag_id = ?',
      [tagId],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// Check if transaction has tag
  Future<bool> transactionHasTag(int transactionId, int tagId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'transaction_tags',
      where: 'transaction_id = ? AND tag_id = ?',
      whereArgs: [transactionId, tagId],
    );
    return maps.isNotEmpty;
  }

  /// Get tag statistics
  Future<Map<String, dynamic>> getTagStatistics(int tagId) async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery('''
      SELECT 
        COUNT(DISTINCT tt.transaction_id) as transaction_count,
        SUM(CASE WHEN trans.type = 'debit' THEN trans.amount ELSE 0 END) as total_debit,
        SUM(CASE WHEN trans.type = 'credit' THEN trans.amount ELSE 0 END) as total_credit,
        AVG(trans.amount) as avg_amount,
        MIN(trans.timestamp) as first_used,
        MAX(trans.timestamp) as last_used
      FROM transaction_tags tt
      INNER JOIN transactions trans ON tt.transaction_id = trans.id
      WHERE tt.tag_id = ?
    ''', [tagId]);

    if (result.isEmpty) {
      return {
        'transactionCount': 0,
        'totalDebit': 0.0,
        'totalCredit': 0.0,
        'avgAmount': 0.0,
        'firstUsed': null,
        'lastUsed': null,
      };
    }

    final data = result.first;
    return {
      'transactionCount': data['transaction_count'] ?? 0,
      'totalDebit': (data['total_debit'] as num?)?.toDouble() ?? 0.0,
      'totalCredit': (data['total_credit'] as num?)?.toDouble() ?? 0.0,
      'avgAmount': (data['avg_amount'] as num?)?.toDouble() ?? 0.0,
      'firstUsed': data['first_used'],
      'lastUsed': data['last_used'],
    };
  }

  /// Get tags by color
  Future<List<Map<String, dynamic>>> getTagsByColor(String color) async {
    final db = await _dbHelper.database;
    return await db.query(
      'tags',
      where: 'color = ?',
      whereArgs: [color],
      orderBy: 'name ASC',
    );
  }

  /// Batch create tags
  Future<void> batchCreateTags(List<Map<String, String>> tags) async {
    final db = await _dbHelper.database;
    final batch = db.batch();
    final now = DateTime.now().toIso8601String();

    for (final tag in tags) {
      batch.insert(
        'tags',
        {
          'name': tag['name'],
          'color': tag['color'],
          'icon': tag['icon'],
          'created_at': now,
        },
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }

    await batch.commit(noResult: true);
  }

  /// Delete all tags (for testing/reset)
  Future<int> deleteAllTags() async {
    final db = await _dbHelper.database;
    return await db.delete('tags');
  }

  /// Delete all transaction-tag associations (for testing/reset)
  Future<int> deleteAllAssociations() async {
    final db = await _dbHelper.database;
    return await db.delete('transaction_tags');
  }
}
