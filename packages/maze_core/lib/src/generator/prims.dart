import 'dart:math';

import '../models/cell.dart';
import '../models/grid.dart';
import 'generator.dart';

/// Prim's algorithm maze generator.
///
/// Tends toward short, branchy corridors radiating from the starting cell.
/// Grows the maze from a frontier of cells adjacent to the visited set.
class Prims extends MazeGenerator {
  const Prims();

  @override
  void generate(Grid grid, Random random) {
    final visited = <Cell>{};
    final frontier = <Cell>[];

    final start = grid.randomCell(random);
    visited.add(start);
    frontier.addAll(start.neighbors);

    while (frontier.isNotEmpty) {
      final index = random.nextInt(frontier.length);
      final cell = frontier[index];

      final visitedNeighbors =
          cell.neighbors.where(visited.contains).toList();

      if (visitedNeighbors.isNotEmpty) {
        final neighbor =
            visitedNeighbors[random.nextInt(visitedNeighbors.length)];
        cell.link(neighbor);
        visited.add(cell);

        for (final n in cell.neighbors) {
          if (!visited.contains(n) && !frontier.contains(n)) {
            frontier.add(n);
          }
        }
      }

      frontier.removeAt(index);
    }
  }
}
