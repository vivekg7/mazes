import 'package:maze_core/maze_core.dart';
import 'package:test/test.dart';

void main() {
  group('TriangleGrid', () {
    test('creates correct number of cells', () {
      final grid = TriangleGrid(3, 6);
      expect(grid.size, equals(18));
    });

    test('upright triangle determined by row+column parity', () {
      final grid = TriangleGrid(2, 4);
      final cell00 = grid.cellAt(0, 0)! as TriangleCell;
      final cell01 = grid.cellAt(0, 1)! as TriangleCell;
      expect(cell00.isUpright, isTrue); // 0+0 = even
      expect(cell01.isUpright, isFalse); // 0+1 = odd
    });

    test('interior cell has up to 3 neighbors', () {
      final grid = TriangleGrid(4, 8);
      final cell = grid.cellAt(1, 3)! as TriangleCell;
      // Interior cells should have 3 neighbors (left, right, base)
      expect(cell.neighbors, hasLength(3));
    });

    test('edge cell has fewer neighbors', () {
      final grid = TriangleGrid(3, 6);
      final cell = grid.cellAt(0, 0)! as TriangleCell;
      expect(cell.neighbors.length, lessThanOrEqualTo(3));
    });

    test('neighbor relationships are bidirectional', () {
      final grid = TriangleGrid(4, 8);
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

    test('masking excludes cells', () {
      final grid = TriangleGrid(3, 6, mask: (r, c) => r != 0 || c != 0);
      expect(grid.size, equals(17));
      expect(grid.cellAt(0, 0), isNull);
    });

    test('vertices returns 3 points', () {
      final grid = TriangleGrid(2, 4);
      final cell = grid.cellAt(0, 0)!;
      expect(cell.vertices, hasLength(3));
    });
  });
}
