import '../models/cell.dart';
import '../models/grid.dart';
import 'solver.dart';

/// Analysis metrics for a generated maze.
class MazeAnalysis {
  const MazeAnalysis({
    required this.totalCells,
    required this.deadEndCount,
    required this.solutionLength,
    required this.longestPathLength,
    required this.averageBranchingFactor,
    required this.decisionPointCount,
  });

  /// Total number of cells in the maze.
  final int totalCells;

  /// Number of dead-end cells (exactly one link).
  final int deadEndCount;

  /// Length of the shortest path from start to end (in steps).
  final int solutionLength;

  /// Length of the longest shortest path in the maze (diameter).
  final int longestPathLength;

  /// Average number of links per cell (excluding dead ends).
  final double averageBranchingFactor;

  /// Number of cells where the player must choose between 2+ directions.
  /// (Cells with 3 or more links, since one link is the way in.)
  final int decisionPointCount;

  /// Ratio of solution length to total cells. Higher = harder.
  double get solutionRatio =>
      totalCells == 0 ? 0 : solutionLength / totalCells;

  /// Ratio of dead ends to total cells.
  double get deadEndRatio =>
      totalCells == 0 ? 0 : deadEndCount / totalCells;

  @override
  String toString() =>
      'MazeAnalysis(cells: $totalCells, deadEnds: $deadEndCount, '
      'solution: $solutionLength, longest: $longestPathLength, '
      'branching: ${averageBranchingFactor.toStringAsFixed(2)}, '
      'decisions: $decisionPointCount)';
}

/// Analyzes a generated maze and returns metrics.
MazeAnalysis analyzeMaze(Grid grid, Cell start, Cell end) {
  final allCells = grid.cells.toList();
  final totalCells = allCells.length;

  // Dead ends.
  final deadEnds = allCells.where((c) => c.isDeadEnd).length;

  // Solution length.
  final solution = solveMaze(start, end);

  // Longest path (diameter).
  final longest = longestPath(start);

  // Branching factor: average links per non-dead-end cell.
  final nonDeadEnds = allCells.where((c) => c.linkCount > 1);
  final avgBranching = nonDeadEnds.isEmpty
      ? 0.0
      : nonDeadEnds.map((c) => c.linkCount).reduce((a, b) => a + b) /
          nonDeadEnds.length;

  // Decision points: cells with 3+ links (2+ choices beyond the entrance).
  final decisions = allCells.where((c) => c.linkCount >= 3).length;

  return MazeAnalysis(
    totalCells: totalCells,
    deadEndCount: deadEnds,
    solutionLength: solution.steps,
    longestPathLength: longest.path.steps,
    averageBranchingFactor: avgBranching,
    decisionPointCount: decisions,
  );
}
