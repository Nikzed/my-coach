import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_coach_serverpod_challenge_client/my_coach_serverpod_challenge_client.dart';

import 'tasks_event.dart';
import 'tasks_state.dart';

class TasksBloc extends Bloc<TasksEvent, TasksState> {
  final Client client;

  TasksBloc({required this.client}) : super(const TasksState.initial()) {
    on<TasksLoadRequested>(_onLoadRequested);
    on<TaskCreateRequested>(_onCreateRequested);
    on<TaskCreateWithRemindersRequested>(_onCreateWithRemindersRequested);
    on<TaskCompleteRequested>(_onCompleteRequested);
    on<TaskUncompleteRequested>(_onUncompleteRequested);
    on<TaskDeleteRequested>(_onDeleteRequested);
    on<TaskUpdateRequested>(_onUpdateRequested);
    on<SubtasksLoadRequested>(_onSubtasksLoadRequested);
    on<SubtaskCompleteRequested>(_onSubtaskCompleteRequested);
    on<SubtaskUncompleteRequested>(_onSubtaskUncompleteRequested);
    on<SubtaskAddRequested>(_onSubtaskAddRequested);
    on<SubtaskUpdateRequested>(_onSubtaskUpdateRequested);
    on<RemindersLoadRequested>(_onRemindersLoadRequested);
    on<ReminderAddRequested>(_onReminderAddRequested);
    on<ReminderRemoveRequested>(_onReminderRemoveRequested);
  }

  Future<void> _onLoadRequested(
    TasksLoadRequested event,
    Emitter<TasksState> emit,
  ) async {
    emit(state.copyWith(status: TasksStatus.loading));
    try {
      final tasks = await client.task.getUserTasks();
      emit(state.copyWith(
        status: TasksStatus.success,
        tasks: tasks,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: TasksStatus.failure,
        error: e.toString(),
      ));
    }
  }

  Future<void> _onCreateRequested(
    TaskCreateRequested event,
    Emitter<TasksState> emit,
  ) async {
    emit(state.copyWith(status: TasksStatus.loading));
    try {
      final newTask = await client.task.createTask(event.task);
      // Reload all tasks to get fresh data
      final tasks = await client.task.getUserTasks();
      emit(state.copyWith(
        status: TasksStatus.success,
        tasks: tasks,
        lastCreatedTask: newTask,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: TasksStatus.failure,
        error: e.toString(),
      ));
    }
  }

  Future<void> _onCompleteRequested(
    TaskCompleteRequested event,
    Emitter<TasksState> emit,
  ) async {
    try {
      await client.task.completeTask(event.taskId);
      // Reload tasks
      final tasks = await client.task.getUserTasks();
      emit(state.copyWith(
        status: TasksStatus.success,
        tasks: tasks,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: TasksStatus.failure,
        error: e.toString(),
      ));
    }
  }

  Future<void> _onUncompleteRequested(
    TaskUncompleteRequested event,
    Emitter<TasksState> emit,
  ) async {
    try {
      await client.task.uncompleteTask(event.taskId);
      // Reload tasks
      final tasks = await client.task.getUserTasks();
      emit(state.copyWith(
        status: TasksStatus.success,
        tasks: tasks,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: TasksStatus.failure,
        error: e.toString(),
      ));
    }
  }

  Future<void> _onDeleteRequested(
    TaskDeleteRequested event,
    Emitter<TasksState> emit,
  ) async {
    try {
      await client.task.deleteTask(event.taskId);
      // Reload tasks
      final tasks = await client.task.getUserTasks();
      emit(state.copyWith(
        status: TasksStatus.success,
        tasks: tasks,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: TasksStatus.failure,
        error: e.toString(),
      ));
    }
  }

  Future<void> _onUpdateRequested(
    TaskUpdateRequested event,
    Emitter<TasksState> emit,
  ) async {
    try {
      await client.task.updateTask(event.task);
      // Reload tasks
      final tasks = await client.task.getUserTasks();
      emit(state.copyWith(
        status: TasksStatus.success,
        tasks: tasks,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: TasksStatus.failure,
        error: e.toString(),
      ));
    }
  }

  Future<void> _onSubtasksLoadRequested(
    SubtasksLoadRequested event,
    Emitter<TasksState> emit,
  ) async {
    try {
      final subtasks = await client.subtask.getSubtasks(event.taskId);
      final newSubtasksByTaskId = Map<int, List<Subtask>>.from(state.subtasksByTaskId);
      newSubtasksByTaskId[event.taskId] = subtasks;
      emit(state.copyWith(
        subtasksByTaskId: newSubtasksByTaskId,
      ));
    } catch (e) {
      // Silently fail - subtasks are optional
    }
  }

  Future<void> _onSubtaskCompleteRequested(
    SubtaskCompleteRequested event,
    Emitter<TasksState> emit,
  ) async {
    try {
      final subtask = await client.subtask.completeSubtask(event.subtaskId);
      // Update the cached subtasks
      final taskId = subtask.taskId;
      final subtasks = await client.subtask.getSubtasks(taskId);
      final newSubtasksByTaskId = Map<int, List<Subtask>>.from(state.subtasksByTaskId);
      newSubtasksByTaskId[taskId] = subtasks;
      emit(state.copyWith(
        subtasksByTaskId: newSubtasksByTaskId,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: TasksStatus.failure,
        error: e.toString(),
      ));
    }
  }

  Future<void> _onSubtaskUncompleteRequested(
    SubtaskUncompleteRequested event,
    Emitter<TasksState> emit,
  ) async {
    try {
      final subtask = await client.subtask.uncompleteSubtask(event.subtaskId);
      // Update the cached subtasks
      final taskId = subtask.taskId;
      final subtasks = await client.subtask.getSubtasks(taskId);
      final newSubtasksByTaskId = Map<int, List<Subtask>>.from(state.subtasksByTaskId);
      newSubtasksByTaskId[taskId] = subtasks;
      emit(state.copyWith(
        subtasksByTaskId: newSubtasksByTaskId,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: TasksStatus.failure,
        error: e.toString(),
      ));
    }
  }

  Future<void> _onSubtaskAddRequested(
    SubtaskAddRequested event,
    Emitter<TasksState> emit,
  ) async {
    try {
      await client.subtask.addSubtask(event.taskId, event.name);
      // Reload subtasks for this task
      final subtasks = await client.subtask.getSubtasks(event.taskId);
      final newSubtasksByTaskId = Map<int, List<Subtask>>.from(state.subtasksByTaskId);
      newSubtasksByTaskId[event.taskId] = subtasks;
      emit(state.copyWith(
        subtasksByTaskId: newSubtasksByTaskId,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: TasksStatus.failure,
        error: e.toString(),
      ));
    }
  }

  Future<void> _onSubtaskUpdateRequested(
    SubtaskUpdateRequested event,
    Emitter<TasksState> emit,
  ) async {
    try {
      await client.subtask.updateSubtask(event.subtaskId, event.name);
      // Reload subtasks for this task
      final subtasks = await client.subtask.getSubtasks(event.taskId);
      final newSubtasksByTaskId = Map<int, List<Subtask>>.from(state.subtasksByTaskId);
      newSubtasksByTaskId[event.taskId] = subtasks;
      emit(state.copyWith(
        subtasksByTaskId: newSubtasksByTaskId,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: TasksStatus.failure,
        error: e.toString(),
      ));
    }
  }

  Future<void> _onCreateWithRemindersRequested(
    TaskCreateWithRemindersRequested event,
    Emitter<TasksState> emit,
  ) async {
    emit(state.copyWith(status: TasksStatus.loading));
    try {
      final newTask = await client.task.createTaskWithReminders(
        event.task,
        event.reminderMinutes,
      );
      // Reload all tasks to get fresh data
      final tasks = await client.task.getUserTasks();
      emit(state.copyWith(
        status: TasksStatus.success,
        tasks: tasks,
        lastCreatedTask: newTask,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: TasksStatus.failure,
        error: e.toString(),
      ));
    }
  }

  Future<void> _onRemindersLoadRequested(
    RemindersLoadRequested event,
    Emitter<TasksState> emit,
  ) async {
    try {
      final reminders = await client.taskReminder.getReminders(event.taskId);
      final newRemindersByTaskId =
          Map<int, List<TaskReminder>>.from(state.remindersByTaskId);
      newRemindersByTaskId[event.taskId] = reminders;
      emit(state.copyWith(
        remindersByTaskId: newRemindersByTaskId,
      ));
    } catch (e) {
      // Silently fail - reminders are optional
    }
  }

  Future<void> _onReminderAddRequested(
    ReminderAddRequested event,
    Emitter<TasksState> emit,
  ) async {
    try {
      await client.taskReminder.addReminder(event.taskId, event.minutesBefore);
      // Reload reminders for this task
      final reminders = await client.taskReminder.getReminders(event.taskId);
      final newRemindersByTaskId =
          Map<int, List<TaskReminder>>.from(state.remindersByTaskId);
      newRemindersByTaskId[event.taskId] = reminders;
      emit(state.copyWith(
        remindersByTaskId: newRemindersByTaskId,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: TasksStatus.failure,
        error: e.toString(),
      ));
    }
  }

  Future<void> _onReminderRemoveRequested(
    ReminderRemoveRequested event,
    Emitter<TasksState> emit,
  ) async {
    try {
      await client.taskReminder.removeReminder(event.reminderId);
      // Reload reminders for this task
      final reminders = await client.taskReminder.getReminders(event.taskId);
      final newRemindersByTaskId =
          Map<int, List<TaskReminder>>.from(state.remindersByTaskId);
      newRemindersByTaskId[event.taskId] = reminders;
      emit(state.copyWith(
        remindersByTaskId: newRemindersByTaskId,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: TasksStatus.failure,
        error: e.toString(),
      ));
    }
  }
}
