
import 'package:flutter/foundation.dart';

import '../data/app_database.dart';
import '../services/auth_service.dart';
import 'finance_provider.dart';

class AuthProvider extends ChangeNotifier {
  final _auth = AuthService.instance;
  final _financeDatabase = AppDatabase.instance;

  LocalUser? _user;
  bool _busy = true;

  LocalUser? get user => _user;
  bool get isLoggedIn => _user != null;
  bool get isBusy => _busy;

  Future<void> initialize(FinanceProvider finance) async {
    _busy = true;
    notifyListeners();

    try {
      final restoredUser = await _auth.restoreSession();

      if (restoredUser != null) {
        await _financeDatabase.selectUser(restoredUser.id);
        await finance.loadData();
      }

      _user = restoredUser;
    } catch (error) {
      _user = null;
      finance.clearData();
      await _financeDatabase.selectUser(null);
      rethrow;
    } finally {
      _busy = false;
      notifyListeners();
    }
  }

  Future<void> _activate(
      LocalUser user,
      FinanceProvider finance,
      ) async {
    await _financeDatabase.selectUser(user.id);

    finance.clearData();
    await finance.loadData();

    if (finance.loadError != null) {
      throw Exception(finance.loadError!);
    }

    await _auth.saveSession(user.id);
    _user = user;
    notifyListeners();
  }

  Future<void> login({
    required String email,
    required String password,
    required FinanceProvider finance,
  }) async {
    final user = await _auth.login(
      email: email,
      password: password,
    );

    await _activate(user, finance);
  }

  Future<void> signup({
    required String name,
    required String email,
    required String password,
    required FinanceProvider finance,
  }) async {
    final user = await _auth.signup(
      name: name,
      email: email,
      password: password,
    );

    await _activate(user, finance);
  }

  Future<void> logout(FinanceProvider finance) async {
    await _auth.logout();

    _user = null;
    finance.clearData();

    await _financeDatabase.selectUser(null);
    notifyListeners();
  }
}
