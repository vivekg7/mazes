import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:maze_core/maze_core.dart';
import 'package:path_provider/path_provider.dart';

import '../models/bookmarked_maze.dart';
import '../models/saved_game.dart';

/// JSON-file backed storage for solve records, saved games, and bookmarks.
///
/// Implements [StatsRepository] so it plugs into [StatsAggregator] from
/// maze_core. Also extends [ChangeNotifier] so the UI can rebuild when
/// data changes.
class StorageService extends ChangeNotifier implements StatsRepository {
  late final String _dirPath;
  List<SolveRecord> _records = [];
  List<SavedGame> _saves = [];
  List<BookmarkedMaze> _bookmarks = [];

  List<SolveRecord> get records => List.unmodifiable(_records);
  List<SavedGame> get saves => List.unmodifiable(_saves);
  List<BookmarkedMaze> get bookmarks => List.unmodifiable(_bookmarks);

  Future<void> init() async {
    final dir = await getApplicationDocumentsDirectory();
    _dirPath = dir.path;
    await Future.wait([_loadRecords(), _loadSaves(), _loadBookmarks()]);
  }

  // --- Solve Records ---

  Future<void> _loadRecords() async {
    final file = File('$_dirPath/maze_stats.json');
    if (file.existsSync()) {
      try {
        final json = jsonDecode(await file.readAsString()) as List;
        _records = json
            .map((e) =>
                SolveRecord.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
      } catch (_) {
        _records = [];
      }
    }
  }

  Future<void> _saveRecords() async {
    final file = File('$_dirPath/maze_stats.json');
    await file
        .writeAsString(jsonEncode(_records.map((r) => r.toJson()).toList()));
  }

  @override
  Future<void> addRecord(SolveRecord record) async {
    _records.add(record);
    await _saveRecords();
    notifyListeners();
  }

  @override
  Future<List<SolveRecord>> getAllRecords() async {
    return List.unmodifiable(_records);
  }

  @override
  Future<void> clear() async {
    _records.clear();
    await _saveRecords();
    notifyListeners();
  }

  // --- Saved Games ---

  Future<void> _loadSaves() async {
    final file = File('$_dirPath/maze_saves.json');
    if (file.existsSync()) {
      try {
        final json = jsonDecode(await file.readAsString()) as List;
        _saves = json
            .map((e) =>
                SavedGame.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
      } catch (_) {
        _saves = [];
      }
    }
  }

  Future<void> _saveSaves() async {
    final file = File('$_dirPath/maze_saves.json');
    await file
        .writeAsString(jsonEncode(_saves.map((s) => s.toJson()).toList()));
  }

  Future<void> saveGame(SavedGame save) async {
    // Replace existing save with same id, or add new.
    final index = _saves.indexWhere((s) => s.id == save.id);
    if (index >= 0) {
      _saves[index] = save;
    } else {
      _saves.add(save);
    }
    await _saveSaves();
    notifyListeners();
  }

  Future<void> deleteSave(String id) async {
    _saves.removeWhere((s) => s.id == id);
    await _saveSaves();
    notifyListeners();
  }

  // --- Bookmarks ---

  Future<void> _loadBookmarks() async {
    final file = File('$_dirPath/maze_bookmarks.json');
    if (file.existsSync()) {
      try {
        final json = jsonDecode(await file.readAsString()) as List;
        _bookmarks = json
            .map((e) =>
                BookmarkedMaze.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
      } catch (_) {
        _bookmarks = [];
      }
    }
  }

  Future<void> _saveBookmarks() async {
    final file = File('$_dirPath/maze_bookmarks.json');
    await file
        .writeAsString(jsonEncode(_bookmarks.map((b) => b.toJson()).toList()));
  }

  Future<void> addBookmark(BookmarkedMaze bookmark) async {
    _bookmarks.add(bookmark);
    await _saveBookmarks();
    notifyListeners();
  }

  Future<void> removeBookmark(String id) async {
    _bookmarks.removeWhere((b) => b.id == id);
    await _saveBookmarks();
    notifyListeners();
  }

  // --- Export / Import ---

  @override
  Future<List<Map<String, dynamic>>> export() async {
    // Wrap in a structured format for forward compatibility.
    return [
      {
        '_format': 'mazes_export_v2',
        'records': _records.map((r) => r.toJson()).toList(),
        'saves': _saves.map((s) => s.toJson()).toList(),
        'bookmarks': _bookmarks.map((b) => b.toJson()).toList(),
      }
    ];
  }

  @override
  Future<void> import_(List<Map<String, dynamic>> data) async {
    if (data.isNotEmpty && data.first.containsKey('_format')) {
      // V2 structured format.
      final envelope = data.first;
      if (envelope['records'] != null) {
        _records.addAll((envelope['records'] as List)
            .map((e) =>
                SolveRecord.fromJson(Map<String, dynamic>.from(e as Map))));
      }
      if (envelope['saves'] != null) {
        _saves.addAll((envelope['saves'] as List)
            .map((e) =>
                SavedGame.fromJson(Map<String, dynamic>.from(e as Map))));
      }
      if (envelope['bookmarks'] != null) {
        _bookmarks.addAll((envelope['bookmarks'] as List)
            .map((e) =>
                BookmarkedMaze.fromJson(Map<String, dynamic>.from(e as Map))));
      }
    } else {
      // V1 flat list of SolveRecords (backward compatible).
      _records.addAll(data.map(SolveRecord.fromJson));
    }
    await Future.wait([_saveRecords(), _saveSaves(), _saveBookmarks()]);
    notifyListeners();
  }
}
