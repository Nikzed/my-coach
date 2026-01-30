import 'dart:async';
import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_coach_serverpod_challenge_client/my_coach_serverpod_challenge_client.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../models/stt_models.dart';
import '../../services/stt_session_manager.dart';
import 'voice_input_event.dart';
import 'voice_input_state.dart';

class VoiceInputBloc extends Bloc<VoiceInputEvent, VoiceInputState> {
  final Client client;
  final SttSessionManager sttSessionManager;

  StreamSubscription? _liveTranscriptSubscription;
  StreamSubscription? _committedTranscriptSubscription;
  StreamSubscription? _connectionStateSubscription;
  StreamSubscription? _errorSubscription;

  bool _isInitialized = false;

  VoiceInputBloc({
    required this.client,
    required this.sttSessionManager,
  }) : super(const VoiceInputState.initial()) {
    on<VoiceInputPermissionRequested>(_onPermissionRequested);
    on<VoiceInputStartListening>(_onStartListening);
    on<VoiceInputStopListening>(_onStopListening);
    on<VoiceInputManualCommit>(_onManualCommit);
    on<VoiceInputLiveTranscriptUpdated>(_onLiveTranscriptUpdated);
    on<VoiceInputCommittedTranscriptReceived>(_onCommittedTranscriptReceived);
    on<VoiceInputConnectionStateChanged>(_onConnectionStateChanged);
    on<VoiceInputSttError>(_onSttError);
    on<VoiceInputParseRequested>(_onParseRequested);
    on<VoiceInputClarificationProvided>(_onClarificationProvided);
    on<VoiceInputClarificationVoiceModeStarted>(_onClarificationVoiceModeStarted);
    on<VoiceInputClarificationVoiceModeEnded>(_onClarificationVoiceModeEnded);
    on<VoiceInputClarificationVoiceSubmitted>(_onClarificationVoiceSubmitted);
    on<VoiceInputDraftConfirmed>(_onDraftConfirmed);
    on<VoiceInputDraftDiscarded>(_onDraftDiscarded);
    on<VoiceInputReset>(_onReset);
    on<VoiceInputError>(_onError);

    _setupSttSubscriptions();
  }

  void _setupSttSubscriptions() {
    // Subscribe to live transcripts
    _liveTranscriptSubscription = sttSessionManager.liveTranscript.listen((text) {
      // Check if we're in voice clarification mode
      if (state.isVoiceClarificationMode) {
        add(VoiceInputLiveTranscriptUpdated(text: text));
      } else {
        add(VoiceInputLiveTranscriptUpdated(text: text));
      }
    });

    // Subscribe to committed transcripts
    _committedTranscriptSubscription = sttSessionManager.committedTranscript.listen((text) {
      add(VoiceInputCommittedTranscriptReceived(text: text));
    });

    // Subscribe to connection state changes
    _connectionStateSubscription = sttSessionManager.connectionState.listen((state) {
      add(VoiceInputConnectionStateChanged(state: state));
    });

    // Subscribe to errors
    _errorSubscription = sttSessionManager.errors.listen((error) {
      add(VoiceInputSttError(error: error));
    });
  }

  Future<void> _onPermissionRequested(
    VoiceInputPermissionRequested event,
    Emitter<VoiceInputState> emit,
  ) async {
    // Check microphone permission
    final status = await Permission.microphone.status;

    if (status.isGranted) {
      _isInitialized = true;
      emit(state.copyWith(
        status: VoiceInputStatus.ready,
        hasPermission: true,
      ));
    } else if (status.isDenied) {
      final result = await Permission.microphone.request();
      if (result.isGranted) {
        _isInitialized = true;
        emit(state.copyWith(
          status: VoiceInputStatus.ready,
          hasPermission: true,
        ));
      } else {
        emit(state.copyWith(
          status: VoiceInputStatus.permissionRequired,
          hasPermission: false,
        ));
      }
    } else if (status.isPermanentlyDenied) {
      emit(state.copyWith(
        status: VoiceInputStatus.permissionRequired,
        hasPermission: false,
        error: 'Microphone permission permanently denied. Please enable in settings.',
      ));
    }
  }

  Future<void> _onStartListening(
    VoiceInputStartListening event,
    Emitter<VoiceInputState> emit,
  ) async {
    if (!_isInitialized) {
      add(const VoiceInputPermissionRequested());
      return;
    }

    emit(state.copyWith(
      status: VoiceInputStatus.listening,
      clearLiveText: true,
      clearTranscribedText: true,
      clearError: true,
    ));

    final started = await sttSessionManager.startSession();
    if (!started) {
      emit(state.copyWith(
        status: VoiceInputStatus.failure,
        error: 'Failed to start voice input. Please check your connection.',
      ));
    }
  }

  Future<void> _onStopListening(
    VoiceInputStopListening event,
    Emitter<VoiceInputState> emit,
  ) async {
    // Send manual commit before stopping to capture any remaining partial text
    sttSessionManager.manualCommit();

    // Brief delay to allow the commit to be processed
    await Future.delayed(const Duration(milliseconds: 300));

    await sttSessionManager.stopSession();

    // If we have text, start parsing
    final text = sttSessionManager.fullCommittedText;
    if (text.isNotEmpty) {
      add(VoiceInputParseRequested(text: text));
    } else if (state.liveText != null && state.liveText!.isNotEmpty) {
      // Fallback to live text if no committed text
      add(VoiceInputParseRequested(text: state.liveText!));
    } else {
      emit(state.copyWith(
        status: VoiceInputStatus.ready,
        clearLiveText: true,
      ));
    }
  }

  void _onManualCommit(
    VoiceInputManualCommit event,
    Emitter<VoiceInputState> emit,
  ) {
    sttSessionManager.manualCommit();
  }

  void _onLiveTranscriptUpdated(
    VoiceInputLiveTranscriptUpdated event,
    Emitter<VoiceInputState> emit,
  ) {
    if (state.isVoiceClarificationMode) {
      emit(state.copyWith(clarificationVoiceText: event.text));
    } else {
      emit(state.copyWith(liveText: event.text));
    }
  }

  void _onCommittedTranscriptReceived(
    VoiceInputCommittedTranscriptReceived event,
    Emitter<VoiceInputState> emit,
  ) {
    if (state.isVoiceClarificationMode) {
      // In voice clarification mode, auto-submit after committed transcript
      final sessionId = state.clarificationSessionId;
      if (sessionId != null && event.text.isNotEmpty) {
        add(VoiceInputClarificationVoiceSubmitted(
          spokenResponse: event.text,
          sessionId: sessionId,
        ));
      }
    } else {
      emit(state.copyWith(
        transcribedText: event.text,
        liveText: event.text,
      ));
    }
  }

  void _onConnectionStateChanged(
    VoiceInputConnectionStateChanged event,
    Emitter<VoiceInputState> emit,
  ) {
    emit(state.copyWith(connectionState: event.state));
  }

  void _onSttError(
    VoiceInputSttError event,
    Emitter<VoiceInputState> emit,
  ) {
    // Map STT errors to user-friendly messages
    String message;
    switch (event.error.type) {
      case SttErrorType.authenticationFailed:
        message = 'Voice service authentication failed. Please try again later.';
        break;
      case SttErrorType.connectionFailed:
      case SttErrorType.connectionLost:
        message = 'Voice connection lost. Please check your internet connection.';
        break;
      case SttErrorType.microphoneError:
        message = 'Microphone error. Please check your microphone permissions.';
        break;
      case SttErrorType.unknown:
        message = event.error.message;
        break;
    }

    emit(state.copyWith(
      status: VoiceInputStatus.failure,
      error: message,
    ));
  }

  Future<void> _onParseRequested(
    VoiceInputParseRequested event,
    Emitter<VoiceInputState> emit,
  ) async {
    emit(state.copyWith(
      status: VoiceInputStatus.processing,
      transcribedText: event.text,
    ));

    try {
      final draft = await client.voiceInput.parseVoiceInput(
        event.text,
        sessionId: event.sessionId,
      );

      if (draft.status == 'needs_clarification') {
        emit(state.copyWith(
          status: VoiceInputStatus.needsClarification,
          draft: draft,
        ));
      } else {
        emit(state.copyWith(
          status: VoiceInputStatus.draftReady,
          draft: draft,
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: VoiceInputStatus.failure,
        error: 'Failed to parse voice input: $e',
      ));
    }
  }

  Future<void> _onClarificationProvided(
    VoiceInputClarificationProvided event,
    Emitter<VoiceInputState> emit,
  ) async {
    emit(state.copyWith(status: VoiceInputStatus.processing));

    try {
      final draft = await client.voiceInput.parseVoiceInput(
        event.response,
        sessionId: event.sessionId,
      );

      if (draft.status == 'needs_clarification') {
        emit(state.copyWith(
          status: VoiceInputStatus.needsClarification,
          draft: draft,
        ));
      } else {
        emit(state.copyWith(
          status: VoiceInputStatus.draftReady,
          draft: draft,
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: VoiceInputStatus.failure,
        error: 'Failed to process clarification: $e',
      ));
    }
  }

  Future<void> _onClarificationVoiceModeStarted(
    VoiceInputClarificationVoiceModeStarted event,
    Emitter<VoiceInputState> emit,
  ) async {
    emit(state.copyWith(
      status: VoiceInputStatus.voiceClarificationListening,
      isVoiceClarificationMode: true,
      clarificationSessionId: event.sessionId,
      clearClarificationVoiceText: true,
    ));

    final started = await sttSessionManager.startSession();
    if (!started) {
      emit(state.copyWith(
        status: VoiceInputStatus.needsClarification,
        isVoiceClarificationMode: false,
        error: 'Failed to start voice input. Please use text input instead.',
      ));
    }
  }

  Future<void> _onClarificationVoiceModeEnded(
    VoiceInputClarificationVoiceModeEnded event,
    Emitter<VoiceInputState> emit,
  ) async {
    await sttSessionManager.stopSession();

    emit(state.copyWith(
      status: VoiceInputStatus.needsClarification,
      isVoiceClarificationMode: false,
      clearClarificationVoiceText: true,
    ));
  }

  Future<void> _onClarificationVoiceSubmitted(
    VoiceInputClarificationVoiceSubmitted event,
    Emitter<VoiceInputState> emit,
  ) async {
    // Stop the session
    await sttSessionManager.stopSession();

    emit(state.copyWith(
      status: VoiceInputStatus.processing,
      isVoiceClarificationMode: false,
      clearClarificationVoiceText: true,
    ));

    try {
      final draft = await client.voiceInput.parseVoiceInput(
        event.spokenResponse,
        sessionId: event.sessionId,
      );

      if (draft.status == 'needs_clarification') {
        emit(state.copyWith(
          status: VoiceInputStatus.needsClarification,
          draft: draft,
        ));
      } else {
        emit(state.copyWith(
          status: VoiceInputStatus.draftReady,
          draft: draft,
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: VoiceInputStatus.failure,
        error: 'Failed to process voice clarification: $e',
      ));
    }
  }

  Future<void> _onDraftConfirmed(
    VoiceInputDraftConfirmed event,
    Emitter<VoiceInputState> emit,
  ) async {
    emit(state.copyWith(status: VoiceInputStatus.confirming));

    try {
      // Convert reminders to JSON string if provided
      String? remindersJson;
      if (event.overrideReminders != null) {
        remindersJson = jsonEncode(event.overrideReminders);
      }

      final task = await client.voiceInput.confirmDraft(
        event.draftId,
        overrideCoachId: event.overrideCoachId,
        overrideReminders: remindersJson,
      );

      emit(state.copyWith(
        status: VoiceInputStatus.success,
        createdTask: task,
        clearDraft: true,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: VoiceInputStatus.failure,
        error: 'Failed to create task: $e',
      ));
    }
  }

  Future<void> _onDraftDiscarded(
    VoiceInputDraftDiscarded event,
    Emitter<VoiceInputState> emit,
  ) async {
    try {
      await client.voiceInput.discardDraft(event.draftId);
    } catch (_) {
      // Ignore discard errors
    }

    emit(state.copyWith(
      status: VoiceInputStatus.ready,
      clearDraft: true,
      clearTranscribedText: true,
      clearLiveText: true,
    ));
  }

  void _onReset(
    VoiceInputReset event,
    Emitter<VoiceInputState> emit,
  ) {
    emit(VoiceInputState(
      status: _isInitialized ? VoiceInputStatus.ready : VoiceInputStatus.initial,
      hasPermission: state.hasPermission,
    ));
  }

  void _onError(
    VoiceInputError event,
    Emitter<VoiceInputState> emit,
  ) {
    emit(state.copyWith(
      status: VoiceInputStatus.failure,
      error: event.error,
    ));
  }

  @override
  Future<void> close() async {
    await _liveTranscriptSubscription?.cancel();
    await _committedTranscriptSubscription?.cancel();
    await _connectionStateSubscription?.cancel();
    await _errorSubscription?.cancel();
    await sttSessionManager.dispose();
    return super.close();
  }
}
