import 'enums.dart';

/// Configuration for generating a maze.
///
/// Captures all user-selected (or auto-selected) parameters needed to produce
/// a maze: grid geometry, shape, algorithm, difficulty, and size.
class MazeConfig {
  const MazeConfig({
    required this.cellType,
    required this.rows,
    required this.columns,
    this.puzzleShape = PuzzleShape.rectangle,
    this.shapeVariant,
    this.algorithm,
    this.difficulty = DifficultyLevel.medium,
    this.seed,
  });

  /// The cell geometry to use.
  final CellType cellType;

  /// The outer boundary shape.
  final PuzzleShape puzzleShape;

  /// Optional variant within the shape category (e.g., "cat" for animal,
  /// "A" for letter).
  final String? shapeVariant;

  /// The generation algorithm. If null, one is chosen automatically based on
  /// the difficulty and cell type.
  final Algorithm? algorithm;

  /// The target difficulty level.
  final DifficultyLevel difficulty;

  /// Number of rows in the grid.
  final int rows;

  /// Number of columns in the grid.
  final int columns;

  /// Optional random seed for reproducible generation.
  final int? seed;

  /// Creates a copy with the given fields replaced.
  MazeConfig copyWith({
    CellType? cellType,
    PuzzleShape? puzzleShape,
    String? shapeVariant,
    Algorithm? algorithm,
    DifficultyLevel? difficulty,
    int? rows,
    int? columns,
    int? seed,
  }) {
    return MazeConfig(
      cellType: cellType ?? this.cellType,
      puzzleShape: puzzleShape ?? this.puzzleShape,
      shapeVariant: shapeVariant ?? this.shapeVariant,
      algorithm: algorithm ?? this.algorithm,
      difficulty: difficulty ?? this.difficulty,
      rows: rows ?? this.rows,
      columns: columns ?? this.columns,
      seed: seed ?? this.seed,
    );
  }

  @override
  String toString() =>
      'MazeConfig($cellType, ${rows}x$columns, $difficulty, $algorithm)';
}
