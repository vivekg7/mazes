import 'shape.dart';

/// A circular disc shape centered in the bounding box.
class CircleShape extends Shape {
  /// Creates a circle with the given [radius].
  ///
  /// The bounding box is a square of side `2 * radius`, centered at
  /// ([radius], [radius]).
  const CircleShape(this.radius);

  final double radius;

  double get centerX => radius;
  double get centerY => radius;

  @override
  double get width => radius * 2;

  @override
  double get height => radius * 2;

  @override
  bool contains(double x, double y) {
    final dx = x - centerX;
    final dy = y - centerY;
    return dx * dx + dy * dy <= radius * radius;
  }
}
