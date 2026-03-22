import 'dart:math';

import '../models/cell.dart';
import '../models/grid.dart';

/// A cell in a Voronoi grid, defined by a seed point.
///
/// The cell's region is the set of all points closer to its seed than to any
/// other seed. Neighbors are cells whose Voronoi regions share an edge
/// (Delaunay neighbors).
class VoronoiCell extends Cell {
  VoronoiCell(super.row, super.column, {required this.seedX, required this.seedY});

  /// The seed point that defines this cell's region.
  final double seedX;
  final double seedY;

  final List<Cell> _neighbors = [];
  List<({double x, double y})> _vertices = [];

  @override
  List<Cell> get neighbors => _neighbors;

  @override
  List<({double x, double y})> get vertices => _vertices;

  @override
  ({double x, double y}) get center => (x: seedX, y: seedY);
}

/// A grid of irregular [VoronoiCell]s from random seed points.
///
/// Uses Delaunay triangulation (Bowyer-Watson) to determine neighbor
/// relationships. [rows] and [columns] define the bounding rectangle.
/// The number of cells is controlled by [cellCount].
class VoronoiGrid extends Grid {
  /// Creates a Voronoi grid within a [rows] x [columns] bounding box.
  ///
  /// [cellCount] seed points are randomly distributed. Pass [seed] for
  /// reproducible layouts.
  VoronoiGrid(
    super.rows,
    super.columns, {
    required int cellCount,
    int? seed,
  }) {
    final rng = Random(seed);
    _generateCells(cellCount, rng);
  }

  late final List<VoronoiCell> _cells;

  void _generateCells(int cellCount, Random rng) {
    // Generate random seed points.
    _cells = List.generate(cellCount, (i) {
      return VoronoiCell(
        0,
        i,
        seedX: rng.nextDouble() * columns,
        seedY: rng.nextDouble() * rows,
      );
    });

    // Build a map from seed index to cell for neighbor lookup.
    final seeds = _cells
        .map((c) => (x: c.seedX, y: c.seedY))
        .toList();

    // Run Delaunay triangulation to find neighbor pairs.
    final triangles = _bowyerWatson(seeds, columns.toDouble(), rows.toDouble());

    // Extract neighbor relationships from triangle edges.
    final neighborSet = <int>{};
    for (final tri in triangles) {
      void addEdge(int a, int b) {
        if (a < cellCount && b < cellCount) {
          final key = a < b ? a * cellCount + b : b * cellCount + a;
          if (neighborSet.add(key)) {
            _cells[a]._neighbors.add(_cells[b]);
            _cells[b]._neighbors.add(_cells[a]);
          }
        }
      }

      addEdge(tri.a, tri.b);
      addEdge(tri.b, tri.c);
      addEdge(tri.a, tri.c);
    }

    // Compute Voronoi vertices for each cell from circumcenters.
    _computeVoronoiVertices(triangles, cellCount);
  }

  void _computeVoronoiVertices(
    List<_Triangle> triangles,
    int cellCount,
  ) {
    // Map each seed index to the circumcenters of its triangles.
    final cellCircumcenters = <int, List<({double x, double y, double angle})>>{};

    for (final tri in triangles) {
      final cc = tri.circumcenter;
      if (cc == null) continue;

      for (final idx in [tri.a, tri.b, tri.c]) {
        if (idx >= cellCount) continue;
        final cell = _cells[idx];
        final angle = atan2(cc.y - cell.seedY, cc.x - cell.seedX);
        cellCircumcenters.putIfAbsent(idx, () => []).add(
          (x: cc.x, y: cc.y, angle: angle),
        );
      }
    }

    // Sort circumcenters by angle around each seed to form the polygon.
    for (var i = 0; i < cellCount; i++) {
      final points = cellCircumcenters[i];
      if (points == null || points.isEmpty) continue;
      points.sort((a, b) => a.angle.compareTo(b.angle));
      _cells[i]._vertices =
          points.map((p) => (x: p.x, y: p.y)).toList();
    }
  }

  @override
  Cell? cellAt(int row, int col) {
    if (col < 0 || col >= _cells.length) return null;
    return _cells[col];
  }

  @override
  Iterable<Cell> get cells => _cells;

  @override
  Iterable<List<Cell?>> get rowsIterable => [_cells.cast<Cell?>()];
}

// ---------------------------------------------------------------------------
// Bowyer-Watson Delaunay triangulation
// ---------------------------------------------------------------------------

class _Triangle {
  _Triangle(this.a, this.b, this.c, this.points);

  final int a, b, c;
  final List<({double x, double y})> points;

  ({double x, double y})? get circumcenter {
    final ax = points[a].x;
    final ay = points[a].y;
    final bx = points[b].x;
    final by = points[b].y;
    final cx = points[c].x;
    final cy = points[c].y;

    final d = 2 * (ax * (by - cy) + bx * (cy - ay) + cx * (ay - by));
    if (d.abs() < 1e-10) return null;

    final ux =
        ((ax * ax + ay * ay) * (by - cy) +
            (bx * bx + by * by) * (cy - ay) +
            (cx * cx + cy * cy) * (ay - by)) /
        d;
    final uy =
        ((ax * ax + ay * ay) * (cx - bx) +
            (bx * bx + by * by) * (ax - cx) +
            (cx * cx + cy * cy) * (bx - ax)) /
        d;

    return (x: ux, y: uy);
  }

  double get circumradiusSq {
    final cc = circumcenter;
    if (cc == null) return double.infinity;
    final dx = points[a].x - cc.x;
    final dy = points[a].y - cc.y;
    return dx * dx + dy * dy;
  }

  bool circumcircleContains(({double x, double y}) p) {
    final cc = circumcenter;
    if (cc == null) return false;
    final dx = p.x - cc.x;
    final dy = p.y - cc.y;
    return dx * dx + dy * dy <= circumradiusSq + 1e-10;
  }

  bool hasVertex(int idx) => a == idx || b == idx || c == idx;
}

class _Edge {
  _Edge(this.a, this.b);

  final int a, b;

  @override
  bool operator ==(Object other) =>
      other is _Edge &&
      ((a == other.a && b == other.b) || (a == other.b && b == other.a));

  @override
  int get hashCode => a < b ? Object.hash(a, b) : Object.hash(b, a);
}

List<_Triangle> _bowyerWatson(
  List<({double x, double y})> seeds,
  double width,
  double height,
) {
  // Create a super-triangle that contains all points.
  final margin = max(width, height) * 10;
  final allPoints = [
    ...seeds,
    (x: -margin, y: -margin),          // super-triangle vertex 0
    (x: width + margin * 2, y: -margin), // super-triangle vertex 1
    (x: width / 2, y: height + margin * 2), // super-triangle vertex 2
  ];

  final st0 = seeds.length;
  final st1 = seeds.length + 1;
  final st2 = seeds.length + 2;

  var triangulation = [_Triangle(st0, st1, st2, allPoints)];

  // Insert each seed point.
  for (var i = 0; i < seeds.length; i++) {
    final point = allPoints[i];

    // Find bad triangles (whose circumcircle contains the point).
    final badTriangles =
        triangulation.where((t) => t.circumcircleContains(point)).toList();

    // Find the boundary polygon (edges not shared by two bad triangles).
    final edgeCount = <_Edge, int>{};
    for (final tri in badTriangles) {
      for (final edge in [
        _Edge(tri.a, tri.b),
        _Edge(tri.b, tri.c),
        _Edge(tri.a, tri.c),
      ]) {
        edgeCount[edge] = (edgeCount[edge] ?? 0) + 1;
      }
    }
    final boundary =
        edgeCount.entries.where((e) => e.value == 1).map((e) => e.key);

    // Remove bad triangles and create new ones from boundary edges.
    triangulation.removeWhere(badTriangles.contains);
    for (final edge in boundary) {
      triangulation.add(_Triangle(edge.a, edge.b, i, allPoints));
    }
  }

  // Remove triangles that share a vertex with the super-triangle.
  triangulation.removeWhere(
    (t) => t.hasVertex(st0) || t.hasVertex(st1) || t.hasVertex(st2),
  );

  return triangulation;
}
