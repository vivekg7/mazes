import 'dart:math';

import '../models/cell.dart';
import '../models/grid.dart';

/// A cell in a hexagonal (honeycomb) grid using flat-top orientation.
///
/// Each cell has up to 6 neighbors: north, northeast, southeast, south,
/// southwest, northwest.
class HexCell extends Cell {
  HexCell(super.row, super.column);

  Cell? north;
  Cell? northeast;
  Cell? southeast;
  Cell? south;
  Cell? southwest;
  Cell? northwest;

  @override
  List<Cell> get neighbors =>
      [north, northeast, southeast, south, southwest, northwest]
          .whereType<Cell>()
          .toList();

  /// Hex size (distance from center to vertex).
  static const double size = 1.0;

  /// Horizontal distance between hex centers.
  static double get width => size * 2;

  /// Vertical distance between hex centers.
  static double get height => size * sqrt(3);

  @override
  List<({double x, double y})> get vertices {
    final cx = center.x;
    final cy = center.y;
    // Flat-top hex: vertices at 0°, 60°, 120°, 180°, 240°, 300°.
    return List.generate(6, (i) {
      final angle = pi / 180 * (60.0 * i);
      return (x: cx + size * cos(angle), y: cy + size * sin(angle));
    });
  }

  @override
  ({double x, double y}) get center {
    // Flat-top hex layout: odd columns are offset vertically by half a height.
    final cx = column * size * 1.5 + size;
    final cy = row * height + (column.isOdd ? height / 2 : 0) + height / 2;
    return (x: cx, y: cy);
  }
}

/// A honeycomb grid of [HexCell]s using flat-top hex orientation.
class HexGrid extends Grid {
  HexGrid(super.rows, super.columns, {bool Function(int row, int col)? mask})
      : _mask = mask {
    _prepareCells();
    _configureNeighbors();
  }

  final bool Function(int row, int col)? _mask;
  late final List<List<HexCell?>> _grid;

  void _prepareCells() {
    _grid = List.generate(rows, (row) {
      return List.generate(columns, (col) {
        if (_mask != null && !_mask(row, col)) return null;
        return HexCell(row, col);
      });
    });
  }

  void _configureNeighbors() {
    for (final cell in cells) {
      final c = cell as HexCell;
      final r = c.row;
      final col = c.column;

      // Flat-top hex: even/odd column offsets differ.
      final offset = col.isEven ? -1 : 0;

      c.north = _at(r - 1, col);
      c.south = _at(r + 1, col);
      c.northwest = _at(r + offset, col - 1);
      c.northeast = _at(r + offset, col + 1);
      c.southwest = _at(r + offset + 1, col - 1);
      c.southeast = _at(r + offset + 1, col + 1);
    }
  }

  HexCell? _at(int row, int col) {
    if (row < 0 || row >= rows || col < 0 || col >= columns) return null;
    return _grid[row][col];
  }

  @override
  Cell? cellAt(int row, int col) => _at(row, col);

  @override
  Iterable<Cell> get cells =>
      _grid.expand((row) => row).whereType<Cell>();

  @override
  Iterable<List<Cell?>> get rowsIterable =>
      _grid.map((row) => row.cast<Cell?>());
}
