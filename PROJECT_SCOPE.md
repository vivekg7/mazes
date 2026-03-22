# Mazes — Project Scope

> This document is for the project owner and Claude Code — not for end users.
> It defines what this project is, what it aims to be, and what it will never become.

## Goal

Build the most complete offline maze puzzle app possible — a hobby project by a puzzle nerd, for puzzle nerds. Every maze is generated at runtime. Every feature respects the player's time and intelligence. Challenge comes first, relaxation second.

---

## Design Principles

1. **Offline-first** — Everything works without internet.
2. **Challenge the player** — Scoring, difficulty, and variety keep things interesting.
3. **No bloat** — No tracking, no ads, no accounts. Just mazes.
4. **Completeness** — If a generation algorithm exists, implement it. If a cell type makes geometric sense, support it. If a feature fits offline mazes, include it.
5. **Full flexibility** — The player controls every aspect of their experience.
6. **Free & open source** — GPLv3. Forever.

---

## Platforms

- **Mobile & Desktop** — Cross-platform app built with **Flutter** (Android, iOS, macOS, Windows, Linux).
- **CLI** — A standalone command-line interface app for terminal lovers.
- **Web** — TBD. Either Flutter web export or a separate lightweight static site. Decision deferred until Flutter web quality can be evaluated.

---

## Cell Types

Every cell type defines the geometry of the maze grid. The app supports all of the following:

| Cell Type              | Description                                                  |
| ---------------------- | ------------------------------------------------------------ |
| **Square**             | Classic rectangular grid. The default.                       |
| **Hexagonal**          | Honeycomb tiling. Six neighbors per cell, organic feel.      |
| **Triangular**         | Alternating up/down triangles. Tight corridors, sharp turns. |
| **Circular**           | Wedge-shaped cells radiating from a center point.            |
| **Concentric Circles** | Rings of cells with passages between and across rings.       |
| **Voronoi**            | Irregular organic cells from random point distributions.     |

Each cell type can be combined with any compatible puzzle shape and generation algorithm.

---

## Puzzle Shapes

Puzzle shape defines the outer boundary of the maze. The app generates a maze that fills the shape using the selected cell type.

- **Rectangular grid** — Standard rectangle. Works with all cell types.
- **Circular disc** — Round boundary. Natural fit for circular and concentric cell types, but works with any.
- **Animal silhouettes** — Library of animal shapes (cat, dog, bird, fish, butterfly, etc.).
- **Letters & numbers** — Alphabet and digit shapes for personalized mazes.
- **Abstract shapes** — Stars, hearts, arrows, spirals, and other geometric forms.
- **Country / continent outlines** — Recognizable geographic silhouettes.

Shape masks are predefined in a library. The user picks a shape, picks a cell type, and the app generates a maze that fills it.

---

## Generation Algorithms

All known maze generation algorithms are implemented. Each produces mazes with distinct characteristics — corridor length, branching factor, dead-end density, and bias patterns.

| Algorithm                 | Character                                                                      |
| ------------------------- | ------------------------------------------------------------------------------ |
| **Recursive Backtracker** | Long, winding corridors. Low dead-end count.                                   |
| **Kruskal's**             | Uniform, organic feel. No directional bias.                                    |
| **Prim's**                | Tends toward short, branchy corridors from a center.                           |
| **Eller's**               | Row-by-row generation. Memory-efficient, slight bias.                          |
| **Wilson's**              | Perfectly uniform spanning tree. Slow but unbiased.                            |
| **Aldous-Broder**         | Uniform like Wilson's. Random walk, very slow on large grids.                  |
| **Growing Tree**          | Tunable — behaves like Prim's or Backtracker depending on selection strategy.  |
| **Hunt-and-Kill**         | Similar to Backtracker but scans for unvisited cells instead of backtracking.  |
| **Sidewinder**            | Row-by-row with upward connections. Slight horizontal bias.                    |
| **Binary Tree**           | Simplest algorithm. Strong diagonal bias.                                      |
| **Recursive Division**    | Builds walls instead of carving passages. Long straight walls, grid-like feel. |

The user can select an algorithm manually or let the app choose one suited to the selected difficulty and cell type.

---

## Interactive Gameplay

### Path Drawing

- The player draws a path from start to exit by tapping/clicking cells or dragging through them. The path snaps to valid cell connections.
- Path can be undone by retracing — drag back over your path to erase it.
- Full undo/redo support.
- Keyboard and touch navigation.

### Fog of War (Optional Mode)

- Only cells within N steps of the player's current position are visible. Everything else is hidden.
- The visible radius can be configured by the player.
- Turns maze-solving into an exploration experience — the player must build a mental map.
- Togglable per-puzzle in settings.

### Breadcrumbs & Wall Marking

- The player can drop breadcrumbs on visited cells to track where they've been.
- Walls can be marked (e.g., "tested, dead end") to record observations.
- Both are optional tools the player can use or ignore.
- Breadcrumbs and marks are visual only — they don't affect scoring or completion.

### Scoring

- Per-puzzle timer with pause support.
- On completion, the app shows the player's path length vs. the shortest possible path (e.g., "Your path: 47 steps — Shortest: 31 steps").
- No star ratings. Just information the player can use to self-assess.

---

## Difficulty

- **6 difficulty levels** — from casual to extreme.
- Difficulty is determined by maze properties: grid size, dead-end density, solution path length relative to total cells, branching factor, and number of decision points.
- The algorithm choice also influences difficulty — some algorithms naturally produce harder mazes.
- Cell type and puzzle shape affect perceived difficulty (hexagonal mazes feel different from square ones at the same size).

---

## Player Stats

- Track solve times, completion rates, and streaks.
- Stats broken down by cell type, puzzle shape, algorithm, and difficulty.
- Stats help the player see their growth across different maze styles.

---

## PDF Export & Bulk Puzzle Creation

- Users can generate mazes in bulk and **export as PDF** for printing.
- PDF layout:
  - Maze pages with rendered grids.
  - Solution pages at the end showing the shortest path.
- Each maze includes a small **QR code** that, when scanned through the app, opens that exact maze for interactive play.

---

## Save, Bookmarks & Data Portability

- Save in-progress mazes and resume later.
- Bookmark mazes to replay or revisit.
- Export and import mazes, bookmarks, and stats — allows users to move data across platforms/devices manually (no cloud, no accounts).

---

## Future Improvements (May Be Added)

- Accessibility improvements (screen reader support, high contrast).
- Collectibles / checkpoints — optional objectives beyond reaching the exit.
- Maze sharing via links or text export.
- Import a maze shape from an image — trace the outline and generate a maze inside it.
- Localization / multi-language support.
- Dark mode / theme customization.
- Animations & transition polish.
- 3D mazes — multi-layered mazes with staircases between floors.

---

## Will Never Be Implemented

These are permanent, intentional exclusions.

- **Internet Requirement** — The app works fully offline. No server, no backend, no cloud sync, no accounts, no login.
- **Monetisation** — No ads, no in-app purchases, no premium tiers. Ever.
- **Analytics / Tracking** — No telemetry, no cookies, no third-party scripts. Zero data collection.
- **Social Features** — No leaderboards, friend lists, or sharing to social media.
- **Multiplayer** — No real-time or turn-based multiplayer.
- **Hints** — The player solves on their own. No hint system.

---

## Tech Stack

**Language: Dart (everywhere)**

All maze logic lives in a shared `maze_core` Dart package. Every target — Flutter, CLI, and web — depends on this single package. One language, one test suite, one set of dependencies.

| Platform         | Technology                           | Status                                           |
| ---------------- | ------------------------------------ | ------------------------------------------------ |
| Core logic       | Pure Dart package (`maze_core`)      | Decided                                          |
| Mobile & Desktop | Flutter (depends on `maze_core`)     | Decided                                          |
| CLI              | Dart CLI (`dart compile exe`)        | Decided                                          |
| Web              | Flutter web or lightweight framework | Deferred — depends on Flutter web output quality |
| PDF export       | `pdf` + `printing` (Dart/Flutter)    | Decided                                          |
| QR code          | `mobile_scanner` + `pdf` Barcode API | Decided                                          |

### Project Structure

```
mazes/
├── packages/
│   └── maze_core/                # Pure Dart — all logic lives here
│       ├── lib/src/
│       │   ├── models/           # Grid, Cell, Wall, Path, Shape, etc.
│       │   ├── cells/            # Cell type implementations (square, hex, etc.)
│       │   ├── shapes/           # Puzzle shape masks (animals, letters, etc.)
│       │   ├── generator/        # All generation algorithms
│       │   ├── solver/           # Shortest-path solver, dead-end analysis
│       │   └── stats/            # Stats tracking logic
│       └── test/
├── apps/
│   ├── flutter_app/              # Flutter UI (depends on maze_core)
│   └── cli/                      # Dart CLI app (depends on maze_core)
├── assets/
│   └── shapes/                   # Shape mask definitions (SVG or point data)
└── PROJECT_SCOPE.md
```

---

## License

GNU General Public License v3 (GPLv3).
