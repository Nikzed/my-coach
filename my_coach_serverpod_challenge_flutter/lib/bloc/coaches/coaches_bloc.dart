import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_coach_serverpod_challenge_client/my_coach_serverpod_challenge_client.dart';

import 'coaches_event.dart';
import 'coaches_state.dart';

class CoachesBloc extends Bloc<CoachesEvent, CoachesState> {
  final Client client;

  CoachesBloc({required this.client}) : super(const CoachesState.initial()) {
    on<CoachesLoadRequested>(_onLoadRequested);
    on<CoachLoadByIdRequested>(_onLoadByIdRequested);
    on<CoachMessagesLoadRequested>(_onMessagesLoadRequested);
  }

  Future<void> _onLoadRequested(
    CoachesLoadRequested event,
    Emitter<CoachesState> emit,
  ) async {
    emit(state.copyWith(status: CoachesStatus.loading));
    try {
      final coaches = await client.coach.getCoaches();
      
      // Build a map for quick lookups
      final coachesById = <int, Coach>{};
      for (final coach in coaches) {
        if (coach.id != null) {
          coachesById[coach.id!] = coach;
        }
      }
      
      emit(state.copyWith(
        status: CoachesStatus.success,
        coaches: coaches,
        coachesById: coachesById,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: CoachesStatus.failure,
        error: e.toString(),
      ));
    }
  }

  Future<void> _onLoadByIdRequested(
    CoachLoadByIdRequested event,
    Emitter<CoachesState> emit,
  ) async {
    // Check if we already have this coach cached
    if (state.coachesById.containsKey(event.coachId)) {
      return;
    }

    try {
      final coach = await client.coach.getCoach(event.coachId);
      if (coach != null) {
        final updatedMap = Map<int, Coach>.from(state.coachesById);
        updatedMap[event.coachId] = coach;
        emit(state.copyWith(coachesById: updatedMap));
      }
    } catch (e) {
      // Silently fail for individual coach loading
    }
  }

  Future<void> _onMessagesLoadRequested(
    CoachMessagesLoadRequested event,
    Emitter<CoachesState> emit,
  ) async {
    try {
      final messages = await client.audio.getMessagesForTask(event.taskId);
      final updatedMessages = Map<int, List<CoachMessage>>.from(state.messagesByTaskId);
      updatedMessages[event.taskId] = messages;
      emit(state.copyWith(messagesByTaskId: updatedMessages));
    } catch (e) {
      // Silently fail for message loading
    }
  }
}
