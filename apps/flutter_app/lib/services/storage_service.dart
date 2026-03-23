import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:maze_core/maze_core.dart';
import 'package:path_provider/path_provider.dart';

/// JSON-file backed storage for solve records.
///
/// Implements [StatsRepository] so it plugs into [StatsAggregator] from
/// maze_core. Also extends [ChangeNotifier] so the UI can rebuild when
/// records change.
class StorageService extends ChangeNotifier implements StatsRepository {
  late final String _dirPath;
  List<SolveRecord> _records = [];

  List<SolveRecord> get records => List.unmodifiable(_records);

  Future<void> init() async {
    final dir = await getApplicationDocumentsDirectory();
    _dirPath = dir.path;
    await _load();
  }

  Future<void> _load() async {
    final file = File('$_dirPath/maze_stats.json');
    if (file.existsSync()) {
      try {
        final json = jsonDecode(await file.readAsString()) as List;
        _records = json
            .map((e) => SolveRecord.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
      } catch (_) {
        _records = [];
      }
    }
  }

  Future<void> _save() async {
    final file = File('$_dirPath/maze_stats.json');
    await file.writeAsString(jsonEncode(_records.map((r) => r.toJson()).toList()));
  }

  @override
  Future<void> addRecord(SolveRecord record) async {
    _records.add(record);
    await _save();
    notifyListeners();
  }

  @override
  Future<List<SolveRecord>> getAllRecords() async {
    return List.unmodifiable(_records);
  }

  @override
  Future<void> clear() async {
    _records.clear();
    await _save();
    notifyListeners();
  }

  @override
  Future<List<Map<String, dynamic>>> export() async {
    return _records.map((r) => r.toJson()).toList();
  }

  @override
  Future<void> import_(List<Map<String, dynamic>> data) async {
    _records.addAll(data.map(SolveRecord.fromJson));
    await _save();
    notifyListeners();
  }
}
