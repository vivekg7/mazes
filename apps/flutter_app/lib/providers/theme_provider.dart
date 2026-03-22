import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Current theme mode (system, light, dark).
final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.system);
