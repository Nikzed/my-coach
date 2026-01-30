// =============================================================================
// DEPRECATED: This file has been replaced with BLoC pattern
// =============================================================================
// The functionality has been migrated to:
// - lib/bloc/auth/auth_bloc.dart (AuthBloc)
// - lib/bloc/tasks/tasks_bloc.dart (TasksBloc)
// - lib/bloc/coaches/coaches_bloc.dart (CoachesBloc)
//
// Keeping this file for reference during the migration period.
// =============================================================================

// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:my_coach_serverpod_challenge_client/my_coach_serverpod_challenge_client.dart';
// import '../main.dart' show client, authStateNotifier;

// /// Provider for fetching all coaches
// final coachesProvider = FutureProvider<List<Coach>>((ref) async {
//   return await client.coach.getCoaches();
// });

// /// Provider for fetching user tasks
// final tasksProvider = FutureProvider<List<Task>>((ref) async {
//   return await client.task.getUserTasks();
// });

// /// Provider for fetching pending tasks only
// final pendingTasksProvider = FutureProvider<List<Task>>((ref) async {
//   return await client.task.getPendingTasks();
// });

// /// Notifier for managing task operations with state updates
// class TasksNotifier extends StateNotifier<AsyncValue<List<Task>>> {
//   TasksNotifier() : super(const AsyncValue.loading()) {
//     loadTasks();
//   }

//   Future<void> loadTasks() async {
//     state = const AsyncValue.loading();
//     try {
//       final tasks = await client.task.getUserTasks();
//       state = AsyncValue.data(tasks);
//     } catch (e, st) {
//       state = AsyncValue.error(e, st);
//     }
//   }

//   Future<Task> createTask(Task task) async {
//     final newTask = await client.task.createTask(task);
//     await loadTasks();
//     return newTask;
//   }

//   Future<void> completeTask(int taskId) async {
//     await client.task.completeTask(taskId);
//     await loadTasks();
//   }

//   Future<void> deleteTask(int taskId) async {
//     await client.task.deleteTask(taskId);
//     await loadTasks();
//   }

//   Future<void> updateTask(Task task) async {
//     await client.task.updateTask(task);
//     await loadTasks();
//   }
// }

// final tasksNotifierProvider =
//     StateNotifierProvider<TasksNotifier, AsyncValue<List<Task>>>((ref) {
//   return TasksNotifier();
// });

// /// Provider for a specific coach by ID
// final coachByIdProvider = FutureProvider.family<Coach?, int>((ref, id) async {
//   return await client.coach.getCoach(id);
// });

// /// Provider for coach messages for a task
// final taskMessagesProvider =
//     FutureProvider.family<List<CoachMessage>, int>((ref, taskId) async {
//   return await client.audio.getMessagesForTask(taskId);
// });

// /// Provider for getting audio data for a message
// final audioDataProvider =
//     FutureProvider.family<List<int>?, int>((ref, messageId) async {
//   final data = await client.audio.getAudio(messageId);
//   return data?.toList();
// });

// /// Selected coach for new task creation
// final selectedCoachProvider = StateProvider<Coach?>((ref) => null);

// /// Authentication state provider
// final isAuthenticatedProvider = StateProvider<bool>((ref) {
//   return authStateNotifier.value;
// });
