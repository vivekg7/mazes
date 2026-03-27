import 'package:maze_core/maze_core.dart';

/// A bookmarked maze that can be replayed.
///
/// Stores the full config with seed so the exact same maze can be regenerated.
class BookmarkedMaze {
  const BookmarkedMaze({
    required this.id,
    required this.config,
    required this.bookmarkedAt,
  });

  /// Unique identifier (timestamp-based).
  final String id;

  /// Maze configuration including seed for deterministic regeneration.
  final MazeConfig config;

  /// When the maze was bookmarked.
  final DateTime bookmarkedAt;

  Map<String, dynamic> toJson() => {
        'id': id,
        'config': config.toJson(),
        'bookmarkedAt': bookmarkedAt.toIso8601String(),
      };

  factory BookmarkedMaze.fromJson(Map<String, dynamic> json) {
    return BookmarkedMaze(
      id: json['id'] as String,
      config: MazeConfig.fromJson(
        Map<String, dynamic>.from(json['config'] as Map),
      ),
      bookmarkedAt: DateTime.parse(json['bookmarkedAt'] as String),
    );
  }
}
