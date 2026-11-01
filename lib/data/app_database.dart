import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import '../models/budget.dart';
import '../models/finance_transaction.dart';

class AppDatabase {
  AppDatabase._();

  static final AppDatabase instance =
  AppDatabase._();

  static const _databaseName = 'cashtrail.db';
  static const _databaseVersion = 1;

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;

    final directory = await getDatabasesPath();
    final databasePath = p.join(
      directory,
      _databaseName,
    );

    _database = await openDatabase(
      databasePath,
      version: _databaseVersion,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE transactions (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            amount REAL NOT NULL CHECK(amount > 0),
            type TEXT NOT NULL
              CHECK(type IN ('income', 'expense')),
            category TEXT NOT NULL,
            date TEXT NOT NULL,
            payment_method TEXT NOT NULL,
            note TEXT NOT NULL DEFAULT ''
          )
        ''');

        await db.execute('''
          CREATE TABLE budgets (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            category TEXT NOT NULL,
            amount REAL NOT NULL CHECK(amount > 0),
            month TEXT NOT NULL,
            UNIQUE(category, month)
          )
        ''');

        await db.execute(
          'CREATE INDEX idx_transactions_date '
              'ON transactions(date)',
        );

        await db.execute(
          'CREATE INDEX idx_transactions_type '
              'ON transactions(type)',
        );
      },
    );

    return _database!;
  }

  // GET ALL TRANSACTIONS

  Future<List<FinanceTransaction>>
  getTransactions() async {
    final db = await database;

    final rows = await db.query(
      'transactions',
      orderBy: 'date DESC, id DESC',
    );

    return rows
        .map(FinanceTransaction.fromMap)
        .toList();
  }

  // INSERT TRANSACTION

  Future<int> insertTransaction(
      FinanceTransaction transaction) async {
    final db = await database;

    return db.insert(
      'transactions',
      transaction.toMap(),
    );
  }

  // UPDATE TRANSACTION

  Future<int> updateTransaction(
      FinanceTransaction transaction) async {
    if (transaction.id == null) {
      throw ArgumentError(
        'Transaction ID is required.',
      );
    }

    final db = await database;

    final values = transaction.toMap()
      ..remove('id');

    return db.update(
      'transactions',
      values,
      where: 'id = ?',
      whereArgs: [transaction.id],
    );
  }

  // DELETE TRANSACTION

  Future<int> deleteTransaction(int id) async {
    final db = await database;

    return db.delete(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // GET BUDGETS

  Future<List<Budget>> getBudgets() async {
    final db = await database;

    final rows = await db.query(
      'budgets',
      orderBy: 'month DESC, category ASC',
    );

    return rows.map(Budget.fromMap).toList();
  }

  // INSERT OR UPDATE BUDGET

  Future<void> saveBudget(Budget budget) async {
    final db = await database;

    final values = budget.toMap()
      ..remove('id');

    await db.insert(
      'budgets',
      values,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // DELETE BUDGET

  Future<int> deleteBudget(int id) async {
    final db = await database;

    return db.delete(
      'budgets',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}