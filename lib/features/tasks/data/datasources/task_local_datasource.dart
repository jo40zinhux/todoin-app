import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/task_model.dart';
import '../models/tasks_read_result.dart';

abstract class TaskLocalDataSource {
  Future<TasksReadResult> getTasks();
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
  Future<TasksReadResult> getTasks() async {
    final jsonString = sharedPreferences.getString(_tasksKey);
    if (jsonString == null) {
      return const TasksReadResult(tasks: []);
    }

    try {
      final jsonList = jsonDecode(jsonString) as List<dynamic>;
      final tasks = jsonList
          .map((json) => TaskModel.fromJson(json as Map<String, dynamic>))
          .toList();
      return TasksReadResult(tasks: tasks);
    } catch (e) {
      debugPrint('[TaskLocalDataSource] JSON corrompido, retornando lista vazia: $e');
      await sharedPreferences.remove(_tasksKey);
      return const TasksReadResult(tasks: [], recoveredFromCorruption: true);
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
