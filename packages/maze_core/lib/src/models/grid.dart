import 'dart:math';

import 'cell.dart';

/// Abstract base class for all maze grids.
///
/// A grid owns a collection of [Cell]s arranged in a geometry-specific layout.
/// Subclasses (SquareGrid, HexGrid, etc.) define how cells are created,
/// positioned, and connected as neighbors.
abstract class Grid {
  /// Creates a grid with the given [rows] and [columns].
  ///
  /// Subclasses should call [prepareCells] and then [configureNeighbors]
  /// during construction.
  Grid(this.rows, this.columns);

  /// Number of rows in the grid.
  final int rows;

  /// Number of columns in the grid.
  final int columns;

  /// Total number of cells in the grid (may be less than rows*columns if
  /// a mask is applied).
  int get size => cells.length;

  /// All cells in the grid as a flat iterable.
  Iterable<Cell> get cells;

  /// Returns the cell at [row], [col], or null if out of bounds or masked.
  Cell? cellAt(int row, int col);

  /// A random cell from the grid.
  Cell randomCell([Random? random]) {
    final rng = random ?? Random();
    final allCells = cells.toList();
    return allCells[rng.nextInt(allCells.length)];
  }

  /// All dead-end cells (cells with exactly one link).
  Iterable<Cell> get deadEnds => cells.where((c) => c.isDeadEnd);

  /// Number of dead-end cells.
  int get deadEndCount => deadEnds.length;

  /// Iterates over each row of cells.
  ///
  /// Each row is a list of nullable cells (null for masked/missing positions).
  Iterable<List<Cell?>> get rowsIterable;

  @override
  String toString() => '$runtimeType($rows x $columns, $size cells)';
}
