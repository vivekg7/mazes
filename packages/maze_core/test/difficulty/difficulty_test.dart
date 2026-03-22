import 'dart:math';

import 'package:maze_core/maze_core.dart';
import 'package:test/test.dart';

void main() {
  group('DifficultyCalculator', () {
    const calc = DifficultyCalculator();

    test('produces larger grids for harder levels', () {
      final casual =
          calc.configFor(level: DifficultyLevel.casual, cellType: CellType.square);
      final extreme =
          calc.configFor(level: DifficultyLevel.extreme, cellType: CellType.square);

      expect(extreme.rows, greaterThan(casual.rows));
      expect(extreme.columns, greaterThan(casual.columns));
    });

    test('all difficulty levels produce valid configs', () {
      for (final level in DifficultyLevel.values) {
        final config =
            calc.configFor(level: level, cellType: CellType.square);
        expect(config.rows, greaterThan(0));
        expect(config.columns, greaterThan(0));
        expect(config.algorithm, isNotNull);
        expect(config.difficulty, equals(level));
      }
    });

    test('all cell types produce valid configs', () {
      for (final cellType in CellType.values) {
        final config = calc.configFor(
          level: DifficultyLevel.medium,
          cellType: cellType,
        );
        expect(config.rows, greaterThan(0));
        expect(config.columns, greaterThan(0));
        expect(config.cellType, equals(cellType));
      }
    });

    test('respects manual algorithm override', () {
      final config = calc.configFor(
        level: DifficultyLevel.medium,
        cellType: CellType.square,
        algorithm: Algorithm.wilsons,
      );
      expect(config.algorithm, equals(Algorithm.wilsons));
    });

    test('passes seed through', () {
      final config = calc.configFor(
        level: DifficultyLevel.easy,
        cellType: CellType.square,
        seed: 42,
      );
      expect(config.seed, equals(42));
    });

    test('hex grids are slightly smaller than square for same level', () {
      final square =
          calc.configFor(level: DifficultyLevel.hard, cellType: CellType.square);
      final hex =
          calc.configFor(level: DifficultyLevel.hard, cellType: CellType.hexagonal);

      expect(hex.rows, lessThanOrEqualTo(square.rows));
    });
  });

  group('DifficultyScorer', () {
    const scorer = DifficultyScorer();

    test('small simple maze scores as casual/easy', () {
      final grid = SquareGrid(5, 5);
      const BinaryTree().generate(grid, Random(42));
      final analysis = analyzeMaze(grid, grid.cellAt(0, 0)!, grid.cellAt(4, 4)!);
      final level = scorer.score(analysis);

      expect(
        level.index,
        lessThanOrEqualTo(DifficultyLevel.medium.index),
      );
    });

    test('large complex maze scores harder', () {
      final grid = SquareGrid(25, 25);
      const RecursiveBacktracker().generate(grid, Random(42));
      final analysis =
          analyzeMaze(grid, grid.cellAt(0, 0)!, grid.cellAt(24, 24)!);
      final level = scorer.score(analysis);

      expect(
        level.index,
        greaterThanOrEqualTo(DifficultyLevel.medium.index),
      );
    });

    test('rawScore returns value between 0 and 1', () {
      final grid = SquareGrid(10, 10);
      const RecursiveBacktracker().generate(grid, Random(42));
      final analysis =
          analyzeMaze(grid, grid.cellAt(0, 0)!, grid.cellAt(9, 9)!);
      final raw = scorer.rawScore(analysis);

      expect(raw, greaterThanOrEqualTo(0.0));
      expect(raw, lessThanOrEqualTo(1.0));
    });
  });
}
