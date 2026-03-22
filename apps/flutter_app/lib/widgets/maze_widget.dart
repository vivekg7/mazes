import 'package:flutter/material.dart';
import 'package:maze_core/maze_core.dart';

import 'maze_painter.dart';

/// Interactive maze display widget.
///
/// Wraps [MazePainter] with zoom/pan via [InteractiveViewer] and handles
/// tap/drag gestures for path drawing.
class MazeWidget extends StatefulWidget {
  const MazeWidget({
    super.key,
    required this.renderState,
    this.cellSize = 30.0,
    this.onCellTap,
    this.onCellDrag,
  });

  final MazeRenderState renderState;
  final double cellSize;

  /// Called when a cell is tapped.
  final ValueChanged<Cell>? onCellTap;

  /// Called when the user drags over a cell.
  final ValueChanged<Cell>? onCellDrag;

  @override
  State<MazeWidget> createState() => _MazeWidgetState();
}

class _MazeWidgetState extends State<MazeWidget> {
  final _transformationController = TransformationController();

  // Cached for hit testing.
  late _MazeLayout _layout;

  @override
  void initState() {
    super.initState();
    _layout = _MazeLayout(widget.renderState.grid, widget.cellSize);
  }

  @override
  void didUpdateWidget(MazeWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.renderState.grid != widget.renderState.grid ||
        oldWidget.cellSize != widget.cellSize) {
      _layout = _MazeLayout(widget.renderState.grid, widget.cellSize);
    }
  }

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final painter = MazePainter(
      state: widget.renderState,
      colorScheme: colorScheme,
      cellSize: widget.cellSize,
    );
    final mazeSize = painter.mazeSize;

    return InteractiveViewer(
      transformationController: _transformationController,
      minScale: 0.5,
      maxScale: 4.0,
      constrained: false,
      boundaryMargin: const EdgeInsets.all(100),
      child: GestureDetector(
        onTapUp: (details) => _handleTap(details.localPosition),
        onPanUpdate: (details) => _handleDrag(details.localPosition),
        child: CustomPaint(
          painter: painter,
          size: mazeSize,
        ),
      ),
    );
  }

  void _handleTap(Offset position) {
    if (widget.onCellTap == null) return;
    final cell = _layout.cellAtPosition(position);
    if (cell != null) {
      widget.onCellTap!(cell);
    }
  }

  void _handleDrag(Offset position) {
    if (widget.onCellDrag == null) return;
    final cell = _layout.cellAtPosition(position);
    if (cell != null) {
      widget.onCellDrag!(cell);
    }
  }
}

/// Precomputed layout data for hit testing (finding which cell a point is in).
class _MazeLayout {
  _MazeLayout(this.grid, this.cellSize) {
    _computeBounds();
    _buildCellCenters();
  }

  final Grid grid;
  final double cellSize;

  double _minX = 0;
  double _minY = 0;
  late List<(Cell, Offset)> _cellCenters;

  void _computeBounds() {
    var minX = double.infinity;
    var minY = double.infinity;

    for (final cell in grid.cells) {
      for (final v in cell.vertices) {
        if (v.x < minX) minX = v.x;
        if (v.y < minY) minY = v.y;
      }
    }
    _minX = minX;
    _minY = minY;
  }

  void _buildCellCenters() {
    _cellCenters = grid.cells.map((cell) {
      final c = cell.center;
      final offset = Offset(
        (c.x - _minX) * cellSize + cellSize / 2,
        (c.y - _minY) * cellSize + cellSize / 2,
      );
      return (cell, offset);
    }).toList();
  }

  /// Finds the cell at a canvas position, or null if no cell is close enough.
  Cell? cellAtPosition(Offset position) {
    Cell? closest;
    var closestDist = double.infinity;

    for (final (cell, center) in _cellCenters) {
      final dist = (position - center).distance;
      if (dist < closestDist && dist < cellSize * 0.7) {
        closestDist = dist;
        closest = cell;
      }
    }

    return closest;
  }
}
