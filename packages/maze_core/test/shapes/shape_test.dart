import 'package:maze_core/maze_core.dart';
import 'package:test/test.dart';

void main() {
  group('RectangleShape', () {
    test('contains points inside', () {
      const shape = RectangleShape(10, 10);
      expect(shape.contains(5, 5), isTrue);
      expect(shape.contains(0, 0), isTrue);
      expect(shape.contains(10, 10), isTrue);
    });

    test('rejects points outside', () {
      const shape = RectangleShape(10, 10);
      expect(shape.contains(-1, 5), isFalse);
      expect(shape.contains(5, -1), isFalse);
      expect(shape.contains(11, 5), isFalse);
      expect(shape.contains(5, 11), isFalse);
    });

    test('containsCell tests cell center', () {
      const shape = RectangleShape(5, 5);
      expect(shape.containsCell(0, 0), isTrue);
      expect(shape.containsCell(4, 4), isTrue);
      expect(shape.containsCell(5, 5), isFalse);
    });
  });

  group('CircleShape', () {
    test('contains center', () {
      const shape = CircleShape(5);
      expect(shape.contains(5, 5), isTrue);
    });

    test('contains points inside radius', () {
      const shape = CircleShape(5);
      expect(shape.contains(5, 3), isTrue);
      expect(shape.contains(3, 5), isTrue);
    });

    test('rejects points outside radius', () {
      const shape = CircleShape(5);
      expect(shape.contains(0, 0), isFalse);
      expect(shape.contains(10, 10), isFalse);
    });

    test('dimensions are 2*radius', () {
      const shape = CircleShape(5);
      expect(shape.width, equals(10));
      expect(shape.height, equals(10));
    });
  });

  group('PolygonShape', () {
    test('triangle contains interior point', () {
      final shape = PolygonShape(
        vertices: [(x: 0.0, y: 0.0), (x: 100.0, y: 0.0), (x: 50.0, y: 100.0)],
        width: 10,
        height: 10,
      );
      expect(shape.contains(5, 5), isTrue);
    });

    test('triangle rejects exterior point', () {
      final shape = PolygonShape(
        vertices: [(x: 0.0, y: 0.0), (x: 100.0, y: 0.0), (x: 50.0, y: 100.0)],
        width: 10,
        height: 10,
      );
      // Far outside the triangle.
      expect(shape.contains(-5, -5), isFalse);
    });

    test('square polygon contains center', () {
      final shape = PolygonShape(
        vertices: [
          (x: 0.0, y: 0.0),
          (x: 100.0, y: 0.0),
          (x: 100.0, y: 100.0),
          (x: 0.0, y: 100.0),
        ],
        width: 10,
        height: 10,
      );
      expect(shape.contains(5, 5), isTrue);
    });
  });

  group('CompoundShape', () {
    test('excludes points inside holes', () {
      // Outer covers full 10x10 area.
      final outer = PolygonShape(
        vertices: [
          (x: 0.0, y: 0.0),
          (x: 10.0, y: 0.0),
          (x: 10.0, y: 10.0),
          (x: 0.0, y: 10.0),
        ],
        width: 10,
        height: 10,
      );
      // Hole covers center 4x4 area (3-7, 3-7) — pre-normalized.
      final hole = PolygonShape.raw(
        vertices: [
          (x: 3.0, y: 3.0),
          (x: 7.0, y: 3.0),
          (x: 7.0, y: 7.0),
          (x: 3.0, y: 7.0),
        ],
        width: 10,
        height: 10,
      );
      final shape = CompoundShape(outer: outer, holes: [hole]);

      expect(shape.contains(1, 1), isTrue); // Inside outer, outside hole.
      expect(shape.contains(5, 5), isFalse); // Inside hole.
    });
  });

  group('ShapeLibrary', () {
    test('rectangle and circle shapes are always available', () {
      final lib = ShapeLibrary.instance;
      final rect = lib.getShape(
        PuzzleShape.rectangle,
        width: 10,
        height: 10,
      );
      expect(rect, isA<RectangleShape>());

      final circle = lib.getShape(
        PuzzleShape.circle,
        width: 10,
        height: 10,
      );
      expect(circle, isA<CircleShape>());
    });

    test('builtin shapes register successfully', () {
      registerBuiltinShapes();
      final lib = ShapeLibrary.instance;

      expect(lib.variants(PuzzleShape.animal), contains('cat'));
      expect(lib.variants(PuzzleShape.animal), contains('dog'));
      expect(lib.variants(PuzzleShape.abstract_), contains('star'));
      expect(lib.variants(PuzzleShape.abstract_), contains('heart'));
      expect(lib.variants(PuzzleShape.letter), contains('A'));
      expect(lib.variants(PuzzleShape.number), contains('0'));
    });

    test('builtin animal shape contains interior points', () {
      registerBuiltinShapes();
      final lib = ShapeLibrary.instance;
      final cat = lib.getShape(
        PuzzleShape.animal,
        variant: 'cat',
        width: 20,
        height: 20,
      );
      // Center of a 20x20 shape should be inside.
      expect(cat.contains(10, 10), isTrue);
    });

    test('loads shapes from JSON', () {
      final lib = ShapeLibrary.instance;
      lib.loadFromJson('''
      {
        "category": "abstract",
        "shapes": {
          "test_triangle": {
            "outer": [[0, 0], [100, 0], [50, 100]]
          }
        }
      }
      ''');
      expect(lib.variants(PuzzleShape.abstract_), contains('test_triangle'));
    });
  });

  group('Shape with SquareGrid masking', () {
    test('circle shape masks corners of square grid', () {
      const shape = CircleShape(5);
      final grid = SquareGrid(
        10,
        10,
        mask: (r, c) => shape.containsCell(r, c),
      );
      // Grid should have fewer than 100 cells (corners masked).
      expect(grid.size, lessThan(100));
      expect(grid.size, greaterThan(50));

      // Corner cells should be masked.
      expect(grid.cellAt(0, 0), isNull);
      expect(grid.cellAt(9, 9), isNull);

      // Center cells should be present.
      expect(grid.cellAt(5, 5), isNotNull);
    });
  });
}
