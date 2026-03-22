import '../models/enums.dart';
import 'solve_record.dart';
import 'stats_repository.dart';

/// Aggregated statistics summary.
class StatsSummary {
  const StatsSummary({
    required this.totalSolved,
    required this.totalCompleted,
    required this.averageSolveTimeMs,
    required this.averageEfficiency,
    required this.bestSolveTimeMs,
    required this.currentStreak,
    required this.longestStreak,
  });

  final int totalSolved;
  final int totalCompleted;
  final double averageSolveTimeMs;
  final double averageEfficiency;
  final int? bestSolveTimeMs;
  final int currentStreak;
  final int longestStreak;

  double get completionRate =>
      totalSolved == 0 ? 0 : totalCompleted / totalSolved;
}

/// Computes aggregated stats from solve records.
class StatsAggregator {
  const StatsAggregator(this.repository);

  final StatsRepository repository;

  /// Overall stats across all records.
  Future<StatsSummary> overall() async {
    final records = await repository.getAllRecords();
    return _summarize(records);
  }

  /// Stats filtered by cell type.
  Future<StatsSummary> byCellType(CellType cellType) async {
    final records = await repository.getAllRecords();
    return _summarize(records.where((r) => r.cellType == cellType).toList());
  }

  /// Stats filtered by puzzle shape.
  Future<StatsSummary> byPuzzleShape(PuzzleShape shape) async {
    final records = await repository.getAllRecords();
    return _summarize(records.where((r) => r.puzzleShape == shape).toList());
  }

  /// Stats filtered by algorithm.
  Future<StatsSummary> byAlgorithm(Algorithm algorithm) async {
    final records = await repository.getAllRecords();
    return _summarize(records.where((r) => r.algorithm == algorithm).toList());
  }

  /// Stats filtered by difficulty.
  Future<StatsSummary> byDifficulty(DifficultyLevel level) async {
    final records = await repository.getAllRecords();
    return _summarize(records.where((r) => r.difficulty == level).toList());
  }

  StatsSummary _summarize(List<SolveRecord> records) {
    if (records.isEmpty) {
      return const StatsSummary(
        totalSolved: 0,
        totalCompleted: 0,
        averageSolveTimeMs: 0,
        averageEfficiency: 0,
        bestSolveTimeMs: null,
        currentStreak: 0,
        longestStreak: 0,
      );
    }

    final completed = records.where((r) => r.completed).toList();

    final avgTime = completed.isEmpty
        ? 0.0
        : completed.map((r) => r.solveTimeMs).reduce((a, b) => a + b) /
            completed.length;

    final avgEfficiency = completed.isEmpty
        ? 0.0
        : completed.map((r) => r.efficiency).reduce((a, b) => a + b) /
            completed.length;

    final bestTime = completed.isEmpty
        ? null
        : completed
            .map((r) => r.solveTimeMs)
            .reduce((a, b) => a < b ? a : b);

    final streaks = _computeStreaks(records);

    return StatsSummary(
      totalSolved: records.length,
      totalCompleted: completed.length,
      averageSolveTimeMs: avgTime,
      averageEfficiency: avgEfficiency,
      bestSolveTimeMs: bestTime,
      currentStreak: streaks.current,
      longestStreak: streaks.longest,
    );
  }

  /// Computes daily solve streaks.
  ///
  /// A streak day is any day with at least one completed solve.
  ({int current, int longest}) _computeStreaks(List<SolveRecord> records) {
    final completedDates = records
        .where((r) => r.completed)
        .map((r) => DateTime(
              r.timestamp.year,
              r.timestamp.month,
              r.timestamp.day,
            ))
        .toSet()
        .toList()
      ..sort();

    if (completedDates.isEmpty) return (current: 0, longest: 0);

    var longest = 1;
    var current = 1;

    for (var i = 1; i < completedDates.length; i++) {
      final diff = completedDates[i].difference(completedDates[i - 1]).inDays;
      if (diff == 1) {
        current++;
        if (current > longest) longest = current;
      } else if (diff > 1) {
        current = 1;
      }
    }

    // Check if current streak is still active (includes today or yesterday).
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    final lastDate = completedDates.last;
    final daysSinceLast = todayDate.difference(lastDate).inDays;
    if (daysSinceLast > 1) {
      current = 0;
    }

    return (current: current, longest: longest);
  }
}
