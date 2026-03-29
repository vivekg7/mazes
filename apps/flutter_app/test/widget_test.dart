import 'package:flutter_test/flutter_test.dart';
import 'package:mazes/services/settings_service.dart';
import 'package:mazes/services/storage_service.dart';
import 'package:mazes/state/game_state.dart';
import 'package:mazes/theme.dart';
import 'package:flutter/material.dart';
import 'package:mazes/screens/home_screen.dart';

void main() {
  testWidgets('App renders home screen', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildLightTheme(AppColor.teal.seed),
        home: HomeScreen(
          storage: StorageService(),
          settings: SettingsService(),
          gameNotifier: GameNotifier(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Mazes'), findsOneWidget);
    expect(find.text('Quick Play'), findsOneWidget);
  });
}
