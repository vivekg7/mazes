import 'shape.dart';

/// A shape defined by a closed polygon outline.
///
/// Uses the ray-casting algorithm for point-in-polygon testing. This is the
/// foundation for all complex shapes: animal silhouettes, letters, country
/// outlines, abstract shapes, etc.
class PolygonShape extends Shape {
  /// Creates a polygon shape from a list of vertices.
  ///
  /// Vertices should be in order (clockwise or counterclockwise). The polygon
  /// is automatically closed (last vertex connects to first).
  ///
  /// The shape is scaled to fit within [width] x [height] grid units.
  PolygonShape({
    required List<({double x, double y})> vertices,
    required this.width,
    required this.height,
  }) : _vertices = _normalize(vertices, width, height);

  /// Creates a polygon with pre-normalized vertices (no scaling applied).
  PolygonShape.raw({
    required List<({double x, double y})> vertices,
    required this.width,
    required this.height,
  }) : _vertices = vertices;

  final List<({double x, double y})> _vertices;

  @override
  final double width;

  @override
  final double height;

  /// Normalizes vertices to fit within the target width/height.
  static List<({double x, double y})> _normalize(
    List<({double x, double y})> vertices,
    double targetWidth,
    double targetHeight,
  ) {
    if (vertices.isEmpty) return vertices;

    var minX = vertices[0].x;
    var maxX = vertices[0].x;
    var minY = vertices[0].y;
    var maxY = vertices[0].y;

    for (final v in vertices) {
      if (v.x < minX) minX = v.x;
      if (v.x > maxX) maxX = v.x;
      if (v.y < minY) minY = v.y;
      if (v.y > maxY) maxY = v.y;
    }

    final srcWidth = maxX - minX;
    final srcHeight = maxY - minY;
    if (srcWidth == 0 || srcHeight == 0) return vertices;

    final scaleX = targetWidth / srcWidth;
    final scaleY = targetHeight / srcHeight;

    return vertices
        .map((v) => (x: (v.x - minX) * scaleX, y: (v.y - minY) * scaleY))
        .toList();
  }

  @override
  bool contains(double x, double y) {
    // Ray-casting algorithm.
    var inside = false;
    final n = _vertices.length;

    for (var i = 0, j = n - 1; i < n; j = i++) {
      final xi = _vertices[i].x;
      final yi = _vertices[i].y;
      final xj = _vertices[j].x;
      final yj = _vertices[j].y;

      if (((yi > y) != (yj > y)) &&
          (x < (xj - xi) * (y - yi) / (yj - yi) + xi)) {
        inside = !inside;
      }
    }

    return inside;
  }
}

/// A shape composed of multiple polygons (e.g., letters with holes like 'O',
/// 'A', 'B', or countries with islands).
class CompoundShape extends Shape {
  /// Creates a compound shape from an outer boundary and optional holes.
  ///
  /// A point is inside if it's inside [outer] and not inside any [holes].
  const CompoundShape({
    required this.outer,
    this.holes = const [],
  });

  final PolygonShape outer;
  final List<PolygonShape> holes;

  @override
  double get width => outer.width;

  @override
  double get height => outer.height;

  @override
  bool contains(double x, double y) {
    if (!outer.contains(x, y)) return false;
    for (final hole in holes) {
      if (hole.contains(x, y)) return false;
    }
    return true;
  }
}
