import 'dart:math';

import '../models/cell.dart';
import '../models/grid.dart';
import 'generator.dart';

/// Kruskal's algorithm maze generator.
///
/// Produces uniform, organic-feeling mazes with no directional bias. Works by
/// randomly connecting cells from different sets until all cells are in one set.
class Kruskals extends MazeGenerator {
  const Kruskals();

  @override
  void generate(Grid grid, Random random) {
    // Union-Find structure.
    final parent = <Cell, Cell>{};
    final rank = <Cell, int>{};

    Cell find(Cell cell) {
      if (parent[cell] != cell) {
        parent[cell] = find(parent[cell]!);
      }
      return parent[cell]!;
    }

    void union(Cell a, Cell b) {
      final rootA = find(a);
      final rootB = find(b);
      if (rootA == rootB) return;

      final rankA = rank[rootA] ?? 0;
      final rankB = rank[rootB] ?? 0;
      if (rankA < rankB) {
        parent[rootA] = rootB;
      } else if (rankA > rankB) {
        parent[rootB] = rootA;
      } else {
        parent[rootB] = rootA;
        rank[rootA] = rankA + 1;
      }
    }

    // Initialize each cell as its own set.
    for (final cell in grid.cells) {
      parent[cell] = cell;
      rank[cell] = 0;
    }

    // Collect all possible edges and shuffle.
    final edges = <(Cell, Cell)>[];
    for (final cell in grid.cells) {
      for (final neighbor in cell.neighbors) {
        // Only add each edge once.
        if (cell.hashCode < neighbor.hashCode) {
          edges.add((cell, neighbor));
        }
      }
    }
    edges.shuffle(random);

    // Connect cells from different sets.
    for (final (a, b) in edges) {
      if (find(a) != find(b)) {
        a.link(b);
        union(a, b);
      }
    }
  }
}
