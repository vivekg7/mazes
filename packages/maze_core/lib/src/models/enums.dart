/// The type of cell geometry used in the maze grid.
enum CellType {
  square,
  hexagonal,
  triangular,
  circular,
  voronoi,
}

/// The outer boundary shape of the maze.
enum PuzzleShape {
  rectangle,
  circle,
  animal,
  letter,
  number,
  abstract_,
  country,
}

/// The algorithm used to generate the maze.
enum Algorithm {
  recursiveBacktracker,
  kruskals,
  prims,
  ellers,
  wilsons,
  aldousBroder,
  growingTree,
  huntAndKill,
  sidewinder,
  binaryTree,
  recursiveDivision,
}

/// Difficulty level from casual to extreme.
enum DifficultyLevel {
  casual,
  easy,
  medium,
  hard,
  expert,
  extreme,
}
