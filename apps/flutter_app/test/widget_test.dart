import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mazes/main.dart';

void main() {
  testWidgets('App renders home screen', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: MazesApp()),
    );
    await tester.pumpAndSettle();

    expect(find.text('Mazes'), findsOneWidget);
    expect(find.text('Quick Play'), findsOneWidget);
  });
}
