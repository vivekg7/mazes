import 'dart:math';

import '../models/cell.dart';
import '../models/grid.dart';
import 'generator.dart';

/// Hunt-and-Kill algorithm maze generator.
///
/// Similar to Recursive Backtracker but scans for unvisited cells instead of
/// maintaining a stack. Produces long corridors with moderate dead-end count.
class HuntAndKill extends MazeGenerator {
  const HuntAndKill();

  @override
  void generate(Grid grid, Random random) {
    Cell? current = grid.randomCell(random);

    while (current != null) {
      // Kill: walk to unvisited neighbors.
      final unvisited =
          current.neighbors.where((n) => n.links.isEmpty).toList();

      if (unvisited.isNotEmpty) {
        final next = unvisited[random.nextInt(unvisited.length)];
        current.link(next);
        current = next;
      } else {
        // Hunt: scan for an unvisited cell adjacent to a visited one.
        current = null;
        for (final cell in grid.cells) {
          if (cell.links.isNotEmpty) continue;

          final visitedNeighbors =
              cell.neighbors.where((n) => n.links.isNotEmpty).toList();
          if (visitedNeighbors.isNotEmpty) {
            final neighbor =
                visitedNeighbors[random.nextInt(visitedNeighbors.length)];
            cell.link(neighbor);
            current = cell;
            break;
          }
        }
      }
    }
  }
}
