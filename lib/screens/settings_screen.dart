
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/app_colors.dart';
import '../providers/auth_provider.dart';
import '../providers/finance_provider.dart';
import '../providers/settings_provider.dart';

import 'auth_gate.dart';
import 'currency_converter_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  // ==========================================
  // LOGOUT WITH CONFIRMATION AND NAVIGATION
  // ==========================================
  Future<void> _showLogoutDialog(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Row(
            children: [
              Icon(
                Icons.logout_rounded,
                color: Colors.redAccent,
              ),
              SizedBox(width: 12),
              Text(
                'Logout',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ],
          ),
          content: const Text(
            'Are you sure you want to log out of CashTrail?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !context.mounted) return;

    // Capture the root navigator before logout.
    final navigator = Navigator.of(
      context,
      rootNavigator: true,
    );

    final auth = context.read<AuthProvider>();
    final finance = context.read<FinanceProvider>();

    try {
      // Clear stored session and financial state.
      await auth.logout(finance);

      if (!navigator.mounted) return;

      // Create a fresh authentication route and remove
      // all previous pages, including Settings.
      navigator.pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => const AuthGate(),
        ),
            (route) => false,
      );
    } catch (error) {
      if (!navigator.mounted) return;

      final messenger = ScaffoldMessenger.maybeOf(
        navigator.context,
      );

      messenger?.showSnackBar(
        SnackBar(
          content: Text('Logout failed: $error'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  // ==========================================
  // SECTION HEADING
  // ==========================================
  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w800,
          color: AppColors.muted,
          fontSize: 13,
          letterSpacing: 1,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // ==================================
          // USER PROFILE
          // ==================================
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF3767E8),
                  Color(0xFF244FC4),
                ],
              ),
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: const Color(
                    0xFF3767E8,
                  ).withValues(alpha: 0.16),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.white24,
                  child: Text(
                    user != null && user.name.isNotEmpty
                        ? user.name[0].toUpperCase()
                        : 'C',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 23,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.name ?? 'CashTrail User',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 20,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        user?.email ??
                            'Personal finance, made clearer.',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.verified_user_outlined,
                  color: Colors.white70,
                  size: 24,
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          // ==================================
          // PREFERENCES
          // ==================================
          _sectionTitle('PREFERENCES'),

          Card(
            child: Consumer<SettingsProvider>(
              builder: (context, settings, _) {
                return SwitchListTile(
                  secondary: const Icon(
                    Icons.dark_mode_outlined,
                  ),
                  title: const Text(
                    'Dark theme',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  subtitle: const Text(
                    'Change application appearance',
                  ),
                  value: settings.isDarkMode,
                  onChanged: settings.setDarkMode,
                );
              },
            ),
          ),

          const SizedBox(height: 22),

          // ==================================
          // TOOLS
          // ==================================
          _sectionTitle('TOOLS'),

          Card(
            child: ListTile(
              leading: const Icon(
                Icons.currency_exchange,
                color: AppColors.accent,
              ),
              title: const Text(
                'Currency converter',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                ),
              ),
              subtitle: const Text(
                'Convert currencies using exchange rates',
              ),
              trailing: const Icon(
                Icons.chevron_right,
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                    const CurrencyConverterScreen(),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 22),

          // ==================================
          // ACCOUNT
          // ==================================
          _sectionTitle('ACCOUNT'),

          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(
                    Icons.person_outline_rounded,
                    color: AppColors.accent,
                  ),
                  title: const Text(
                    'My account',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  subtitle: Text(
                    user?.email ?? 'Account information',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                const Divider(height: 1),

                ListTile(
                  leading: const Icon(
                    Icons.logout_rounded,
                    color: Colors.redAccent,
                  ),
                  title: const Text(
                    'Logout',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Colors.redAccent,
                    ),
                  ),
                  subtitle: const Text(
                    'Sign out of your CashTrail account',
                  ),
                  trailing: const Icon(
                    Icons.chevron_right,
                    color: Colors.redAccent,
                  ),
                  onTap: () => _showLogoutDialog(context),
                ),
              ],
            ),
          ),

          const SizedBox(height: 22),

          // ==================================
          // ABOUT CASH TRAIL
          // ==================================
          _sectionTitle('ABOUT CASH TRAIL'),

          const Card(
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.storage_outlined),
                  title: Text('Local database'),
                  subtitle: Text(
                    'Your transactions are stored locally '
                        'on your device.',
                  ),
                ),

                Divider(height: 1),

                ListTile(
                  leading: Icon(Icons.security_outlined),
                  title: Text('Privacy & security'),
                  subtitle: Text(
                    'Your account uses offline SQLite '
                        'authentication. Financial data is '
                        'stored on this device.',
                  ),
                ),

                Divider(height: 1),

                ListTile(
                  leading: Icon(Icons.info_outline),
                  title: Text('Application version'),
                  subtitle: Text('CashTrail 1.0.0'),
                ),
              ],
            ),
          ),

          const SizedBox(height: 25),

          // ==================================
          // FOOTER
          // ==================================
          const Center(
            child: Text(
              'CashTrail • Track smarter, spend better',
              style: TextStyle(
                color: AppColors.muted,
                fontSize: 12,
              ),
            ),
          ),

          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
