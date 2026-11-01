import 'package:flutter/foundation.dart';

import '../core/app_utils.dart';
import '../data/app_database.dart';
import '../models/budget.dart';
import '../models/finance_transaction.dart';

class FinanceProvider extends ChangeNotifier {
  final AppDatabase _database = AppDatabase.instance;

  List<FinanceTransaction> _transactions = [];
  List<Budget> _budgets = [];

  bool _isLoading = true;
  String? _loadError;

  List<FinanceTransaction> get transactions =>
      List.unmodifiable(_transactions);

  List<Budget> get budgets =>
      List.unmodifiable(_budgets);

  bool get isLoading => _isLoading;
  String? get loadError => _loadError;

  double get totalIncome => _sum(
    _transactions.where((item) => item.isIncome),
  );

  double get totalExpenses => _sum(
    _transactions.where((item) => !item.isIncome),
  );

  double get totalBalance => totalIncome - totalExpenses;

  double get currentMonthIncome =>
      incomeForMonth(DateTime.now());

  double get currentMonthExpenses =>
      expenseForMonth(DateTime.now());

  double get currentMonthSavings =>
      currentMonthIncome - currentMonthExpenses;

  List<Budget> get currentMonthBudgets {
    final key = monthKey(DateTime.now());

    return _budgets
        .where((budget) => budget.month == key)
        .toList();
  }

  double get currentMonthBudgetTotal {
    return currentMonthBudgets.fold<double>(
      0,
          (total, budget) => total + budget.amount,
    );
  }

  Future<void> loadData() async {
    _isLoading = true;
    _loadError = null;

    notifyListeners();

    try {
      await _refreshFromDatabase();
    } catch (error) {
      _loadError = 'Could not load data: $error';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _refreshFromDatabase() async {
    _transactions = await _database.getTransactions();
    _budgets = await _database.getBudgets();
  }

  Future<void> addTransaction(
      FinanceTransaction transaction,
      ) async {
    await _database.insertTransaction(transaction);
    await _refreshFromDatabase();
    notifyListeners();
  }

  Future<void> updateTransaction(
      FinanceTransaction transaction,
      ) async {
    await _database.updateTransaction(transaction);
    await _refreshFromDatabase();
    notifyListeners();
  }

  Future<void> deleteTransaction(int id) async {
    await _database.deleteTransaction(id);
    await _refreshFromDatabase();
    notifyListeners();
  }

  Future<void> saveBudget(Budget budget) async {
    await _database.saveBudget(budget);
    await _refreshFromDatabase();
    notifyListeners();
  }

  Future<void> deleteBudget(int id) async {
    await _database.deleteBudget(id);
    await _refreshFromDatabase();
    notifyListeners();
  }

  double incomeForMonth(DateTime month) {
    return _sum(
      _transactions.where(
            (item) =>
        item.isIncome && _isInMonth(item.date, month),
      ),
    );
  }

  double expenseForMonth(DateTime month) {
    return _sum(
      _transactions.where(
            (item) =>
        !item.isIncome && _isInMonth(item.date, month),
      ),
    );
  }

  double expenseForCategory(
      String category,
      DateTime month,
      ) {
    return _sum(
      _transactions.where(
            (item) =>
        !item.isIncome &&
            item.category == category &&
            _isInMonth(item.date, month),
      ),
    );
  }

  Map<String, double> expenseBreakdown(DateTime month) {
    final result = <String, double>{};

    for (final transaction in _transactions) {
      if (!transaction.isIncome &&
          _isInMonth(transaction.date, month)) {
        result.update(
          transaction.category,
              (value) => value + transaction.amount,
          ifAbsent: () => transaction.amount,
        );
      }
    }

    return result;
  }

  double expenseForDay(DateTime day) {
    return _sum(
      _transactions.where(
            (item) =>
        !item.isIncome &&
            item.date.year == day.year &&
            item.date.month == day.month &&
            item.date.day == day.day,
      ),
    );
  }

  double _sum(Iterable<FinanceTransaction> items) {
    return items.fold<double>(
      0,
          (total, item) => total + item.amount,
    );
  }

  bool _isInMonth(DateTime date, DateTime month) {
    return date.year == month.year &&
        date.month == month.month;
  }
}