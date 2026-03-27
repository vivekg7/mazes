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
  bool _generating = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Export PDF')),
      body: _generating
          ? const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Generating mazes...'),
                ],
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  'Generate a printable PDF booklet with mazes and solutions.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
                const SizedBox(height: 24),

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
                Text('Number of Mazes',
                    style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 8),
                Row(
                  children: [
                    IconButton(
                      onPressed:
                          _count > 1 ? () => setState(() => _count--) : null,
                      icon: const Icon(Icons.remove),
                    ),
                    SizedBox(
                      width: 48,
                      child: Text(
                        '$_count',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    IconButton(
                      onPressed:
                          _count < 50 ? () => setState(() => _count++) : null,
                      icon: const Icon(Icons.add),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Slider(
                        value: _count.toDouble(),
                        min: 1,
                        max: 50,
                        divisions: 49,
                        onChanged: (v) => setState(() => _count = v.round()),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                FilledButton.icon(
                  onPressed: _generate,
                  icon: const Icon(Icons.picture_as_pdf),
                  label: const Text('Generate & Share PDF'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ],
            ),
    );
  }

  Future<void> _generate() async {
    setState(() => _generating = true);

    try {
      const calc = DifficultyCalculator();
      final config = calc.configFor(
        level: _difficulty,
        cellType: _cellType,
        algorithm: _algorithm,
      );

      final service = PdfExportService();
      final doc = service.generate(config: config, count: _count);

      final bytes = await doc.save();

      if (!mounted) return;

      await Printing.sharePdf(
        bytes: bytes,
        filename:
            'mazes_${_cellType.name}_${_difficulty.name}_x$_count.pdf',
      );
    } finally {
      if (mounted) setState(() => _generating = false);
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

extension on String {
  String _capitalize() =>
      isEmpty ? this : this[0].toUpperCase() + substring(1);
}
