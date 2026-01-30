import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';

/// Endpoint for managing user tasks with CRUD operations.
class TaskEndpoint extends Endpoint {
  /// Requires authentication for all methods in this endpoint.
  @override
  bool get requireLogin => true;

  /// Creates a new task for the authenticated user.
  /// If dueTime is set, default reminders (30 min before + at due time) are created.
  Future<Task> createTask(Session session, Task task) async {
    final auth = session.authenticated;
    if (auth == null) {
      throw Exception('User must be authenticated');
    }

    // Set server-side fields
    task.userId = auth.userIdentifier;
    task.isCompleted = false;
    task.createdAt = DateTime.now();
    task.completedAt = null;

    final createdTask = await Task.db.insertRow(session, task);

    // Add default reminders if task has a due time
    if (createdTask.dueTime != null) {
      await _createDefaultReminders(session, createdTask.id!);
    }

    return createdTask;
  }

  /// Creates a new task with custom reminder settings.
  ///
  /// [task] - The task to create
  /// [reminderMinutes] - List of minutesBefore values for reminders
  ///   - Empty list = no reminders
  ///   - null = use defaults (30 min before + at due time)
  ///
  /// Returns the created task.
  Future<Task> createTaskWithReminders(
    Session session,
    Task task,
    List<int>? reminderMinutes,
  ) async {
    final auth = session.authenticated;
    if (auth == null) {
      throw Exception('User must be authenticated');
    }

    // Set server-side fields
    task.userId = auth.userIdentifier;
    task.isCompleted = false;
    task.createdAt = DateTime.now();
    task.completedAt = null;

    final createdTask = await Task.db.insertRow(session, task);

    // Create reminders if task has a due time
    if (createdTask.dueTime != null) {
      if (reminderMinutes == null) {
        // Use defaults
        await _createDefaultReminders(session, createdTask.id!);
      } else if (reminderMinutes.isNotEmpty) {
        // Calculate minutes until due to skip past reminders
        final now = DateTime.now();
        final minutesUntilDue =
            createdTask.dueTime!.difference(now).inMinutes;

        // Use custom reminders, skipping those that would be in the past
        for (final minutes in reminderMinutes) {
          if (minutes > minutesUntilDue) {
            session.log(
              'Skipping reminder $minutes min before - already passed '
              '(due in $minutesUntilDue min)',
              level: LogLevel.info,
            );
            continue;
          }

          final reminder = TaskReminder(
            taskId: createdTask.id!,
            minutesBefore: minutes,
            isSent: false,
            sentAt: null,
          );
          await TaskReminder.db.insertRow(session, reminder);
        }
      }
      // If reminderMinutes is empty, no reminders are created
    }

    return createdTask;
  }

  /// Creates default reminders (at due time only) for a task.
  Future<void> _createDefaultReminders(Session session, int taskId) async {
    final defaultMinutes = [0];
    for (final minutes in defaultMinutes) {
      final reminder = TaskReminder(
        taskId: taskId,
        minutesBefore: minutes,
        isSent: false,
        sentAt: null,
      );
      await TaskReminder.db.insertRow(session, reminder);
    }
  }

  /// Updates an existing task owned by the authenticated user.
  Future<Task> updateTask(Session session, Task task) async {
    final auth = session.authenticated;
    if (auth == null) {
      throw Exception('User must be authenticated');
    }

    // Verify ownership
    final existingTask = await Task.db.findById(session, task.id!);
    if (existingTask == null) {
      throw ArgumentError('Task not found');
    }
    if (existingTask.userId != auth.userIdentifier) {
      throw Exception('Not authorized to update this task');
    }

    // Preserve server-managed fields
    task.userId = auth.userIdentifier;
    task.createdAt = existingTask.createdAt;

    final updatedTask = await Task.db.updateRow(session, task);

    // If due time changed from null to set, add default reminders
    if (existingTask.dueTime == null && updatedTask.dueTime != null) {
      await _createDefaultReminders(session, updatedTask.id!);
    }

    // If due time removed, delete all reminders
    if (existingTask.dueTime != null && updatedTask.dueTime == null) {
      await TaskReminder.db.deleteWhere(
        session,
        where: (r) => r.taskId.equals(updatedTask.id!),
      );
    }

    // If due time changed to a different non-null value, reset all
    // sent reminders so they fire again at the new time
    if (existingTask.dueTime != null &&
        updatedTask.dueTime != null &&
        existingTask.dueTime != updatedTask.dueTime) {
      final reminders = await TaskReminder.db.find(
        session,
        where: (r) =>
            r.taskId.equals(updatedTask.id!) & r.isSent.equals(true),
      );
      for (final reminder in reminders) {
        reminder.isSent = false;
        reminder.sentAt = null;
        await TaskReminder.db.updateRow(session, reminder);
      }
    }

    return updatedTask;
  }

  /// Deletes a task owned by the authenticated user.
  /// Also deletes associated coach messages, reminders, and subtasks.
  /// Returns the number of deleted tasks.
  Future<int> deleteTask(Session session, int taskId) async {
    final auth = session.authenticated;
    if (auth == null) {
      throw Exception('User must be authenticated');
    }

    final task = await Task.db.findById(session, taskId);
    if (task == null) {
      throw ArgumentError('Task not found');
    }
    if (task.userId != auth.userIdentifier) {
      throw Exception('Not authorized to delete this task');
    }

    // Delete related entities (to avoid FK constraint violations)
    await CoachMessage.db.deleteWhere(
      session,
      where: (m) => m.taskId.equals(taskId),
    );
    await TaskReminder.db.deleteWhere(
      session,
      where: (r) => r.taskId.equals(taskId),
    );
    await Subtask.db.deleteWhere(
      session,
      where: (s) => s.taskId.equals(taskId),
    );

    final deleted = await Task.db.deleteWhere(
      session,
      where: (t) => t.id.equals(taskId),
    );
    return deleted.length;
  }

  /// Marks a task as completed.
  /// Also marks all pending reminders as sent.
  Future<Task> completeTask(Session session, int taskId) async {
    final auth = session.authenticated;
    if (auth == null) {
      throw Exception('User must be authenticated');
    }

    final task = await Task.db.findById(session, taskId);
    if (task == null) {
      throw ArgumentError('Task not found');
    }
    if (task.userId != auth.userIdentifier) {
      throw Exception('Not authorized to complete this task');
    }

    task.isCompleted = true;
    task.completedAt = DateTime.now();

    // Mark all pending reminders as sent (to prevent late notifications)
    final pendingReminders = await TaskReminder.db.find(
      session,
      where: (r) => r.taskId.equals(taskId) & r.isSent.equals(false),
    );
    for (final reminder in pendingReminders) {
      reminder.isSent = true;
      reminder.sentAt = task.completedAt;
      await TaskReminder.db.updateRow(session, reminder);
    }

    return await Task.db.updateRow(session, task);
  }

  /// Gets all tasks for the authenticated user.
  Future<List<Task>> getUserTasks(Session session) async {
    final auth = session.authenticated;
    if (auth == null) {
      throw Exception('User must be authenticated');
    }

    return await Task.db.find(
      session,
      where: (t) => t.userId.equals(auth.userIdentifier),
      orderBy: (t) => t.createdAt,
      orderDescending: true,
    );
  }

  /// Gets all incomplete tasks for the authenticated user.
  Future<List<Task>> getPendingTasks(Session session) async {
    final auth = session.authenticated;
    if (auth == null) {
      throw Exception('User must be authenticated');
    }

    return await Task.db.find(
      session,
      where: (t) =>
          t.userId.equals(auth.userIdentifier) & t.isCompleted.equals(false),
      orderBy: (t) => t.dueTime,
    );
  }

  /// Marks a completed task as incomplete (uncomplete).
  /// Resets reminders if task has a due time in the future.
  Future<Task> uncompleteTask(Session session, int taskId) async {
    final auth = session.authenticated;
    if (auth == null) {
      throw Exception('User must be authenticated');
    }

    final task = await Task.db.findById(session, taskId);
    if (task == null) {
      throw ArgumentError('Task not found');
    }
    if (task.userId != auth.userIdentifier) {
      throw Exception('Not authorized to modify this task');
    }

    task.isCompleted = false;
    task.completedAt = null;

    // Reset reminders if task has a due time in the future
    if (task.dueTime != null && task.dueTime!.isAfter(DateTime.now())) {
      final existingReminders = await TaskReminder.db.find(
        session,
        where: (r) => r.taskId.equals(taskId),
      );
      for (final reminder in existingReminders) {
        reminder.isSent = false;
        reminder.sentAt = null;
        await TaskReminder.db.updateRow(session, reminder);
      }
    }

    return await Task.db.updateRow(session, task);
  }
}
