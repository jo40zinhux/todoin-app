import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todoin_focus_app/features/tasks/data/datasources/task_local_datasource.dart';

void main() {
  late TaskLocalDataSourceImpl datasource;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    datasource = TaskLocalDataSourceImpl(sharedPreferences: prefs);
  });

  test('getTasks returns empty list when no data stored', () async {
    final result = await datasource.getTasks();
    expect(result.tasks, isEmpty);
    expect(result.recoveredFromCorruption, isFalse);
  });

  test('getTasks returns empty list and clears key when JSON is corrupt', () async {
    SharedPreferences.setMockInitialValues({
      'todoin_tasks': 'not-valid-json{{{',
    });
    final prefs = await SharedPreferences.getInstance();
    datasource = TaskLocalDataSourceImpl(sharedPreferences: prefs);

    final result = await datasource.getTasks();

    expect(result.tasks, isEmpty);
    expect(result.recoveredFromCorruption, isTrue);
    expect(prefs.getString('todoin_tasks'), isNull);
  });
}
