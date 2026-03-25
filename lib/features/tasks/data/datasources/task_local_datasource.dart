import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task_model.dart';

abstract class TaskLocalDataSource {
  Future<List<TaskModel>> getTasks();
  Future<void> saveTasks(List<TaskModel> tasks);
  Future<int> getXp();
  Future<void> saveXp(int xp);
}

class TaskLocalDataSourceImpl implements TaskLocalDataSource {
  final SharedPreferences sharedPreferences;

  static const _tasksKey = 'todoin_tasks';
  static const _xpKey = 'todoin_xp';

  TaskLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<List<TaskModel>> getTasks() async {
    final jsonString = sharedPreferences.getString(_tasksKey);
    if (jsonString != null) {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList
          .map((json) => TaskModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } else {
      return [];
    }
  }

  @override
  Future<void> saveTasks(List<TaskModel> tasks) async {
    final List<Map<String, dynamic>> jsonList =
        tasks.map((task) => task.toJson()).toList();
    final jsonString = jsonEncode(jsonList);
    await sharedPreferences.setString(_tasksKey, jsonString);
  }

  @override
  Future<int> getXp() async {
    return sharedPreferences.getInt(_xpKey) ?? 0;
  }

  @override
  Future<void> saveXp(int xp) async {
    await sharedPreferences.setInt(_xpKey, xp);
  }
}
