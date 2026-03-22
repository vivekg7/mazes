import '../models/enums.dart';
import 'shape_library.dart';

/// Registers all built-in shapes with the [ShapeLibrary].
///
/// Call this once at app startup before using shape-masked mazes.
void registerBuiltinShapes() {
  final lib = ShapeLibrary.instance;

  // ── Animals ──────────────────────────────────────────────────────────────
  _registerAnimals(lib);

  // ── Abstract shapes ─────────────────────────────────────────────────────
  _registerAbstracts(lib);

  // ── Letters A–Z ─────────────────────────────────────────────────────────
  _registerLetters(lib);

  // ── Digits 0–9 ──────────────────────────────────────────────────────────
  _registerDigits(lib);
}

void _registerAnimals(ShapeLibrary lib) {
  // Cat silhouette (simplified).
  lib.registerPolygon(PuzzleShape.animal, 'cat', [
    (x: 10, y: 90), (x: 5, y: 60), (x: 0, y: 30), (x: 10, y: 0),
    (x: 20, y: 20), (x: 30, y: 10), (x: 40, y: 0), (x: 50, y: 5),
    (x: 60, y: 0), (x: 70, y: 10), (x: 80, y: 20), (x: 90, y: 0),
    (x: 100, y: 30), (x: 95, y: 60), (x: 90, y: 90), (x: 75, y: 100),
    (x: 60, y: 95), (x: 50, y: 100), (x: 40, y: 95), (x: 25, y: 100),
  ]);

  // Dog silhouette.
  lib.registerPolygon(PuzzleShape.animal, 'dog', [
    (x: 5, y: 100), (x: 5, y: 60), (x: 0, y: 50), (x: 0, y: 30),
    (x: 10, y: 20), (x: 15, y: 10), (x: 25, y: 5), (x: 35, y: 0),
    (x: 45, y: 5), (x: 50, y: 15), (x: 55, y: 10), (x: 65, y: 10),
    (x: 75, y: 15), (x: 85, y: 25), (x: 90, y: 40), (x: 95, y: 55),
    (x: 100, y: 70), (x: 95, y: 85), (x: 90, y: 100), (x: 75, y: 100),
    (x: 70, y: 80), (x: 65, y: 100), (x: 40, y: 100), (x: 35, y: 80),
    (x: 30, y: 100), (x: 15, y: 100),
  ]);

  // Bird silhouette.
  lib.registerPolygon(PuzzleShape.animal, 'bird', [
    (x: 0, y: 50), (x: 10, y: 40), (x: 20, y: 35), (x: 30, y: 25),
    (x: 40, y: 20), (x: 50, y: 10), (x: 60, y: 0), (x: 65, y: 5),
    (x: 60, y: 15), (x: 70, y: 10), (x: 80, y: 15), (x: 90, y: 25),
    (x: 100, y: 35), (x: 95, y: 40), (x: 85, y: 35), (x: 90, y: 45),
    (x: 85, y: 55), (x: 75, y: 60), (x: 65, y: 55), (x: 55, y: 50),
    (x: 45, y: 55), (x: 35, y: 60), (x: 25, y: 55), (x: 15, y: 50),
    (x: 10, y: 55),
  ]);

  // Fish silhouette.
  lib.registerPolygon(PuzzleShape.animal, 'fish', [
    (x: 0, y: 50), (x: 10, y: 30), (x: 20, y: 20), (x: 35, y: 10),
    (x: 50, y: 5), (x: 65, y: 10), (x: 75, y: 20), (x: 80, y: 30),
    (x: 85, y: 20), (x: 95, y: 10), (x: 100, y: 0), (x: 100, y: 100),
    (x: 95, y: 90), (x: 85, y: 80), (x: 80, y: 70), (x: 75, y: 80),
    (x: 65, y: 90), (x: 50, y: 95), (x: 35, y: 90), (x: 20, y: 80),
    (x: 10, y: 70),
  ]);

  // Butterfly silhouette.
  lib.registerPolygon(PuzzleShape.animal, 'butterfly', [
    (x: 50, y: 0), (x: 45, y: 10), (x: 30, y: 5), (x: 15, y: 0),
    (x: 0, y: 10), (x: 5, y: 30), (x: 10, y: 40), (x: 20, y: 45),
    (x: 40, y: 48), (x: 45, y: 50), (x: 40, y: 52), (x: 20, y: 55),
    (x: 10, y: 60), (x: 5, y: 70), (x: 0, y: 90), (x: 15, y: 100),
    (x: 30, y: 95), (x: 45, y: 90), (x: 50, y: 100), (x: 55, y: 90),
    (x: 70, y: 95), (x: 85, y: 100), (x: 100, y: 90), (x: 95, y: 70),
    (x: 90, y: 60), (x: 80, y: 55), (x: 60, y: 52), (x: 55, y: 50),
    (x: 60, y: 48), (x: 80, y: 45), (x: 90, y: 40), (x: 95, y: 30),
    (x: 100, y: 10), (x: 85, y: 0), (x: 70, y: 5), (x: 55, y: 10),
  ]);
}

void _registerAbstracts(ShapeLibrary lib) {
  // Star (5-pointed).
  lib.registerPolygon(PuzzleShape.abstract_, 'star', [
    (x: 50, y: 0), (x: 61, y: 35), (x: 98, y: 35), (x: 68, y: 57),
    (x: 79, y: 91), (x: 50, y: 70), (x: 21, y: 91), (x: 32, y: 57),
    (x: 2, y: 35), (x: 39, y: 35),
  ]);

  // Heart.
  lib.registerPolygon(PuzzleShape.abstract_, 'heart', [
    (x: 50, y: 100), (x: 0, y: 55), (x: 0, y: 30), (x: 5, y: 15),
    (x: 15, y: 5), (x: 25, y: 0), (x: 35, y: 0), (x: 45, y: 10),
    (x: 50, y: 20), (x: 55, y: 10), (x: 65, y: 0), (x: 75, y: 0),
    (x: 85, y: 5), (x: 95, y: 15), (x: 100, y: 30), (x: 100, y: 55),
  ]);

  // Arrow (pointing right).
  lib.registerPolygon(PuzzleShape.abstract_, 'arrow', [
    (x: 0, y: 35), (x: 60, y: 35), (x: 60, y: 10), (x: 100, y: 50),
    (x: 60, y: 90), (x: 60, y: 65), (x: 0, y: 65),
  ]);

  // Diamond.
  lib.registerPolygon(PuzzleShape.abstract_, 'diamond', [
    (x: 50, y: 0), (x: 100, y: 50), (x: 50, y: 100), (x: 0, y: 50),
  ]);
}

void _registerLetters(ShapeLibrary lib) {
  // Simplified block letter outlines. Each letter is defined as a polygon
  // in a 100x100 coordinate space.
  const category = PuzzleShape.letter;

  lib.registerPolygon(category, 'A', [
    (x: 50, y: 0), (x: 100, y: 100), (x: 80, y: 100), (x: 70, y: 70),
    (x: 30, y: 70), (x: 20, y: 100), (x: 0, y: 100),
  ]);

  lib.registerPolygon(category, 'B', [
    (x: 0, y: 0), (x: 70, y: 0), (x: 90, y: 10), (x: 95, y: 25),
    (x: 85, y: 45), (x: 70, y: 50), (x: 90, y: 55), (x: 100, y: 70),
    (x: 95, y: 90), (x: 75, y: 100), (x: 0, y: 100), (x: 0, y: 50),
    (x: 25, y: 50), (x: 25, y: 0),
  ]);

  lib.registerPolygon(category, 'C', [
    (x: 100, y: 20), (x: 80, y: 5), (x: 55, y: 0), (x: 30, y: 0),
    (x: 10, y: 10), (x: 0, y: 30), (x: 0, y: 70), (x: 10, y: 90),
    (x: 30, y: 100), (x: 55, y: 100), (x: 80, y: 95), (x: 100, y: 80),
    (x: 80, y: 80), (x: 65, y: 85), (x: 45, y: 80), (x: 30, y: 70),
    (x: 25, y: 50), (x: 30, y: 30), (x: 45, y: 20), (x: 65, y: 15),
    (x: 80, y: 20),
  ]);

  lib.registerPolygon(category, 'D', [
    (x: 0, y: 0), (x: 55, y: 0), (x: 80, y: 10), (x: 95, y: 30),
    (x: 100, y: 50), (x: 95, y: 70), (x: 80, y: 90), (x: 55, y: 100),
    (x: 0, y: 100),
  ]);

  lib.registerPolygon(category, 'E', [
    (x: 0, y: 0), (x: 100, y: 0), (x: 100, y: 20), (x: 25, y: 20),
    (x: 25, y: 45), (x: 80, y: 45), (x: 80, y: 55), (x: 25, y: 55),
    (x: 25, y: 80), (x: 100, y: 80), (x: 100, y: 100), (x: 0, y: 100),
  ]);

  lib.registerPolygon(category, 'F', [
    (x: 0, y: 0), (x: 100, y: 0), (x: 100, y: 20), (x: 25, y: 20),
    (x: 25, y: 45), (x: 80, y: 45), (x: 80, y: 55), (x: 25, y: 55),
    (x: 25, y: 100), (x: 0, y: 100),
  ]);

  lib.registerPolygon(category, 'H', [
    (x: 0, y: 0), (x: 25, y: 0), (x: 25, y: 45), (x: 75, y: 45),
    (x: 75, y: 0), (x: 100, y: 0), (x: 100, y: 100), (x: 75, y: 100),
    (x: 75, y: 55), (x: 25, y: 55), (x: 25, y: 100), (x: 0, y: 100),
  ]);

  lib.registerPolygon(category, 'I', [
    (x: 20, y: 0), (x: 80, y: 0), (x: 80, y: 15), (x: 60, y: 15),
    (x: 60, y: 85), (x: 80, y: 85), (x: 80, y: 100), (x: 20, y: 100),
    (x: 20, y: 85), (x: 40, y: 85), (x: 40, y: 15), (x: 20, y: 15),
  ]);

  lib.registerPolygon(category, 'L', [
    (x: 0, y: 0), (x: 25, y: 0), (x: 25, y: 80), (x: 100, y: 80),
    (x: 100, y: 100), (x: 0, y: 100),
  ]);

  lib.registerPolygon(category, 'M', [
    (x: 0, y: 100), (x: 0, y: 0), (x: 20, y: 0), (x: 50, y: 40),
    (x: 80, y: 0), (x: 100, y: 0), (x: 100, y: 100), (x: 80, y: 100),
    (x: 80, y: 40), (x: 50, y: 75), (x: 20, y: 40), (x: 20, y: 100),
  ]);

  lib.registerPolygon(category, 'N', [
    (x: 0, y: 100), (x: 0, y: 0), (x: 20, y: 0), (x: 80, y: 70),
    (x: 80, y: 0), (x: 100, y: 0), (x: 100, y: 100), (x: 80, y: 100),
    (x: 20, y: 30), (x: 20, y: 100),
  ]);

  lib.registerPolygon(category, 'O', [
    (x: 30, y: 0), (x: 70, y: 0), (x: 90, y: 15), (x: 100, y: 40),
    (x: 100, y: 60), (x: 90, y: 85), (x: 70, y: 100), (x: 30, y: 100),
    (x: 10, y: 85), (x: 0, y: 60), (x: 0, y: 40), (x: 10, y: 15),
  ]);

  lib.registerPolygon(category, 'P', [
    (x: 0, y: 0), (x: 70, y: 0), (x: 90, y: 10), (x: 100, y: 25),
    (x: 100, y: 40), (x: 90, y: 50), (x: 70, y: 55), (x: 25, y: 55),
    (x: 25, y: 100), (x: 0, y: 100),
  ]);

  lib.registerPolygon(category, 'S', [
    (x: 100, y: 15), (x: 80, y: 5), (x: 55, y: 0), (x: 25, y: 0),
    (x: 5, y: 10), (x: 0, y: 25), (x: 5, y: 40), (x: 20, y: 48),
    (x: 55, y: 52), (x: 80, y: 58), (x: 95, y: 65), (x: 100, y: 80),
    (x: 90, y: 95), (x: 70, y: 100), (x: 35, y: 100), (x: 10, y: 90),
    (x: 0, y: 80), (x: 20, y: 80), (x: 40, y: 85), (x: 65, y: 85),
    (x: 80, y: 78), (x: 75, y: 68), (x: 55, y: 62), (x: 25, y: 55),
    (x: 5, y: 48), (x: 0, y: 35), (x: 5, y: 20), (x: 25, y: 12),
    (x: 50, y: 12), (x: 75, y: 15),
  ]);

  lib.registerPolygon(category, 'T', [
    (x: 0, y: 0), (x: 100, y: 0), (x: 100, y: 20), (x: 60, y: 20),
    (x: 60, y: 100), (x: 40, y: 100), (x: 40, y: 20), (x: 0, y: 20),
  ]);

  lib.registerPolygon(category, 'V', [
    (x: 0, y: 0), (x: 20, y: 0), (x: 50, y: 80), (x: 80, y: 0),
    (x: 100, y: 0), (x: 60, y: 100), (x: 40, y: 100),
  ]);

  lib.registerPolygon(category, 'W', [
    (x: 0, y: 0), (x: 15, y: 0), (x: 30, y: 65), (x: 45, y: 20),
    (x: 55, y: 20), (x: 70, y: 65), (x: 85, y: 0), (x: 100, y: 0),
    (x: 80, y: 100), (x: 65, y: 100), (x: 50, y: 55), (x: 35, y: 100),
    (x: 20, y: 100),
  ]);

  lib.registerPolygon(category, 'X', [
    (x: 0, y: 0), (x: 20, y: 0), (x: 50, y: 40), (x: 80, y: 0),
    (x: 100, y: 0), (x: 62, y: 50), (x: 100, y: 100), (x: 80, y: 100),
    (x: 50, y: 60), (x: 20, y: 100), (x: 0, y: 100), (x: 38, y: 50),
  ]);

  lib.registerPolygon(category, 'Y', [
    (x: 0, y: 0), (x: 20, y: 0), (x: 50, y: 45), (x: 80, y: 0),
    (x: 100, y: 0), (x: 60, y: 55), (x: 60, y: 100), (x: 40, y: 100),
    (x: 40, y: 55),
  ]);

  lib.registerPolygon(category, 'Z', [
    (x: 0, y: 0), (x: 100, y: 0), (x: 100, y: 15), (x: 25, y: 80),
    (x: 100, y: 80), (x: 100, y: 100), (x: 0, y: 100), (x: 0, y: 85),
    (x: 75, y: 20), (x: 0, y: 20),
  ]);
}

void _registerDigits(ShapeLibrary lib) {
  const category = PuzzleShape.number;

  lib.registerPolygon(category, '0', [
    (x: 30, y: 0), (x: 70, y: 0), (x: 90, y: 15), (x: 100, y: 40),
    (x: 100, y: 60), (x: 90, y: 85), (x: 70, y: 100), (x: 30, y: 100),
    (x: 10, y: 85), (x: 0, y: 60), (x: 0, y: 40), (x: 10, y: 15),
  ]);

  lib.registerPolygon(category, '1', [
    (x: 25, y: 15), (x: 45, y: 0), (x: 60, y: 0), (x: 60, y: 80),
    (x: 85, y: 80), (x: 85, y: 100), (x: 15, y: 100), (x: 15, y: 80),
    (x: 40, y: 80), (x: 40, y: 25), (x: 25, y: 30),
  ]);

  lib.registerPolygon(category, '2', [
    (x: 5, y: 20), (x: 15, y: 5), (x: 40, y: 0), (x: 70, y: 0),
    (x: 90, y: 10), (x: 100, y: 30), (x: 95, y: 50), (x: 75, y: 65),
    (x: 40, y: 80), (x: 100, y: 80), (x: 100, y: 100), (x: 0, y: 100),
    (x: 0, y: 85), (x: 70, y: 55), (x: 80, y: 40), (x: 75, y: 20),
    (x: 55, y: 15), (x: 30, y: 18),
  ]);

  lib.registerPolygon(category, '3', [
    (x: 5, y: 15), (x: 25, y: 5), (x: 50, y: 0), (x: 75, y: 0),
    (x: 95, y: 12), (x: 100, y: 30), (x: 90, y: 45), (x: 70, y: 48),
    (x: 90, y: 55), (x: 100, y: 70), (x: 95, y: 90), (x: 75, y: 100),
    (x: 45, y: 100), (x: 20, y: 95), (x: 5, y: 85), (x: 20, y: 82),
    (x: 45, y: 85), (x: 70, y: 80), (x: 78, y: 68), (x: 70, y: 58),
    (x: 50, y: 55), (x: 50, y: 45), (x: 70, y: 42), (x: 78, y: 30),
    (x: 70, y: 18), (x: 45, y: 15), (x: 20, y: 18),
  ]);

  lib.registerPolygon(category, '4', [
    (x: 60, y: 0), (x: 80, y: 0), (x: 80, y: 55), (x: 100, y: 55),
    (x: 100, y: 70), (x: 80, y: 70), (x: 80, y: 100), (x: 60, y: 100),
    (x: 60, y: 70), (x: 0, y: 70), (x: 0, y: 55),
  ]);

  lib.registerPolygon(category, '5', [
    (x: 100, y: 0), (x: 0, y: 0), (x: 0, y: 50), (x: 60, y: 45),
    (x: 85, y: 55), (x: 100, y: 70), (x: 100, y: 85), (x: 90, y: 95),
    (x: 65, y: 100), (x: 35, y: 100), (x: 10, y: 92), (x: 0, y: 80),
    (x: 15, y: 80), (x: 35, y: 85), (x: 60, y: 85), (x: 80, y: 78),
    (x: 80, y: 65), (x: 60, y: 58), (x: 0, y: 60), (x: 0, y: 15),
    (x: 100, y: 15),
  ]);

  lib.registerPolygon(category, '6', [
    (x: 80, y: 5), (x: 55, y: 0), (x: 30, y: 0), (x: 10, y: 15),
    (x: 0, y: 40), (x: 0, y: 75), (x: 10, y: 90), (x: 30, y: 100),
    (x: 60, y: 100), (x: 85, y: 90), (x: 100, y: 70), (x: 95, y: 55),
    (x: 75, y: 45), (x: 50, y: 45), (x: 25, y: 55), (x: 20, y: 40),
    (x: 30, y: 20), (x: 50, y: 12),
  ]);

  lib.registerPolygon(category, '7', [
    (x: 0, y: 0), (x: 100, y: 0), (x: 100, y: 15), (x: 45, y: 100),
    (x: 25, y: 100), (x: 80, y: 15), (x: 0, y: 15),
  ]);

  lib.registerPolygon(category, '8', [
    (x: 30, y: 0), (x: 70, y: 0), (x: 90, y: 10), (x: 100, y: 25),
    (x: 95, y: 40), (x: 80, y: 48), (x: 95, y: 58), (x: 100, y: 75),
    (x: 90, y: 92), (x: 70, y: 100), (x: 30, y: 100), (x: 10, y: 92),
    (x: 0, y: 75), (x: 5, y: 58), (x: 20, y: 48), (x: 5, y: 40),
    (x: 0, y: 25), (x: 10, y: 10),
  ]);

  lib.registerPolygon(category, '9', [
    (x: 20, y: 95), (x: 45, y: 100), (x: 70, y: 100), (x: 90, y: 85),
    (x: 100, y: 60), (x: 100, y: 25), (x: 90, y: 10), (x: 70, y: 0),
    (x: 40, y: 0), (x: 15, y: 10), (x: 0, y: 30), (x: 5, y: 45),
    (x: 25, y: 55), (x: 50, y: 55), (x: 75, y: 45), (x: 80, y: 60),
    (x: 70, y: 80), (x: 50, y: 88),
  ]);
}
