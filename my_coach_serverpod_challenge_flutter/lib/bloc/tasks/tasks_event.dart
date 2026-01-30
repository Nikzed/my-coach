import 'package:equatable/equatable.dart';
import 'package:my_coach_serverpod_challenge_client/my_coach_serverpod_challenge_client.dart';

abstract class TasksEvent extends Equatable {
  const TasksEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load all tasks
class TasksLoadRequested extends TasksEvent {
  const TasksLoadRequested();
}

/// Event to create a new task
class TaskCreateRequested extends TasksEvent {
  final Task task;

  const TaskCreateRequested({required this.task});

  @override
  List<Object?> get props => [task];
}

/// Event to complete a task
class TaskCompleteRequested extends TasksEvent {
  final int taskId;

  const TaskCompleteRequested({required this.taskId});

  @override
  List<Object?> get props => [taskId];
}

/// Event to delete a task
class TaskDeleteRequested extends TasksEvent {
  final int taskId;

  const TaskDeleteRequested({required this.taskId});

  @override
  List<Object?> get props => [taskId];
}

/// Event to update a task
class TaskUpdateRequested extends TasksEvent {
  final Task task;

  const TaskUpdateRequested({required this.task});

  @override
  List<Object?> get props => [task];
}

/// Event to load subtasks for a task
class SubtasksLoadRequested extends TasksEvent {
  final int taskId;

  const SubtasksLoadRequested({required this.taskId});

  @override
  List<Object?> get props => [taskId];
}

/// Event to complete a subtask
class SubtaskCompleteRequested extends TasksEvent {
  final int subtaskId;

  const SubtaskCompleteRequested({required this.subtaskId});

  @override
  List<Object?> get props => [subtaskId];
}

/// Event to add a subtask to a task
class SubtaskAddRequested extends TasksEvent {
  final int taskId;
  final String name;

  const SubtaskAddRequested({required this.taskId, required this.name});

  @override
  List<Object?> get props => [taskId, name];
}

/// Event to uncomplete a task (mark as pending again)
class TaskUncompleteRequested extends TasksEvent {
  final int taskId;

  const TaskUncompleteRequested({required this.taskId});

  @override
  List<Object?> get props => [taskId];
}

/// Event to uncomplete a subtask (mark as pending again)
class SubtaskUncompleteRequested extends TasksEvent {
  final int subtaskId;

  const SubtaskUncompleteRequested({required this.subtaskId});

  @override
  List<Object?> get props => [subtaskId];
}

/// Event to update a subtask's name
class SubtaskUpdateRequested extends TasksEvent {
  final int subtaskId;
  final int taskId;
  final String name;

  const SubtaskUpdateRequested({
    required this.subtaskId,
    required this.taskId,
    required this.name,
  });

  @override
  List<Object?> get props => [subtaskId, taskId, name];
}

/// Event to load reminders for a task
class RemindersLoadRequested extends TasksEvent {
  final int taskId;

  const RemindersLoadRequested({required this.taskId});

  @override
  List<Object?> get props => [taskId];
}

/// Event to add a reminder to a task
class ReminderAddRequested extends TasksEvent {
  final int taskId;
  final int minutesBefore;

  const ReminderAddRequested({
    required this.taskId,
    required this.minutesBefore,
  });

  @override
  List<Object?> get props => [taskId, minutesBefore];
}

/// Event to remove a reminder from a task
class ReminderRemoveRequested extends TasksEvent {
  final int reminderId;
  final int taskId;

  const ReminderRemoveRequested({
    required this.reminderId,
    required this.taskId,
  });

  @override
  List<Object?> get props => [reminderId, taskId];
}

/// Event to create a task with reminders
class TaskCreateWithRemindersRequested extends TasksEvent {
  final Task task;
  final List<int> reminderMinutes;

  const TaskCreateWithRemindersRequested({
    required this.task,
    required this.reminderMinutes,
  });

  @override
  List<Object?> get props => [task, reminderMinutes];
}
