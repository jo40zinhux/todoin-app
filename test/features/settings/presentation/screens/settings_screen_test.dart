import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todoin_focus_app/core/providers/shared_preferences_provider.dart';
import 'package:todoin_focus_app/features/settings/presentation/screens/settings_screen.dart';

import '../../../../helpers/reminder_test_overrides.dart';

void main() {
  Future<void> pumpSettings(WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final sharedPrefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(sharedPrefs),
          ...reminderTestOverrides,
        ],
        child: const MaterialApp(home: SettingsScreen()),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
  }

  group('SettingsScreen', () {
    testWidgets('shows title and main sections', (tester) async {
      await pumpSettings(tester);

      expect(find.text('Configurações'), findsOneWidget);
      expect(find.text('Geral'), findsOneWidget);
      expect(find.text('Lembretes gentis'), findsOneWidget);
      expect(find.text('Modo dia difícil'), findsOneWidget);
      expect(find.byTooltip('Fechar'), findsOneWidget);
    });

    testWidgets('closes when tapping X', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final sharedPrefs = await SharedPreferences.getInstance();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(sharedPrefs),
            ...reminderTestOverrides,
          ],
          child: MaterialApp(
            home: Builder(
              builder: (context) => Scaffold(
                body: Center(
                  child: ElevatedButton(
                    onPressed: () => SettingsScreen.open(context),
                    child: const Text('Abrir'),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      await tester.tap(find.text('Abrir'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Configurações'), findsOneWidget);

      await tester.tap(find.byTooltip('Fechar'));
      await tester.pumpAndSettle();

      expect(find.text('Configurações'), findsNothing);
      expect(find.text('Abrir'), findsOneWidget);
    });
  });
}
