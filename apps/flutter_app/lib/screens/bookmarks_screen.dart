import 'package:flutter/material.dart';
import 'package:maze_core/maze_core.dart';

import '../services/storage_service.dart';
import '../state/game_state.dart';
import 'play_screen.dart';

class BookmarksScreen extends StatelessWidget {
  const BookmarksScreen({
    super.key,
    required this.storage,
    required this.gameNotifier,
  });

  final StorageService storage;
  final GameNotifier gameNotifier;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bookmarks')),
      body: ListenableBuilder(
        listenable: storage,
        builder: (context, _) {
          final bookmarks = storage.bookmarks;

          if (bookmarks.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.bookmark_outline,
                    size: 64,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No bookmarked mazes',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Complete a maze and bookmark it to replay later',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            );
          }

          // Show most recent first.
          final sorted = List.of(bookmarks)
            ..sort((a, b) => b.bookmarkedAt.compareTo(a.bookmarkedAt));

          return ListView.builder(
            itemCount: sorted.length,
            itemBuilder: (context, index) {
              final bookmark = sorted[index];
              final config = bookmark.config;
              final ago = _timeAgo(bookmark.bookmarkedAt);
              final algorithmName =
                  config.algorithm?.name.capitalize() ?? 'Auto';

              return Dismissible(
                key: ValueKey(bookmark.id),
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
                onDismissed: (_) => storage.removeBookmark(bookmark.id),
                child: ListTile(
                  leading: Icon(_cellTypeIcon(config.cellType)),
                  title: Text(
                    '${config.cellType.name.capitalize()} '
                    '${config.rows}x${config.columns}',
                  ),
                  subtitle: Text(
                    '${config.difficulty.name.capitalize()} '
                    '- $algorithmName '
                    '- $ago',
                  ),
                  trailing: const Icon(Icons.play_arrow),
                  onTap: () => _replay(context, bookmark),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _replay(BuildContext context, bookmark) {
    gameNotifier.newGame(bookmark.config);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PlayScreen(
          storage: storage,
          gameNotifier: gameNotifier,
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
