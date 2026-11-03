
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/finance_provider.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  static const green = Color(0xFF16866A);
  static const darkGreen = Color(0xFF153D35);

  final formKey = GlobalKey<FormState>();

  final name = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();
  final confirmPassword = TextEditingController();

  bool signup = false;
  bool hidePassword = true;
  bool hideConfirm = true;
  bool loading = false;

  @override
  void dispose() {
    name.dispose();
    email.dispose();
    password.dispose();
    confirmPassword.dispose();
    super.dispose();
  }

  void toggleMode() {
    formKey.currentState?.reset();

    setState(() {
      signup = !signup;
      hidePassword = true;
      hideConfirm = true;
    });
  }

  String? validateEmail(String? value) {
    final text = value?.trim() ?? '';

    if (text.isEmpty) return 'Email is required';

    final pattern = RegExp(
      r'^[^\s@]+@[^\s@]+\.[^\s@]+$',
    );

    if (!pattern.hasMatch(text)) {
      return 'Enter a valid email address';
    }

    return null;
  }

  Future<void> submit() async {
    if (loading || !formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();

    setState(() => loading = true);

    try {
      final auth = context.read<AuthProvider>();
      final finance = context.read<FinanceProvider>();

      if (signup) {
        await auth.signup(
          name: name.text.trim(),
          email: email.text.trim(),
          password: password.text,
          finance: finance,
        );
      } else {
        await auth.login(
          email: email.text.trim(),
          password: password.text,
          finance: finance,
        );
      }

      // AuthGate opens MainShell automatically.
    } catch (error) {
      if (!mounted) return;

      final message = error.toString().replaceFirst(
        'Exception: ',
        '',
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFFB73B3B),
        ),
      );
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  InputDecoration fieldDecoration(
      String label,
      IconData icon, {
        Widget? suffix,
      }) {
    final isDark =
        Theme.of(context).brightness == Brightness.dark;

    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, size: 21),
      suffixIcon: suffix,
      filled: true,
      fillColor: isDark
          ? Theme.of(context).colorScheme.surfaceContainerHighest
          : const Color(0xFFF3F7F5),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 18,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: green,
          width: 1.5,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: Colors.redAccent,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark =
        Theme.of(context).brightness == Brightness.dark;

    final textColor = isDark ? Colors.white : darkGreen;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 26,
              vertical: 25,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Logo
                    Center(
                      child: Container(
                        width: 82,
                        height: 82,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFF27B78F),
                              green,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(25),
                          boxShadow: [
                            BoxShadow(
                              color: green.withValues(alpha: 0.22),
                              blurRadius: 24,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.account_balance_wallet_rounded,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    Text(
                      'CashTrail',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -1,
                        color: textColor,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      'Your money. Your journey.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurfaceVariant,
                      ),
                    ),

                    const SizedBox(height: 38),

                    Text(
                      signup
                          ? 'Create your account'
                          : 'Welcome back!',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.8,
                        color: textColor,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      signup
                          ? 'Start tracking your money with confidence.'
                          : 'Sign in to continue managing your finances.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurfaceVariant,
                      ),
                    ),

                    const SizedBox(height: 28),

                    if (signup) ...[
                      TextFormField(
                        controller: name,
                        textCapitalization:
                        TextCapitalization.words,
                        textInputAction: TextInputAction.next,
                        decoration: fieldDecoration(
                          'Full name',
                          Icons.person_outline_rounded,
                        ),
                        validator: (value) {
                          if ((value?.trim().length ?? 0) < 2) {
                            return 'Enter your full name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                    ],

                    TextFormField(
                      controller: email,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.email],
                      decoration: fieldDecoration(
                        'Email address',
                        Icons.email_outlined,
                      ),
                      validator: validateEmail,
                    ),

                    const SizedBox(height: 16),

                    TextFormField(
                      controller: password,
                      obscureText: hidePassword,
                      textInputAction: signup
                          ? TextInputAction.next
                          : TextInputAction.done,
                      autofillHints: [
                        signup
                            ? AutofillHints.newPassword
                            : AutofillHints.password,
                      ],
                      decoration: fieldDecoration(
                        'Password',
                        Icons.lock_outline_rounded,
                        suffix: IconButton(
                          onPressed: () {
                            setState(() {
                              hidePassword = !hidePassword;
                            });
                          },
                          icon: Icon(
                            hidePassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Password is required';
                        }

                        if (signup && value.length < 8) {
                          return 'Use at least 8 characters';
                        }

                        return null;
                      },
                      onFieldSubmitted: (_) {
                        if (!signup) submit();
                      },
                    ),

                    if (signup) ...[
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: confirmPassword,
                        obscureText: hideConfirm,
                        textInputAction: TextInputAction.done,
                        decoration: fieldDecoration(
                          'Confirm password',
                          Icons.verified_user_outlined,
                          suffix: IconButton(
                            onPressed: () {
                              setState(() {
                                hideConfirm = !hideConfirm;
                              });
                            },
                            icon: Icon(
                              hideConfirm
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Confirm your password';
                          }

                          if (value != password.text) {
                            return 'Passwords do not match';
                          }

                          return null;
                        },
                        onFieldSubmitted: (_) => submit(),
                      ),

                      const SizedBox(height: 12),

                      const Text(
                        'Use a password with at least 8 characters.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],

                    const SizedBox(height: 28),

                    SizedBox(
                      height: 56,
                      child: FilledButton(
                        onPressed: loading ? null : submit,
                        style: FilledButton.styleFrom(
                          backgroundColor: green,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius.circular(16),
                          ),
                        ),
                        child: loading
                            ? const SizedBox(
                          width: 23,
                          height: 23,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                            : Row(
                          mainAxisAlignment:
                          MainAxisAlignment.center,
                          children: [
                            Text(
                              signup
                                  ? 'Create Account'
                                  : 'Sign In',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Icon(
                              Icons.arrow_forward_rounded,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 25),

                    Row(
                      mainAxisAlignment:
                      MainAxisAlignment.center,
                      children: [
                        Flexible(
                          child: Text(
                            signup
                                ? 'Already have an account?'
                                : "Don't have an account?",
                            style: TextStyle(
                              fontSize: 13,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: loading ? null : toggleMode,
                          child: Text(
                            signup ? 'Sign In' : 'Sign Up',
                            style: const TextStyle(
                              color: green,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    const Row(
                      mainAxisAlignment:
                      MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.lock_outline_rounded,
                          size: 15,
                          color: Colors.grey,
                        ),
                        SizedBox(width: 6),
                        Text(
                          'Offline account • Local storage',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
