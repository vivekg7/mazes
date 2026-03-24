import 'package:maze_core/maze_core.dart';
import 'package:test/test.dart';

void main() {
  group('MazeConfig', () {
    test('creates with required fields', () {
      const config = MazeConfig(
        cellType: CellType.square,
        rows: 10,
        columns: 10,
      );
      expect(config.cellType, equals(CellType.square));
      expect(config.rows, equals(10));
      expect(config.columns, equals(10));
      expect(config.difficulty, equals(DifficultyLevel.medium));
      expect(config.puzzleShape, equals(PuzzleShape.rectangle));
      expect(config.algorithm, isNull);
      expect(config.seed, isNull);
    });

    test('creates with all fields', () {
      const config = MazeConfig(
        cellType: CellType.hexagonal,
        rows: 20,
        columns: 15,
        puzzleShape: PuzzleShape.circle,
        shapeVariant: 'large',
        algorithm: Algorithm.wilsons,
        difficulty: DifficultyLevel.hard,
        seed: 42,
      );
      expect(config.cellType, equals(CellType.hexagonal));
      expect(config.puzzleShape, equals(PuzzleShape.circle));
      expect(config.algorithm, equals(Algorithm.wilsons));
      expect(config.difficulty, equals(DifficultyLevel.hard));
      expect(config.seed, equals(42));
    });

    test('copyWith replaces fields', () {
      const original = MazeConfig(
        cellType: CellType.square,
        rows: 10,
        columns: 10,
      );
      final copy = original.copyWith(
        cellType: CellType.hexagonal,
        rows: 20,
      );
      expect(copy.cellType, equals(CellType.hexagonal));
      expect(copy.rows, equals(20));
      expect(copy.columns, equals(10)); // unchanged
    });
  });

  group('Enums', () {
    test('CellType has all expected values', () {
      expect(CellType.values, hasLength(4));
    });

    test('Algorithm has all expected values', () {
      expect(Algorithm.values, hasLength(11));
    });

    test('DifficultyLevel has all expected values', () {
      expect(DifficultyLevel.values, hasLength(6));
    });
  });
}
