import 'dart:math';

import '../models/cell.dart';
import '../models/grid.dart';
import 'generator.dart';

/// Sidewinder algorithm maze generator.
///
/// Row-by-row algorithm with a slight horizontal bias. The first row is always
/// a single corridor. Works best on rectangular grids.
class Sidewinder extends MazeGenerator {
  const Sidewinder();

  @override
  void generate(Grid grid, Random random) {
    for (final row in grid.rowsIterable) {
      final cells = row.whereType<Cell>().toList();
      var runStart = 0;

      for (var i = 0; i < cells.length; i++) {
        final cell = cells[i];

        // Check if we're at the northern boundary (no north-like neighbors
        // that are in a previous row).
        final northNeighbors = cell.neighbors
            .where((n) => n.row < cell.row)
            .toList();
        final eastNeighbor =
            i + 1 < cells.length ? cells[i + 1] : null;
        final hasEast =
            eastNeighbor != null && cell.neighbors.contains(eastNeighbor);
        final hasNorth = northNeighbors.isNotEmpty;

        final shouldCloseRun = !hasEast || (hasNorth && random.nextBool());

        if (shouldCloseRun) {
          // Close the run: connect one cell in the run to a northern neighbor.
          if (hasNorth) {
            final runIndex = runStart + random.nextInt(i - runStart + 1);
            final runCell = cells[runIndex];
            final northOptions = runCell.neighbors
                .where((n) => n.row < runCell.row)
                .toList();
            if (northOptions.isNotEmpty) {
              runCell.link(northOptions[random.nextInt(northOptions.length)]);
            }
          }
          runStart = i + 1;
        } else {
          // Extend the run eastward.
          cell.link(eastNeighbor);
        }
      }
    }
  }
}
