import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:maze_core/maze_core.dart';

import '../models/bookmarked_maze.dart';
import '../models/saved_game.dart';
import '../services/storage_service.dart';
import '../state/game_state.dart';
import '../widgets/maze_painter.dart';
import '../widgets/maze_widget.dart';

class PlayScreen extends StatefulWidget {
  const PlayScreen({
    super.key,
    required this.storage,
    required this.gameNotifier,
    this.savedGameId,
  });

  final StorageService storage;
  final GameNotifier gameNotifier;

  /// If resuming a saved game, the ID to delete on resume.
  final String? savedGameId;

  @override
  State<PlayScreen> createState() => _PlayScreenState();
}

class _PlayScreenState extends State<PlayScreen> {
  Timer? _timer;
  _ToolMode _toolMode = _ToolMode.path;

  GameNotifier get _game => widget.gameNotifier;

  @override
  void initState() {
    super.initState();
    _startTimer();
    // If resuming a saved game, delete the save file.
    if (widget.savedGameId != null) {
      widget.storage.deleteSave(widget.savedGameId!);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      _game.tick(100);
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        _onClosePressed();
      },
      child: ListenableBuilder(
        listenable: _game,
        builder: (context, _) {
          final game = _game.state;
          if (game == null) {
            return Scaffold(
              appBar: AppBar(title: const Text('Play')),
              body: const Center(child: Text('No maze loaded')),
            );
          }

          return Scaffold(
            appBar: AppBar(
              leading: IconButton(
                icon: const Icon(Icons.close),
                onPressed: _onClosePressed,
              ),
              title: _TimerDisplay(elapsedMs: game.elapsedMs),
              actions: [
                IconButton(
                  icon: Icon(game.isPaused ? Icons.play_arrow : Icons.pause),
                  onPressed: () => _game.togglePause(),
                  tooltip: game.isPaused ? 'Resume' : 'Pause',
                ),
                IconButton(
                  icon: const Icon(Icons.undo),
                  onPressed:
                      game.undoStack.isNotEmpty ? () => _game.undo() : null,
                  tooltip: 'Undo',
                ),
              ],
            ),
            body: KeyboardListener(
              focusNode: FocusNode()..requestFocus(),
              onKeyEvent: (event) => _handleKeyEvent(event, game),
              child: Column(
                children: [
                  Expanded(
                    child: game.isPaused
                        ? Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.pause_circle_outline,
                                  size: 64,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Paused',
                                  style:
                                      Theme.of(context).textTheme.headlineSmall,
                                ),
                              ],
                            ),
                          )
                        : MazeWidget(
                            renderState: MazeRenderState(
                              grid: game.grid,
                              startCell: game.startCell,
                              endCell: game.endCell,
                              playerPath: game.playerPath,
                              solution: game.solution,
                              showSolution: game.showSolution,
                              fogOfWarRadius: game.fogOfWarRadius,
                              fogOfWarCenter: game.playerPath.isNotEmpty
                                  ? game.playerPath.last
                                  : null,
                              breadcrumbs: game.breadcrumbs,
                              wallMarks: game.wallMarks,
                            ),
                            onCellTap: (cell) =>
                                _onCellInteraction(cell, game),
                            onCellDrag: (cell) =>
                                _onCellInteraction(cell, game),
                          ),
                  ),
                  _Toolbar(
                    toolMode: _toolMode,
                    onToolChanged: (mode) => setState(() => _toolMode = mode),
                    fogEnabled: game.fogOfWarRadius != null,
                    onFogToggle: () => _game.toggleFogOfWar(),
                    solutionVisible: game.showSolution,
                    onSolutionToggle: () => _game.toggleSolution(),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _onCellInteraction(Cell cell, GameState game) {
    switch (_toolMode) {
      case _ToolMode.path:
        _game.moveToCell(cell);
        final updated = _game.state;
        if (updated != null && updated.isCompleted) {
          _onCompleted(updated);
        }
      case _ToolMode.breadcrumb:
        _game.toggleBreadcrumb(cell);
      case _ToolMode.wallMark:
        if (game.playerPath.isNotEmpty) {
          _game.toggleWallMark(game.playerPath.last, cell);
        }
    }
  }

  void _handleKeyEvent(KeyEvent event, GameState game) {
    if (event is! KeyDownEvent) return;
    if (game.isPaused || game.isCompleted) return;

    final current = game.playerPath.last;

    Cell? target;
    if (current is SquareCell) {
      target = switch (event.logicalKey) {
        LogicalKeyboardKey.arrowUp => current.north,
        LogicalKeyboardKey.arrowDown => current.south,
        LogicalKeyboardKey.arrowLeft => current.west,
        LogicalKeyboardKey.arrowRight => current.east,
        _ => null,
      };
    }

    if (target != null && current.isLinked(target)) {
      _game.moveToCell(target);
      final updated = _game.state;
      if (updated != null && updated.isCompleted) {
        _onCompleted(updated);
      }
    }
  }

  void _onCompleted(GameState game) {
    _timer?.cancel();

    // Record the solve.
    final record = SolveRecord(
      timestamp: DateTime.now(),
      cellType: game.config.cellType,
      puzzleShape: game.config.puzzleShape,
      shapeVariant: game.config.shapeVariant,
      algorithm: game.config.algorithm ?? Algorithm.recursiveBacktracker,
      difficulty: game.config.difficulty,
      rows: game.config.rows,
      columns: game.config.columns,
      solveTimeMs: game.elapsedMs,
      playerPathLength: game.playerPath.length - 1,
      shortestPathLength: game.solution.steps,
      completed: true,
    );
    widget.storage.addRecord(record);

    _showCompletionDialog(game);
  }

  void _showCompletionDialog(GameState game) {
    final duration = Duration(milliseconds: game.elapsedMs);
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Maze Complete!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Time: ${minutes}m ${seconds}s'),
            const SizedBox(height: 8),
            Text('Your path: ${game.playerPath.length - 1} steps'),
            Text('Shortest path: ${game.solution.steps} steps'),
            const SizedBox(height: 8),
            Text(
              'Efficiency: ${((game.solution.steps / (game.playerPath.length - 1)) * 100).toStringAsFixed(0)}%',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Home'),
          ),
          OutlinedButton(
            onPressed: () {
              _bookmarkCurrentMaze(game);
              Navigator.of(dialogContext).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Bookmark'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              _game.newGame(game.config);
              _startTimer();
            },
            child: const Text('New Maze'),
          ),
        ],
      ),
    );
  }

  void _bookmarkCurrentMaze(GameState game) {
    final bookmark = BookmarkedMaze(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      config: game.config,
      bookmarkedAt: DateTime.now(),
    );
    widget.storage.addBookmark(bookmark);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Maze bookmarked'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  SavedGame _buildSavedGame(GameState game) {
    return SavedGame(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      config: game.config,
      playerPath:
          game.playerPath.map((c) => (c.row, c.column)).toList(),
      elapsedMs: game.elapsedMs,
      breadcrumbs:
          game.breadcrumbs.map((c) => (c.row, c.column)).toSet(),
      wallMarks: game.wallMarks.map(
        (cell, neighbors) => MapEntry(
          (cell.row, cell.column),
          neighbors.map((n) => (n.row, n.column)).toSet(),
        ),
      ),
      savedAt: DateTime.now(),
    );
  }

  void _onClosePressed() {
    final game = _game.state;
    if (game == null || game.isCompleted) {
      Navigator.of(context).pop();
      return;
    }

    _game.togglePause();

    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Leave maze?'),
        content: const Text('Would you like to save your progress?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              _game.togglePause();
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Discard'),
          ),
          FilledButton(
            onPressed: () {
              widget.storage.saveGame(_buildSavedGame(game));
              Navigator.of(dialogContext).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Save & Exit'),
          ),
        ],
      ),
    );
  }
}

enum _ToolMode { path, breadcrumb, wallMark }

class _TimerDisplay extends StatelessWidget {
  const _TimerDisplay({required this.elapsedMs});

  final int elapsedMs;

  @override
  Widget build(BuildContext context) {
    final duration = Duration(milliseconds: elapsedMs);
    final minutes = duration.inMinutes.toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return Text(
      '$minutes:$seconds',
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontFeatures: [const FontFeature.tabularFigures()],
          ),
    );
  }
}

class _Toolbar extends StatelessWidget {
  const _Toolbar({
    required this.toolMode,
    required this.onToolChanged,
    required this.fogEnabled,
    required this.onFogToggle,
    required this.solutionVisible,
    required this.onSolutionToggle,
  });

  final _ToolMode toolMode;
  final ValueChanged<_ToolMode> onToolChanged;
  final bool fogEnabled;
  final VoidCallback onFogToggle;
  final bool solutionVisible;
  final VoidCallback onSolutionToggle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _toolButton(
              context,
              icon: Icons.route,
              label: 'Path',
              isSelected: toolMode == _ToolMode.path,
              onTap: () => onToolChanged(_ToolMode.path),
            ),
            _toolButton(
              context,
              icon: Icons.circle,
              label: 'Crumbs',
              isSelected: toolMode == _ToolMode.breadcrumb,
              onTap: () => onToolChanged(_ToolMode.breadcrumb),
            ),
            _toolButton(
              context,
              icon: Icons.block,
              label: 'Marks',
              isSelected: toolMode == _ToolMode.wallMark,
              onTap: () => onToolChanged(_ToolMode.wallMark),
            ),
            _toolButton(
              context,
              icon: fogEnabled ? Icons.visibility_off : Icons.visibility,
              label: 'Fog',
              isSelected: fogEnabled,
              onTap: onFogToggle,
            ),
            _toolButton(
              context,
              icon: Icons.lightbulb_outline,
              label: 'Solve',
              isSelected: solutionVisible,
              onTap: onSolutionToggle,
            ),
          ],
        ),
      ),
    );
  }

  Widget _toolButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final color = isSelected
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).colorScheme.onSurfaceVariant;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 2),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: color,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
