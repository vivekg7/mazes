import 'dart:math';

import '../models/grid.dart';
import 'generator.dart';

/// Binary Tree algorithm maze generator.
///
/// The simplest maze algorithm. Each cell links to either its north or east
/// neighbor (or the only available one). Produces a strong diagonal bias —
/// the north and east edges are always open corridors.
class BinaryTree extends MazeGenerator {
  const BinaryTree();

  @override
  void generate(Grid grid, Random random) {
    for (final cell in grid.cells) {
      // Prefer neighbors in the "north" (lower row) or "east" (higher column)
      // directions. For non-rectangular grids, pick the two lowest-index
      // neighbors as the bias directions.
      final neighbors = cell.neighbors;
      final northLike =
          neighbors.where((n) => n.row < cell.row).toList();
      final eastLike =
          neighbors.where((n) => n.column > cell.column && n.row == cell.row).toList();

      final candidates = [...northLike, ...eastLike];

      if (candidates.isNotEmpty) {
        final chosen = candidates[random.nextInt(candidates.length)];
        cell.link(chosen);
      }
    }
  }
}
