import 'dart:math';

import 'package:maze_core/maze_core.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// Generates a PDF document containing maze puzzles and their solutions.
class PdfExportService {
  /// Generate a PDF booklet with [count] mazes using the given [config].
  ///
  /// Each maze gets a puzzle page, and solution pages are appended at the end.
  /// A QR code on each puzzle page encodes the config for in-app play.
  pw.Document generate({
    required MazeConfig config,
    required int count,
    bool includeSolutions = true,
    void Function(int completed)? onProgress,
  }) {
    final pdf = pw.Document(
      title: 'Mazes',
      author: 'Mazes App',
    );

    final mazes = <_GeneratedMaze>[];

    for (var i = 0; i < count; i++) {
      final seed = config.seed != null ? config.seed! + i : Random().nextInt(1 << 32);
      final seededConfig = config.copyWith(seed: seed);

      final rng = Random(seed);
      final grid = _createGrid(seededConfig);
      final generator = _createGenerator(seededConfig.algorithm);
      generator.generate(grid, rng);

      final longest = longestPath(grid.cells.first);
      final solution = solveMaze(longest.start, longest.end);

      mazes.add(_GeneratedMaze(
        index: i + 1,
        config: seededConfig,
        grid: grid,
        startCell: longest.start,
        endCell: longest.end,
        solution: solution,
      ));

      onProgress?.call(i + 1);
    }

    // Puzzle pages.
    for (final maze in mazes) {
      pdf.addPage(_buildMazePage(maze, showSolution: false));
    }

    // Solution pages.
    if (includeSolutions) {
      for (final maze in mazes) {
        pdf.addPage(_buildMazePage(maze, showSolution: true));
      }
    }

    return pdf;
  }

  pw.Page _buildMazePage(_GeneratedMaze maze, {required bool showSolution}) {
    return pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(36),
      build: (context) {
        final title = showSolution
            ? 'Solution #${maze.index}'
            : 'Maze #${maze.index}';
        final subtitle =
            '${maze.config.cellType.name._capitalize()} '
            '${maze.config.rows}x${maze.config.columns} '
            '- ${maze.config.difficulty.name._capitalize()}';

        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      title,
                      style: pw.TextStyle(
                        fontSize: 18,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      subtitle,
                      style: const pw.TextStyle(
                        fontSize: 10,
                        color: PdfColors.grey700,
                      ),
                    ),
                  ],
                ),
                if (!showSolution)
                  pw.BarcodeWidget(
                    barcode: pw.Barcode.qrCode(),
                    data: _encodeQrData(maze.config),
                    width: 60,
                    height: 60,
                  ),
              ],
            ),
            pw.SizedBox(height: 16),
            pw.Expanded(
              child: pw.Center(
                child: _MazeWidget(
                  maze: maze,
                  showSolution: showSolution,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  String _encodeQrData(MazeConfig config) {
    // Compact format for QR: maze://type/rows/cols/difficulty/algo/seed
    final algo = config.algorithm?.name ?? 'auto';
    return 'maze://${config.cellType.name}'
        '/${config.rows}/${config.columns}'
        '/${config.difficulty.name}'
        '/$algo'
        '/${config.seed}';
  }

  Grid _createGrid(MazeConfig config) {
    return switch (config.cellType) {
      CellType.square => SquareGrid(config.rows, config.columns),
      CellType.hexagonal => HexGrid(config.rows, config.columns),
      CellType.triangular => TriangleGrid(config.rows, config.columns),
      CellType.circular => CircularGrid(config.rows),
    };
  }

  MazeGenerator _createGenerator(Algorithm? algorithm) {
    return switch (algorithm) {
      Algorithm.recursiveBacktracker => const RecursiveBacktracker(),
      Algorithm.kruskals => const Kruskals(),
      Algorithm.prims => const Prims(),
      Algorithm.ellers => const Ellers(),
      Algorithm.wilsons => const Wilsons(),
      Algorithm.aldousBroder => const AldousBroder(),
      Algorithm.growingTree => const GrowingTree(),
      Algorithm.huntAndKill => const HuntAndKill(),
      Algorithm.sidewinder => const Sidewinder(),
      Algorithm.binaryTree => const BinaryTree(),
      Algorithm.recursiveDivision => const RecursiveDivision(),
      null => const RecursiveBacktracker(),
    };
  }
}

class _GeneratedMaze {
  const _GeneratedMaze({
    required this.index,
    required this.config,
    required this.grid,
    required this.startCell,
    required this.endCell,
    required this.solution,
  });

  final int index;
  final MazeConfig config;
  final Grid grid;
  final Cell startCell;
  final Cell endCell;
  final MazePath solution;
}

/// Custom PDF widget that draws a maze grid.
class _MazeWidget extends pw.StatelessWidget {
  _MazeWidget({
    required this.maze,
    required this.showSolution,
  });

  final _GeneratedMaze maze;
  final bool showSolution;

  @override
  pw.Widget build(pw.Context context) {
    return pw.CustomPaint(
      size: const PdfPoint(500, 700),
      painter: (canvas, size) => _paint(canvas, size),
    );
  }

  void _paint(PdfGraphics canvas, PdfPoint size) {
    final grid = maze.grid;

    // Compute bounds.
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

    final gridWidth = maxX - minX;
    final gridHeight = maxY - minY;
    if (gridWidth == 0 || gridHeight == 0) return;

    // Fit maze into available space with padding.
    const padding = 10.0;
    final availW = size.x - padding * 2;
    final availH = size.y - padding * 2;
    final scale = min(availW / gridWidth, availH / gridHeight);
    final offsetX = padding + (availW - gridWidth * scale) / 2;
    final offsetY = padding + (availH - gridHeight * scale) / 2;

    // PDF coordinates: y=0 is bottom. Flip y-axis.
    double tx(double x) => (x - minX) * scale + offsetX;
    double ty(double y) => size.y - ((y - minY) * scale + offsetY);

    // Draw solution path if enabled.
    if (showSolution) {
      final cells = maze.solution.cells;
      if (cells.length >= 2) {
        canvas
          ..setStrokeColor(PdfColors.blue200)
          ..setLineWidth(scale * 0.3);
        canvas.moveTo(tx(cells[0].center.x), ty(cells[0].center.y));
        for (var i = 1; i < cells.length; i++) {
          canvas.lineTo(tx(cells[i].center.x), ty(cells[i].center.y));
        }
        canvas.strokePath();
      }
    }

    // Draw walls.
    canvas
      ..setStrokeColor(PdfColors.black)
      ..setLineWidth(1.0)
      ..setLineCap(PdfLineCap.round);

    for (final cell in grid.cells) {
      final vertices = cell.vertices;
      if (vertices.isEmpty) continue;

      for (var i = 0; i < vertices.length; i++) {
        final neighbor = cell.neighborForEdge(i);
        if (neighbor != null && cell.isLinked(neighbor)) continue;

        final v1 = vertices[i];
        final v2 = vertices[(i + 1) % vertices.length];

        canvas
          ..moveTo(tx(v1.x), ty(v1.y))
          ..lineTo(tx(v2.x), ty(v2.y))
          ..strokePath();
      }
    }

    // Draw start marker (green circle).
    final sc = maze.startCell.center;
    final markerRadius = scale * 0.3;
    canvas
      ..setFillColor(PdfColors.green)
      ..drawEllipse(tx(sc.x), ty(sc.y), markerRadius, markerRadius)
      ..fillPath();

    // Draw end marker (red circle).
    final ec = maze.endCell.center;
    canvas
      ..setFillColor(PdfColors.red)
      ..drawEllipse(tx(ec.x), ty(ec.y), markerRadius, markerRadius)
      ..fillPath();
  }
}

extension on String {
  String _capitalize() =>
      isEmpty ? this : this[0].toUpperCase() + substring(1);
}
