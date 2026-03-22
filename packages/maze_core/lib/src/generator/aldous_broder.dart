import 'dart:math';

import '../models/grid.dart';
import 'generator.dart';

/// Aldous-Broder algorithm maze generator.
///
/// Like Wilson's, produces a perfectly uniform spanning tree. Uses a simple
/// random walk — very slow on large grids but completely unbiased.
class AldousBroder extends MazeGenerator {
  const AldousBroder();

  @override
  void generate(Grid grid, Random random) {
    var cell = grid.randomCell(random);
    var unvisited = grid.size - 1;

    while (unvisited > 0) {
      final neighbors = cell.neighbors;
      final neighbor = neighbors[random.nextInt(neighbors.length)];

      if (neighbor.links.isEmpty) {
        cell.link(neighbor);
        unvisited--;
      }

      cell = neighbor;
    }
  }
}
