import 'package:equatable/equatable.dart';

abstract class CoachesEvent extends Equatable {
  const CoachesEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load all coaches
class CoachesLoadRequested extends CoachesEvent {
  const CoachesLoadRequested();
}

/// Event to load a specific coach by ID
class CoachLoadByIdRequested extends CoachesEvent {
  final int coachId;

  const CoachLoadByIdRequested({required this.coachId});

  @override
  List<Object?> get props => [coachId];
}

/// Event to load messages for a task
class CoachMessagesLoadRequested extends CoachesEvent {
  final int taskId;

  const CoachMessagesLoadRequested({required this.taskId});

  @override
  List<Object?> get props => [taskId];
}
