import 'dart:collection';

import '../models/cell.dart';
import '../models/path.dart';

/// Finds the shortest path between two cells using BFS.
///
/// Returns a [MazePath] from [start] to [end], or an empty path if no
/// path exists.
MazePath solveMaze(Cell start, Cell end) {
  if (start == end) return MazePath([start]);

  final visited = <Cell>{start};
  final parent = <Cell, Cell>{};
  final queue = Queue<Cell>()..add(start);

  while (queue.isNotEmpty) {
    final current = queue.removeFirst();

    for (final neighbor in current.links) {
      if (visited.contains(neighbor)) continue;
      visited.add(neighbor);
      parent[neighbor] = current;

      if (neighbor == end) {
        // Reconstruct path.
        final path = <Cell>[end];
        var cell = end;
        while (cell != start) {
          cell = parent[cell]!;
          path.add(cell);
        }
        return MazePath(path.reversed.toList());
      }

      queue.add(neighbor);
    }
  }

  return const MazePath.empty();
}

/// Computes the distance from [start] to every reachable cell using BFS.
///
/// Returns a map from cell to distance (number of steps).
Map<Cell, int> distances(Cell start) {
  final dist = <Cell, int>{start: 0};
  final queue = Queue<Cell>()..add(start);

  while (queue.isNotEmpty) {
    final current = queue.removeFirst();
    final d = dist[current]!;

    for (final neighbor in current.links) {
      if (dist.containsKey(neighbor)) continue;
      dist[neighbor] = d + 1;
      queue.add(neighbor);
    }
  }

  return dist;
}

/// Finds the longest shortest path in the maze (the diameter).
///
/// Uses two BFS passes: first from an arbitrary cell to find the farthest
/// cell, then from that cell to find the actual farthest pair.
/// Returns the two endpoints and the path between them.
({Cell start, Cell end, MazePath path}) longestPath(Cell anyCell) {
  // First BFS: find farthest cell from anyCell.
  final dist1 = distances(anyCell);
  final farthest1 = dist1.entries.reduce(
    (a, b) => a.value > b.value ? a : b,
  ).key;

  // Second BFS: find farthest cell from farthest1.
  final dist2 = distances(farthest1);
  final farthest2 = dist2.entries.reduce(
    (a, b) => a.value > b.value ? a : b,
  ).key;

  return (
    start: farthest1,
    end: farthest2,
    path: solveMaze(farthest1, farthest2),
  );
}
