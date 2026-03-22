import 'package:maze_core/maze_core.dart';
import 'package:test/test.dart';

void main() {
  group('ConcentricGrid', () {
    test('creates rows x columns cells', () {
      final grid = ConcentricGrid(4, 8);
      expect(grid.size, equals(32));
    });

    test('all cells have clockwise and counterclockwise', () {
      final grid = ConcentricGrid(3, 6);
      for (final cell in grid.cells) {
        final c = cell as ConcentricCell;
        expect(c.clockwise, isNotNull);
        expect(c.counterClockwise, isNotNull);
      }
    });

    test('inner ring has no inward neighbor', () {
      final grid = ConcentricGrid(3, 6);
      final cell = grid.cellAt(0, 0)! as ConcentricCell;
      expect(cell.inward, isNull);
    });

    test('outer ring has no outward neighbor', () {
      final grid = ConcentricGrid(3, 6);
      final cell = grid.cellAt(2, 0)! as ConcentricCell;
      expect(cell.outward, isNull);
    });

    test('middle ring has both inward and outward', () {
      final grid = ConcentricGrid(3, 6);
      final cell = grid.cellAt(1, 0)! as ConcentricCell;
      expect(cell.inward, isNotNull);
      expect(cell.outward, isNotNull);
    });

    test('neighbor relationships are bidirectional', () {
      final grid = ConcentricGrid(3, 6);
      for (final cell in grid.cells) {
        for (final neighbor in cell.neighbors) {
          expect(
            neighbor.neighbors.contains(cell),
            isTrue,
            reason: '$cell should be in neighbors of $neighbor',
          );
        }
      }
    });

    test('cellAt returns null out of bounds', () {
      final grid = ConcentricGrid(3, 6);
      expect(grid.cellAt(-1, 0), isNull);
      expect(grid.cellAt(3, 0), isNull);
      expect(grid.cellAt(0, 6), isNull);
    });

    test('vertices are non-empty', () {
      final grid = ConcentricGrid(3, 6);
      for (final cell in grid.cells) {
        expect(cell.vertices, isNotEmpty);
      }
    });
  });
}
