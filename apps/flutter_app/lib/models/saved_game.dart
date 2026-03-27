import 'package:maze_core/maze_core.dart';

/// A serializable snapshot of an in-progress maze game.
///
/// Stores the config (with seed for deterministic regeneration) and player
/// state as coordinate pairs rather than Cell objects.
class SavedGame {
  const SavedGame({
    required this.id,
    required this.config,
    required this.playerPath,
    required this.elapsedMs,
    required this.breadcrumbs,
    required this.wallMarks,
    required this.savedAt,
  });

  /// Unique identifier (timestamp-based).
  final String id;

  /// Maze configuration including seed for deterministic regeneration.
  final MazeConfig config;

  /// Player path as (row, column) pairs.
  final List<(int, int)> playerPath;

  /// Elapsed time in milliseconds.
  final int elapsedMs;

  /// Breadcrumb positions as (row, column) pairs.
  final Set<(int, int)> breadcrumbs;

  /// Wall marks as cell→{neighbor} mapping using (row, column) pairs.
  final Map<(int, int), Set<(int, int)>> wallMarks;

  /// When the game was saved.
  final DateTime savedAt;

  Map<String, dynamic> toJson() => {
        'id': id,
        'config': config.toJson(),
        'playerPath': playerPath
            .map((p) => [p.$1, p.$2])
            .toList(),
        'elapsedMs': elapsedMs,
        'breadcrumbs': breadcrumbs
            .map((p) => [p.$1, p.$2])
            .toList(),
        'wallMarks': wallMarks.map(
          (cell, neighbors) => MapEntry(
            '${cell.$1},${cell.$2}',
            neighbors.map((n) => [n.$1, n.$2]).toList(),
          ),
        ),
        'savedAt': savedAt.toIso8601String(),
      };

  factory SavedGame.fromJson(Map<String, dynamic> json) {
    final pathList = (json['playerPath'] as List)
        .map((e) => ((e as List)[0] as int, e[1] as int))
        .toList();

    final crumbsList = (json['breadcrumbs'] as List)
        .map((e) => ((e as List)[0] as int, e[1] as int))
        .toSet();

    final marksMap = (json['wallMarks'] as Map<String, dynamic>).map(
      (key, value) {
        final parts = key.split(',');
        final cell = (int.parse(parts[0]), int.parse(parts[1]));
        final neighbors = (value as List)
            .map((e) => ((e as List)[0] as int, e[1] as int))
            .toSet();
        return MapEntry(cell, neighbors);
      },
    );

    return SavedGame(
      id: json['id'] as String,
      config: MazeConfig.fromJson(
        Map<String, dynamic>.from(json['config'] as Map),
      ),
      playerPath: pathList,
      elapsedMs: json['elapsedMs'] as int,
      breadcrumbs: crumbsList,
      wallMarks: marksMap,
      savedAt: DateTime.parse(json['savedAt'] as String),
    );
  }
}
