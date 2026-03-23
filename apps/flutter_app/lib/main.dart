import 'package:flutter/material.dart';

import 'screens/home_screen.dart';
import 'services/settings_service.dart';
import 'services/storage_service.dart';
import 'state/game_state.dart';
import 'theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final storage = StorageService();
  final settings = SettingsService();
  final gameNotifier = GameNotifier();
  await Future.wait([storage.init(), settings.init()]);
  runApp(MazesApp(
    storage: storage,
    settings: settings,
    gameNotifier: gameNotifier,
  ));
}

class MazesApp extends StatelessWidget {
  final StorageService storage;
  final SettingsService settings;
  final GameNotifier gameNotifier;

  const MazesApp({
    super.key,
    required this.storage,
    required this.settings,
    required this.gameNotifier,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: settings,
      builder: (context, _) => MaterialApp(
        title: 'Mazes',
        debugShowCheckedModeBanner: false,
        theme: lightTheme,
        darkTheme: darkTheme,
        themeMode: settings.themeMode,
        home: HomeScreen(
          storage: storage,
          settings: settings,
          gameNotifier: gameNotifier,
        ),
      ),
    );
  }
}
