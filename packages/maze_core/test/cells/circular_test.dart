import 'package:maze_core/maze_core.dart';
import 'package:test/test.dart';

void main() {
  group('CircularGrid', () {
    test('creates center cell plus rings', () {
      final grid = CircularGrid(3);
      // Ring 0 = 1 center cell, rings 1-2 have subdivided cells.
      expect(grid.size, greaterThanOrEqualTo(3));
    });

    test('center cell exists at row 0, col 0', () {
      final grid = CircularGrid(3);
      final center = grid.cellAt(0, 0)!;
      expect(center.row, equals(0));
      expect(center.column, equals(0));
    });

    test('center cell has outward neighbors', () {
      final grid = CircularGrid(3);
      final center = grid.cellAt(0, 0)! as CircularCell;
      expect(center.outward, isNotEmpty);
    });

    test('ring cells have clockwise and counterclockwise neighbors', () {
      final grid = CircularGrid(3);
      final ring1 = grid.cellAt(1, 0)! as CircularCell;
      expect(ring1.clockwise, isNotNull);
      expect(ring1.counterClockwise, isNotNull);
    });

    test('ring cells have inward neighbor', () {
      final grid = CircularGrid(3);
      final ring1 = grid.cellAt(1, 0)! as CircularCell;
      expect(ring1.inward, isNotNull);
    });

    test('all neighbor relationships are bidirectional', () {
      final grid = CircularGrid(4);
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

    test('vertices are non-empty for all cells', () {
      final grid = CircularGrid(3);
      for (final cell in grid.cells) {
        expect(cell.vertices, isNotEmpty);
      }
    });

    test('ringCellCounts shows subdivision', () {
      final grid = CircularGrid(4);
      final counts = grid.ringCellCounts;
      expect(counts[0], equals(1)); // center
      expect(counts[1], greaterThanOrEqualTo(6)); // first ring
    });
  });
}
