
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/finance_provider.dart';

import 'auth_screen.dart';
import 'main_shell.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _initializing = true;
  String? _error;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _initializeAuth();
      }
    });
  }

  // ==========================================
  // RESTORE LOGIN SESSION
  // ==========================================
  Future<void> _initializeAuth() async {
    setState(() {
      _initializing = true;
      _error = null;
    });

    try {
      final auth = context.read<AuthProvider>();
      final finance = context.read<FinanceProvider>();

      await auth.initialize(finance);
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _error = error.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _initializing = false;
        });
      }
    }
  }

  // ==========================================
  // LOADING SCREEN
  // ==========================================
  Widget _loadingScreen() {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.account_balance_wallet_rounded,
              color: Color(0xFF16866A),
              size: 55,
            ),
            SizedBox(height: 22),
            CircularProgressIndicator(
              color: Color(0xFF16866A),
            ),
            SizedBox(height: 16),
            Text(
              'Opening CashTrail...',
              style: TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // ERROR SCREEN
  // ==========================================
  Widget _errorScreen() {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                color: Colors.redAccent,
                size: 48,
              ),
              const SizedBox(height: 16),
              const Text(
                'Unable to start CashTrail',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                _error ?? 'An unexpected error occurred.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: _initializeAuth,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Try Again'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================
  // AUTHENTICATION NAVIGATION
  // ==========================================
  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        if (_initializing || auth.isBusy) {
          return _loadingScreen();
        }

        if (_error != null) {
          return _errorScreen();
        }

        // Logged in: open CashTrail Dashboard.
        if (auth.isLoggedIn) {
          return const MainShell();
        }

        // Logged out: open Login/Signup screen.
        return const AuthScreen();
      },
    );
  }
}
