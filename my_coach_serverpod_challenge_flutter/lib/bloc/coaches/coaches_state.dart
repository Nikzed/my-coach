import 'package:equatable/equatable.dart';
import 'package:my_coach_serverpod_challenge_client/my_coach_serverpod_challenge_client.dart';

enum CoachesStatus { initial, loading, success, failure }

class CoachesState extends Equatable {
  final CoachesStatus status;
  final List<Coach> coaches;
  final Map<int, Coach> coachesById;
  final Map<int, List<CoachMessage>> messagesByTaskId;
  final String? error;

  const CoachesState({
    this.status = CoachesStatus.initial,
    this.coaches = const [],
    this.coachesById = const {},
    this.messagesByTaskId = const {},
    this.error,
  });

  const CoachesState.initial() : this();

  CoachesState copyWith({
    CoachesStatus? status,
    List<Coach>? coaches,
    Map<int, Coach>? coachesById,
    Map<int, List<CoachMessage>>? messagesByTaskId,
    String? error,
  }) {
    return CoachesState(
      status: status ?? this.status,
      coaches: coaches ?? this.coaches,
      coachesById: coachesById ?? this.coachesById,
      messagesByTaskId: messagesByTaskId ?? this.messagesByTaskId,
      error: error,
    );
  }

  /// Get a coach by ID from the cache
  Coach? getCoachById(int id) => coachesById[id];

  /// Get messages for a specific task
  List<CoachMessage>? getMessagesForTask(int taskId) => messagesByTaskId[taskId];

  /// Check if currently loading
  bool get isLoading => status == CoachesStatus.loading;

  @override
  List<Object?> get props => [status, coaches, coachesById, messagesByTaskId, error];
}
