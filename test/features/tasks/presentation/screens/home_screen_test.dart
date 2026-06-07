import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todoin_focus_app/core/providers/shared_preferences_provider.dart';
import 'package:todoin_focus_app/features/tasks/data/models/subtask_model.dart';
import 'package:todoin_focus_app/features/tasks/data/models/task_model.dart';
import 'package:todoin_focus_app/features/tasks/presentation/screens/home_screen.dart';

import '../../../../helpers/reminder_test_overrides.dart';

void main() {
  Future<void> pumpHome(
    WidgetTester tester, {
    Map<String, Object>? prefs,
    Size surfaceSize = const Size(800, 1200),
  }) async {
    tester.view.physicalSize = surfaceSize;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    SharedPreferences.setMockInitialValues(prefs ?? {});
    final sharedPrefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(sharedPrefs),
          ...reminderTestOverrides,
        ],
        child: const MaterialApp(home: HomeScreen()),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
  }

  group('HomeScreen interactions', () {
    testWidgets('adds a task from the bottom sheet', (tester) async {
      await pumpHome(tester);

      await tester.tap(find.text('Começar algo agora'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      await tester.enterText(find.byType(TextField), 'Estudar Flutter');
      await tester.tap(find.text('Começar 🚀'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('Estudar Flutter'), findsOneWidget);
      expect(find.text('🎯 Sua tarefa agora'), findsOneWidget);
    });

    testWidgets('shows confirmation before removing upcoming task', (tester) async {
      final tasksJson = jsonEncode([
        TaskModel(
          id: '1',
          title: 'Tarefa atual',
          subtasks: const [
            SubTaskModel(title: 'Passo 1'),
            SubTaskModel(title: 'Passo 2'),
            SubTaskModel(title: 'Passo 3'),
          ],
        ).toJson(),
        TaskModel(
          id: '2',
          title: 'Próxima tarefa',
          subtasks: const [SubTaskModel(title: 'Passo A')],
        ).toJson(),
        TaskModel(
          id: '3',
          title: 'Terceira tarefa',
          subtasks: const [SubTaskModel(title: 'Passo B')],
        ).toJson(),
      ]);

      await pumpHome(tester, prefs: {'todoin_tasks': tasksJson});

      expect(find.text('Próxima tarefa'), findsOneWidget);

      final upcomingTile = find.widgetWithText(ListTile, 'Próxima tarefa');
      await tester.ensureVisible(upcomingTile);
      await tester.tap(
        find.descendant(
          of: upcomingTile,
          matching: find.byIcon(Icons.close_rounded),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Remover tarefa?'), findsOneWidget);

      await tester.tap(find.text('Cancelar'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('Próxima tarefa'), findsOneWidget);
    });

    testWidgets('opens settings screen from header gear icon', (tester) async {
      await pumpHome(tester);

      await tester.tap(find.byTooltip('Configurações'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Configurações'), findsWidgets);
      expect(find.text('Geral'), findsOneWidget);

      await tester.tap(find.byTooltip('Fechar'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.text('Geral'), findsNothing);
      expect(find.text('Começar algo agora'), findsOneWidget);
    });

    testWidgets('opens timer dialog from task card', (tester) async {
      final tasksJson = jsonEncode([
        TaskModel(
          id: '1',
          title: 'Focar agora',
          subtasks: const [SubTaskModel(title: 'Passo 1')],
        ).toJson(),
      ]);

      await pumpHome(tester, prefs: {'todoin_tasks': tasksJson});

      await tester.tap(find.text('Começar por 2 minutos'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('🧠 Foco ativo'), findsOneWidget);
      expect(find.text('Cancelar'), findsOneWidget);

      await tester.tap(find.text('Cancelar'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('🧠 Foco ativo'), findsNothing);
    });
  });
}
