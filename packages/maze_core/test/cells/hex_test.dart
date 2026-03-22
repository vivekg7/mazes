import 'package:maze_core/maze_core.dart';
import 'package:test/test.dart';

void main() {
  group('HexGrid', () {
    test('creates correct number of cells', () {
      final grid = HexGrid(4, 4);
      expect(grid.size, equals(16));
    });

    test('interior cell has 6 neighbors', () {
      final grid = HexGrid(5, 5);
      final cell = grid.cellAt(2, 2)!;
      expect(cell.neighbors, hasLength(6));
    });

    test('corner cell has fewer neighbors', () {
      final grid = HexGrid(4, 4);
      final corner = grid.cellAt(0, 0)!;
      // Top-left corner of hex grid: has south, southeast, northeast (if even col)
      expect(corner.neighbors.length, lessThan(6));
    });

    test('cellAt returns null out of bounds', () {
      final grid = HexGrid(3, 3);
      expect(grid.cellAt(-1, 0), isNull);
      expect(grid.cellAt(0, 3), isNull);
    });

    test('neighbor relationships are bidirectional', () {
      final grid = HexGrid(4, 4);
      final cell = grid.cellAt(2, 2)!;
      for (final neighbor in cell.neighbors) {
        expect(
          neighbor.neighbors.contains(cell),
          isTrue,
          reason: 'Neighbor $neighbor should list $cell as a neighbor',
        );
      }
    });

    test('masking excludes cells', () {
      final grid = HexGrid(3, 3, mask: (r, c) => r != 1 || c != 1);
      expect(grid.size, equals(8));
      expect(grid.cellAt(1, 1), isNull);
    });

    test('vertices returns 6 points', () {
      final grid = HexGrid(2, 2);
      final cell = grid.cellAt(0, 0)!;
      expect(cell.vertices, hasLength(6));
    });
  });
}
