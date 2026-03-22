/// Abstract mask that defines the outer boundary of a maze.
///
/// A shape determines which cells in a grid are included. The grid passes
/// each candidate cell position through [contains] — cells outside the shape
/// are excluded (masked out).
abstract class Shape {
  const Shape();

  /// Whether the point ([x], [y]) falls inside this shape.
  ///
  /// Coordinates are in grid units (row/column space). For rectangular grids,
  /// x maps to column and y maps to row. For non-rectangular grids, the grid
  /// provides normalized coordinates.
  bool contains(double x, double y);

  /// Convenience: whether the grid cell at [row], [col] should be included.
  ///
  /// Tests the cell center point (row + 0.5, col + 0.5) against the shape.
  bool containsCell(int row, int col) =>
      contains(col + 0.5, row + 0.5);

  /// The bounding box width in grid units.
  double get width;

  /// The bounding box height in grid units.
  double get height;
}
