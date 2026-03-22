import 'cell.dart';

/// An ordered sequence of linked cells representing a route through the maze.
///
/// Used for both the player's drawn path and the computed solution.
class MazePath {
  /// Creates a path from an ordered list of [cells].
  ///
  /// Each consecutive pair of cells should be linked (open passage between
  /// them) for the path to be valid.
  const MazePath(this.cells);

  /// Creates an empty path.
  const MazePath.empty() : cells = const [];

  /// The ordered list of cells in this path.
  final List<Cell> cells;

  /// Number of cells in the path.
  int get length => cells.length;

  /// Number of steps (passages traversed) in the path.
  int get steps => cells.isEmpty ? 0 : cells.length - 1;

  /// Whether this path contains no cells.
  bool get isEmpty => cells.isEmpty;

  /// Whether this path contains at least one cell.
  bool get isNotEmpty => cells.isNotEmpty;

  /// The first cell in the path, or null if empty.
  Cell? get start => cells.isEmpty ? null : cells.first;

  /// The last cell in the path, or null if empty.
  Cell? get end => cells.isEmpty ? null : cells.last;

  /// Whether this path passes through [cell].
  bool contains(Cell cell) => cells.contains(cell);

  /// Whether every consecutive pair of cells in this path is linked.
  bool get isValid {
    for (var i = 0; i < cells.length - 1; i++) {
      if (!cells[i].isLinked(cells[i + 1])) return false;
    }
    return true;
  }
}
