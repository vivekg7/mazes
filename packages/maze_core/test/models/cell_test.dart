import 'package:maze_core/maze_core.dart';
import 'package:test/test.dart';

/// Minimal concrete Cell for testing.
class TestCell extends Cell {
  TestCell(super.row, super.column);

  final List<Cell> _neighbors = [];

  void addNeighbor(Cell other) {
    _neighbors.add(other);
  }

  @override
  List<Cell> get neighbors => _neighbors;

  @override
  List<({double x, double y})> get vertices => [
        (x: column.toDouble(), y: row.toDouble()),
        (x: column + 1.0, y: row.toDouble()),
        (x: column + 1.0, y: row + 1.0),
        (x: column.toDouble(), y: row + 1.0),
      ];

  @override
  ({double x, double y}) get center =>
      (x: column + 0.5, y: row + 0.5);
}

void main() {
  group('Cell', () {
    late TestCell a;
    late TestCell b;
    late TestCell c;

    setUp(() {
      a = TestCell(0, 0);
      b = TestCell(0, 1);
      c = TestCell(1, 0);
    });

    test('starts with no links', () {
      expect(a.links, isEmpty);
      expect(a.isIsolated, isTrue);
    });

    test('link creates bidirectional passage', () {
      a.link(b);
      expect(a.isLinked(b), isTrue);
      expect(b.isLinked(a), isTrue);
    });

    test('unlink removes bidirectional passage', () {
      a.link(b);
      a.unlink(b);
      expect(a.isLinked(b), isFalse);
      expect(b.isLinked(a), isFalse);
    });

    test('unidirectional link', () {
      a.link(b, bidirectional: false);
      expect(a.isLinked(b), isTrue);
      expect(b.isLinked(a), isFalse);
    });

    test('unidirectional unlink', () {
      a.link(b);
      a.unlink(b, bidirectional: false);
      expect(a.isLinked(b), isFalse);
      expect(b.isLinked(a), isTrue);
    });

    test('isDeadEnd when exactly one link', () {
      a.link(b);
      expect(a.isDeadEnd, isTrue);
      a.link(c);
      expect(a.isDeadEnd, isFalse);
    });

    test('linkCount tracks open passages', () {
      expect(a.linkCount, equals(0));
      a.link(b);
      expect(a.linkCount, equals(1));
      a.link(c);
      expect(a.linkCount, equals(2));
    });

    test('equality based on row and column', () {
      final a2 = TestCell(0, 0);
      expect(a, equals(a2));
      expect(a.hashCode, equals(a2.hashCode));
      expect(a, isNot(equals(b)));
    });

    test('vertices returns four corners', () {
      expect(a.vertices, hasLength(4));
    });

    test('center returns midpoint', () {
      final center = a.center;
      expect(center.x, equals(0.5));
      expect(center.y, equals(0.5));
    });
  });
}
