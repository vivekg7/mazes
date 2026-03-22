/// A single cell in a maze grid.
///
/// Each cell tracks its neighbors (adjacent cells in the grid) and its links
/// (neighbors with an open passage between them). A wall exists between two
/// neighboring cells that are not linked.
///
/// Subclasses define geometry-specific neighbor relationships (e.g., north/south
/// for square cells, or six directions for hex cells).
abstract class Cell {
  /// Creates a cell at the given [row] and [column].
  Cell(this.row, this.column);

  /// Row index in the grid.
  final int row;

  /// Column index in the grid.
  final int column;

  final Set<Cell> _links = {};

  /// All neighboring cells (adjacent in the grid geometry).
  ///
  /// Subclasses populate this based on their geometry. A neighbor is any cell
  /// that *could* have a passage to this cell, whether or not one exists.
  List<Cell> get neighbors;

  /// All cells linked to this one (open passage between them).
  Set<Cell> get links => Set.unmodifiable(_links);

  /// Whether this cell has an open passage to [other].
  bool isLinked(Cell other) => _links.contains(other);

  /// Opens a passage between this cell and [other].
  ///
  /// If [bidirectional] is true (the default), the link is created in both
  /// directions.
  void link(Cell other, {bool bidirectional = true}) {
    _links.add(other);
    if (bidirectional) {
      other._links.add(this);
    }
  }

  /// Closes the passage between this cell and [other].
  ///
  /// If [bidirectional] is true (the default), the link is removed in both
  /// directions.
  void unlink(Cell other, {bool bidirectional = true}) {
    _links.remove(other);
    if (bidirectional) {
      other._links.remove(this);
    }
  }

  /// The number of open passages from this cell.
  int get linkCount => _links.length;

  /// Whether this cell has no open passages (a dead end or isolated cell).
  bool get isDeadEnd => _links.length == 1;

  /// Whether this cell has no links at all.
  bool get isIsolated => _links.isEmpty;

  /// Vertex positions defining this cell's polygon for rendering.
  ///
  /// Returns a list of (x, y) pairs in order. The polygon is closed
  /// (last vertex connects back to first).
  List<({double x, double y})> get vertices;

  /// Center point of this cell for rendering.
  ({double x, double y}) get center;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Cell && row == other.row && column == other.column;

  @override
  int get hashCode => Object.hash(row, column);

  @override
  String toString() => 'Cell($row, $column)';
}
