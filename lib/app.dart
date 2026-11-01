import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/app_theme.dart';
import 'providers/settings_provider.dart';
import 'screens/main_shell.dart';

class CashTrailApp extends StatelessWidget {
  const CashTrailApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, _) {
        return MaterialApp(
          title: 'CashTrail',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: settings.isDarkMode
              ? ThemeMode.dark
              : ThemeMode.light,
          home: const MainShell(),
        );
      },
    );
  }
}