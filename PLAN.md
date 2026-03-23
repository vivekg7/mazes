# Mazes — V1 Implementation Plan

> Build order: `maze_core` package → Flutter app.
> CLI app is out of scope for V1.

---

## Phase 1: Project Scaffolding

- [ ] Create Dart monorepo structure with `pubspec.yaml` workspace
- [ ] Scaffold `packages/maze_core` as a pure Dart package
- [ ] Scaffold `apps/flutter_app` as a Flutter project depending on `maze_core`
- [ ] Set up linting (`analysis_options.yaml`) and test runner

---

## Phase 2: Core Models (`maze_core/lib/src/models/`)

Define the foundational data types everything else builds on.

- [ ] **Cell** — abstract base class. Position, list of neighbors, list of walls, linked/unlinked status
- [ ] **Wall** — shared edge between two cells, open/closed state
- [ ] **Grid** — abstract base class. Holds cells, knows dimensions, provides iteration and neighbor lookup
- [ ] **Path** — ordered list of cells representing a player's route or a solution
- [ ] **MazeConfig** — value object: cell type, shape, algorithm, difficulty, dimensions
- [ ] **MazeResult** — generated maze: grid + start cell + end cell + solution path + metadata

---

## Phase 3: Cell Types (`maze_core/lib/src/cells/`)

Each cell type implements `Grid` with its own geometry and neighbor logic.

- [ ] **SquareGrid** — 4-neighbor rectangular grid
- [ ] **HexGrid** — 6-neighbor honeycomb grid
- [ ] **TriangleGrid** — alternating up/down triangles, 3 neighbors each
- [ ] **CircularGrid** — wedge cells radiating from center
- [ ] **ConcentricGrid** — ring-based cells with radial + ring connections
- [ ] **VoronoiGrid** — irregular cells from random point seeds (Delaunay → Voronoi)

Each grid type must:

- Generate cell positions and neighbor relationships
- Support masking (for puzzle shapes)
- Provide cell geometry data for rendering (vertex positions)

---

## Phase 4: Puzzle Shapes (`maze_core/lib/src/shapes/`)

Shape masks determine which cells are included in the maze.

- [ ] **Shape** — abstract mask interface: `bool contains(row, col)` or point-in-polygon test
- [ ] **RectangleShape** — full grid, no masking
- [ ] **CircleShape** — circular disc boundary
- [ ] **Shape library loader** — load predefined shapes from asset data (SVG paths or point lists)
- [ ] **Built-in shape sets:**
  - [ ] Animal silhouettes (cat, dog, bird, fish, butterfly — start with 5)
  - [ ] Letters A–Z and digits 0–9
  - [ ] Abstract shapes (star, heart, arrow, spiral — start with 4)
  - [ ] Country outlines (start with 5–10 recognizable countries)

Shape data lives in `assets/shapes/` as SVG or JSON point data.

---

## Phase 5: Generation Algorithms (`maze_core/lib/src/generator/`)

All algorithms operate on the abstract `Grid` — cell-type-agnostic.

- [ ] **Generator** — common interface: `MazeResult generate(Grid, {seed})`
- [ ] **Recursive Backtracker** (DFS)
- [ ] **Kruskal's**
- [ ] **Prim's**
- [ ] **Eller's**
- [ ] **Wilson's** (loop-erased random walk)
- [ ] **Aldous-Broder** (random walk)
- [ ] **Growing Tree** (configurable selection: newest / random / oldest)
- [ ] **Hunt-and-Kill**
- [ ] **Sidewinder**
- [ ] **Binary Tree**
- [ ] **Recursive Division** (wall-adding)

Each algorithm:

- Accepts an optional random seed for reproducibility
- Works on any `Grid` implementation (square, hex, etc.)
- Returns a `MazeResult` with the carved grid

---

## Phase 6: Solver (`maze_core/lib/src/solver/`)

- [ ] **Shortest-path solver** — BFS on the carved grid, returns optimal `Path`
- [ ] **Dead-end analysis** — count and locate dead ends (used for difficulty scoring)
- [ ] **Path metrics** — solution length, branching factor, decision point count

---

## Phase 7: Difficulty Engine (`maze_core/lib/src/difficulty/`)

- [ ] **DifficultyLevel** — enum with 6 levels (casual → extreme)
- [ ] **DifficultyCalculator** — given a level + cell type + shape, output `MazeConfig` (grid size, recommended algorithm, etc.)
- [ ] **DifficultyScorer** — score a generated maze's actual difficulty from its metrics (dead ends, solution length ratio, branching)
- [ ] Optional: regenerate if scored difficulty doesn't match target

---

## Phase 8: Stats Engine (`maze_core/lib/src/stats/`)

- [ ] **StatsRepository** — interface for persisting stats (implemented in Flutter layer with local storage)
- [ ] **StatsTracker** — record solve time, path efficiency, completion
- [ ] **StatsAggregator** — breakdowns by cell type, shape, algorithm, difficulty
- [ ] **Streak tracking** — daily/consecutive solve streaks

---

## Phase 9: Core Package Tests

- [ ] Unit tests for each grid type (neighbor correctness, masking)
- [ ] Unit tests for each algorithm (produces valid spanning tree, all cells reachable)
- [ ] Unit tests for solver (correct shortest path)
- [ ] Unit tests for difficulty engine
- [ ] Property-based tests: for any grid + algorithm combo, solution exists and all cells are reachable

---

## Phase 10: Flutter App — Foundation (`apps/flutter_app/`)

- [ ] App shell with navigation (home, play, stats, settings)
- [ ] State management with `ChangeNotifier` + `ListenableBuilder`
- [ ] Local storage via JSON files in application documents directory (`path_provider`)
- [ ] Theme setup (light + dark mode)
- [ ] Imperative navigation with `Navigator.push` + `MaterialPageRoute`

---

## Phase 11: Flutter App — Maze Renderer

The renderer converts grid geometry data from `maze_core` into visuals.

- [ ] **MazePainter** — `CustomPainter` that draws any grid type from cell vertex data
- [ ] Renders walls, open passages, start/end markers
- [ ] Renders player path (drawn cells highlighted)
- [ ] Renders fog of war (dim/hide cells beyond radius)
- [ ] Renders breadcrumbs and wall marks
- [ ] Zoom & pan via `InteractiveViewer`
- [ ] Smooth path animation on draw/undo

---

## Phase 12: Flutter App — Gameplay

- [ ] **New Maze screen** — pick cell type, shape, algorithm (or auto), difficulty → generate & play
- [ ] **Play screen** — draw path by tap/drag, snap to valid connections
- [ ] Path undo by retracing (drag back)
- [ ] Full undo/redo stack
- [ ] Keyboard navigation (arrow keys on desktop)
- [ ] Timer with pause
- [ ] Completion screen — path length vs shortest, time taken
- [ ] Fog of war toggle + radius setting
- [ ] Breadcrumb and wall mark tools

---

## Phase 13: Flutter App — Save, Bookmarks & Data

- [ ] Save in-progress maze (grid state + player path + timer)
- [ ] Resume saved maze
- [ ] Bookmark completed mazes for replay
- [ ] Export/import mazes, bookmarks, stats as JSON file
- [ ] Data stored locally, no network calls

---

## Phase 14: Flutter App — Stats UI

- [ ] Stats dashboard — overall and per-category breakdowns
- [ ] Solve time history charts
- [ ] Streak display
- [ ] Filter by cell type / shape / algorithm / difficulty

---

## Phase 15: PDF Export

- [ ] Generate maze pages with rendered grid (using `pdf` package)
- [ ] Solution pages at the end with shortest path drawn
- [ ] QR code per maze linking back to interactive play in-app
- [ ] Bulk generation — user picks count + config, gets a PDF booklet
- [ ] Share/save PDF via system share sheet

---

## Phase 16: Polish & Release Prep

- [ ] Responsive layout for mobile and desktop
- [ ] Accessibility pass (semantics, contrast, font scaling)
- [ ] Performance profiling on large grids
- [ ] App icons and splash screen
- [ ] Store listing assets (screenshots, description)
- [ ] Final test pass across Android, iOS, macOS, Windows, Linux

---

## Build Order Summary

```
Phase 1   Scaffolding
Phase 2   Core models
Phase 3   Cell types          ← maze_core
Phase 4   Puzzle shapes
Phase 5   Generation algorithms
Phase 6   Solver
Phase 7   Difficulty engine
Phase 8   Stats engine
Phase 9   Core tests
Phase 10  Flutter foundation
Phase 11  Maze renderer       ← Flutter app
Phase 12  Gameplay
Phase 13  Save & data
Phase 14  Stats UI
Phase 15  PDF export
Phase 16  Polish & release
```
