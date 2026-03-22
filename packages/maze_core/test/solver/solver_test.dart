import 'dart:math';

import 'package:maze_core/maze_core.dart';
import 'package:test/test.dart';

void main() {
  group('solveMaze', () {
    test('finds shortest path in simple grid', () {
      final grid = SquareGrid(3, 3);
      const RecursiveBacktracker().generate(grid, Random(42));

      final start = grid.cellAt(0, 0)!;
      final end = grid.cellAt(2, 2)!;
      final path = solveMaze(start, end);

      expect(path.isNotEmpty, isTrue);
      expect(path.start, equals(start));
      expect(path.end, equals(end));
      expect(path.isValid, isTrue);
    });

    test('returns path of length 1 when start == end', () {
      final grid = SquareGrid(3, 3);
      final cell = grid.cellAt(1, 1)!;
      final path = solveMaze(cell, cell);

      expect(path.length, equals(1));
      expect(path.steps, equals(0));
    });

    test('path is shortest possible', () {
      // Create a known simple maze: straight corridor.
      final grid = SquareGrid(1, 5);
      const RecursiveBacktracker().generate(grid, Random(42));

      final start = grid.cellAt(0, 0)!;
      final end = grid.cellAt(0, 4)!;
      final path = solveMaze(start, end);

      // In a 1-row maze, shortest path must be exactly 4 steps.
      expect(path.steps, equals(4));
    });

    test('works on hex grid', () {
      final grid = HexGrid(5, 5);
      const RecursiveBacktracker().generate(grid, Random(42));

      final start = grid.cellAt(0, 0)!;
      final end = grid.cellAt(4, 4)!;
      final path = solveMaze(start, end);

      expect(path.isNotEmpty, isTrue);
      expect(path.isValid, isTrue);
    });
  });

  group('distances', () {
    test('distance from cell to itself is 0', () {
      final grid = SquareGrid(3, 3);
      const RecursiveBacktracker().generate(grid, Random(42));

      final start = grid.cellAt(0, 0)!;
      final dist = distances(start);

      expect(dist[start], equals(0));
    });

    test('distances cover all reachable cells', () {
      final grid = SquareGrid(5, 5);
      const RecursiveBacktracker().generate(grid, Random(42));

      final start = grid.cellAt(0, 0)!;
      final dist = distances(start);

      expect(dist.length, equals(grid.size));
    });
  });

  group('longestPath', () {
    test('finds diameter of maze', () {
      final grid = SquareGrid(5, 5);
      const RecursiveBacktracker().generate(grid, Random(42));

      final result = longestPath(grid.cellAt(0, 0)!);
      expect(result.path.isNotEmpty, isTrue);
      expect(result.path.isValid, isTrue);
      expect(result.path.steps, greaterThan(0));
    });
  });

  group('analyzeMaze', () {
    test('produces valid analysis for square maze', () {
      final grid = SquareGrid(8, 8);
      const RecursiveBacktracker().generate(grid, Random(42));

      final analysis = analyzeMaze(
        grid,
        grid.cellAt(0, 0)!,
        grid.cellAt(7, 7)!,
      );

      expect(analysis.totalCells, equals(64));
      expect(analysis.deadEndCount, greaterThan(0));
      expect(analysis.solutionLength, greaterThan(0));
      expect(analysis.longestPathLength, greaterThanOrEqualTo(analysis.solutionLength));
      expect(analysis.averageBranchingFactor, greaterThan(0));
      expect(analysis.solutionRatio, greaterThan(0));
      expect(analysis.deadEndRatio, greaterThan(0));
    });

    test('different algorithms produce different metrics', () {
      final grid1 = SquareGrid(10, 10);
      final grid2 = SquareGrid(10, 10);
      const RecursiveBacktracker().generate(grid1, Random(42));
      const BinaryTree().generate(grid2, Random(42));

      final a1 = analyzeMaze(grid1, grid1.cellAt(0, 0)!, grid1.cellAt(9, 9)!);
      final a2 = analyzeMaze(grid2, grid2.cellAt(0, 0)!, grid2.cellAt(9, 9)!);

      // Binary tree typically has more dead ends than backtracker.
      expect(a1.deadEndCount != a2.deadEndCount, isTrue);
    });
  });
}
