import 'dart:math';

import '../models/cell.dart';
import '../models/grid.dart';

/// A cell in a triangular grid.
///
/// Triangles alternate between pointing up and down. An upward triangle has
/// neighbors to the left, right, and below. A downward triangle has neighbors
/// to the left, right, and above.
class TriangleCell extends Cell {
  TriangleCell(super.row, super.column);

  /// Whether this triangle points upward.
  bool get isUpright => (row + column).isEven;

  Cell? left;
  Cell? right;

  /// The neighbor opposite the base — below for upright, above for inverted.
  Cell? base;

  @override
  List<Cell> get neighbors =>
      [left, right, base].whereType<Cell>().toList();

  static const double _size = 1.0;
  static double get _height => _size * sqrt(3) / 2;

  @override
  List<({double x, double y})> get vertices {
    const halfSize = _size / 2;
    // Left edge x position.
    final cx = column * halfSize;

    if (isUpright) {
      final topY = row * _height;
      return [
        (x: cx, y: topY + _height),           // bottom-left
        (x: cx + _size, y: topY + _height),   // bottom-right
        (x: cx + halfSize, y: topY),           // top
      ];
    } else {
      final topY = row * _height;
      return [
        (x: cx, y: topY),                     // top-left
        (x: cx + _size, y: topY),             // top-right
        (x: cx + halfSize, y: topY + _height), // bottom
      ];
    }
  }

  @override
  ({double x, double y}) get center {
    const halfSize = _size / 2;
    final cx = column * halfSize + halfSize;
    if (isUpright) {
      return (x: cx, y: row * _height + _height * 2 / 3);
    } else {
      return (x: cx, y: row * _height + _height / 3);
    }
  }

  /// Edge 0 = base edge (bottom for upright, top for inverted).
  /// Edge 1 = right edge. Edge 2 = left edge.
  @override
  Cell? neighborForEdge(int edgeIndex) => switch (edgeIndex) {
        0 => base,
        1 => right,
        2 => left,
        _ => null,
      };
}

/// A grid of alternating up/down [TriangleCell]s.
class TriangleGrid extends Grid {
  TriangleGrid(
    super.rows,
    super.columns, {
    bool Function(int row, int col)? mask,
  }) : _mask = mask {
    _prepareCells();
    _configureNeighbors();
  }

  final bool Function(int row, int col)? _mask;
  late final List<List<TriangleCell?>> _grid;

  void _prepareCells() {
    _grid = List.generate(rows, (row) {
      return List.generate(columns, (col) {
        if (_mask != null && !_mask(row, col)) return null;
        return TriangleCell(row, col);
      });
    });
  }

  void _configureNeighbors() {
    for (final cell in cells) {
      final c = cell as TriangleCell;
      c.left = _at(c.row, c.column - 1);
      c.right = _at(c.row, c.column + 1);

      if (c.isUpright) {
        c.base = _at(c.row + 1, c.column);
      } else {
        c.base = _at(c.row - 1, c.column);
      }
    }
  }

  TriangleCell? _at(int row, int col) {
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
