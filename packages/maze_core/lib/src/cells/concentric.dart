import 'dart:math';

import '../models/cell.dart';
import '../models/grid.dart';

/// A cell in a concentric-circle grid.
///
/// Unlike [CircularGrid], concentric grids have a fixed number of cells per
/// ring (no subdivision). This creates uniform ring segments and emphasizes
/// movement between rings.
class ConcentricCell extends Cell {
  ConcentricCell(super.row, super.column);

  Cell? inward;
  Cell? clockwise;
  Cell? counterClockwise;
  Cell? outward;

  @override
  List<Cell> get neighbors =>
      [inward, outward, clockwise, counterClockwise]
          .whereType<Cell>()
          .toList();

  late final double innerRadius;
  late final double outerRadius;
  late final double startAngle;
  late final double endAngle;

  @override
  List<({double x, double y})> get vertices {
    const segments = 8;
    final points = <({double x, double y})>[];

    for (var i = 0; i <= segments; i++) {
      final angle = startAngle + (endAngle - startAngle) * i / segments;
      points.add((x: innerRadius * cos(angle), y: innerRadius * sin(angle)));
    }

    for (var i = segments; i >= 0; i--) {
      final angle = startAngle + (endAngle - startAngle) * i / segments;
      points.add((x: outerRadius * cos(angle), y: outerRadius * sin(angle)));
    }

    return points;
  }

  @override
  ({double x, double y}) get center {
    final midR = (innerRadius + outerRadius) / 2;
    final midA = (startAngle + endAngle) / 2;
    return (x: midR * cos(midA), y: midR * sin(midA));
  }
}

/// A grid of concentric rings with a fixed number of cells per ring.
///
/// [rows] is the number of rings. [columns] is the number of cells per ring.
/// All rings have the same cell count, creating uniform wedge segments.
class ConcentricGrid extends Grid {
  ConcentricGrid(
    super.rows,
    super.columns, {
    this.ringHeight = 1.0,
  }) {
    _prepareCells();
    _configureNeighbors();
  }

  final double ringHeight;
  late final List<List<ConcentricCell>> _rings;

  void _prepareCells() {
    _rings = List.generate(rows, (ring) {
      final innerR = ring * ringHeight;
      final outerR = (ring + 1) * ringHeight;
      final angleStep = 2 * pi / columns;

      return List.generate(columns, (col) {
        return ConcentricCell(ring, col)
          ..innerRadius = innerR
          ..outerRadius = outerR
          ..startAngle = col * angleStep
          ..endAngle = (col + 1) * angleStep;
      });
    });
  }

  void _configureNeighbors() {
    for (var ring = 0; ring < _rings.length; ring++) {
      final currentRing = _rings[ring];

      for (var i = 0; i < currentRing.length; i++) {
        final cell = currentRing[i];

        // Same-ring neighbors.
        cell.clockwise = currentRing[(i + 1) % columns];
        cell.counterClockwise =
            currentRing[(i - 1 + columns) % columns];

        // Cross-ring neighbors.
        if (ring > 0) {
          cell.inward = _rings[ring - 1][i];
        }
        if (ring < _rings.length - 1) {
          cell.outward = _rings[ring + 1][i];
        }
      }
    }
  }

  @override
  Cell? cellAt(int row, int col) {
    if (row < 0 || row >= rows || col < 0 || col >= columns) return null;
    return _rings[row][col];
  }

  @override
  Iterable<Cell> get cells => _rings.expand((ring) => ring);

  @override
  Iterable<List<Cell?>> get rowsIterable =>
      _rings.map((ring) => ring.cast<Cell?>());
}
