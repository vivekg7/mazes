import 'package:flutter/material.dart';
import 'package:maze_core/maze_core.dart';

import '../services/settings_service.dart';
import '../services/storage_service.dart';
import '../state/game_state.dart';
import 'bookmarks_screen.dart';
import 'export_screen.dart';
import 'new_maze_screen.dart';
import 'play_screen.dart';
import 'saved_games_screen.dart';
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
      1 => StatsScreen(storage: widget.storage),
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

    return ListenableBuilder(
      listenable: storage,
      builder: (context, _) {
        final hasSaves = storage.saves.isNotEmpty;
        final hasBookmarks = storage.bookmarks.isNotEmpty;

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
                if (hasSaves) ...[
                  FilledButton.icon(
                    onPressed: () => _resumeLatestSave(context),
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Continue'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                  if (storage.saves.length > 1)
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => _openSavedGames(context),
                        child: const Text('See all saved games'),
                      ),
                    )
                  else
                    const SizedBox(height: 12),
                ],
                if (!hasSaves)
                  FilledButton.icon(
                    onPressed: () => _startQuickPlay(context),
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Quick Play'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  )
                else
                  OutlinedButton.icon(
                    onPressed: () => _startQuickPlay(context),
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Quick Play'),
                    style: OutlinedButton.styleFrom(
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
                if (hasBookmarks) ...[
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () => _openBookmarks(context),
                    icon: const Icon(Icons.bookmark_outline),
                    label: const Text('Bookmarks'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const ExportScreen(),
                    ),
                  ),
                  icon: const Icon(Icons.picture_as_pdf),
                  label: const Text('Export PDF'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
                const SizedBox(height: 48),
              ],
            ),
          ),
        );
      },
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

  void _resumeLatestSave(BuildContext context) {
    final latest = storage.saves.last;
    gameNotifier.loadSavedGame(latest);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PlayScreen(
          storage: storage,
          gameNotifier: gameNotifier,
          savedGameId: latest.id,
        ),
      ),
    );
  }

  void _openSavedGames(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SavedGamesScreen(
          storage: storage,
          gameNotifier: gameNotifier,
        ),
      ),
    );
  }

  void _openBookmarks(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BookmarksScreen(
          storage: storage,
          gameNotifier: gameNotifier,
        ),
      ),
    );
  }
}
