import 'package:maze_core/maze_core.dart';
import 'package:test/test.dart';

void main() {
  group('SquareGrid', () {
    test('creates correct number of cells', () {
      final grid = SquareGrid(5, 5);
      expect(grid.size, equals(25));
    });

    test('cellAt returns correct cell', () {
      final grid = SquareGrid(3, 3);
      final cell = grid.cellAt(1, 2);
      expect(cell, isNotNull);
      expect(cell!.row, equals(1));
      expect(cell.column, equals(2));
    });

    test('cellAt returns null for out of bounds', () {
      final grid = SquareGrid(3, 3);
      expect(grid.cellAt(-1, 0), isNull);
      expect(grid.cellAt(0, -1), isNull);
      expect(grid.cellAt(3, 0), isNull);
      expect(grid.cellAt(0, 3), isNull);
    });

    test('corner cell has 2 neighbors', () {
      final grid = SquareGrid(3, 3);
      final corner = grid.cellAt(0, 0)!;
      expect(corner.neighbors, hasLength(2));
    });

    test('edge cell has 3 neighbors', () {
      final grid = SquareGrid(3, 3);
      final edge = grid.cellAt(0, 1)!;
      expect(edge.neighbors, hasLength(3));
    });

    test('interior cell has 4 neighbors', () {
      final grid = SquareGrid(3, 3);
      final interior = grid.cellAt(1, 1)!;
      expect(interior.neighbors, hasLength(4));
    });

    test('neighbor directions are correct', () {
      final grid = SquareGrid(3, 3);
      final cell = grid.cellAt(1, 1)! as SquareCell;
      expect(cell.north, equals(grid.cellAt(0, 1)));
      expect(cell.south, equals(grid.cellAt(2, 1)));
      expect(cell.east, equals(grid.cellAt(1, 2)));
      expect(cell.west, equals(grid.cellAt(1, 0)));
    });

    test('masking excludes cells', () {
      final grid = SquareGrid(3, 3, mask: (r, c) => !(r == 1 && c == 1));
      expect(grid.size, equals(8));
      expect(grid.cellAt(1, 1), isNull);
    });

    test('masked cell not in neighbors', () {
      final grid = SquareGrid(3, 3, mask: (r, c) => !(r == 1 && c == 1));
      final above = grid.cellAt(0, 1)! as SquareCell;
      expect(above.south, isNull);
    });

    test('rowsIterable returns all rows', () {
      final grid = SquareGrid(3, 4);
      final allRows = grid.rowsIterable.toList();
      expect(allRows, hasLength(3));
      expect(allRows[0], hasLength(4));
    });

    test('vertices form unit square', () {
      final grid = SquareGrid(2, 2);
      final cell = grid.cellAt(0, 0)!;
      expect(cell.vertices, hasLength(4));
    });

    test('randomCell returns a valid cell', () {
      final grid = SquareGrid(5, 5);
      final cell = grid.randomCell();
      expect(grid.cells.contains(cell), isTrue);
    });
  });
}
