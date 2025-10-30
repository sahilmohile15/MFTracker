/// Database helper singleton for SQLite operations
library;

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../utils/constants.dart';

/// Singleton class to manage SQLite database operations
class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._internal();
  static Database? _database;

  DatabaseHelper._internal();

  /// Get database instance
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// Initialize database
  Future<Database> _initDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, DatabaseConfig.databaseName);

    return await openDatabase(
      path,
      version: DatabaseConfig.databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      onOpen: _onOpen,
    );
  }

  /// Create database tables
  Future<void> _onCreate(Database db, int version) async {
    await _createTables(db);
    await _createIndexes(db);
    await _insertDefaultData(db);
  }

  /// Handle database upgrades
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Migration logic will be added here in future versions
    if (oldVersion < newVersion) {
      // Example: if (oldVersion < 2) { await _migrateToV2(db); }
    }
  }

  /// Called when database is opened
  Future<void> _onOpen(Database db) async {
    // Enable foreign key constraints
    await db.execute('PRAGMA foreign_keys = ON');
  }

  /// Create all database tables
  Future<void> _createTables(Database db) async {
    // 1. Accounts Table
    await db.execute('''
      CREATE TABLE accounts (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        type TEXT NOT NULL,
        institution TEXT NOT NULL,
        account_number TEXT,
        balance REAL,
        credit_limit REAL,
        currency TEXT DEFAULT 'INR',
        color TEXT,
        icon TEXT,
        is_active INTEGER DEFAULT 1,
        include_in_total INTEGER DEFAULT 1,
        default_category TEXT,
        notes TEXT,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');

    // 2. Transactions Table
    await db.execute('''
      CREATE TABLE transactions (
        id TEXT PRIMARY KEY,
        amount REAL NOT NULL,
        type TEXT NOT NULL,
        category TEXT NOT NULL,
        categorization_method TEXT NOT NULL,
        timestamp INTEGER NOT NULL,
        description TEXT NOT NULL,
        account_id TEXT NOT NULL,
        account_number TEXT,
        merchant_name TEXT,
        upi_transaction_id TEXT,
        upi_id TEXT,
        payment_method TEXT,
        balance_after REAL,
        sms_body TEXT,
        sms_sender TEXT,
        sms_timestamp INTEGER,
        is_recurring INTEGER DEFAULT 0,
        recurring_parent_id TEXT,
        tags TEXT,
        notes TEXT,
        categorization_confidence REAL DEFAULT 0.0,
        is_manually_edited INTEGER DEFAULT 0,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        FOREIGN KEY (account_id) REFERENCES accounts (id) ON DELETE CASCADE,
        FOREIGN KEY (recurring_parent_id) REFERENCES recurring_transactions (id)
      )
    ''');

    // 3. Categories Table (for custom categories)
    await db.execute('''
      CREATE TABLE categories (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL UNIQUE,
        type TEXT NOT NULL,
        icon TEXT,
        color TEXT,
        parent_category TEXT,
        is_system INTEGER DEFAULT 0,
        is_active INTEGER DEFAULT 1,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');

    // 4. Budgets Table
    await db.execute('''
      CREATE TABLE budgets (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        amount REAL NOT NULL,
        period TEXT NOT NULL,
        category TEXT,
        account_id TEXT,
        start_date INTEGER NOT NULL,
        end_date INTEGER,
        is_active INTEGER DEFAULT 1,
        notifications_enabled INTEGER DEFAULT 1,
        alert_threshold REAL DEFAULT 80.0,
        description TEXT,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        FOREIGN KEY (account_id) REFERENCES accounts (id) ON DELETE CASCADE
      )
    ''');

    // 5. Recurring Transactions Table
    await db.execute('''
      CREATE TABLE recurring_transactions (
        id TEXT PRIMARY KEY,
        amount REAL NOT NULL,
        type TEXT NOT NULL,
        category TEXT NOT NULL,
        description TEXT NOT NULL,
        account_id TEXT NOT NULL,
        frequency TEXT NOT NULL,
        interval_value INTEGER NOT NULL,
        start_date INTEGER NOT NULL,
        end_date INTEGER,
        next_occurrence INTEGER NOT NULL,
        last_occurrence INTEGER,
        is_active INTEGER DEFAULT 1,
        auto_categorize INTEGER DEFAULT 1,
        merchant_name TEXT,
        notes TEXT,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        FOREIGN KEY (account_id) REFERENCES accounts (id) ON DELETE CASCADE
      )
    ''');

    // 6. Tags Table
    await db.execute('''
      CREATE TABLE tags (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL UNIQUE,
        color TEXT,
        created_at INTEGER NOT NULL
      )
    ''');

    // 7. Transaction Tags Junction Table
    await db.execute('''
      CREATE TABLE transaction_tags (
        transaction_id TEXT NOT NULL,
        tag_id TEXT NOT NULL,
        created_at INTEGER NOT NULL,
        PRIMARY KEY (transaction_id, tag_id),
        FOREIGN KEY (transaction_id) REFERENCES transactions (id) ON DELETE CASCADE,
        FOREIGN KEY (tag_id) REFERENCES tags (id) ON DELETE CASCADE
      )
    ''');

    // 8. SMS Messages Table (for tracking processed SMS)
    await db.execute('''
      CREATE TABLE sms_messages (
        id TEXT PRIMARY KEY,
        sender TEXT NOT NULL,
        body TEXT NOT NULL,
        timestamp INTEGER NOT NULL,
        is_processed INTEGER DEFAULT 0,
        is_transaction INTEGER DEFAULT 0,
        transaction_id TEXT,
        parsing_confidence REAL DEFAULT 0.0,
        error_message TEXT,
        created_at INTEGER NOT NULL,
        FOREIGN KEY (transaction_id) REFERENCES transactions (id) ON DELETE SET NULL
      )
    ''');

    // 9. Sync Status Table
    await db.execute('''
      CREATE TABLE sync_status (
        id TEXT PRIMARY KEY,
        last_sync INTEGER NOT NULL,
        sync_type TEXT NOT NULL,
        status TEXT NOT NULL,
        sms_count INTEGER DEFAULT 0,
        transactions_created INTEGER DEFAULT 0,
        transactions_updated INTEGER DEFAULT 0,
        errors_count INTEGER DEFAULT 0,
        duration_ms INTEGER,
        created_at INTEGER NOT NULL
      )
    ''');
  }

  /// Create database indexes for performance
  Future<void> _createIndexes(Database db) async {
    // Transactions indexes
    await db.execute(
      'CREATE INDEX idx_transactions_account_id ON transactions(account_id)',
    );
    await db.execute(
      'CREATE INDEX idx_transactions_timestamp ON transactions(timestamp DESC)',
    );
    await db.execute(
      'CREATE INDEX idx_transactions_category ON transactions(category)',
    );
    await db.execute(
      'CREATE INDEX idx_transactions_type ON transactions(type)',
    );
    await db.execute(
      'CREATE INDEX idx_transactions_merchant ON transactions(merchant_name)',
    );

    // SMS Messages indexes
    await db.execute(
      'CREATE INDEX idx_sms_timestamp ON sms_messages(timestamp DESC)',
    );
    await db.execute(
      'CREATE INDEX idx_sms_sender ON sms_messages(sender)',
    );
    await db.execute(
      'CREATE INDEX idx_sms_processed ON sms_messages(is_processed)',
    );

    // Budgets indexes
    await db.execute(
      'CREATE INDEX idx_budgets_category ON budgets(category)',
    );
    await db.execute(
      'CREATE INDEX idx_budgets_account_id ON budgets(account_id)',
    );
    await db.execute(
      'CREATE INDEX idx_budgets_active ON budgets(is_active)',
    );

    // Recurring Transactions indexes
    await db.execute(
      'CREATE INDEX idx_recurring_next_occurrence ON recurring_transactions(next_occurrence)',
    );
    await db.execute(
      'CREATE INDEX idx_recurring_active ON recurring_transactions(is_active)',
    );

    // Tags indexes
    await db.execute(
      'CREATE INDEX idx_transaction_tags_transaction ON transaction_tags(transaction_id)',
    );
    await db.execute(
      'CREATE INDEX idx_transaction_tags_tag ON transaction_tags(tag_id)',
    );
  }

  /// Insert default data (system categories, default account)
  Future<void> _insertDefaultData(Database db) async {
    final now = DateTime.now().millisecondsSinceEpoch;

    // Insert system categories (matching the Category enum)
    final systemCategories = [
      {'name': 'upiPayments', 'type': 'debit', 'icon': 'payment', 'color': '0xFF2196F3'},
      {'name': 'foodDelivery', 'type': 'debit', 'icon': 'fastfood', 'color': '0xFFFF9800'},
      {'name': 'shopping', 'type': 'debit', 'icon': 'shopping_bag', 'color': '0xFF9C27B0'},
      {'name': 'groceries', 'type': 'debit', 'icon': 'shopping_cart', 'color': '0xFF4CAF50'},
      {'name': 'transportation', 'type': 'debit', 'icon': 'directions_car', 'color': '0xFF009688'},
      {'name': 'entertainment', 'type': 'debit', 'icon': 'movie', 'color': '0xFFE91E63'},
      {'name': 'billPayments', 'type': 'debit', 'icon': 'receipt', 'color': '0xFFF44336'},
      {'name': 'recharge', 'type': 'debit', 'icon': 'phone_android', 'color': '0xFF3F51B5'},
      {'name': 'cardPayments', 'type': 'debit', 'icon': 'credit_card', 'color': '0xFFFFC107'},
      {'name': 'bankTransfers', 'type': 'both', 'icon': 'account_balance', 'color': '0xFF00BCD4'},
      {'name': 'atmWithdrawals', 'type': 'debit', 'icon': 'atm', 'color': '0xFF795548'},
      {'name': 'emi', 'type': 'debit', 'icon': 'payment', 'color': '0xFFFF5722'},
      {'name': 'subscriptions', 'type': 'debit', 'icon': 'subscriptions', 'color': '0xFF673AB7'},
      {'name': 'healthcare', 'type': 'debit', 'icon': 'medical_services', 'color': '0xFFE57373'},
      {'name': 'income', 'type': 'credit', 'icon': 'trending_up', 'color': '0xFF8BC34A'},
      {'name': 'investment', 'type': 'both', 'icon': 'show_chart', 'color': '0xFF1976D2'},
      {'name': 'others', 'type': 'both', 'icon': 'more_horiz', 'color': '0xFF9E9E9E'},
    ];

    for (final category in systemCategories) {
      await db.insert('categories', {
        'id': 'cat_${category['name']}',
        'name': category['name'],
        'type': category['type'],
        'icon': category['icon'],
        'color': category['color'],
        'parent_category': null,
        'is_system': 1,
        'is_active': 1,
        'created_at': now,
        'updated_at': now,
      });
    }
  }

  /// Close database connection
  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }

  /// Delete database (for testing/reset)
  Future<void> deleteDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, DatabaseConfig.databaseName);
    await databaseFactory.deleteDatabase(path);
    _database = null;
  }

  /// Clear all data from database (keeps structure, deletes data)
  Future<void> clearAllData() async {
    final db = await database;
    await db.transaction((txn) async {
      // Delete in order to respect foreign key constraints
      // Junction tables first
      await txn.delete('transaction_tags');
      
      // Dependent tables
      await txn.delete('transactions');
      await txn.delete('budgets');
      await txn.delete('recurring_transactions');
      
      // Parent tables
      await txn.delete('accounts');
      await txn.delete('categories');
      await txn.delete('tags');
      
      // Optional: Clear SMS tracking
      await txn.delete('sms_messages');
    });
    
    // Re-insert default data
    await _insertDefaultData(db);
  }

  /// Check if database exists
  Future<bool> databaseExists() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, DatabaseConfig.databaseName);
    return await databaseFactory.databaseExists(path);
  }

  /// Get database file size in bytes
  Future<int> getDatabaseSize() async {
    // Size calculation would need platform-specific implementation
    // For now, return 0 as placeholder
    return 0;
  }
}
