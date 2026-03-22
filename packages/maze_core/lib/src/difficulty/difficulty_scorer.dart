import '../models/enums.dart';
import '../solver/maze_analyzer.dart';

/// Scores a generated maze's actual difficulty from its metrics.
///
/// This allows the app to verify that a generated maze matches the target
/// difficulty, or to display the actual difficulty to the player.
class DifficultyScorer {
  const DifficultyScorer();

  /// Scores the [analysis] and returns the closest difficulty level.
  DifficultyLevel score(MazeAnalysis analysis) {
    // Compute a composite difficulty score from 0.0 (easiest) to 1.0 (hardest).
    final composite = _compositeScore(analysis);

    if (composite < 0.12) return DifficultyLevel.casual;
    if (composite < 0.25) return DifficultyLevel.easy;
    if (composite < 0.42) return DifficultyLevel.medium;
    if (composite < 0.60) return DifficultyLevel.hard;
    if (composite < 0.80) return DifficultyLevel.expert;
    return DifficultyLevel.extreme;
  }

  /// Returns a raw difficulty score from 0.0 to 1.0.
  double rawScore(MazeAnalysis analysis) => _compositeScore(analysis);

  double _compositeScore(MazeAnalysis analysis) {
    // Factor 1: Solution length relative to total cells.
    // Higher ratio = longer solution path = harder.
    final solutionFactor = (analysis.solutionRatio).clamp(0.0, 1.0);

    // Factor 2: Dead-end density. More dead ends = more wrong turns.
    final deadEndFactor = (analysis.deadEndRatio * 2).clamp(0.0, 1.0);

    // Factor 3: Decision points relative to total cells.
    // More decision points = more choices = harder.
    final decisionFactor = analysis.totalCells == 0
        ? 0.0
        : (analysis.decisionPointCount / analysis.totalCells * 3)
            .clamp(0.0, 1.0);

    // Factor 4: Grid size. Larger mazes are inherently harder.
    final sizeFactor = (analysis.totalCells / 1000).clamp(0.0, 1.0);

    // Weighted composite.
    return solutionFactor * 0.30 +
        deadEndFactor * 0.20 +
        decisionFactor * 0.20 +
        sizeFactor * 0.30;
  }
}
