import 'package:hive/hive.dart';
import 'package:maze_core/maze_core.dart';

/// Hive-backed implementation of [StatsRepository].
class HiveStatsRepository implements StatsRepository {
  static const _boxName = 'solve_records';

  Box<Map>? _box;

  Future<Box<Map>> _getBox() async {
    if (_box != null && _box!.isOpen) return _box!;
    _box = await Hive.openBox<Map>(_boxName);
    return _box!;
  }

  @override
  Future<void> addRecord(SolveRecord record) async {
    final box = await _getBox();
    await box.add(record.toJson().cast<dynamic, dynamic>());
  }

  @override
  Future<List<SolveRecord>> getAllRecords() async {
    final box = await _getBox();
    return box.values
        .map((raw) => SolveRecord.fromJson(
              Map<String, dynamic>.from(raw),
            ))
        .toList();
  }

  @override
  Future<void> clear() async {
    final box = await _getBox();
    await box.clear();
  }

  @override
  Future<List<Map<String, dynamic>>> export() async {
    final records = await getAllRecords();
    return records.map((r) => r.toJson()).toList();
  }

  @override
  Future<void> import_(List<Map<String, dynamic>> data) async {
    final box = await _getBox();
    for (final json in data) {
      await box.add(json.cast<dynamic, dynamic>());
    }
  }
}
