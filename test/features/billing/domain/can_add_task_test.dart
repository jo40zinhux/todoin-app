import 'package:flutter_test/flutter_test.dart';
import 'package:todoin_focus_app/features/billing/domain/entities/entitlement.dart';
import 'package:todoin_focus_app/features/billing/domain/usecases/can_add_task.dart';
import 'package:todoin_focus_app/features/tasks/domain/entities/task.dart';

void main() {
  late CanAddTask canAddTask;

  setUp(() {
    canAddTask = CanAddTask();
  });

  test('pro user can always add tasks', () async {
    final tasks = List.generate(
      10,
      (i) => Task(id: '$i', title: 'Task $i', subtasks: []),
    );

    final result = await canAddTask(CanAddTaskParams(
      tasks: tasks,
      entitlement: const Entitlement(isPro: true),
    ));

    expect(result, isTrue);
  });

  test('free user blocked at 5 active tasks', () async {
    final tasks = List.generate(
      5,
      (i) => Task(id: '$i', title: 'Task $i', subtasks: []),
    );

    final result = await canAddTask(CanAddTaskParams(
      tasks: tasks,
      entitlement: const Entitlement(isPro: false),
    ));

    expect(result, isFalse);
  });

  test('completed tasks do not count toward free limit', () async {
    final tasks = [
      ...List.generate(
        5,
        (i) => Task(
          id: '$i',
          title: 'Done $i',
          completed: true,
          subtasks: [],
        ),
      ),
      const Task(id: 'active', title: 'Active', subtasks: []),
    ];

    final result = await canAddTask(CanAddTaskParams(
      tasks: tasks,
      entitlement: const Entitlement(isPro: false),
    ));

    expect(result, isTrue);
  });
}
