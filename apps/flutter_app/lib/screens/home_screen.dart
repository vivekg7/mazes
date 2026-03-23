import 'package:flutter/material.dart';
import 'package:maze_core/maze_core.dart';

import '../services/settings_service.dart';
import '../services/storage_service.dart';
import '../state/game_state.dart';
import 'new_maze_screen.dart';
import 'play_screen.dart';
import 'settings_screen.dart';
import 'stats_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.storage,
    required this.settings,
    required this.gameNotifier,
  });

  final StorageService storage;
  final SettingsService settings;
  final GameNotifier gameNotifier;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _navIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildBody(),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _navIndex,
        onDestinationSelected: (index) => setState(() => _navIndex = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart),
            label: 'Stats',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    return switch (_navIndex) {
      1 => const StatsScreen(),
      2 => SettingsScreen(settings: widget.settings),
      _ => _HomeContent(
          storage: widget.storage,
          settings: widget.settings,
          gameNotifier: widget.gameNotifier,
        ),
    };
  }
}

class _HomeContent extends StatelessWidget {
  const _HomeContent({
    required this.storage,
    required this.settings,
    required this.gameNotifier,
  });

  final StorageService storage;
  final SettingsService settings;
  final GameNotifier gameNotifier;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Spacer(),
            Icon(
              Icons.grid_4x4,
              size: 80,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'Mazes',
              style: theme.textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Challenge your mind',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const Spacer(),
            FilledButton.icon(
              onPressed: () => _startQuickPlay(context),
              icon: const Icon(Icons.play_arrow),
              label: const Text('Quick Play'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => NewMazeScreen(
                    storage: storage,
                    settings: settings,
                    gameNotifier: gameNotifier,
                  ),
                ),
              ),
              icon: const Icon(Icons.tune),
              label: const Text('Custom Maze'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  void _startQuickPlay(BuildContext context) {
    const config = MazeConfig(
      cellType: CellType.square,
      rows: 12,
      columns: 12,
      difficulty: DifficultyLevel.medium,
      algorithm: Algorithm.recursiveBacktracker,
    );
    gameNotifier.newGame(config);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PlayScreen(
          storage: storage,
          gameNotifier: gameNotifier,
        ),
      ),
    );
  }
}
