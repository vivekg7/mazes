import 'dart:math';

import 'package:maze_core/maze_core.dart';
import 'package:test/test.dart';

/// Verifies that all cells in [grid] are reachable from the first cell
/// (i.e., the maze is a connected spanning tree).
bool isFullyConnected(Grid grid) {
  final allCells = grid.cells.toList();
  if (allCells.isEmpty) return true;

  final visited = <Cell>{};
  final stack = <Cell>[allCells.first];

  while (stack.isNotEmpty) {
    final cell = stack.removeLast();
    if (visited.contains(cell)) continue;
    visited.add(cell);
    stack.addAll(cell.links.where((c) => !visited.contains(c)));
  }

  return visited.length == allCells.length;
}

/// Verifies that the maze is a perfect maze (spanning tree):
/// connected and has exactly (cellCount - 1) passages.
bool isPerfectMaze(Grid grid) {
  if (!isFullyConnected(grid)) return false;

  // Count total links (each passage counted once).
  var linkCount = 0;
  for (final cell in grid.cells) {
    linkCount += cell.links.length;
  }
  // Each link is bidirectional, so divide by 2.
  return linkCount ~/ 2 == grid.size - 1;
}

void main() {
  const generators = <String, MazeGenerator>{
    'RecursiveBacktracker': RecursiveBacktracker(),
    'Kruskals': Kruskals(),
    'Prims': Prims(),
    'Ellers': Ellers(),
    'Wilsons': Wilsons(),
    'AldousBroder': AldousBroder(),
    'GrowingTree(newest)': GrowingTree(strategy: GrowingTreeStrategy.newest),
    'GrowingTree(random)': GrowingTree(strategy: GrowingTreeStrategy.random),
    'GrowingTree(mixed)': GrowingTree(strategy: GrowingTreeStrategy.mixed),
    'HuntAndKill': HuntAndKill(),
    'Sidewinder': Sidewinder(),
    'BinaryTree': BinaryTree(),
    'RecursiveDivision': RecursiveDivision(),
  };

  // Row-based algorithms that depend on rectangular row/column structure.
  // They work on SquareGrid and HexGrid but may not produce connected mazes
  // on TriangleGrid or masked grids.
  const rowBasedAlgorithms = {
    'Ellers',
    'Sidewinder',
    'BinaryTree',
    'RecursiveDivision',
  };

  for (final entry in generators.entries) {
    final name = entry.key;
    final generator = entry.value;
    final isRowBased = rowBasedAlgorithms.contains(name);

    group(name, () {
      test('produces perfect maze on SquareGrid', () {
        final grid = SquareGrid(8, 8);
        generator.generate(grid, Random(42));
        expect(isPerfectMaze(grid), isTrue,
            reason: '$name should produce a perfect maze on SquareGrid');
      });

      test('produces connected maze on HexGrid', () {
        final grid = HexGrid(6, 6);
        generator.generate(grid, Random(42));
        expect(isFullyConnected(grid), isTrue,
            reason: '$name should produce a connected maze on HexGrid');
      });

      if (!isRowBased) {
        test('produces connected maze on TriangleGrid', () {
          final grid = TriangleGrid(5, 10);
          generator.generate(grid, Random(42));
          expect(isFullyConnected(grid), isTrue,
              reason: '$name should produce a connected maze on TriangleGrid');
        });
      }

      test('deterministic with same seed on SquareGrid', () {
        final grid1 = SquareGrid(6, 6);
        final grid2 = SquareGrid(6, 6);
        generator.generate(grid1, Random(123));
        generator.generate(grid2, Random(123));

        final cells1 = grid1.cells.toList();
        final cells2 = grid2.cells.toList();
        for (var i = 0; i < cells1.length; i++) {
          expect(
            cells1[i].links.map((c) => '${c.row},${c.column}').toSet(),
            equals(cells2[i].links.map((c) => '${c.row},${c.column}').toSet()),
            reason: '$name should be deterministic with same seed',
          );
        }
      });

      test('works on small 2x2 grid', () {
        final grid = SquareGrid(2, 2);
        generator.generate(grid, Random(42));
        expect(isFullyConnected(grid), isTrue);
      });

      if (!isRowBased) {
        test('works on masked grid', () {
          final grid = SquareGrid(5, 5, mask: (r, c) => !(r == 2 && c == 2));
          generator.generate(grid, Random(42));
          expect(isFullyConnected(grid), isTrue,
              reason: '$name should handle masked grids');
        });
      }
    });
  }

  group('Generator-specific properties', () {
    test('RecursiveDivision starts fully linked then adds walls', () {
      final grid = SquareGrid(5, 5);
      const RecursiveDivision().generate(grid, Random(42));
      // Should still be a perfect maze.
      expect(isPerfectMaze(grid), isTrue);
    });

    test('GrowingTree strategies produce different mazes', () {
      final grid1 = SquareGrid(8, 8);
      final grid2 = SquareGrid(8, 8);
      const GrowingTree(strategy: GrowingTreeStrategy.newest)
          .generate(grid1, Random(42));
      const GrowingTree(strategy: GrowingTreeStrategy.random)
          .generate(grid2, Random(42));

      // Different strategies should usually produce different dead-end counts.
      // This is probabilistic, but with these settings should be reliable.
      final de1 = grid1.deadEndCount;
      final de2 = grid2.deadEndCount;
      expect(de1 != de2, isTrue,
          reason: 'Different strategies should produce different mazes');
    });
  });
}
