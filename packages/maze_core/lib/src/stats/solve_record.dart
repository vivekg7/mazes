import '../models/enums.dart';

/// A single maze solve record.
class SolveRecord {
  const SolveRecord({
    required this.timestamp,
    required this.cellType,
    required this.puzzleShape,
    required this.algorithm,
    required this.difficulty,
    required this.rows,
    required this.columns,
    required this.solveTimeMs,
    required this.playerPathLength,
    required this.shortestPathLength,
    required this.completed,
    this.shapeVariant,
  });

  final DateTime timestamp;
  final CellType cellType;
  final PuzzleShape puzzleShape;
  final String? shapeVariant;
  final Algorithm algorithm;
  final DifficultyLevel difficulty;
  final int rows;
  final int columns;

  /// Time taken to solve in milliseconds.
  final int solveTimeMs;

  /// Number of steps the player took.
  final int playerPathLength;

  /// Shortest possible path length.
  final int shortestPathLength;

  /// Whether the maze was completed (reached the exit).
  final bool completed;

  /// Player efficiency: shortest / player path (1.0 = perfect).
  double get efficiency => playerPathLength == 0
      ? 0
      : shortestPathLength / playerPathLength;

  /// Solve time as a Duration.
  Duration get solveTime => Duration(milliseconds: solveTimeMs);

  /// Converts to a JSON-compatible map.
  Map<String, dynamic> toJson() => {
        'timestamp': timestamp.toIso8601String(),
        'cellType': cellType.name,
        'puzzleShape': puzzleShape.name,
        'shapeVariant': shapeVariant,
        'algorithm': algorithm.name,
        'difficulty': difficulty.name,
        'rows': rows,
        'columns': columns,
        'solveTimeMs': solveTimeMs,
        'playerPathLength': playerPathLength,
        'shortestPathLength': shortestPathLength,
        'completed': completed,
      };

  /// Creates a [SolveRecord] from a JSON map.
  factory SolveRecord.fromJson(Map<String, dynamic> json) {
    return SolveRecord(
      timestamp: DateTime.parse(json['timestamp'] as String),
      cellType: CellType.values.byName(json['cellType'] as String),
      puzzleShape: PuzzleShape.values.byName(json['puzzleShape'] as String),
      shapeVariant: json['shapeVariant'] as String?,
      algorithm: Algorithm.values.byName(json['algorithm'] as String),
      difficulty: DifficultyLevel.values.byName(json['difficulty'] as String),
      rows: json['rows'] as int,
      columns: json['columns'] as int,
      solveTimeMs: json['solveTimeMs'] as int,
      playerPathLength: json['playerPathLength'] as int,
      shortestPathLength: json['shortestPathLength'] as int,
      completed: json['completed'] as bool,
    );
  }
}
