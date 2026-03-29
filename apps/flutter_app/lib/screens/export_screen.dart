import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:maze_core/maze_core.dart';
import 'package:printing/printing.dart';

import '../services/pdf_export_service.dart';

class ExportScreen extends StatefulWidget {
  const ExportScreen({super.key});

  @override
  State<ExportScreen> createState() => _ExportScreenState();
}

class _ExportScreenState extends State<ExportScreen> {
  CellType _cellType = CellType.square;
  DifficultyLevel _difficulty = DifficultyLevel.medium;
  Algorithm? _algorithm;
  int _count = 5;
  bool _includeSolutions = true;
  bool _generating = false;
  int _generatedCount = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Export PDF')),
      body: _configView(),
    );
  }

  Widget _configView() {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Generate Mazes',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w300,
                letterSpacing: 2,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Configure and export to PDF',
              style:
                  TextStyle(fontSize: 14, color: colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 32),

            // Cell type.
            Text('Cell Type',
                style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: CellType.values.map((type) {
                return ChoiceChip(
                  label: Text(type.name._capitalize()),
                  selected: _cellType == type,
                  onSelected: (_) => setState(() => _cellType = type),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // Difficulty.
            Text('Difficulty',
                style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: DifficultyLevel.values.map((level) {
                return ChoiceChip(
                  label: Text(level.name._capitalize()),
                  selected: _difficulty == level,
                  onSelected: (_) => setState(() => _difficulty = level),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // Algorithm.
            Text('Algorithm',
                style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                ChoiceChip(
                  label: const Text('Auto'),
                  selected: _algorithm == null,
                  onSelected: (_) => setState(() => _algorithm = null),
                ),
                ...Algorithm.values.map((alg) {
                  return ChoiceChip(
                    label: Text(_algorithmLabel(alg)),
                    selected: _algorithm == alg,
                    onSelected: (_) => setState(() => _algorithm = alg),
                  );
                }),
              ],
            ),
            const SizedBox(height: 20),

            // Count.
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Mazes', style: TextStyle(fontSize: 16)),
                const SizedBox(width: 12),
                IconButton.filled(
                  icon: const Icon(Icons.remove, size: 18),
                  onPressed:
                      _count > 1 ? () => setState(() => _count--) : null,
                  style: IconButton.styleFrom(
                    minimumSize: const Size(36, 36),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
                SizedBox(
                  width: 48,
                  child: Text(
                    '$_count',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      fontFeatures: [FontFeature.tabularFigures()],
                    ),
                  ),
                ),
                IconButton.filled(
                  icon: const Icon(Icons.add, size: 18),
                  onPressed:
                      _count < 50 ? () => setState(() => _count++) : null,
                  style: IconButton.styleFrom(
                    minimumSize: const Size(36, 36),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Solutions toggle.
            SizedBox(
              width: 220,
              child: SwitchListTile(
                title: const Text('Include solutions',
                    style: TextStyle(fontSize: 14)),
                value: _includeSolutions,
                onChanged: (v) => setState(() => _includeSolutions = v),
                dense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const SizedBox(height: 32),

            if (_generating)
              Column(
                children: [
                  SizedBox(
                    width: 48,
                    height: 48,
                    child: CircularProgressIndicator(
                      value: _count > 0 ? _generatedCount / _count : null,
                      strokeWidth: 3,
                      backgroundColor: colorScheme.surfaceContainerHighest,
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _generatedCount < _count
                        ? 'Generating maze $_generatedCount of $_count…'
                        : 'Building PDF…',
                    style: TextStyle(
                        fontSize: 14, color: colorScheme.onSurfaceVariant),
                  ),
                ],
              )
            else
              SizedBox(
                width: 220,
                child: FilledButton.icon(
                  onPressed: _generate,
                  icon: const Icon(Icons.picture_as_pdf),
                  label: const Text('Generate PDF'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String get _pdfFileName {
    final parts = <String>[
      'mazes',
      _cellType.name,
      _difficulty.name,
      '${_count}x',
    ];
    if (_includeSolutions) parts.add('solutions');
    return '${parts.join('_')}.pdf';
  }

  Future<void> _generate() async {
    setState(() {
      _generating = true;
      _generatedCount = 0;
    });

    try {
      const calc = DifficultyCalculator();
      final config = calc.configFor(
        level: _difficulty,
        cellType: _cellType,
        algorithm: _algorithm,
      );

      final service = PdfExportService();
      final doc = service.generate(
        config: config,
        count: _count,
        includeSolutions: _includeSolutions,
        onProgress: (completed) {
          if (mounted) setState(() => _generatedCount = completed);
        },
      );

      final bytes = await doc.save();

      if (!mounted) return;
      setState(() => _generating = false);

      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => _PdfPreviewScreen(
            pdfBytes: bytes,
            fileName: _pdfFileName,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _generating = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Generation failed: $e')),
      );
    }
  }

  String _algorithmLabel(Algorithm alg) {
    return switch (alg) {
      Algorithm.recursiveBacktracker => 'Backtracker',
      Algorithm.kruskals => "Kruskal's",
      Algorithm.prims => "Prim's",
      Algorithm.ellers => "Eller's",
      Algorithm.wilsons => "Wilson's",
      Algorithm.aldousBroder => 'Aldous-Broder',
      Algorithm.growingTree => 'Growing Tree',
      Algorithm.huntAndKill => 'Hunt & Kill',
      Algorithm.sidewinder => 'Sidewinder',
      Algorithm.binaryTree => 'Binary Tree',
      Algorithm.recursiveDivision => 'Rec. Division',
    };
  }
}

class _PdfPreviewScreen extends StatelessWidget {
  final Uint8List pdfBytes;
  final String fileName;

  const _PdfPreviewScreen({
    required this.pdfBytes,
    required this.fileName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PDF Preview'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save_alt),
            onPressed: () => _savePdf(context),
            tooltip: 'Save PDF',
          ),
          IconButton(
            icon: const Icon(Icons.print),
            onPressed: () => _printPdf(context),
            tooltip: 'Print',
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => _sharePdf(context),
            tooltip: 'Share',
          ),
        ],
      ),
      body: PdfPreview(
        build: (_) => pdfBytes,
        pdfFileName: fileName,
        allowPrinting: false,
        allowSharing: false,
        canChangePageFormat: false,
        canChangeOrientation: false,
        useActions: false,
      ),
    );
  }

  Future<void> _savePdf(BuildContext context) async {
    try {
      final result = await FilePicker.platform.saveFile(
        dialogTitle: 'Save Mazes PDF',
        fileName: fileName,
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        bytes: pdfBytes,
      );
      if (result != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('PDF saved.')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Save failed: $e')),
        );
      }
    }
  }

  Future<void> _printPdf(BuildContext context) async {
    try {
      await Printing.layoutPdf(onLayout: (_) async => pdfBytes);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Print failed: $e')),
        );
      }
    }
  }

  Future<void> _sharePdf(BuildContext context) async {
    try {
      await Printing.sharePdf(bytes: pdfBytes, filename: fileName);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Share failed: $e')),
        );
      }
    }
  }
}

extension on String {
  String _capitalize() =>
      isEmpty ? this : this[0].toUpperCase() + substring(1);
}
