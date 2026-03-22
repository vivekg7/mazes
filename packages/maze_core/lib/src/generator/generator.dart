import 'dart:math';

import '../models/grid.dart';

/// Base class for maze generation algorithms.
///
/// Each algorithm operates on an abstract [Grid], linking cells to carve
/// passages. After generation, every cell should be reachable from every
/// other cell (a perfect maze / spanning tree).
abstract class MazeGenerator {
  const MazeGenerator();

  /// Generates a maze by carving passages in [grid].
  ///
  /// Uses [random] for any randomized decisions. The grid is modified
  /// in place — cells are linked to create passages.
  void generate(Grid grid, Random random);
}
