import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:maze_core/maze_core.dart';

/// The complete state of a maze game in progress.
class GameState {
  const GameState({
    required this.config,
    required this.grid,
    required this.startCell,
    required this.endCell,
    required this.solution,
    required this.playerPath,
    required this.undoStack,
    required this.elapsedMs,
    required this.isPaused,
    required this.isCompleted,
    required this.fogOfWarRadius,
    required this.breadcrumbs,
    required this.wallMarks,
    required this.showSolution,
  });

  final MazeConfig config;
  final Grid grid;
  final Cell startCell;
  final Cell endCell;
  final MazePath solution;
  final List<Cell> playerPath;
  final List<List<Cell>> undoStack;
  final int elapsedMs;
  final bool isPaused;
  final bool isCompleted;
  final int? fogOfWarRadius;
  final Set<Cell> breadcrumbs;
  final Map<Cell, Set<Cell>> wallMarks;
  final bool showSolution;

  GameState copyWith({
    List<Cell>? playerPath,
    List<List<Cell>>? undoStack,
    int? elapsedMs,
    bool? isPaused,
    bool? isCompleted,
    int? Function()? fogOfWarRadius,
    Set<Cell>? breadcrumbs,
    Map<Cell, Set<Cell>>? wallMarks,
    bool? showSolution,
  }) {
    return GameState(
      config: config,
      grid: grid,
      startCell: startCell,
      endCell: endCell,
      solution: solution,
      playerPath: playerPath ?? this.playerPath,
      undoStack: undoStack ?? this.undoStack,
      elapsedMs: elapsedMs ?? this.elapsedMs,
      isPaused: isPaused ?? this.isPaused,
      isCompleted: isCompleted ?? this.isCompleted,
      fogOfWarRadius:
          fogOfWarRadius != null ? fogOfWarRadius() : this.fogOfWarRadius,
      breadcrumbs: breadcrumbs ?? this.breadcrumbs,
      wallMarks: wallMarks ?? this.wallMarks,
      showSolution: showSolution ?? this.showSolution,
    );
  }
}

/// Manages the game state for the current maze.
class GameNotifier extends ChangeNotifier {
  GameState? _state;
  GameState? get state => _state;

  /// Generates a new maze and initializes the game state.
  void newGame(MazeConfig config) {
    final rng = Random(config.seed);

    final grid = _createGrid(config);
    final generator = _createGenerator(config.algorithm);
    generator.generate(grid, rng);

    final longest = longestPath(grid.cells.first);
    final solution = solveMaze(longest.start, longest.end);

    _state = GameState(
      config: config,
      grid: grid,
      startCell: longest.start,
      endCell: longest.end,
      solution: solution,
      playerPath: [longest.start],
      undoStack: const [],
      elapsedMs: 0,
      isPaused: false,
      isCompleted: false,
      fogOfWarRadius: null,
      breadcrumbs: const {},
      wallMarks: const {},
      showSolution: false,
    );
    notifyListeners();
  }

  /// Handles player moving to a cell (tap or drag).
  void moveToCell(Cell cell) {
    final s = _state;
    if (s == null || s.isCompleted || s.isPaused) return;

    final currentPath = s.playerPath;

    // Retrace: if the cell is the second-to-last in path, undo last move.
    if (currentPath.length >= 2 &&
        currentPath[currentPath.length - 2] == cell) {
      final newPath = List<Cell>.from(currentPath)..removeLast();
      _state = s.copyWith(
        playerPath: newPath,
        undoStack: [...s.undoStack, currentPath],
      );
      notifyListeners();
      return;
    }

    // Only allow moves to linked neighbors of the current position.
    final current = currentPath.last;
    if (!current.isLinked(cell)) return;

    // Don't allow revisiting cells already in the path.
    if (currentPath.contains(cell)) return;

    final newPath = [...currentPath, cell];
    _state = s.copyWith(
      playerPath: newPath,
      undoStack: [...s.undoStack, currentPath],
    );

    // Check for completion.
    if (cell == s.endCell) {
      _state = _state!.copyWith(isCompleted: true);
    }
    notifyListeners();
  }

  /// Undo the last move.
  void undo() {
    final s = _state;
    if (s == null || s.undoStack.isEmpty) return;

    final previousPath = s.undoStack.last;
    final newUndo = List<List<Cell>>.from(s.undoStack)..removeLast();
    _state = s.copyWith(playerPath: previousPath, undoStack: newUndo);
    notifyListeners();
  }

  /// Update elapsed time (called by timer).
  void tick(int ms) {
    final s = _state;
    if (s == null || s.isPaused || s.isCompleted) return;
    _state = s.copyWith(elapsedMs: s.elapsedMs + ms);
    notifyListeners();
  }

  void togglePause() {
    if (_state != null) {
      _state = _state!.copyWith(isPaused: !_state!.isPaused);
      notifyListeners();
    }
  }

  void toggleFogOfWar({int radius = 3}) {
    if (_state == null) return;
    _state = _state!.copyWith(
      fogOfWarRadius: () => _state!.fogOfWarRadius == null ? radius : null,
    );
    notifyListeners();
  }

  void setFogRadius(int radius) {
    if (_state == null) return;
    _state = _state!.copyWith(fogOfWarRadius: () => radius);
    notifyListeners();
  }

  void toggleBreadcrumb(Cell cell) {
    if (_state == null) return;
    final crumbs = Set<Cell>.from(_state!.breadcrumbs);
    if (crumbs.contains(cell)) {
      crumbs.remove(cell);
    } else {
      crumbs.add(cell);
    }
    _state = _state!.copyWith(breadcrumbs: crumbs);
    notifyListeners();
  }

  void toggleWallMark(Cell cell, Cell neighbor) {
    if (_state == null) return;
    final marks = Map<Cell, Set<Cell>>.from(_state!.wallMarks);
    final cellMarks = Set<Cell>.from(marks[cell] ?? {});
    if (cellMarks.contains(neighbor)) {
      cellMarks.remove(neighbor);
    } else {
      cellMarks.add(neighbor);
    }
    marks[cell] = cellMarks;
    _state = _state!.copyWith(wallMarks: marks);
    notifyListeners();
  }

  void toggleSolution() {
    if (_state == null) return;
    _state = _state!.copyWith(showSolution: !_state!.showSolution);
    notifyListeners();
  }

  Grid _createGrid(MazeConfig config) {
    return switch (config.cellType) {
      CellType.square => SquareGrid(config.rows, config.columns),
      CellType.hexagonal => HexGrid(config.rows, config.columns),
      CellType.triangular => TriangleGrid(config.rows, config.columns),
      CellType.circular => CircularGrid(config.rows),
      CellType.voronoi => VoronoiGrid(
          config.rows,
          config.columns,
          cellCount: config.rows * config.columns ~/ 2,
          seed: config.seed,
        ),
    };
  }

  MazeGenerator _createGenerator(Algorithm? algorithm) {
    return switch (algorithm) {
      Algorithm.recursiveBacktracker => const RecursiveBacktracker(),
      Algorithm.kruskals => const Kruskals(),
      Algorithm.prims => const Prims(),
      Algorithm.ellers => const Ellers(),
      Algorithm.wilsons => const Wilsons(),
      Algorithm.aldousBroder => const AldousBroder(),
      Algorithm.growingTree => const GrowingTree(),
      Algorithm.huntAndKill => const HuntAndKill(),
      Algorithm.sidewinder => const Sidewinder(),
      Algorithm.binaryTree => const BinaryTree(),
      Algorithm.recursiveDivision => const RecursiveDivision(),
      null => const RecursiveBacktracker(),
    };
  }
}
