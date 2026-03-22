import 'shape.dart';

/// A rectangular shape — the full grid with no masking.
class RectangleShape extends Shape {
  const RectangleShape(this.width, this.height);

  @override
  final double width;

  @override
  final double height;

  @override
  bool contains(double x, double y) =>
      x >= 0 && x <= width && y >= 0 && y <= height;
}
