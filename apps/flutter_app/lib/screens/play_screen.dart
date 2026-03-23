import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:maze_core/maze_core.dart';

import '../services/storage_service.dart';
import '../state/game_state.dart';
import '../widgets/maze_painter.dart';
import '../widgets/maze_widget.dart';

class PlayScreen extends StatefulWidget {
  const PlayScreen({
    super.key,
    required this.storage,
    required this.gameNotifier,
  });

  final StorageService storage;
  final GameNotifier gameNotifier;

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
    return ListenableBuilder(
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
              onPressed: () => Navigator.of(context).pop(),
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
    );
  }

  void _onCellInteraction(Cell cell, GameState game) {
    switch (_toolMode) {
      case _ToolMode.path:
        _game.moveToCell(cell);
        final updated = _game.state;
        if (updated != null && updated.isCompleted) {
          _showCompletionDialog(updated);
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
        _showCompletionDialog(updated);
      }
    }
  }

  void _showCompletionDialog(GameState game) {
    _timer?.cancel();

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
