import 'dart:math';

import '../models/cell.dart';
import '../models/grid.dart';
import 'generator.dart';

/// Recursive Backtracker (DFS) maze generator.
///
/// Produces long, winding corridors with low dead-end count. One of the most
/// popular algorithms — fast and produces visually appealing mazes.
class RecursiveBacktracker extends MazeGenerator {
  const RecursiveBacktracker();

  @override
  void generate(Grid grid, Random random) {
    final stack = <Cell>[grid.randomCell(random)];

    while (stack.isNotEmpty) {
      final current = stack.last;
      final unvisited =
          current.neighbors.where((n) => n.links.isEmpty).toList();

      if (unvisited.isEmpty) {
        stack.removeLast();
      } else {
        final next = unvisited[random.nextInt(unvisited.length)];
        current.link(next);
        stack.add(next);
      }
    }
  }
}
