import 'dart:math';

import '../models/cell.dart';
import '../models/grid.dart';

/// A wedge-shaped cell in a circular (polar) grid.
///
/// [row] represents the ring index (0 = center), and [column] the position
/// within that ring. Cells in outer rings may subdivide to maintain roughly
/// equal cell sizes.
class CircularCell extends Cell {
  CircularCell(super.row, super.column);

  /// Neighbor(s) closer to the center (inward ring).
  Cell? inward;

  /// Neighbor in the same ring, counterclockwise.
  Cell? clockwise;

  /// Neighbor in the same ring, clockwise.
  Cell? counterClockwise;

  /// Neighbors in the next ring outward. May be more than one if the outer
  /// ring has subdivided cells.
  final List<Cell> outward = [];

  @override
  List<Cell> get neighbors => [
        inward,
        clockwise,
        counterClockwise,
        ...outward,
      ].whereType<Cell>().toList();

  /// These are set by the grid after construction.
  late final double innerRadius;
  late final double outerRadius;
  late final double startAngle;
  late final double endAngle;

  @override
  List<({double x, double y})> get vertices {
    final points = <({double x, double y})>[];

    // Inner arc (from start to end angle).
    for (var i = 0; i <= _segments; i++) {
      final angle = startAngle + (endAngle - startAngle) * i / _segments;
      points.add((x: innerRadius * cos(angle), y: innerRadius * sin(angle)));
    }

    // Outer arc (from end back to start angle).
    for (var i = _segments; i >= 0; i--) {
      final angle = startAngle + (endAngle - startAngle) * i / _segments;
      points.add((x: outerRadius * cos(angle), y: outerRadius * sin(angle)));
    }

    return points;
  }

  @override
  ({double x, double y}) get center {
    final midRadius = (innerRadius + outerRadius) / 2;
    final midAngle = (startAngle + endAngle) / 2;
    return (x: midRadius * cos(midAngle), y: midRadius * sin(midAngle));
  }

  /// Edges 0.._segments-1: inner arc → inward.
  /// Edge _segments: radial at endAngle → clockwise.
  /// Edges _segments+1..2*_segments: outer arc → outward neighbor(s).
  /// Edge 2*_segments+1: radial at startAngle → counterClockwise.
  @override
  Cell? neighborForEdge(int edgeIndex) {
    if (edgeIndex < _segments) {
      return inward;
    } else if (edgeIndex == _segments) {
      return clockwise;
    } else if (edgeIndex < 2 * _segments + 1) {
      if (outward.isEmpty) return null;
      if (outward.length == 1) return outward.first;
      // Multiple outward neighbors: outer arc runs end→start angle (reversed).
      // Edge _segments+1 is at endAngle side, edge 2*_segments is at startAngle.
      // Outward neighbors are ordered by column (ascending angle).
      // So the last outward neighbor is at endAngle, first at startAngle.
      final outerEdgeIdx = edgeIndex - _segments - 1; // 0 = endAngle side
      final neighborIdx =
          outward.length - 1 - (outerEdgeIdx * outward.length ~/ _segments);
      return outward[neighborIdx.clamp(0, outward.length - 1)];
    } else if (edgeIndex == 2 * _segments + 1) {
      return counterClockwise;
    }
    return null;
  }

  static const _segments = 8;
}

/// A circular (polar) grid where cells are wedge-shaped and arranged in
/// concentric rings radiating from a center point.
///
/// Outer rings automatically subdivide to keep cell sizes roughly uniform.
/// [rows] controls the number of rings, [columns] is ignored (cell count per
/// ring is computed from geometry).
class CircularGrid extends Grid {
  /// Creates a circular grid with [rows] rings.
  ///
  /// [startingCells] controls how many cells are in the first ring (default 6).
  CircularGrid(
    int rows, {
    int startingCells = 6,
    this.ringHeight = 1.0,
  }) : super(rows, startingCells) {
    _prepareCells();
    _configureNeighbors();
  }

  final double ringHeight;
  late final List<List<CircularCell>> _rings;

  /// Number of cells in each ring.
  List<int> get ringCellCounts => _rings.map((r) => r.length).toList();

  void _prepareCells() {
    _rings = [];

    // Center cell (ring 0).
    final centerCell = CircularCell(0, 0)
      ..innerRadius = 0
      ..outerRadius = ringHeight
      ..startAngle = 0
      ..endAngle = 2 * pi;
    _rings.add([centerCell]);

    // Subsequent rings.
    var previousCount = 1;
    for (var ring = 1; ring < rows; ring++) {
      final innerR = ring * ringHeight;
      final outerR = (ring + 1) * ringHeight;

      // Determine cell count: double when cells get too wide.
      final circumference = 2 * pi * innerR;
      final estimatedWidth = circumference / previousCount;
      final ratio = (estimatedWidth / ringHeight).round();
      final cellCount = previousCount * (ratio > 1 ? ratio : 1);

      final ringCells = <CircularCell>[];
      final angleStep = 2 * pi / cellCount;

      for (var i = 0; i < cellCount; i++) {
        final cell = CircularCell(ring, i)
          ..innerRadius = innerR
          ..outerRadius = outerR
          ..startAngle = i * angleStep
          ..endAngle = (i + 1) * angleStep;
        ringCells.add(cell);
      }

      _rings.add(ringCells);
      previousCount = cellCount;
    }
  }

  void _configureNeighbors() {
    for (var ring = 1; ring < _rings.length; ring++) {
      final currentRing = _rings[ring];
      final innerRing = _rings[ring - 1];

      for (var i = 0; i < currentRing.length; i++) {
        final cell = currentRing[i];

        // Clockwise / counterclockwise neighbors in same ring.
        cell.clockwise = currentRing[(i + 1) % currentRing.length];
        cell.counterClockwise =
            currentRing[(i - 1 + currentRing.length) % currentRing.length];

        // Inward neighbor: map this cell's angular position to the inner ring.
        final ratio = innerRing.length / currentRing.length;
        final innerIndex = (i * ratio).floor() % innerRing.length;
        cell.inward = innerRing[innerIndex];

        // Register as outward neighbor on the inner cell.
        innerRing[innerIndex].outward.add(cell);
      }
    }
  }

  @override
  Cell? cellAt(int row, int col) {
    if (row < 0 || row >= _rings.length) return null;
    final ring = _rings[row];
    if (col < 0 || col >= ring.length) return null;
    return ring[col];
  }

  @override
  Iterable<Cell> get cells => _rings.expand((ring) => ring);

  @override
  Iterable<List<Cell?>> get rowsIterable =>
      _rings.map((ring) => ring.cast<Cell?>());
}
