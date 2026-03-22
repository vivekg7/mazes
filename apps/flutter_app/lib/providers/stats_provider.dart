import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:maze_core/maze_core.dart';

import '../storage/hive_stats_repository.dart';

/// The stats repository instance (Hive-backed).
final statsRepositoryProvider = Provider<StatsRepository>((ref) {
  return HiveStatsRepository();
});

/// The stats aggregator.
final statsAggregatorProvider = Provider<StatsAggregator>((ref) {
  return StatsAggregator(ref.watch(statsRepositoryProvider));
});
