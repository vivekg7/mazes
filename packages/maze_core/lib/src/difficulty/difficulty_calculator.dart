import '../models/enums.dart';
import '../models/maze_config.dart';

/// Computes [MazeConfig] parameters from a difficulty level and cell type.
///
/// Maps each difficulty level to appropriate grid dimensions and a recommended
/// algorithm that suits the target challenge.
class DifficultyCalculator {
  const DifficultyCalculator();

  /// Returns a [MazeConfig] for the given [level] and [cellType].
  ///
  /// If [algorithm] is null, one is selected automatically.
  MazeConfig configFor({
    required DifficultyLevel level,
    required CellType cellType,
    PuzzleShape puzzleShape = PuzzleShape.rectangle,
    String? shapeVariant,
    Algorithm? algorithm,
    int? seed,
  }) {
    final dims = _dimensions(level, cellType);
    return MazeConfig(
      cellType: cellType,
      rows: dims.rows,
      columns: dims.columns,
      puzzleShape: puzzleShape,
      shapeVariant: shapeVariant,
      algorithm: algorithm ?? _recommendAlgorithm(level),
      difficulty: level,
      seed: seed,
    );
  }

  /// Grid dimensions for a given difficulty and cell type.
  ({int rows, int columns}) _dimensions(
    DifficultyLevel level,
    CellType cellType,
  ) {
    // Base dimensions for square cells. Other cell types adjust.
    final base = switch (level) {
      DifficultyLevel.casual => (rows: 5, columns: 5),
      DifficultyLevel.easy => (rows: 8, columns: 8),
      DifficultyLevel.medium => (rows: 12, columns: 12),
      DifficultyLevel.hard => (rows: 18, columns: 18),
      DifficultyLevel.expert => (rows: 25, columns: 25),
      DifficultyLevel.extreme => (rows: 35, columns: 35),
    };

    // Adjust for cell type — some types feel denser or sparser.
    return switch (cellType) {
      CellType.square => base,
      CellType.hexagonal => (
          rows: (base.rows * 0.85).round(),
          columns: (base.columns * 0.85).round(),
        ),
      CellType.triangular => (
          rows: base.rows,
          columns: base.columns * 2,
        ),
      CellType.circular => (
          rows: (base.rows * 0.7).round(),
          columns: base.columns,
        ),
      CellType.voronoi => base,
    };
  }

  /// Picks an algorithm suited to the difficulty level.
  ///
  /// Easier levels use algorithms that produce more structured mazes.
  /// Harder levels use algorithms that produce more complex, winding mazes.
  Algorithm _recommendAlgorithm(DifficultyLevel level) {
    return switch (level) {
      DifficultyLevel.casual => Algorithm.binaryTree,
      DifficultyLevel.easy => Algorithm.sidewinder,
      DifficultyLevel.medium => Algorithm.prims,
      DifficultyLevel.hard => Algorithm.recursiveBacktracker,
      DifficultyLevel.expert => Algorithm.wilsons,
      DifficultyLevel.extreme => Algorithm.recursiveBacktracker,
    };
  }
}
