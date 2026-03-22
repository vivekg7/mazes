import 'package:maze_core/maze_core.dart';
import 'package:test/test.dart';

void main() {
  group('VoronoiGrid', () {
    test('creates correct number of cells', () {
      final grid = VoronoiGrid(10, 10, cellCount: 20, seed: 42);
      expect(grid.size, equals(20));
    });

    test('cells have seed positions within bounds', () {
      final grid = VoronoiGrid(10, 10, cellCount: 30, seed: 42);
      for (final cell in grid.cells) {
        final c = cell as VoronoiCell;
        expect(c.seedX, greaterThanOrEqualTo(0));
        expect(c.seedX, lessThanOrEqualTo(10));
        expect(c.seedY, greaterThanOrEqualTo(0));
        expect(c.seedY, lessThanOrEqualTo(10));
      }
    });

    test('cells have neighbors from Delaunay triangulation', () {
      final grid = VoronoiGrid(10, 10, cellCount: 20, seed: 42);
      // Not all cells are guaranteed neighbors, but most should have some.
      final withNeighbors = grid.cells.where((c) => c.neighbors.isNotEmpty);
      expect(withNeighbors.length, greaterThan(grid.size ~/ 2));
    });

    test('neighbor relationships are bidirectional', () {
      final grid = VoronoiGrid(10, 10, cellCount: 20, seed: 42);
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

    test('deterministic with same seed', () {
      final grid1 = VoronoiGrid(10, 10, cellCount: 15, seed: 123);
      final grid2 = VoronoiGrid(10, 10, cellCount: 15, seed: 123);

      for (var i = 0; i < 15; i++) {
        final c1 = grid1.cellAt(0, i)! as VoronoiCell;
        final c2 = grid2.cellAt(0, i)! as VoronoiCell;
        expect(c1.seedX, equals(c2.seedX));
        expect(c1.seedY, equals(c2.seedY));
      }
    });

    test('different seeds produce different layouts', () {
      final grid1 = VoronoiGrid(10, 10, cellCount: 15, seed: 1);
      final grid2 = VoronoiGrid(10, 10, cellCount: 15, seed: 2);

      final c1 = grid1.cellAt(0, 0)! as VoronoiCell;
      final c2 = grid2.cellAt(0, 0)! as VoronoiCell;
      // Very unlikely to be identical with different seeds.
      expect(c1.seedX != c2.seedX || c1.seedY != c2.seedY, isTrue);
    });

    test('cells have Voronoi vertices', () {
      final grid = VoronoiGrid(10, 10, cellCount: 20, seed: 42);
      final cellsWithVertices =
          grid.cells.where((c) => c.vertices.isNotEmpty);
      expect(cellsWithVertices, isNotEmpty);
    });
  });
}
