import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';

/// Endpoint for managing subtasks.
class SubtaskEndpoint extends Endpoint {
  /// Requires authentication for all methods.
  @override
  bool get requireLogin => true;

  /// Gets all subtasks for a task.
  ///
  /// [taskId] - The ID of the parent task
  ///
  /// Returns a list of subtasks ordered by orderIndex.
  Future<List<Subtask>> getSubtasks(Session session, int taskId) async {
    final auth = session.authenticated;
    if (auth == null) {
      throw Exception('User must be authenticated');
    }

    // Verify task ownership
    final task = await Task.db.findById(session, taskId);
    if (task == null) {
      throw ArgumentError('Task not found');
    }
    if (task.userId != auth.userIdentifier) {
      throw Exception('Not authorized to view subtasks for this task');
    }

    return await Subtask.db.find(
      session,
      where: (s) => s.taskId.equals(taskId),
      orderBy: (s) => s.orderIndex,
    );
  }

  /// Marks a subtask as completed.
  ///
  /// [subtaskId] - The ID of the subtask to complete
  ///
  /// Returns the updated subtask.
  Future<Subtask> completeSubtask(Session session, int subtaskId) async {
    final auth = session.authenticated;
    if (auth == null) {
      throw Exception('User must be authenticated');
    }

    final subtask = await Subtask.db.findById(session, subtaskId);
    if (subtask == null) {
      throw ArgumentError('Subtask not found');
    }

    // Verify task ownership
    final task = await Task.db.findById(session, subtask.taskId);
    if (task == null) {
      throw ArgumentError('Parent task not found');
    }
    if (task.userId != auth.userIdentifier) {
      throw Exception('Not authorized to complete this subtask');
    }

    subtask.isCompleted = true;
    subtask.completedAt = DateTime.now();

    return await Subtask.db.updateRow(session, subtask);
  }

  /// Marks a subtask as incomplete.
  ///
  /// [subtaskId] - The ID of the subtask to uncomplete
  ///
  /// Returns the updated subtask.
  Future<Subtask> uncompleteSubtask(Session session, int subtaskId) async {
    final auth = session.authenticated;
    if (auth == null) {
      throw Exception('User must be authenticated');
    }

    final subtask = await Subtask.db.findById(session, subtaskId);
    if (subtask == null) {
      throw ArgumentError('Subtask not found');
    }

    // Verify task ownership
    final task = await Task.db.findById(session, subtask.taskId);
    if (task == null) {
      throw ArgumentError('Parent task not found');
    }
    if (task.userId != auth.userIdentifier) {
      throw Exception('Not authorized to modify this subtask');
    }

    subtask.isCompleted = false;
    subtask.completedAt = null;

    return await Subtask.db.updateRow(session, subtask);
  }

  /// Adds a new subtask to a task.
  ///
  /// [taskId] - The ID of the parent task
  /// [name] - The name/description of the subtask
  ///
  /// Returns the created subtask.
  Future<Subtask> addSubtask(Session session, int taskId, String name) async {
    final auth = session.authenticated;
    if (auth == null) {
      throw Exception('User must be authenticated');
    }

    // Verify task ownership
    final task = await Task.db.findById(session, taskId);
    if (task == null) {
      throw ArgumentError('Task not found');
    }
    if (task.userId != auth.userIdentifier) {
      throw Exception('Not authorized to add subtasks to this task');
    }

    // Get the max order index
    final existingSubtasks = await Subtask.db.find(
      session,
      where: (s) => s.taskId.equals(taskId),
      orderBy: (s) => s.orderIndex,
      orderDescending: true,
      limit: 1,
    );

    final newOrderIndex =
        existingSubtasks.isEmpty ? 0 : existingSubtasks.first.orderIndex + 1;

    final subtask = Subtask(
      taskId: taskId,
      name: name,
      orderIndex: newOrderIndex,
      isCompleted: false,
      completedAt: null,
    );

    return await Subtask.db.insertRow(session, subtask);
  }

  /// Updates a subtask's name.
  ///
  /// [subtaskId] - The ID of the subtask to update
  /// [name] - The new name for the subtask
  ///
  /// Returns the updated subtask.
  Future<Subtask> updateSubtask(
    Session session,
    int subtaskId,
    String name,
  ) async {
    final auth = session.authenticated;
    if (auth == null) {
      throw Exception('User must be authenticated');
    }

    final subtask = await Subtask.db.findById(session, subtaskId);
    if (subtask == null) {
      throw ArgumentError('Subtask not found');
    }

    // Verify task ownership
    final task = await Task.db.findById(session, subtask.taskId);
    if (task == null) {
      throw ArgumentError('Parent task not found');
    }
    if (task.userId != auth.userIdentifier) {
      throw Exception('Not authorized to update this subtask');
    }

    subtask.name = name;

    return await Subtask.db.updateRow(session, subtask);
  }

  /// Deletes a subtask.
  ///
  /// [subtaskId] - The ID of the subtask to delete
  Future<void> deleteSubtask(Session session, int subtaskId) async {
    final auth = session.authenticated;
    if (auth == null) {
      throw Exception('User must be authenticated');
    }

    final subtask = await Subtask.db.findById(session, subtaskId);
    if (subtask == null) {
      throw ArgumentError('Subtask not found');
    }

    // Verify task ownership
    final task = await Task.db.findById(session, subtask.taskId);
    if (task == null) {
      throw ArgumentError('Parent task not found');
    }
    if (task.userId != auth.userIdentifier) {
      throw Exception('Not authorized to delete this subtask');
    }

    await Subtask.db.deleteRow(session, subtask);
  }

  /// Reorders subtasks within a task.
  ///
  /// [subtaskIds] - List of subtask IDs in the desired order
  Future<void> reorderSubtasks(Session session, List<int> subtaskIds) async {
    final auth = session.authenticated;
    if (auth == null) {
      throw Exception('User must be authenticated');
    }

    if (subtaskIds.isEmpty) {
      return;
    }

    // Get the first subtask to verify task ownership
    final firstSubtask = await Subtask.db.findById(session, subtaskIds.first);
    if (firstSubtask == null) {
      throw ArgumentError('Subtask not found');
    }

    final task = await Task.db.findById(session, firstSubtask.taskId);
    if (task == null) {
      throw ArgumentError('Parent task not found');
    }
    if (task.userId != auth.userIdentifier) {
      throw Exception('Not authorized to reorder subtasks for this task');
    }

    // Update order indexes
    for (int i = 0; i < subtaskIds.length; i++) {
      final subtask = await Subtask.db.findById(session, subtaskIds[i]);
      if (subtask != null && subtask.taskId == firstSubtask.taskId) {
        subtask.orderIndex = i;
        await Subtask.db.updateRow(session, subtask);
      }
    }
  }
}
