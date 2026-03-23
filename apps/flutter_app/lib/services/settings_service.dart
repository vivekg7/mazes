import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

/// Persists user settings to a JSON file.
class SettingsService extends ChangeNotifier {
  late final String _dirPath;

  ThemeMode _themeMode = ThemeMode.system;
  ThemeMode get themeMode => _themeMode;

  Future<void> init() async {
    final dir = await getApplicationDocumentsDirectory();
    _dirPath = dir.path;
    await _load();
  }

  Future<void> _load() async {
    final file = File('$_dirPath/maze_settings.json');
    if (file.existsSync()) {
      try {
        final json = jsonDecode(await file.readAsString()) as Map<String, dynamic>;
        _themeMode = ThemeMode.values.firstWhere(
          (m) => m.name == json['themeMode'],
          orElse: () => ThemeMode.system,
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
    }));
  }

  set themeMode(ThemeMode mode) {
    if (_themeMode == mode) return;
    _themeMode = mode;
    notifyListeners();
    _save();
  }
}
