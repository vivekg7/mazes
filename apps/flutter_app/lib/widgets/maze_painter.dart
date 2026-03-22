import 'package:flutter/material.dart';
import 'package:maze_core/maze_core.dart';

/// Render state for a maze: what to draw and how.
class MazeRenderState {
  const MazeRenderState({
    required this.grid,
    required this.startCell,
    required this.endCell,
    this.playerPath = const [],
    this.solution,
    this.showSolution = false,
    this.fogOfWarRadius,
    this.fogOfWarCenter,
    this.breadcrumbs = const {},
    this.wallMarks = const {},
  });

  final Grid grid;
  final Cell startCell;
  final Cell endCell;

  /// Cells in the player's current path, in order.
  final List<Cell> playerPath;

  /// The shortest solution path (for overlay display).
  final MazePath? solution;

  /// Whether to show the solution overlay.
  final bool showSolution;

  /// Fog of war: only cells within this many steps of [fogOfWarCenter]
  /// are visible. Null = no fog.
  final int? fogOfWarRadius;

  /// Center cell for fog of war calculation.
  final Cell? fogOfWarCenter;

  /// Cells the player has marked with breadcrumbs.
  final Set<Cell> breadcrumbs;

  /// Walls the player has marked (cell → set of marked neighbor walls).
  final Map<Cell, Set<Cell>> wallMarks;
}

/// CustomPainter that renders any maze grid type.
///
/// Uses cell vertex data from maze_core to draw walls, passages, markers,
/// player path, fog of war, and breadcrumbs.
class MazePainter extends CustomPainter {
  MazePainter({
    required this.state,
    required this.colorScheme,
    this.cellSize = 30.0,
  });

  final MazeRenderState state;
  final ColorScheme colorScheme;
  final double cellSize;

  @override
  void paint(Canvas canvas, Size size) {
    final grid = state.grid;

    // Compute visible cells for fog of war.
    final visibleCells = _computeVisibleCells();

    // Scale factor: map grid coordinates to canvas pixels.
    final bounds = _computeBounds(grid);
    final scaleX = cellSize;
    final scaleY = cellSize;

    Offset toCanvas(double x, double y) {
      return Offset(
        (x - bounds.minX) * scaleX + cellSize / 2,
        (y - bounds.minY) * scaleY + cellSize / 2,
      );
    }

    // Draw cell fills.
    _drawCellFills(canvas, grid, visibleCells, toCanvas);

    // Draw player path.
    _drawPlayerPath(canvas, toCanvas);

    // Draw solution overlay.
    if (state.showSolution && state.solution != null) {
      _drawSolution(canvas, toCanvas);
    }

    // Draw breadcrumbs.
    _drawBreadcrumbs(canvas, visibleCells, toCanvas);

    // Draw walls.
    _drawWalls(canvas, grid, visibleCells, toCanvas);

    // Draw wall marks.
    _drawWallMarks(canvas, visibleCells, toCanvas);

    // Draw start and end markers.
    _drawMarkers(canvas, toCanvas);
  }

  /// Computes the bounding box of all cell vertices.
  ({double minX, double maxX, double minY, double maxY}) _computeBounds(
    Grid grid,
  ) {
    var minX = double.infinity;
    var maxX = double.negativeInfinity;
    var minY = double.infinity;
    var maxY = double.negativeInfinity;

    for (final cell in grid.cells) {
      for (final v in cell.vertices) {
        if (v.x < minX) minX = v.x;
        if (v.x > maxX) maxX = v.x;
        if (v.y < minY) minY = v.y;
        if (v.y > maxY) maxY = v.y;
      }
    }

    return (minX: minX, maxX: maxX, minY: minY, maxY: maxY);
  }

  Set<Cell>? _computeVisibleCells() {
    if (state.fogOfWarRadius == null || state.fogOfWarCenter == null) {
      return null; // All visible.
    }

    final dist = distances(state.fogOfWarCenter!);
    return dist.entries
        .where((e) => e.value <= state.fogOfWarRadius!)
        .map((e) => e.key)
        .toSet();
  }

  void _drawCellFills(
    Canvas canvas,
    Grid grid,
    Set<Cell>? visibleCells,
    Offset Function(double x, double y) toCanvas,
  ) {
    for (final cell in grid.cells) {
      final isVisible = visibleCells == null || visibleCells.contains(cell);

      Color fillColor;
      if (!isVisible) {
        fillColor = colorScheme.surfaceContainerHighest.withValues(alpha: 0.8);
      } else if (state.playerPath.contains(cell)) {
        fillColor = colorScheme.primaryContainer.withValues(alpha: 0.5);
      } else {
        fillColor = colorScheme.surface;
      }

      final vertices = cell.vertices;
      if (vertices.isEmpty) continue;

      final path = Path()
        ..moveTo(
          toCanvas(vertices[0].x, vertices[0].y).dx,
          toCanvas(vertices[0].x, vertices[0].y).dy,
        );
      for (var i = 1; i < vertices.length; i++) {
        final p = toCanvas(vertices[i].x, vertices[i].y);
        path.lineTo(p.dx, p.dy);
      }
      path.close();

      canvas.drawPath(
        path,
        Paint()..color = fillColor,
      );
    }
  }

  void _drawWalls(
    Canvas canvas,
    Grid grid,
    Set<Cell>? visibleCells,
    Offset Function(double x, double y) toCanvas,
  ) {
    final wallPaint = Paint()
      ..color = colorScheme.onSurface
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final fogWallPaint = Paint()
      ..color = colorScheme.onSurface.withValues(alpha: 0.15)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    for (final cell in grid.cells) {
      final isVisible = visibleCells == null || visibleCells.contains(cell);
      final vertices = cell.vertices;
      if (vertices.isEmpty) continue;

      // Draw each edge of the cell polygon, but skip edges where there's
      // a linked neighbor (open passage).
      final neighbors = cell.neighbors;

      for (var i = 0; i < vertices.length; i++) {
        final v1 = toCanvas(vertices[i].x, vertices[i].y);
        final v2 = toCanvas(
          vertices[(i + 1) % vertices.length].x,
          vertices[(i + 1) % vertices.length].y,
        );

        // Check if this edge is shared with a linked neighbor.
        // We use a heuristic: if the midpoint of this edge is close to the
        // midpoint between this cell and a linked neighbor, it's an open passage.
        final edgeMid = Offset((v1.dx + v2.dx) / 2, (v1.dy + v2.dy) / 2);
        var isPassage = false;

        for (final neighbor in neighbors) {
          if (!cell.isLinked(neighbor)) continue;

          // Find the shared edge by checking if the edge midpoint lies
          // between the two cell centers.
          final nc = toCanvas(neighbor.center.x, neighbor.center.y);
          final cc = toCanvas(cell.center.x, cell.center.y);
          final neighborMid = Offset((nc.dx + cc.dx) / 2, (nc.dy + cc.dy) / 2);

          if ((edgeMid - neighborMid).distance < cellSize * 0.5) {
            isPassage = true;
            break;
          }
        }

        if (!isPassage) {
          canvas.drawLine(v1, v2, isVisible ? wallPaint : fogWallPaint);
        }
      }
    }
  }

  void _drawPlayerPath(
    Canvas canvas,
    Offset Function(double x, double y) toCanvas,
  ) {
    if (state.playerPath.length < 2) return;

    final pathPaint = Paint()
      ..color = colorScheme.primary
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    final first = state.playerPath[0].center;
    var p = toCanvas(first.x, first.y);
    path.moveTo(p.dx, p.dy);

    for (var i = 1; i < state.playerPath.length; i++) {
      final c = state.playerPath[i].center;
      p = toCanvas(c.x, c.y);
      path.lineTo(p.dx, p.dy);
    }

    canvas.drawPath(path, pathPaint);
  }

  void _drawSolution(
    Canvas canvas,
    Offset Function(double x, double y) toCanvas,
  ) {
    final cells = state.solution!.cells;
    if (cells.length < 2) return;

    final paint = Paint()
      ..color = colorScheme.tertiary.withValues(alpha: 0.6)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    final first = cells[0].center;
    var p = toCanvas(first.x, first.y);
    path.moveTo(p.dx, p.dy);

    for (var i = 1; i < cells.length; i++) {
      final c = cells[i].center;
      p = toCanvas(c.x, c.y);
      path.lineTo(p.dx, p.dy);
    }

    // Dashed effect via dashPath would be ideal, but solid line is fine.
    canvas.drawPath(path, paint);
  }

  void _drawBreadcrumbs(
    Canvas canvas,
    Set<Cell>? visibleCells,
    Offset Function(double x, double y) toCanvas,
  ) {
    if (state.breadcrumbs.isEmpty) return;

    final paint = Paint()
      ..color = colorScheme.secondary.withValues(alpha: 0.6);

    for (final cell in state.breadcrumbs) {
      if (visibleCells != null && !visibleCells.contains(cell)) continue;
      final c = cell.center;
      final p = toCanvas(c.x, c.y);
      canvas.drawCircle(p, 3.0, paint);
    }
  }

  void _drawWallMarks(
    Canvas canvas,
    Set<Cell>? visibleCells,
    Offset Function(double x, double y) toCanvas,
  ) {
    if (state.wallMarks.isEmpty) return;

    final paint = Paint()
      ..color = colorScheme.error.withValues(alpha: 0.7)
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    for (final entry in state.wallMarks.entries) {
      final cell = entry.key;
      if (visibleCells != null && !visibleCells.contains(cell)) continue;

      final cc = toCanvas(cell.center.x, cell.center.y);

      for (final neighbor in entry.value) {
        final nc = toCanvas(neighbor.center.x, neighbor.center.y);
        final mid = Offset((cc.dx + nc.dx) / 2, (cc.dy + nc.dy) / 2);

        // Draw an X at the wall.
        const s = 4.0;
        canvas.drawLine(
          Offset(mid.dx - s, mid.dy - s),
          Offset(mid.dx + s, mid.dy + s),
          paint,
        );
        canvas.drawLine(
          Offset(mid.dx + s, mid.dy - s),
          Offset(mid.dx - s, mid.dy + s),
          paint,
        );
      }
    }
  }

  void _drawMarkers(
    Canvas canvas,
    Offset Function(double x, double y) toCanvas,
  ) {
    // Start marker (green circle).
    final sc = state.startCell.center;
    final startPos = toCanvas(sc.x, sc.y);
    canvas.drawCircle(
      startPos,
      cellSize * 0.25,
      Paint()..color = Colors.green.shade600,
    );

    // End marker (red circle).
    final ec = state.endCell.center;
    final endPos = toCanvas(ec.x, ec.y);
    canvas.drawCircle(
      endPos,
      cellSize * 0.25,
      Paint()..color = Colors.red.shade600,
    );
  }

  /// The total canvas size needed to render this maze.
  Size get mazeSize {
    final bounds = _computeBounds(state.grid);
    return Size(
      (bounds.maxX - bounds.minX) * cellSize + cellSize,
      (bounds.maxY - bounds.minY) * cellSize + cellSize,
    );
  }

  @override
  bool shouldRepaint(covariant MazePainter oldDelegate) {
    return oldDelegate.state != state ||
        oldDelegate.cellSize != cellSize ||
        oldDelegate.colorScheme != colorScheme;
  }
}
