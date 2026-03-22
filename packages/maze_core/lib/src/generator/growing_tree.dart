import 'dart:math';

import '../models/cell.dart';
import '../models/grid.dart';
import 'generator.dart';

/// Selection strategy for the Growing Tree algorithm.
enum GrowingTreeStrategy {
  /// Always pick the newest cell (behaves like Recursive Backtracker).
  newest,

  /// Pick a random cell from the active list (behaves like Prim's).
  random,

  /// Always pick the oldest cell.
  oldest,

  /// Mix of newest and random (50/50).
  mixed,
}

/// Growing Tree algorithm maze generator.
///
/// Highly tunable — the selection strategy controls behavior:
/// - [GrowingTreeStrategy.newest] → Recursive Backtracker behavior
/// - [GrowingTreeStrategy.random] → Prim's behavior
/// - [GrowingTreeStrategy.mixed] → blend of both
class GrowingTree extends MazeGenerator {
  const GrowingTree({this.strategy = GrowingTreeStrategy.mixed});

  final GrowingTreeStrategy strategy;

  @override
  void generate(Grid grid, Random random) {
    final active = <Cell>[grid.randomCell(random)];

    while (active.isNotEmpty) {
      final index = _selectIndex(active, random);
      final cell = active[index];

      final unvisited =
          cell.neighbors.where((n) => n.links.isEmpty).toList();

      if (unvisited.isEmpty) {
        active.removeAt(index);
      } else {
        final next = unvisited[random.nextInt(unvisited.length)];
        cell.link(next);
        active.add(next);
      }
    }
  }

  int _selectIndex(List<Cell> active, Random random) {
    return switch (strategy) {
      GrowingTreeStrategy.newest => active.length - 1,
      GrowingTreeStrategy.oldest => 0,
      GrowingTreeStrategy.random => random.nextInt(active.length),
      GrowingTreeStrategy.mixed => random.nextBool()
          ? active.length - 1
          : random.nextInt(active.length),
    };
  }
}
