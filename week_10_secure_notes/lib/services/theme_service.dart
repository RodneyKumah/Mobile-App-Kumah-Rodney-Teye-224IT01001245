import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ThemeService extends ChangeNotifier {
  final _storage = const FlutterSecureStorage();
  bool _isDark = false;

  bool get isDark => _isDark;

  ThemeService() {
    loadTheme();
  }

  void toggleTheme() async {
    _isDark = !_isDark;
    await _storage.write(key: "dark_mode", value: _isDark.toString());
    notifyListeners();
  }

  void loadTheme() async {
    final saved = await _storage.read(key: "dark_mode");
    _isDark = saved == "true";
    notifyListeners();
  }
}