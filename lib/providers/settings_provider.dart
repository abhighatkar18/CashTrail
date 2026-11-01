import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider extends ChangeNotifier {
  static const _darkModeKey = 'cashtrail_dark_mode';

  final SharedPreferencesAsync _preferences =
  SharedPreferencesAsync();

  bool _isDarkMode = false;
  bool _isReady = false;

  bool get isDarkMode => _isDarkMode;
  bool get isReady => _isReady;

  SettingsProvider() {
    _load();
  }

  Future<void> _load() async {
    try {
      _isDarkMode =
          await _preferences.getBool(_darkModeKey) ?? false;
    } finally {
      _isReady = true;
      notifyListeners();
    }
  }

  Future<void> setDarkMode(bool value) async {
    _isDarkMode = value;
    notifyListeners();

    await _preferences.setBool(
      _darkModeKey,
      value,
    );
  }
}