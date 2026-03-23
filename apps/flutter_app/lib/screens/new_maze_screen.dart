import 'package:flutter/material.dart';
import 'package:maze_core/maze_core.dart';

import '../services/settings_service.dart';
import '../services/storage_service.dart';
import '../state/game_state.dart';
import 'play_screen.dart';

class NewMazeScreen extends StatefulWidget {
  const NewMazeScreen({
    super.key,
    required this.storage,
    required this.settings,
    required this.gameNotifier,
  });

  final StorageService storage;
  final SettingsService settings;
  final GameNotifier gameNotifier;

  @override
  State<NewMazeScreen> createState() => _NewMazeScreenState();
}

class _NewMazeScreenState extends State<NewMazeScreen> {
  CellType _cellType = CellType.square;
  DifficultyLevel _difficulty = DifficultyLevel.medium;
  Algorithm? _algorithm;

  static const _cellTypeLabels = {
    CellType.square: 'Square',
    CellType.hexagonal: 'Hexagonal',
    CellType.triangular: 'Triangular',
    CellType.circular: 'Circular',
    CellType.concentric: 'Concentric',
    CellType.voronoi: 'Voronoi',
  };

  static const _difficultyLabels = {
    DifficultyLevel.casual: 'Casual',
    DifficultyLevel.easy: 'Easy',
    DifficultyLevel.medium: 'Medium',
    DifficultyLevel.hard: 'Hard',
    DifficultyLevel.expert: 'Expert',
    DifficultyLevel.extreme: 'Extreme',
  };

  static const _algorithmLabels = {
    Algorithm.recursiveBacktracker: 'Recursive Backtracker',
    Algorithm.kruskals: "Kruskal's",
    Algorithm.prims: "Prim's",
    Algorithm.ellers: "Eller's",
    Algorithm.wilsons: "Wilson's",
    Algorithm.aldousBroder: 'Aldous-Broder',
    Algorithm.growingTree: 'Growing Tree',
    Algorithm.huntAndKill: 'Hunt and Kill',
    Algorithm.sidewinder: 'Sidewinder',
    Algorithm.binaryTree: 'Binary Tree',
    Algorithm.recursiveDivision: 'Recursive Division',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Maze'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Cell Type',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: CellType.values.map((type) {
              return ChoiceChip(
                label: Text(_cellTypeLabels[type]!),
                selected: _cellType == type,
                onSelected: (_) => setState(() => _cellType = type),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          Text(
            'Difficulty',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: DifficultyLevel.values.map((level) {
              return ChoiceChip(
                label: Text(_difficultyLabels[level]!),
                selected: _difficulty == level,
                onSelected: (_) => setState(() => _difficulty = level),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          Text(
            'Algorithm',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ChoiceChip(
                label: const Text('Auto'),
                selected: _algorithm == null,
                onSelected: (_) => setState(() => _algorithm = null),
              ),
              ...Algorithm.values.map((algo) {
                return ChoiceChip(
                  label: Text(_algorithmLabels[algo]!),
                  selected: _algorithm == algo,
                  onSelected: (_) => setState(() => _algorithm = algo),
                );
              }),
            ],
          ),
          const SizedBox(height: 32),

          FilledButton.icon(
            onPressed: _generate,
            icon: const Icon(Icons.play_arrow),
            label: const Text('Generate & Play'),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ],
      ),
    );
  }

  void _generate() {
    const calc = DifficultyCalculator();
    final config = calc.configFor(
      level: _difficulty,
      cellType: _cellType,
      algorithm: _algorithm,
    );

    widget.gameNotifier.newGame(config);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PlayScreen(
          storage: widget.storage,
          gameNotifier: widget.gameNotifier,
        ),
      ),
    );
  }
}
