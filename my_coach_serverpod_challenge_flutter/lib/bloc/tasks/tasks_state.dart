import 'package:equatable/equatable.dart';
import 'package:my_coach_serverpod_challenge_client/my_coach_serverpod_challenge_client.dart';

enum TasksStatus { initial, loading, success, failure }

class TasksState extends Equatable {
  final TasksStatus status;
  final List<Task> tasks;
  final String? error;
  final Task? lastCreatedTask;
  final Map<int, List<Subtask>> subtasksByTaskId;
  final Map<int, List<TaskReminder>> remindersByTaskId;

  const TasksState({
    this.status = TasksStatus.initial,
    this.tasks = const [],
    this.error,
    this.lastCreatedTask,
    this.subtasksByTaskId = const {},
    this.remindersByTaskId = const {},
  });

  const TasksState.initial() : this();

  TasksState copyWith({
    TasksStatus? status,
    List<Task>? tasks,
    String? error,
    Task? lastCreatedTask,
    Map<int, List<Subtask>>? subtasksByTaskId,
    Map<int, List<TaskReminder>>? remindersByTaskId,
  }) {
    return TasksState(
      status: status ?? this.status,
      tasks: tasks ?? this.tasks,
      error: error,
      lastCreatedTask: lastCreatedTask,
      subtasksByTaskId: subtasksByTaskId ?? this.subtasksByTaskId,
      remindersByTaskId: remindersByTaskId ?? this.remindersByTaskId,
    );
  }

  /// Get pending tasks only
  List<Task> get pendingTasks => tasks.where((t) => !t.isCompleted).toList();

  /// Check if currently loading
  bool get isLoading => status == TasksStatus.loading;

  /// Check if has error
  bool get hasError => status == TasksStatus.failure;

  /// Get subtasks for a specific task
  List<Subtask>? getSubtasksForTask(int taskId) => subtasksByTaskId[taskId];

  /// Get subtask progress for a task (completed / total)
  (int, int)? getSubtaskProgress(int taskId) {
    final subtasks = subtasksByTaskId[taskId];
    if (subtasks == null || subtasks.isEmpty) return null;
    final completed = subtasks.where((s) => s.isCompleted).length;
    return (completed, subtasks.length);
  }

  /// Get reminders for a specific task
  List<TaskReminder>? getRemindersForTask(int taskId) =>
      remindersByTaskId[taskId];

  @override
  List<Object?> get props => [
        status,
        tasks,
        error,
        lastCreatedTask,
        subtasksByTaskId,
        remindersByTaskId,
      ];
}
