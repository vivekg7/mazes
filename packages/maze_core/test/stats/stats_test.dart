import 'package:maze_core/maze_core.dart';
import 'package:test/test.dart';

SolveRecord _record({
  int daysAgo = 0,
  bool completed = true,
  int solveTimeMs = 5000,
  int playerPath = 20,
  int shortestPath = 15,
  DifficultyLevel difficulty = DifficultyLevel.medium,
  CellType cellType = CellType.square,
  Algorithm algorithm = Algorithm.recursiveBacktracker,
}) {
  return SolveRecord(
    timestamp: DateTime.now().subtract(Duration(days: daysAgo)),
    cellType: cellType,
    puzzleShape: PuzzleShape.rectangle,
    algorithm: algorithm,
    difficulty: difficulty,
    rows: 10,
    columns: 10,
    solveTimeMs: solveTimeMs,
    playerPathLength: playerPath,
    shortestPathLength: shortestPath,
    completed: completed,
  );
}

void main() {
  group('SolveRecord', () {
    test('efficiency is shortest/player path', () {
      final record = _record(playerPath: 20, shortestPath: 10);
      expect(record.efficiency, equals(0.5));
    });

    test('perfect efficiency is 1.0', () {
      final record = _record(playerPath: 15, shortestPath: 15);
      expect(record.efficiency, equals(1.0));
    });

    test('JSON round-trip preserves data', () {
      final record = _record();
      final json = record.toJson();
      final restored = SolveRecord.fromJson(json);

      expect(restored.cellType, equals(record.cellType));
      expect(restored.difficulty, equals(record.difficulty));
      expect(restored.solveTimeMs, equals(record.solveTimeMs));
      expect(restored.completed, equals(record.completed));
      expect(restored.playerPathLength, equals(record.playerPathLength));
    });
  });

  group('InMemoryStatsRepository', () {
    test('add and retrieve records', () async {
      final repo = InMemoryStatsRepository();
      await repo.addRecord(_record());
      await repo.addRecord(_record());

      final records = await repo.getAllRecords();
      expect(records, hasLength(2));
    });

    test('clear removes all records', () async {
      final repo = InMemoryStatsRepository();
      await repo.addRecord(_record());
      await repo.clear();

      final records = await repo.getAllRecords();
      expect(records, isEmpty);
    });

    test('export/import round-trip', () async {
      final repo = InMemoryStatsRepository();
      await repo.addRecord(_record(solveTimeMs: 1234));

      final exported = await repo.export();
      final repo2 = InMemoryStatsRepository();
      await repo2.import_(exported);

      final records = await repo2.getAllRecords();
      expect(records, hasLength(1));
      expect(records[0].solveTimeMs, equals(1234));
    });
  });

  group('StatsAggregator', () {
    late InMemoryStatsRepository repo;
    late StatsAggregator aggregator;

    setUp(() {
      repo = InMemoryStatsRepository();
      aggregator = StatsAggregator(repo);
    });

    test('empty stats', () async {
      final stats = await aggregator.overall();
      expect(stats.totalSolved, equals(0));
      expect(stats.totalCompleted, equals(0));
      expect(stats.currentStreak, equals(0));
    });

    test('overall stats computed correctly', () async {
      await repo.addRecord(_record(solveTimeMs: 3000, completed: true));
      await repo.addRecord(_record(solveTimeMs: 5000, completed: true));
      await repo.addRecord(_record(completed: false));

      final stats = await aggregator.overall();
      expect(stats.totalSolved, equals(3));
      expect(stats.totalCompleted, equals(2));
      expect(stats.averageSolveTimeMs, equals(4000));
      expect(stats.bestSolveTimeMs, equals(3000));
    });

    test('filter by cell type', () async {
      await repo.addRecord(_record(cellType: CellType.square));
      await repo.addRecord(_record(cellType: CellType.hexagonal));
      await repo.addRecord(_record(cellType: CellType.square));

      final stats = await aggregator.byCellType(CellType.square);
      expect(stats.totalSolved, equals(2));
    });

    test('filter by difficulty', () async {
      await repo.addRecord(_record(difficulty: DifficultyLevel.easy));
      await repo.addRecord(_record(difficulty: DifficultyLevel.hard));
      await repo.addRecord(_record(difficulty: DifficultyLevel.hard));

      final stats = await aggregator.byDifficulty(DifficultyLevel.hard);
      expect(stats.totalSolved, equals(2));
    });

    test('streak tracking with consecutive days', () async {
      await repo.addRecord(_record(daysAgo: 0));
      await repo.addRecord(_record(daysAgo: 1));
      await repo.addRecord(_record(daysAgo: 2));

      final stats = await aggregator.overall();
      expect(stats.currentStreak, equals(3));
      expect(stats.longestStreak, equals(3));
    });

    test('broken streak resets current but keeps longest', () async {
      // Streak of 3, then a gap, then 1 today.
      await repo.addRecord(_record(daysAgo: 0));
      await repo.addRecord(_record(daysAgo: 5));
      await repo.addRecord(_record(daysAgo: 6));
      await repo.addRecord(_record(daysAgo: 7));

      final stats = await aggregator.overall();
      expect(stats.currentStreak, equals(1));
      expect(stats.longestStreak, equals(3));
    });

    test('completion rate', () async {
      await repo.addRecord(_record(completed: true));
      await repo.addRecord(_record(completed: true));
      await repo.addRecord(_record(completed: false));

      final stats = await aggregator.overall();
      expect(stats.completionRate, closeTo(0.667, 0.01));
    });
  });
}
