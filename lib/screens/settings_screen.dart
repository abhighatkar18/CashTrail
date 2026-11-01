import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/app_colors.dart';
import '../providers/settings_provider.dart';
import 'currency_converter_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
      ),

      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
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
            ),

            child: const Row(
              children: [
                CircleAvatar(
                  radius: 27,
                  backgroundColor: Colors.white24,
                  child: Icon(
                    Icons.account_balance_wallet,
                    color: Colors.white,
                    size: 28,
                  ),
                ),

                SizedBox(width: 15),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'CashTrail',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 20,
                      ),
                    ),

                    SizedBox(height: 4),

                    Text(
                      'Personal finance, made clearer.',
                      style: TextStyle(
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 25),

          const Text(
            'PREFERENCES',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              color: AppColors.muted,
              letterSpacing: 1,
            ),
          ),

          const SizedBox(height: 10),

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

          const Text(
            'TOOLS',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              color: AppColors.muted,
              letterSpacing: 1,
            ),
          ),

          const SizedBox(height: 10),

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
              trailing: const Icon(Icons.chevron_right),
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

          const Text(
            'ABOUT CASH TRAIL',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              color: AppColors.muted,
              letterSpacing: 1,
            ),
          ),

          const SizedBox(height: 10),

          const Card(
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.storage),
                  title: Text('Local database'),
                  subtitle: Text(
                    'Your transactions are stored on your device.',
                  ),
                ),

                Divider(height: 1),

                ListTile(
                  leading: Icon(Icons.security),
                  title: Text('Privacy'),
                  subtitle: Text(
                    'This version does not require an account.',
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
        ],
      ),
    );
  }
}