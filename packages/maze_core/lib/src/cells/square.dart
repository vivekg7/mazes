import '../models/cell.dart';
import '../models/grid.dart';

/// A cell in a square (rectangular) grid.
///
/// Each cell has up to 4 neighbors: north, south, east, west.
class SquareCell extends Cell {
  SquareCell(super.row, super.column);

  /// Neighbor to the north (row - 1).
  Cell? north;

  /// Neighbor to the south (row + 1).
  Cell? south;

  /// Neighbor to the east (column + 1).
  Cell? east;

  /// Neighbor to the west (column - 1).
  Cell? west;

  @override
  List<Cell> get neighbors =>
      [north, south, east, west].whereType<Cell>().toList();

  @override
  List<({double x, double y})> get vertices => [
        (x: column.toDouble(), y: row.toDouble()),
        (x: column + 1.0, y: row.toDouble()),
        (x: column + 1.0, y: row + 1.0),
        (x: column.toDouble(), y: row + 1.0),
      ];

  @override
  ({double x, double y}) get center => (x: column + 0.5, y: row + 0.5);
}

/// A rectangular grid of [SquareCell]s.
///
/// Supports masking: pass a [mask] function to exclude cells from the grid.
/// Masked positions return null from [cellAt] and are excluded from iteration.
class SquareGrid extends Grid {
  /// Creates a square grid with the given dimensions.
  ///
  /// If [mask] is provided, cells where `mask(row, col)` returns false are
  /// excluded from the grid.
  SquareGrid(super.rows, super.columns, {bool Function(int row, int col)? mask})
      : _mask = mask {
    _prepareCells();
    _configureNeighbors();
  }

  final bool Function(int row, int col)? _mask;
  late final List<List<SquareCell?>> _grid;

  void _prepareCells() {
    _grid = List.generate(rows, (row) {
      return List.generate(columns, (col) {
        if (_mask != null && !_mask(row, col)) return null;
        return SquareCell(row, col);
      });
    });
  }

  void _configureNeighbors() {
    for (final cell in cells) {
      final c = cell as SquareCell;
      c.north = cellAt(c.row - 1, c.column) as SquareCell?;
      c.south = cellAt(c.row + 1, c.column) as SquareCell?;
      c.west = cellAt(c.row, c.column - 1) as SquareCell?;
      c.east = cellAt(c.row, c.column + 1) as SquareCell?;
    }
  }

  @override
  Cell? cellAt(int row, int col) {
    if (row < 0 || row >= rows || col < 0 || col >= columns) return null;
    return _grid[row][col];
  }

  @override
  Iterable<Cell> get cells =>
      _grid.expand((row) => row).whereType<Cell>();

  @override
  Iterable<List<Cell?>> get rowsIterable =>
      _grid.map((row) => row.cast<Cell?>());
}
