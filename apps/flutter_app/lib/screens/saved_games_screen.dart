import 'package:flutter/material.dart';
import 'package:maze_core/maze_core.dart';

import '../services/storage_service.dart';
import '../state/game_state.dart';
import 'play_screen.dart';

class SavedGamesScreen extends StatelessWidget {
  const SavedGamesScreen({
    super.key,
    required this.storage,
    required this.gameNotifier,
  });

  final StorageService storage;
  final GameNotifier gameNotifier;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Saved Games')),
      body: ListenableBuilder(
        listenable: storage,
        builder: (context, _) {
          final saves = storage.saves;

          if (saves.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.save_outlined,
                    size: 64,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No saved games',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            );
          }

          // Show most recent first.
          final sorted = List.of(saves)
            ..sort((a, b) => b.savedAt.compareTo(a.savedAt));

          return ListView.builder(
            itemCount: sorted.length,
            itemBuilder: (context, index) {
              final save = sorted[index];
              final config = save.config;
              final elapsed = Duration(milliseconds: save.elapsedMs);
              final minutes = elapsed.inMinutes;
              final seconds = elapsed.inSeconds % 60;
              final ago = _timeAgo(save.savedAt);

              return Dismissible(
                key: ValueKey(save.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 24),
                  color: Theme.of(context).colorScheme.error,
                  child: Icon(
                    Icons.delete,
                    color: Theme.of(context).colorScheme.onError,
                  ),
                ),
                onDismissed: (_) => storage.deleteSave(save.id),
                child: ListTile(
                  leading: Icon(_cellTypeIcon(config.cellType)),
                  title: Text(
                    '${config.cellType.name.capitalize()} '
                    '${config.rows}x${config.columns}',
                  ),
                  subtitle: Text(
                    '${config.difficulty.name.capitalize()} '
                    '- ${minutes}m ${seconds}s elapsed '
                    '- $ago',
                  ),
                  trailing: const Icon(Icons.play_arrow),
                  onTap: () => _resume(context, save),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _resume(BuildContext context, save) {
    gameNotifier.loadSavedGame(save);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => PlayScreen(
          storage: storage,
          gameNotifier: gameNotifier,
          savedGameId: save.id,
        ),
      ),
    );
  }

  IconData _cellTypeIcon(CellType type) {
    return switch (type) {
      CellType.square => Icons.grid_4x4,
      CellType.hexagonal => Icons.hexagon_outlined,
      CellType.triangular => Icons.change_history,
      CellType.circular => Icons.radio_button_unchecked,
    };
  }

  String _timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${date.month}/${date.day}';
  }
}

extension _StringCap on String {
  String capitalize() => isEmpty ? this : this[0].toUpperCase() + substring(1);
}
