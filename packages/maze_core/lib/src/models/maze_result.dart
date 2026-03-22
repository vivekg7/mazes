import 'grid.dart';
import 'maze_config.dart';
import 'path.dart';

/// The output of maze generation.
///
/// Contains the carved grid, start/end cells, the shortest solution path,
/// and metadata about the generated maze.
class MazeResult {
  const MazeResult({
    required this.config,
    required this.grid,
    required this.startRow,
    required this.startCol,
    required this.endRow,
    required this.endCol,
    required this.solution,
    required this.generationTimeMs,
  });

  /// The configuration used to generate this maze.
  final MazeConfig config;

  /// The carved grid with all passages opened.
  final Grid grid;

  /// Start cell position.
  final int startRow;
  final int startCol;

  /// End cell position.
  final int endRow;
  final int endCol;

  /// The shortest path from start to end.
  final MazePath solution;

  /// How long generation took in milliseconds.
  final int generationTimeMs;

  /// Number of steps in the shortest solution path.
  int get solutionLength => solution.steps;

  /// Total number of cells in the maze.
  int get totalCells => grid.size;

  /// Number of dead ends in the maze.
  int get deadEndCount => grid.deadEndCount;

  @override
  String toString() =>
      'MazeResult(${grid.rows}x${grid.columns}, '
      'solution: $solutionLength steps, '
      'dead ends: $deadEndCount)';
}
