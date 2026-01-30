import 'package:equatable/equatable.dart';

import '../../models/stt_models.dart';

abstract class VoiceInputEvent extends Equatable {
  const VoiceInputEvent();

  @override
  List<Object?> get props => [];
}

/// Start listening for voice input
class VoiceInputStartListening extends VoiceInputEvent {
  const VoiceInputStartListening();
}

/// Stop listening for voice input
class VoiceInputStopListening extends VoiceInputEvent {
  const VoiceInputStopListening();
}

/// Manual commit of current transcript (Done button)
class VoiceInputManualCommit extends VoiceInputEvent {
  const VoiceInputManualCommit();
}

/// Live transcript updated (partial result while speaking)
class VoiceInputLiveTranscriptUpdated extends VoiceInputEvent {
  final String text;

  const VoiceInputLiveTranscriptUpdated({required this.text});

  @override
  List<Object?> get props => [text];
}

/// Committed transcript received (final text after silence)
class VoiceInputCommittedTranscriptReceived extends VoiceInputEvent {
  final String text;

  const VoiceInputCommittedTranscriptReceived({required this.text});

  @override
  List<Object?> get props => [text];
}

/// Connection state changed
class VoiceInputConnectionStateChanged extends VoiceInputEvent {
  final SttConnectionState state;

  const VoiceInputConnectionStateChanged({required this.state});

  @override
  List<Object?> get props => [state];
}

/// STT error occurred
class VoiceInputSttError extends VoiceInputEvent {
  final SttError error;

  const VoiceInputSttError({required this.error});

  @override
  List<Object?> get props => [error];
}

/// Parse the transcribed text using AI
class VoiceInputParseRequested extends VoiceInputEvent {
  final String text;
  final String? sessionId;

  const VoiceInputParseRequested({
    required this.text,
    this.sessionId,
  });

  @override
  List<Object?> get props => [text, sessionId];
}

/// User provided clarification response (text input)
class VoiceInputClarificationProvided extends VoiceInputEvent {
  final String response;
  final String sessionId;

  const VoiceInputClarificationProvided({
    required this.response,
    required this.sessionId,
  });

  @override
  List<Object?> get props => [response, sessionId];
}

/// Start voice clarification mode (user wants to speak the answer)
class VoiceInputClarificationVoiceModeStarted extends VoiceInputEvent {
  final String sessionId;

  const VoiceInputClarificationVoiceModeStarted({required this.sessionId});

  @override
  List<Object?> get props => [sessionId];
}

/// End voice clarification mode
class VoiceInputClarificationVoiceModeEnded extends VoiceInputEvent {
  const VoiceInputClarificationVoiceModeEnded();
}

/// Voice clarification transcript received (submit the spoken answer)
class VoiceInputClarificationVoiceSubmitted extends VoiceInputEvent {
  final String spokenResponse;
  final String sessionId;

  const VoiceInputClarificationVoiceSubmitted({
    required this.spokenResponse,
    required this.sessionId,
  });

  @override
  List<Object?> get props => [spokenResponse, sessionId];
}

/// Confirm draft and create task
class VoiceInputDraftConfirmed extends VoiceInputEvent {
  final int draftId;
  final int? overrideCoachId;
  final List<int>? overrideReminders;

  const VoiceInputDraftConfirmed({
    required this.draftId,
    this.overrideCoachId,
    this.overrideReminders,
  });

  @override
  List<Object?> get props => [draftId, overrideCoachId, overrideReminders];
}

/// Discard the current draft
class VoiceInputDraftDiscarded extends VoiceInputEvent {
  final int draftId;

  const VoiceInputDraftDiscarded({required this.draftId});

  @override
  List<Object?> get props => [draftId];
}

/// Reset to initial state
class VoiceInputReset extends VoiceInputEvent {
  const VoiceInputReset();
}

/// Speech recognition error
class VoiceInputError extends VoiceInputEvent {
  final String error;

  const VoiceInputError({required this.error});

  @override
  List<Object?> get props => [error];
}

/// Check and request microphone permission
class VoiceInputPermissionRequested extends VoiceInputEvent {
  const VoiceInputPermissionRequested();
}
