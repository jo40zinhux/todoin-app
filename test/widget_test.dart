import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todoin_focus_app/main.dart';
import 'package:todoin_focus_app/core/providers/shared_preferences_provider.dart';

void main() {
  testWidgets('Home screen renders correctly with Riverpod ProviderScope',
      (WidgetTester tester) async {
    // Inject Mock SharedPreferences directly since no specific mocktail class needed for Map injection
    SharedPreferences.setMockInitialValues({'onboarding_completed': true});
    final sharedPrefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(sharedPrefs),
        ],
        child: const TodoinApp(),
      ),
    );
    // Use pump with a finite duration instead of pumpAndSettle because
    // repeating animations (e.g. EmptyState icon pulse) never settle.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('toDoin'), findsOneWidget);
    expect(find.text('Pronto para começar?'), findsOneWidget);

    // Empty state CTA (FAB oculto quando não há tarefa ativa)
    expect(find.text('Começar algo agora'), findsOneWidget);
    expect(find.text('Começar algo'), findsNothing);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(sharedPrefs),
        ],
        child: const MaterialApp(home: SizedBox()),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 800));
  });
}
