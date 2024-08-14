import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coaching_admin/models/task.dart';
import 'package:coaching_admin/services/firestore_service.dart';
import 'package:flutter/material.dart';

class TaskProvider with ChangeNotifier {
  final FirestoreService _firestore = FirestoreService();
  late Map<String, List<Task>> _tasksList;
  String? _currentUserId;

  Map<String, List<Task>> get tasksByDeadline => _tasksList;
  String? get currentUserId => _currentUserId;

  Future<Map<String, List<Task>>> fetchTasks(String userId) async {
    // Check if the userId is the same as the current one
    if (_currentUserId == userId) {
      return {};
    }

    try {
      QuerySnapshot snapshot = await _firestore.readDocuments('students',
          docId: userId, subCollectionPath: 'tasks');
      List<Task> tasks =
          snapshot.docs.map((doc) => Task.fromFirestore(doc)).toList();
      _tasksList = {};
      _tasksList = _groupTasksByDeadline(tasks);

      // Update the current userId
      _currentUserId = userId;

      notifyListeners();
      return _tasksList;
    } catch (e) {
      debugPrint('Error fetching tasks: $e');
      return {};
    }
  }

  Map<String, List<Task>> _groupTasksByDeadline(List<Task> tasks) {
    Map<String, List<Task>> groupedTasks = {};

    for (var task in tasks) {
      String dateString =
          DateTime.parse(task.deadline).toLocal().toString().split(' ')[0];

      if (groupedTasks.containsKey(dateString)) {
        groupedTasks[dateString]!.add(task);
      } else {
        groupedTasks[dateString] = [task];
      }
    }

    // Sort keys (deadline dates)
    var sortedKeys = groupedTasks.keys.toList()..sort();
    Map<String, List<Task>> sortedTasks = {
      for (var key in sortedKeys) key: groupedTasks[key]!
    };

    return sortedTasks;
  }

  Future<void> addTask(String userId, Task task) async {
    String dateString =
        DateTime.parse(task.deadline).toLocal().toString().split(' ')[0];
    try {
      // Add task to Firestore
      await _firestore.createDocument(
        'students',
        userId,
        task.toFirestore(),
        subCollectionPath: 'tasks',
      );

      // Ensure the key exists and initialize if necessary
      if (!_tasksList.containsKey(dateString)) {
        _tasksList[dateString] = [];
      }

      // Insert task in sorted order by deadline
      int insertIndex = _tasksList[dateString]!.indexWhere(
        (existingTask) => DateTime.parse(existingTask.deadline)
            .isAfter(DateTime.parse(task.deadline)),
      );

      if (insertIndex == -1) {
        // Append at the end if no tasks with later deadlines found
        _tasksList[dateString]!.add(task);
      } else {
        // Insert at the correct position to maintain sorting
        _tasksList[dateString]!.insert(insertIndex, task);
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding task: $e');
    }
  }

  Future<void> updateTask(String userId, Task updatedTask) async {
    try {
      await _firestore.updateDocument(
          'students', userId, updatedTask.toFirestore(),
          subCollectionPath: 'tasks', subDocId: updatedTask.id);

      _updateMemoryList(updatedTask);
    } catch (e) {
      debugPrint('Error updating task: $e');
    }
  }

  void _updateMemoryList(Task updatedTask) {
    String dateString =
        DateTime.parse(updatedTask.deadline).toLocal().toString().split(' ')[0];

    if (_tasksList.containsKey(dateString)) {
      final index = _tasksList[dateString]!
          .indexWhere((task) => task.id == updatedTask.id);
      if (index != -1) {
        _tasksList[dateString]![index] = updatedTask;
      }
    }
    notifyListeners();
  }
}
