import 'package:equatable/equatable.dart';
import 'package:my_coach_serverpod_challenge_client/my_coach_serverpod_challenge_client.dart';

import '../../models/stt_models.dart';

enum VoiceInputStatus {
  initial,
  permissionRequired,
  ready,
  listening,
  processing,
  draftReady,
  needsClarification,
  voiceClarificationListening, // New: listening for voice clarification answer
  confirming,
  success,
  failure,
}

class VoiceInputState extends Equatable {
  final VoiceInputStatus status;
  final String? transcribedText;
  final String? liveText; // Text being spoken (interim results)
  final VoiceTaskDraft? draft;
  final Task? createdTask;
  final String? error;
  final bool hasPermission;

  // New fields for ElevenLabs STT integration
  final SttConnectionState connectionState;
  final bool isVoiceClarificationMode;
  final String? clarificationVoiceText; // Live text during voice clarification
  final String? clarificationSessionId; // Session ID for voice clarification

  const VoiceInputState({
    this.status = VoiceInputStatus.initial,
    this.transcribedText,
    this.liveText,
    this.draft,
    this.createdTask,
    this.error,
    this.hasPermission = false,
    this.connectionState = SttConnectionState.disconnected,
    this.isVoiceClarificationMode = false,
    this.clarificationVoiceText,
    this.clarificationSessionId,
  });

  const VoiceInputState.initial()
      : status = VoiceInputStatus.initial,
        transcribedText = null,
        liveText = null,
        draft = null,
        createdTask = null,
        error = null,
        hasPermission = false,
        connectionState = SttConnectionState.disconnected,
        isVoiceClarificationMode = false,
        clarificationVoiceText = null,
        clarificationSessionId = null;

  VoiceInputState copyWith({
    VoiceInputStatus? status,
    String? transcribedText,
    String? liveText,
    VoiceTaskDraft? draft,
    Task? createdTask,
    String? error,
    bool? hasPermission,
    SttConnectionState? connectionState,
    bool? isVoiceClarificationMode,
    String? clarificationVoiceText,
    String? clarificationSessionId,
    bool clearTranscribedText = false,
    bool clearLiveText = false,
    bool clearDraft = false,
    bool clearCreatedTask = false,
    bool clearError = false,
    bool clearClarificationVoiceText = false,
    bool clearClarificationSessionId = false,
  }) {
    return VoiceInputState(
      status: status ?? this.status,
      transcribedText: clearTranscribedText ? null : (transcribedText ?? this.transcribedText),
      liveText: clearLiveText ? null : (liveText ?? this.liveText),
      draft: clearDraft ? null : (draft ?? this.draft),
      createdTask: clearCreatedTask ? null : (createdTask ?? this.createdTask),
      error: clearError ? null : (error ?? this.error),
      hasPermission: hasPermission ?? this.hasPermission,
      connectionState: connectionState ?? this.connectionState,
      isVoiceClarificationMode: isVoiceClarificationMode ?? this.isVoiceClarificationMode,
      clarificationVoiceText: clearClarificationVoiceText
          ? null
          : (clarificationVoiceText ?? this.clarificationVoiceText),
      clarificationSessionId: clearClarificationSessionId
          ? null
          : (clarificationSessionId ?? this.clarificationSessionId),
    );
  }

  /// Check if currently listening to voice input
  bool get isListening =>
      status == VoiceInputStatus.listening ||
      status == VoiceInputStatus.voiceClarificationListening;

  /// Check if processing AI parsing
  bool get isProcessing => status == VoiceInputStatus.processing;

  /// Check if draft is ready for confirmation
  bool get isDraftReady => status == VoiceInputStatus.draftReady;

  /// Check if clarification is needed
  bool get needsClarification => status == VoiceInputStatus.needsClarification;

  /// Check if listening for voice clarification
  bool get isVoiceClarificationListening =>
      status == VoiceInputStatus.voiceClarificationListening;

  /// Check if STT is connected
  bool get isSttConnected => connectionState == SttConnectionState.connected;

  /// Check if STT is reconnecting
  bool get isSttReconnecting => connectionState == SttConnectionState.reconnecting;

  /// Get the clarification question from draft
  String? get clarificationQuestion => draft?.clarificationQuestion;

  /// Get parsed task name from draft
  String? get parsedName => draft?.parsedName;

  /// Get parsed description from draft
  String? get parsedDescription => draft?.parsedDescription;

  /// Get parsed due time from draft
  String? get parsedDueTime => draft?.parsedDueTime;

  /// Get suggested coach ID from draft
  int? get suggestedCoachId => draft?.suggestedCoachId;

  /// Get coach confidence from draft
  double? get coachConfidence => draft?.coachConfidence;

  @override
  List<Object?> get props => [
        status,
        transcribedText,
        liveText,
        draft,
        createdTask,
        error,
        hasPermission,
        connectionState,
        isVoiceClarificationMode,
        clarificationVoiceText,
        clarificationSessionId,
      ];
}
