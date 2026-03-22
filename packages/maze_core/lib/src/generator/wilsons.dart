import 'dart:math';

import '../models/cell.dart';
import '../models/grid.dart';
import 'generator.dart';

/// Wilson's algorithm maze generator.
///
/// Produces a perfectly uniform spanning tree (each possible maze is equally
/// likely). Uses loop-erased random walks. Can be slow on large grids but
/// completely unbiased.
class Wilsons extends MazeGenerator {
  const Wilsons();

  @override
  void generate(Grid grid, Random random) {
    final unvisited = grid.cells.toSet();

    // Start with one random cell in the maze.
    unvisited.remove(grid.randomCell(random));

    while (unvisited.isNotEmpty) {
      // Start a random walk from a random unvisited cell.
      var cell = unvisited.elementAt(random.nextInt(unvisited.length));
      final path = <Cell>[cell];
      final pathIndex = <Cell, int>{cell: 0};

      // Walk until we reach a visited cell.
      while (unvisited.contains(cell)) {
        final neighbors = cell.neighbors;
        cell = neighbors[random.nextInt(neighbors.length)];

        if (pathIndex.containsKey(cell)) {
          // Loop detected — erase the loop.
          final loopStart = pathIndex[cell]!;
          for (var i = path.length - 1; i > loopStart; i--) {
            pathIndex.remove(path[i]);
          }
          path.removeRange(loopStart + 1, path.length);
        } else {
          pathIndex[cell] = path.length;
          path.add(cell);
        }
      }

      // Carve the path into the maze.
      for (var i = 0; i < path.length - 1; i++) {
        path[i].link(path[i + 1]);
        unvisited.remove(path[i]);
      }
    }
  }
}
