import 'package:flutter/material.dart';
import 'package:maze_core/maze_core.dart';

import '../services/storage_service.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key, required this.storage});

  final StorageService storage;

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

enum _FilterCategory { overall, cellType, difficulty, algorithm }

class _StatsScreenState extends State<StatsScreen> {
  _FilterCategory _category = _FilterCategory.overall;

  late final StatsAggregator _aggregator;

  @override
  void initState() {
    super.initState();
    _aggregator = StatsAggregator(widget.storage);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Stats')),
      body: ListenableBuilder(
        listenable: widget.storage,
        builder: (context, _) {
          if (widget.storage.records.isEmpty) {
            return _buildEmptyState(context);
          }
          return _buildStats(context);
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.bar_chart,
            size: 64,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            'No stats yet',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Complete a maze to start tracking your progress',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildStats(BuildContext context) {
    return Column(
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              for (final cat in _FilterCategory.values)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(_categoryLabel(cat)),
                    selected: _category == cat,
                    onSelected: (_) => setState(() => _category = cat),
                  ),
                ),
            ],
          ),
        ),
        Expanded(
          child: switch (_category) {
            _FilterCategory.overall => _OverallView(aggregator: _aggregator),
            _FilterCategory.cellType =>
              _BreakdownView<CellType>(
                values: CellType.values,
                label: (v) => v.name._capitalize(),
                fetcher: (v) => _aggregator.byCellType(v),
              ),
            _FilterCategory.difficulty =>
              _BreakdownView<DifficultyLevel>(
                values: DifficultyLevel.values,
                label: (v) => v.name._capitalize(),
                fetcher: (v) => _aggregator.byDifficulty(v),
              ),
            _FilterCategory.algorithm =>
              _BreakdownView<Algorithm>(
                values: Algorithm.values,
                label: (v) => _algorithmLabel(v),
                fetcher: (v) => _aggregator.byAlgorithm(v),
              ),
          },
        ),
      ],
    );
  }

  String _categoryLabel(_FilterCategory cat) {
    return switch (cat) {
      _FilterCategory.overall => 'Overall',
      _FilterCategory.cellType => 'Cell Type',
      _FilterCategory.difficulty => 'Difficulty',
      _FilterCategory.algorithm => 'Algorithm',
    };
  }

  String _algorithmLabel(Algorithm alg) {
    return switch (alg) {
      Algorithm.recursiveBacktracker => 'Recursive Backtracker',
      Algorithm.kruskals => "Kruskal's",
      Algorithm.prims => "Prim's",
      Algorithm.ellers => "Eller's",
      Algorithm.wilsons => "Wilson's",
      Algorithm.aldousBroder => 'Aldous-Broder',
      Algorithm.growingTree => 'Growing Tree',
      Algorithm.huntAndKill => 'Hunt & Kill',
      Algorithm.sidewinder => 'Sidewinder',
      Algorithm.binaryTree => 'Binary Tree',
      Algorithm.recursiveDivision => 'Recursive Division',
    };
  }
}

/// Shows overall stats summary with streaks and recent history.
class _OverallView extends StatelessWidget {
  const _OverallView({required this.aggregator});

  final StatsAggregator aggregator;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<StatsSummary>(
      future: aggregator.overall(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final stats = snapshot.data!;
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _SummaryCard(stats: stats),
            const SizedBox(height: 16),
            _StreakCard(
              currentStreak: stats.currentStreak,
              longestStreak: stats.longestStreak,
            ),
          ],
        );
      },
    );
  }
}

/// Displays overall stats in a card with grid of metrics.
class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.stats});

  final StatsSummary stats;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Summary', style: theme.textTheme.titleMedium),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _MetricTile(
                    label: 'Completed',
                    value: '${stats.totalCompleted}',
                  ),
                ),
                Expanded(
                  child: _MetricTile(
                    label: 'Completion Rate',
                    value:
                        '${(stats.completionRate * 100).toStringAsFixed(0)}%',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _MetricTile(
                    label: 'Avg Time',
                    value: _formatTime(stats.averageSolveTimeMs.round()),
                  ),
                ),
                Expanded(
                  child: _MetricTile(
                    label: 'Best Time',
                    value: stats.bestSolveTimeMs != null
                        ? _formatTime(stats.bestSolveTimeMs!)
                        : '-',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _MetricTile(
              label: 'Avg Efficiency',
              value:
                  '${(stats.averageEfficiency * 100).toStringAsFixed(0)}%',
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(int ms) {
    final duration = Duration(milliseconds: ms);
    final m = duration.inMinutes;
    final s = duration.inSeconds % 60;
    return '${m}m ${s}s';
  }
}

/// Streak display card.
class _StreakCard extends StatelessWidget {
  const _StreakCard({
    required this.currentStreak,
    required this.longestStreak,
  });

  final int currentStreak;
  final int longestStreak;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Streaks', style: theme.textTheme.titleMedium),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _MetricTile(
                    label: 'Current Streak',
                    value: '$currentStreak day${currentStreak == 1 ? '' : 's'}',
                  ),
                ),
                Expanded(
                  child: _MetricTile(
                    label: 'Longest Streak',
                    value: '$longestStreak day${longestStreak == 1 ? '' : 's'}',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// A single labeled metric value.
class _MetricTile extends StatelessWidget {
  const _MetricTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

/// Shows stats broken down by enum values (cell type, difficulty, algorithm).
class _BreakdownView<T> extends StatelessWidget {
  const _BreakdownView({
    super.key,
    required this.values,
    required this.label,
    required this.fetcher,
  });

  final List<T> values;
  final String Function(T) label;
  final Future<StatsSummary> Function(T) fetcher;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: values.length,
      itemBuilder: (context, index) {
        final value = values[index];
        return FutureBuilder<StatsSummary>(
          future: fetcher(value),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const SizedBox.shrink();
            }
            final stats = snapshot.data!;
            if (stats.totalSolved == 0) return const SizedBox.shrink();
            return _BreakdownTile(
              label: label(value),
              stats: stats,
            );
          },
        );
      },
    );
  }
}

/// A single row in the breakdown view showing stats for one category value.
class _BreakdownTile extends StatelessWidget {
  const _BreakdownTile({required this.label, required this.stats});

  final String label;
  final StatsSummary stats;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: theme.textTheme.titleSmall),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _MiniMetric(
                    label: 'Solved',
                    value: '${stats.totalCompleted}',
                  ),
                ),
                Expanded(
                  child: _MiniMetric(
                    label: 'Avg Time',
                    value: _formatTime(stats.averageSolveTimeMs.round()),
                  ),
                ),
                Expanded(
                  child: _MiniMetric(
                    label: 'Avg Efficiency',
                    value:
                        '${(stats.averageEfficiency * 100).toStringAsFixed(0)}%',
                  ),
                ),
                Expanded(
                  child: _MiniMetric(
                    label: 'Best',
                    value: stats.bestSolveTimeMs != null
                        ? _formatTime(stats.bestSolveTimeMs!)
                        : '-',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(int ms) {
    final duration = Duration(milliseconds: ms);
    final m = duration.inMinutes;
    final s = duration.inSeconds % 60;
    return '${m}m ${s}s';
  }
}

/// Compact metric for breakdown rows.
class _MiniMetric extends StatelessWidget {
  const _MiniMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

extension on String {
  String _capitalize() =>
      isEmpty ? this : this[0].toUpperCase() + substring(1);
}
