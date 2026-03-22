import 'package:maze_core/maze_core.dart';
import 'package:test/test.dart';

import 'cell_test.dart';

void main() {
  group('MazePath', () {
    late TestCell a;
    late TestCell b;
    late TestCell c;

    setUp(() {
      a = TestCell(0, 0);
      b = TestCell(0, 1);
      c = TestCell(0, 2);
      a.link(b);
      b.link(c);
    });

    test('empty path', () {
      const path = MazePath.empty();
      expect(path.isEmpty, isTrue);
      expect(path.isNotEmpty, isFalse);
      expect(path.length, equals(0));
      expect(path.steps, equals(0));
      expect(path.start, isNull);
      expect(path.end, isNull);
    });

    test('path with cells', () {
      final path = MazePath([a, b, c]);
      expect(path.length, equals(3));
      expect(path.steps, equals(2));
      expect(path.start, equals(a));
      expect(path.end, equals(c));
    });

    test('contains checks membership', () {
      final path = MazePath([a, b]);
      expect(path.contains(a), isTrue);
      expect(path.contains(c), isFalse);
    });

    test('isValid checks all consecutive cells are linked', () {
      final validPath = MazePath([a, b, c]);
      expect(validPath.isValid, isTrue);

      // a and c are not linked directly
      final invalidPath = MazePath([a, c]);
      expect(invalidPath.isValid, isFalse);
    });

    test('empty path is valid', () {
      const path = MazePath.empty();
      expect(path.isValid, isTrue);
    });

    test('single cell path is valid', () {
      final path = MazePath([a]);
      expect(path.isValid, isTrue);
    });
  });
}
