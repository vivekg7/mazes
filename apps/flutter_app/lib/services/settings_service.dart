import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

enum AppColor {
  teal(Color(0xFF1B5E5E), 'Teal'),
  blue(Color(0xFF1565C0), 'Blue'),
  indigo(Color(0xFF3949AB), 'Indigo'),
  green(Color(0xFF2E7D32), 'Green'),
  purple(Color(0xFF6A1B9A), 'Purple'),
  rose(Color(0xFFC62828), 'Rose'),
  orange(Color(0xFFE65100), 'Orange'),
  slate(Color(0xFF546E7A), 'Slate');

  const AppColor(this.seed, this.label);
  final Color seed;
  final String label;
}

enum AppThemeMode {
  system('System', Icons.settings_brightness),
  light('Light', Icons.light_mode),
  dark('Dark', Icons.dark_mode),
  amoled('AMOLED', Icons.brightness_1);

  const AppThemeMode(this.label, this.icon);
  final String label;
  final IconData icon;

  bool get isAmoled => this == AppThemeMode.amoled;

  ThemeMode get flutterMode => switch (this) {
        AppThemeMode.system => ThemeMode.system,
        AppThemeMode.light => ThemeMode.light,
        AppThemeMode.dark => ThemeMode.dark,
        AppThemeMode.amoled => ThemeMode.dark,
      };
}

/// Persists user settings to a JSON file.
class SettingsService extends ChangeNotifier {
  late final String _dirPath;

  AppThemeMode _themeMode = AppThemeMode.system;
  AppThemeMode get themeMode => _themeMode;

  AppColor _appColor = AppColor.teal;
  AppColor get appColor => _appColor;

  Future<void> init() async {
    final dir = await getApplicationDocumentsDirectory();
    _dirPath = dir.path;
    await _load();
  }

  Future<void> _load() async {
    final file = File('$_dirPath/maze_settings.json');
    if (file.existsSync()) {
      try {
        final json =
            jsonDecode(await file.readAsString()) as Map<String, dynamic>;
        _themeMode = AppThemeMode.values.firstWhere(
          (m) => m.name == json['themeMode'],
          orElse: () => AppThemeMode.system,
        );
        _appColor = AppColor.values.firstWhere(
          (c) => c.name == json['appColor'],
          orElse: () => AppColor.teal,
        );
      } catch (_) {
        // Corrupted file — use defaults.
      }
    }
  }

  Future<void> _save() async {
    final file = File('$_dirPath/maze_settings.json');
    await file.writeAsString(jsonEncode({
      'themeMode': _themeMode.name,
      'appColor': _appColor.name,
    }));
  }

  void setThemeMode(AppThemeMode mode) {
    if (_themeMode == mode) return;
    _themeMode = mode;
    notifyListeners();
    _save();
  }

  void setAppColor(AppColor color) {
    if (_appColor == color) return;
    _appColor = color;
    notifyListeners();
    _save();
  }
}
