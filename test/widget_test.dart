import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todoin_focus_app/main.dart';
import 'package:todoin_focus_app/features/tasks/presentation/providers/tasks_provider.dart';

void main() {
  testWidgets('Home screen renders correctly with Riverpod ProviderScope',
      (WidgetTester tester) async {
    // Inject Mock SharedPreferences directly since no specific mocktail class needed for Map injection
    SharedPreferences.setMockInitialValues({});
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
    await tester.pump(const Duration(seconds: 2));

    // Verify main app title
    expect(find.text('toDoin'), findsOneWidget);

    // Verify empty state is displayed
    expect(find.text('Pronto para começar?'), findsOneWidget);

    // Verify FAB
    expect(find.text('Começar algo'), findsOneWidget);
  });
}
