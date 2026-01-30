import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';

/// Endpoint for managing task reminders.
class TaskReminderEndpoint extends Endpoint {
  /// Requires authentication for all methods.
  @override
  bool get requireLogin => true;

  /// Gets all reminders for a task.
  ///
  /// [taskId] - The ID of the task
  ///
  /// Returns a list of reminders ordered by minutesBefore.
  Future<List<TaskReminder>> getReminders(Session session, int taskId) async {
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
      throw Exception('Not authorized to view reminders for this task');
    }

    return await TaskReminder.db.find(
      session,
      where: (r) => r.taskId.equals(taskId),
      orderBy: (r) => r.minutesBefore,
      orderDescending: true, // Largest (earliest) first
    );
  }

  /// Adds a new reminder to a task.
  ///
  /// [taskId] - The ID of the task
  /// [minutesBefore] - Minutes before due time (0 = at due time)
  ///
  /// Returns the created reminder.
  Future<TaskReminder> addReminder(
    Session session,
    int taskId,
    int minutesBefore,
  ) async {
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
      throw Exception('Not authorized to add reminders to this task');
    }

    // Task must have a due time for reminders to work
    if (task.dueTime == null) {
      throw ArgumentError('Cannot add reminders to a task without a due time');
    }

    // Validate minutesBefore
    if (minutesBefore < 0) {
      throw ArgumentError('Minutes before must be non-negative');
    }

    // Validate reminder time is not in the past
    final now = DateTime.now();
    final minutesUntilDue = task.dueTime!.difference(now).inMinutes;
    if (minutesBefore > minutesUntilDue) {
      throw ArgumentError(
        'Cannot set reminder $minutesBefore minutes before - '
        'deadline is only $minutesUntilDue minutes away',
      );
    }

    // Check for duplicate reminder
    final existing = await TaskReminder.db.findFirstRow(
      session,
      where: (r) =>
          r.taskId.equals(taskId) & r.minutesBefore.equals(minutesBefore),
    );
    if (existing != null) {
      throw ArgumentError('A reminder at this time already exists');
    }

    final reminder = TaskReminder(
      taskId: taskId,
      minutesBefore: minutesBefore,
      isSent: false,
      sentAt: null,
    );

    return await TaskReminder.db.insertRow(session, reminder);
  }

  /// Removes a reminder.
  ///
  /// [reminderId] - The ID of the reminder to remove
  Future<void> removeReminder(Session session, int reminderId) async {
    final auth = session.authenticated;
    if (auth == null) {
      throw Exception('User must be authenticated');
    }

    final reminder = await TaskReminder.db.findById(session, reminderId);
    if (reminder == null) {
      throw ArgumentError('Reminder not found');
    }

    // Verify task ownership
    final task = await Task.db.findById(session, reminder.taskId);
    if (task == null) {
      throw ArgumentError('Task not found');
    }
    if (task.userId != auth.userIdentifier) {
      throw Exception('Not authorized to remove this reminder');
    }

    await TaskReminder.db.deleteRow(session, reminder);
  }

  /// Updates a reminder's time.
  ///
  /// [reminderId] - The ID of the reminder to update
  /// [minutesBefore] - New minutes before due time
  ///
  /// Returns the updated reminder.
  Future<TaskReminder> updateReminder(
    Session session,
    int reminderId,
    int minutesBefore,
  ) async {
    final auth = session.authenticated;
    if (auth == null) {
      throw Exception('User must be authenticated');
    }

    final reminder = await TaskReminder.db.findById(session, reminderId);
    if (reminder == null) {
      throw ArgumentError('Reminder not found');
    }

    // Verify task ownership
    final task = await Task.db.findById(session, reminder.taskId);
    if (task == null) {
      throw ArgumentError('Task not found');
    }
    if (task.userId != auth.userIdentifier) {
      throw Exception('Not authorized to update this reminder');
    }

    // Validate minutesBefore
    if (minutesBefore < 0) {
      throw ArgumentError('Minutes before must be non-negative');
    }

    // Validate reminder time is not in the past
    if (task.dueTime != null) {
      final now = DateTime.now();
      final minutesUntilDue = task.dueTime!.difference(now).inMinutes;
      if (minutesBefore > minutesUntilDue) {
        throw ArgumentError(
          'Cannot set reminder $minutesBefore minutes before - '
          'deadline is only $minutesUntilDue minutes away',
        );
      }
    }

    // Check if already sent (can't change sent reminders)
    if (reminder.isSent) {
      throw Exception('Cannot update a reminder that has already been sent');
    }

    // Check for duplicate
    final existing = await TaskReminder.db.findFirstRow(
      session,
      where: (r) =>
          r.taskId.equals(task.id!) &
          r.minutesBefore.equals(minutesBefore) &
          r.id.notEquals(reminderId),
    );
    if (existing != null) {
      throw ArgumentError('A reminder at this time already exists');
    }

    reminder.minutesBefore = minutesBefore;

    return await TaskReminder.db.updateRow(session, reminder);
  }

  /// Adds default reminders to a task (at due time only).
  ///
  /// [taskId] - The ID of the task
  ///
  /// Returns the list of created reminders.
  Future<List<TaskReminder>> addDefaultReminders(
    Session session,
    int taskId,
  ) async {
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
      throw Exception('Not authorized to add reminders to this task');
    }

    if (task.dueTime == null) {
      throw ArgumentError('Cannot add reminders to a task without a due time');
    }

    final defaultMinutes = [0]; // At due time only
    final createdReminders = <TaskReminder>[];

    for (final minutes in defaultMinutes) {
      // Check if already exists
      final existing = await TaskReminder.db.findFirstRow(
        session,
        where: (r) =>
            r.taskId.equals(taskId) & r.minutesBefore.equals(minutes),
      );

      if (existing == null) {
        final reminder = TaskReminder(
          taskId: taskId,
          minutesBefore: minutes,
          isSent: false,
          sentAt: null,
        );
        createdReminders.add(await TaskReminder.db.insertRow(session, reminder));
      }
    }

    return createdReminders;
  }

  /// Removes all reminders from a task.
  ///
  /// [taskId] - The ID of the task
  ///
  /// Returns the number of removed reminders.
  Future<int> removeAllReminders(Session session, int taskId) async {
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
      throw Exception('Not authorized to remove reminders from this task');
    }

    final deleted = await TaskReminder.db.deleteWhere(
      session,
      where: (r) => r.taskId.equals(taskId),
    );

    return deleted.length;
  }
}
