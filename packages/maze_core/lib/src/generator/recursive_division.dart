import 'dart:math';

import '../models/cell.dart';
import '../models/grid.dart';
import 'generator.dart';

/// Recursive Division algorithm maze generator.
///
/// Unlike other algorithms that carve passages, this one starts with all
/// passages open and adds walls. Produces long straight walls giving a
/// grid-like, room-and-corridor feel.
///
/// Works best on rectangular grids.
class RecursiveDivision extends MazeGenerator {
  const RecursiveDivision();

  @override
  void generate(Grid grid, Random random) {
    // Start by linking every cell to all its neighbors (fully open grid).
    for (final cell in grid.cells) {
      for (final neighbor in cell.neighbors) {
        if (!cell.isLinked(neighbor)) {
          cell.link(neighbor);
        }
      }
    }

    // Recursively divide using walls.
    final allCells = grid.cells.toList();
    _divide(allCells, grid, random);
  }

  void _divide(List<Cell> region, Grid grid, Random random) {
    if (region.length <= 1) return;

    // Determine region bounds.
    var minRow = region[0].row;
    var maxRow = region[0].row;
    var minCol = region[0].column;
    var maxCol = region[0].column;

    for (final cell in region) {
      if (cell.row < minRow) minRow = cell.row;
      if (cell.row > maxRow) maxRow = cell.row;
      if (cell.column < minCol) minCol = cell.column;
      if (cell.column > maxCol) maxCol = cell.column;
    }

    final height = maxRow - minRow + 1;
    final width = maxCol - minCol + 1;

    if (height <= 1 && width <= 1) return;

    // Choose to divide horizontally or vertically.
    final divideHorizontally =
        height > width || (height == width && random.nextBool());

    if (divideHorizontally && height > 1) {
      // Pick a row to place the wall.
      final wallRow = minRow + random.nextInt(height - 1);

      // Find all linked pairs crossing this wall.
      final crossings = <(Cell, Cell)>[];
      for (final cell in region) {
        if (cell.row != wallRow) continue;
        for (final neighbor in cell.links) {
          if (neighbor.row == wallRow + 1 && region.contains(neighbor)) {
            crossings.add((cell, neighbor));
          }
        }
      }

      if (crossings.length > 1) {
        // Keep one passage open, wall off the rest.
        crossings.shuffle(random);
        for (var i = 1; i < crossings.length; i++) {
          crossings[i].$1.unlink(crossings[i].$2);
        }
      }

      // Recurse on both halves.
      final top = region.where((c) => c.row <= wallRow).toList();
      final bottom = region.where((c) => c.row > wallRow).toList();
      _divide(top, grid, random);
      _divide(bottom, grid, random);
    } else if (width > 1) {
      // Pick a column to place the wall.
      final wallCol = minCol + random.nextInt(width - 1);

      final crossings = <(Cell, Cell)>[];
      for (final cell in region) {
        if (cell.column != wallCol) continue;
        for (final neighbor in cell.links) {
          if (neighbor.column == wallCol + 1 && region.contains(neighbor)) {
            crossings.add((cell, neighbor));
          }
        }
      }

      if (crossings.length > 1) {
        crossings.shuffle(random);
        for (var i = 1; i < crossings.length; i++) {
          crossings[i].$1.unlink(crossings[i].$2);
        }
      }

      final left = region.where((c) => c.column <= wallCol).toList();
      final right = region.where((c) => c.column > wallCol).toList();
      _divide(left, grid, random);
      _divide(right, grid, random);
    }
  }
}
