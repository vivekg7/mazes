import 'dart:convert';

import '../models/enums.dart';
import 'circle_shape.dart';
import 'polygon_shape.dart';
import 'rectangle_shape.dart';
import 'shape.dart';

/// Registry of all predefined shapes.
///
/// Shapes are organized by [PuzzleShape] category. Each category contains
/// named variants (e.g., "cat" under [PuzzleShape.animal]).
class ShapeLibrary {
  ShapeLibrary._();

  static final ShapeLibrary instance = ShapeLibrary._();

  final Map<PuzzleShape, Map<String, Shape Function(double w, double h)>>
      _registry = {};

  /// Registers a shape factory under [category] with the given [name].
  void register(
    PuzzleShape category,
    String name,
    Shape Function(double width, double height) factory,
  ) {
    _registry.putIfAbsent(category, () => {})[name] = factory;
  }

  /// Returns the shape for [category] and [variant], scaled to [width] x
  /// [height] grid units.
  ///
  /// For [PuzzleShape.rectangle] and [PuzzleShape.circle], [variant] is
  /// ignored and can be null.
  Shape getShape(
    PuzzleShape category, {
    String? variant,
    required double width,
    required double height,
  }) {
    switch (category) {
      case PuzzleShape.rectangle:
        return RectangleShape(width, height);
      case PuzzleShape.circle:
        return CircleShape(width < height ? width / 2 : height / 2);
      default:
        final variants = _registry[category];
        if (variants == null || variants.isEmpty) {
          // Fallback to rectangle if no shapes registered.
          return RectangleShape(width, height);
        }
        final name = variant ?? variants.keys.first;
        final factory = variants[name] ?? variants.values.first;
        return factory(width, height);
    }
  }

  /// Lists all available variant names for a [category].
  List<String> variants(PuzzleShape category) {
    return _registry[category]?.keys.toList() ?? [];
  }

  /// Registers a polygon shape from raw vertex data.
  void registerPolygon(
    PuzzleShape category,
    String name,
    List<({double x, double y})> vertices,
  ) {
    register(category, name, (w, h) {
      return PolygonShape(vertices: vertices, width: w, height: h);
    });
  }

  /// Registers a compound shape (polygon with holes) from raw data.
  void registerCompound(
    PuzzleShape category,
    String name, {
    required List<({double x, double y})> outer,
    List<List<({double x, double y})>> holes = const [],
  }) {
    register(category, name, (w, h) {
      // Normalize all polygons using the outer polygon's bounding box.
      final allPoints = outer;
      var minX = allPoints[0].x;
      var maxX = allPoints[0].x;
      var minY = allPoints[0].y;
      var maxY = allPoints[0].y;
      for (final p in allPoints) {
        if (p.x < minX) minX = p.x;
        if (p.x > maxX) maxX = p.x;
        if (p.y < minY) minY = p.y;
        if (p.y > maxY) maxY = p.y;
      }
      final srcW = maxX - minX;
      final srcH = maxY - minY;
      if (srcW == 0 || srcH == 0) {
        return PolygonShape(vertices: outer, width: w, height: h);
      }
      final scaleX = w / srcW;
      final scaleY = h / srcH;
      List<({double x, double y})> norm(List<({double x, double y})> pts) =>
          pts.map((p) => (x: (p.x - minX) * scaleX, y: (p.y - minY) * scaleY)).toList();

      return CompoundShape(
        outer: PolygonShape.raw(vertices: norm(outer), width: w, height: h),
        holes: holes
            .map((hv) => PolygonShape.raw(vertices: norm(hv), width: w, height: h))
            .toList(),
      );
    });
  }

  /// Loads shapes from a JSON string.
  ///
  /// Expected format:
  /// ```json
  /// {
  ///   "category": "animal",
  ///   "shapes": {
  ///     "cat": {
  ///       "outer": [[x, y], [x, y], ...],
  ///       "holes": [[[x, y], ...], ...]  // optional
  ///     }
  ///   }
  /// }
  /// ```
  void loadFromJson(String jsonString) {
    final data = jsonDecode(jsonString) as Map<String, dynamic>;
    final categoryName = data['category'] as String;
    final category = _parsePuzzleShape(categoryName);
    final shapes = data['shapes'] as Map<String, dynamic>;

    for (final entry in shapes.entries) {
      final shapeData = entry.value as Map<String, dynamic>;
      final outerPoints = _parsePoints(shapeData['outer'] as List);

      if (shapeData.containsKey('holes')) {
        final holes = (shapeData['holes'] as List)
            .map((h) => _parsePoints(h as List))
            .toList();
        registerCompound(category, entry.key, outer: outerPoints, holes: holes);
      } else {
        registerPolygon(category, entry.key, outerPoints);
      }
    }
  }

  static List<({double x, double y})> _parsePoints(List<dynamic> points) {
    return points
        .map((p) => (
              x: (p[0] as num).toDouble(),
              y: (p[1] as num).toDouble(),
            ))
        .toList();
  }

  static PuzzleShape _parsePuzzleShape(String name) {
    return switch (name) {
      'animal' => PuzzleShape.animal,
      'letter' => PuzzleShape.letter,
      'number' => PuzzleShape.number,
      'abstract' => PuzzleShape.abstract_,
      'country' => PuzzleShape.country,
      _ => PuzzleShape.rectangle,
    };
  }
}
