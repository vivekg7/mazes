import 'solve_record.dart';

/// Interface for persisting solve records.
///
/// The Flutter app implements this with local storage (e.g., Hive, Isar).
/// The core package only defines the interface.
abstract class StatsRepository {
  /// Saves a solve record.
  Future<void> addRecord(SolveRecord record);

  /// Returns all saved records.
  Future<List<SolveRecord>> getAllRecords();

  /// Deletes all records.
  Future<void> clear();

  /// Exports all records as a JSON-compatible list.
  Future<List<Map<String, dynamic>>> export();

  /// Imports records from a JSON-compatible list.
  Future<void> import_(List<Map<String, dynamic>> data);
}

/// In-memory implementation of [StatsRepository] for testing.
class InMemoryStatsRepository implements StatsRepository {
  final List<SolveRecord> _records = [];

  @override
  Future<void> addRecord(SolveRecord record) async {
    _records.add(record);
  }

  @override
  Future<List<SolveRecord>> getAllRecords() async {
    return List.unmodifiable(_records);
  }

  @override
  Future<void> clear() async {
    _records.clear();
  }

  @override
  Future<List<Map<String, dynamic>>> export() async {
    return _records.map((r) => r.toJson()).toList();
  }

  @override
  Future<void> import_(List<Map<String, dynamic>> data) async {
    _records.addAll(data.map(SolveRecord.fromJson));
  }
}
