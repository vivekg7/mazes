import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              Icon(
                Icons.grid_4x4,
                size: 80,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                'Mazes',
                style: theme.textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Challenge your mind',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              FilledButton.icon(
                onPressed: () => _startQuickPlay(context),
                icon: const Icon(Icons.play_arrow),
                label: const Text('Quick Play'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () => _startCustomPlay(context),
                icon: const Icon(Icons.tune),
                label: const Text('Custom Maze'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }

  void _startQuickPlay(BuildContext context) {
    // TODO: Navigate to play screen with a default config.
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Play screen coming soon')),
    );
  }

  void _startCustomPlay(BuildContext context) {
    // TODO: Navigate to maze configuration screen.
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Custom maze coming soon')),
    );
  }
}
