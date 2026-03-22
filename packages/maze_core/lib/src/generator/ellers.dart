import 'dart:math';

import '../models/cell.dart';
import '../models/grid.dart';
import 'generator.dart';

/// Eller's algorithm maze generator.
///
/// Generates row by row with minimal memory. Has a slight horizontal bias.
/// Only works well on rectangular-style grids that have a meaningful row
/// structure.
class Ellers extends MazeGenerator {
  const Ellers();

  @override
  void generate(Grid grid, Random random) {
    final setForCell = <Cell, int>{};
    var nextSet = 0;

    final rows = grid.rowsIterable.toList();

    for (var rowIndex = 0; rowIndex < rows.length; rowIndex++) {
      final row = rows[rowIndex].whereType<Cell>().toList();
      final isLastRow = rowIndex == rows.length - 1;

      // Assign sets to cells that don't have one.
      for (final cell in row) {
        setForCell.putIfAbsent(cell, () => nextSet++);
      }

      // Randomly merge adjacent cells in same row (if in different sets).
      for (var i = 0; i < row.length - 1; i++) {
        final current = row[i];
        final next = row[i + 1];

        if (!current.neighbors.contains(next)) continue;

        final currentSet = setForCell[current]!;
        final nextSet_ = setForCell[next]!;

        if (currentSet == nextSet_) continue;

        // On last row, always merge different sets. Otherwise, random.
        if (isLastRow || random.nextBool()) {
          current.link(next);
          // Merge sets.
          final oldSet = nextSet_;
          for (final c in row) {
            if (setForCell[c] == oldSet) {
              setForCell[c] = currentSet;
            }
          }
        }
      }

      // Create vertical connections (not on last row).
      if (!isLastRow) {
        final nextRow = rows[rowIndex + 1].whereType<Cell>().toList();

        // Group current row cells by set.
        final setMembers = <int, List<Cell>>{};
        for (final cell in row) {
          setMembers.putIfAbsent(setForCell[cell]!, () => []).add(cell);
        }

        // Each set must have at least one downward connection.
        for (final members in setMembers.values) {
          // Find members that have a neighbor in the next row.
          final withSouth = members.where((c) {
            return c.neighbors.any(nextRow.contains);
          }).toList();

          if (withSouth.isEmpty) continue;

          withSouth.shuffle(random);

          // At least one must connect down; others connect randomly.
          final count = 1 + random.nextInt(withSouth.length);
          for (var i = 0; i < count; i++) {
            final cell = withSouth[i];
            final southNeighbors =
                cell.neighbors.where(nextRow.contains).toList();
            if (southNeighbors.isEmpty) continue;

            final south =
                southNeighbors[random.nextInt(southNeighbors.length)];
            cell.link(south);
            setForCell[south] = setForCell[cell]!;
          }
        }
      }
    }
  }
}
