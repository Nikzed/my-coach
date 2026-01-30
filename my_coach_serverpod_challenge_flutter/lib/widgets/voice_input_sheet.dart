import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:my_coach_serverpod_challenge_client/my_coach_serverpod_challenge_client.dart';

import '../bloc/bloc_exports.dart';
import '../theme/app_theme.dart';

class VoiceInputSheet extends StatefulWidget {
  const VoiceInputSheet({super.key});

  @override
  State<VoiceInputSheet> createState() => _VoiceInputSheetState();
}

class _VoiceInputSheetState extends State<VoiceInputSheet> {
  final TextEditingController _clarificationController = TextEditingController();
  int? _selectedCoachId;
  List<int> _selectedReminders = [30, 0]; // Default reminders

  @override
  void dispose() {
    _clarificationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<VoiceInputBloc, VoiceInputState>(
      listener: (context, state) {
        if (state.status == VoiceInputStatus.success) {
          // Task created successfully - close sheet and refresh tasks
          Navigator.of(context).pop();
          context.read<TasksBloc>().add(const TasksLoadRequested());
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white, size: 18),
                  const SizedBox(width: 8),
                  Text('Task "${state.createdTask?.name}" created!'),
                ],
              ),
              backgroundColor: AppTheme.success,
            ),
          );
        }

        // Update local state when draft is ready
        if (state.status == VoiceInputStatus.draftReady && state.draft != null) {
          _selectedCoachId = state.draft!.suggestedCoachId;
          if (state.draft!.parsedReminders != null) {
            try {
              final reminders = jsonDecode(state.draft!.parsedReminders!) as List;
              _selectedReminders = reminders.map((e) => (e as num).toInt()).toList();
            } catch (_) {}
          }
        }
      },
      builder: (context, state) {
        return DraggableScrollableSheet(
          initialChildSize: 0.5,
          minChildSize: 0.3,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: SingleChildScrollView(
                controller: scrollController,
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Handle bar
                      Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppTheme.textMuted,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Connection status indicator
                      _buildConnectionStatusIndicator(state),
                      const SizedBox(height: 16),
                      _buildContent(context, state),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildConnectionStatusIndicator(VoiceInputState state) {
    // Only show when listening or in voice clarification mode
    if (!state.isListening && !state.isVoiceClarificationListening) {
      return const SizedBox.shrink();
    }

    final isReconnecting = state.isSttReconnecting;
    final isConnected = state.isSttConnected;

    if (isReconnecting) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppTheme.warning.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 12,
              height: 12,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppTheme.warning,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Reconnecting...',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppTheme.warning,
                  ),
            ),
          ],
        ),
      ).animate().fadeIn();
    }

    if (isConnected) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppTheme.success.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.success,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Connected',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppTheme.success,
                  ),
            ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildContent(BuildContext context, VoiceInputState state) {
    switch (state.status) {
      case VoiceInputStatus.initial:
      case VoiceInputStatus.permissionRequired:
        return _buildInitialState(context, state);
      case VoiceInputStatus.ready:
        return _buildReadyState(context);
      case VoiceInputStatus.listening:
        return _buildListeningState(context, state);
      case VoiceInputStatus.processing:
      case VoiceInputStatus.confirming:
        return _buildProcessingState(context, state);
      case VoiceInputStatus.draftReady:
        return _buildDraftPreview(context, state);
      case VoiceInputStatus.needsClarification:
        return _buildClarificationState(context, state);
      case VoiceInputStatus.voiceClarificationListening:
        return _buildVoiceClarificationListeningState(context, state);
      case VoiceInputStatus.success:
        return _buildSuccessState(context, state);
      case VoiceInputStatus.failure:
        return _buildErrorState(context, state);
    }
  }

  Widget _buildInitialState(BuildContext context, VoiceInputState state) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.mic_off,
          size: 64,
          color: AppTheme.textMuted,
        ),
        const SizedBox(height: 16),
        Text(
          'Microphone Permission Required',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Text(
          state.error ?? 'Please allow microphone access to use voice input.',
          style: Theme.of(context).textTheme.bodySmall,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        ElevatedButton.icon(
          onPressed: () {
            context.read<VoiceInputBloc>().add(const VoiceInputPermissionRequested());
          },
          icon: const Icon(Icons.mic),
          label: const Text('Enable Microphone'),
        ),
      ],
    );
  }

  Widget _buildReadyState(BuildContext context) {
    // Auto-start recording when ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<VoiceInputBloc>().add(const VoiceInputStartListening());
    });

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppTheme.accent.withValues(alpha: 0.2),
            border: Border.all(
              color: AppTheme.accent,
              width: 3,
            ),
          ),
          child: const Icon(
            Icons.mic,
            size: 48,
            color: AppTheme.accent,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Starting...',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Text(
          'Describe your task naturally, like "Call mom tomorrow at 3pm"',
          style: Theme.of(context).textTheme.bodySmall,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildListeningState(BuildContext context, VoiceInputState state) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Pulsating microphone icon
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppTheme.accent.withValues(alpha: 0.2),
            border: Border.all(
              color: AppTheme.accent,
              width: 3,
            ),
          ),
          child: const Icon(
            Icons.mic,
            size: 48,
            color: AppTheme.accent,
          ),
        )
            .animate(onPlay: (controller) => controller.repeat())
            .scale(
              begin: const Offset(1, 1),
              end: const Offset(1.1, 1.1),
              duration: 600.ms,
              curve: Curves.easeInOut,
            )
            .then()
            .scale(
              begin: const Offset(1.1, 1.1),
              end: const Offset(1, 1),
              duration: 600.ms,
              curve: Curves.easeInOut,
            ),
        const SizedBox(height: 24),
        Text(
          'Listening...',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppTheme.accent,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'Describe your task naturally',
          style: Theme.of(context).textTheme.bodySmall,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        // Live transcript display
        if (state.liveText != null && state.liveText!.isNotEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.surfaceElevated,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              state.liveText!,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ).animate().fadeIn(),
        const SizedBox(height: 24),
        // Cancel and Done buttons
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  context.read<VoiceInputBloc>().add(const VoiceInputReset());
                  Navigator.of(context).pop();
                },
                child: const Text('Cancel'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  context.read<VoiceInputBloc>().add(const VoiceInputStopListening());
                },
                icon: const Icon(Icons.check, size: 18),
                label: const Text('Done'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildProcessingState(BuildContext context, VoiceInputState state) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(
          width: 64,
          height: 64,
          child: CircularProgressIndicator(
            color: AppTheme.accent,
            strokeWidth: 3,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          state.status == VoiceInputStatus.confirming
              ? 'Creating your task...'
              : 'Understanding your task...',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        if (state.transcribedText != null) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.surfaceElevated,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '"${state.transcribedText}"',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontStyle: FontStyle.italic,
                  ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildDraftPreview(BuildContext context, VoiceInputState state) {
    final draft = state.draft!;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.check_circle, color: AppTheme.success, size: 24),
            const SizedBox(width: 8),
            Text(
              'Task Preview',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Task name
        _buildPreviewField(
          context,
          icon: Icons.title,
          label: 'Task',
          value: draft.parsedName ?? 'Unknown',
        ),

        // Description
        if (draft.parsedDescription != null && draft.parsedDescription!.isNotEmpty)
          _buildPreviewField(
            context,
            icon: Icons.notes,
            label: 'Description',
            value: draft.parsedDescription!,
          ),

        // Due time
        if (draft.parsedDueTime != null && draft.parsedDueTime!.isNotEmpty)
          _buildPreviewField(
            context,
            icon: Icons.calendar_today,
            label: 'Due',
            value: _formatDueTime(draft.parsedDueTime!),
          ),

        const SizedBox(height: 16),

        // Coach selection
        Text(
          'Coach',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        BlocBuilder<CoachesBloc, CoachesState>(
          builder: (context, coachState) {
            return Wrap(
              spacing: 8,
              runSpacing: 8,
              children: coachState.coaches.map((coach) {
                final isSelected = _selectedCoachId == coach.id;
                final isSuggested = draft.suggestedCoachId == coach.id;
                return ChoiceChip(
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(coach.name),
                      if (isSuggested) ...[
                        const SizedBox(width: 4),
                        const Icon(Icons.auto_awesome, size: 14),
                      ],
                    ],
                  ),
                  selected: isSelected,
                  onSelected: (_) => setState(() => _selectedCoachId = coach.id),
                  selectedColor: coach.name.coachPrimaryColor.withValues(alpha: 0.3),
                );
              }).toList(),
            );
          },
        ),

        // Reminders
        if (draft.parsedDueTime != null) ...[
          const SizedBox(height: 16),
          Text(
            'Reminders',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildReminderChip(context, 0, 'At due time'),
              _buildReminderChip(context, 15, '15m before'),
              _buildReminderChip(context, 30, '30m before'),
              _buildReminderChip(context, 60, '1h before'),
              _buildReminderChip(context, 1440, '1 day before'),
            ],
          ),
        ],

        // Subtasks preview
        if (draft.parsedSubtasks != null) ...[
          const SizedBox(height: 16),
          Text(
            'Subtasks',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          ...(_parseSubtasks(draft.parsedSubtasks!).map((subtask) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  const Icon(Icons.check_box_outline_blank, size: 18, color: AppTheme.textMuted),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      subtask,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            );
          })),
        ],

        const SizedBox(height: 24),

        // Action buttons
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  context.read<VoiceInputBloc>().add(
                        VoiceInputDraftDiscarded(draftId: draft.id!),
                      );
                },
                child: const Text('Discard'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: ElevatedButton.icon(
                onPressed: () {
                  context.read<VoiceInputBloc>().add(
                        VoiceInputDraftConfirmed(
                          draftId: draft.id!,
                          overrideCoachId: _selectedCoachId,
                          overrideReminders: _selectedReminders,
                        ),
                      );
                },
                icon: const Icon(Icons.add),
                label: const Text('Create Task'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildReminderChip(BuildContext context, int minutes, String label) {
    final isSelected = _selectedReminders.contains(minutes);
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          if (selected) {
            _selectedReminders.add(minutes);
          } else {
            _selectedReminders.remove(minutes);
          }
        });
      },
      selectedColor: AppTheme.accent.withValues(alpha: 0.3),
    );
  }

  Widget _buildClarificationState(BuildContext context, VoiceInputState state) {
    final draft = state.draft!;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.help_outline,
          size: 48,
          color: AppTheme.warning,
        ),
        const SizedBox(height: 16),
        Text(
          'Quick question',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.surfaceElevated,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            draft.clarificationQuestion ?? 'Could you clarify your task?',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _clarificationController,
          decoration: const InputDecoration(
            hintText: 'Type your response...',
          ),
          textCapitalization: TextCapitalization.sentences,
          onSubmitted: (_) => _submitClarification(draft),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            // Voice input button for clarification
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  context.read<VoiceInputBloc>().add(
                        VoiceInputClarificationVoiceModeStarted(
                          sessionId: draft.sessionId,
                        ),
                      );
                },
                icon: const Icon(Icons.mic, size: 18),
                label: const Text('Voice'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton(
                onPressed: () => _submitClarification(draft),
                child: const Text('Continue'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildVoiceClarificationListeningState(BuildContext context, VoiceInputState state) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.help_outline,
          size: 32,
          color: AppTheme.warning,
        ),
        const SizedBox(height: 8),
        Text(
          'Quick question',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.surfaceElevated,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            state.draft?.clarificationQuestion ?? 'Could you clarify your task?',
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 24),
        GestureDetector(
          onTap: () {
            context.read<VoiceInputBloc>().add(const VoiceInputClarificationVoiceModeEnded());
          },
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.accent.withValues(alpha: 0.2),
              border: Border.all(
                color: AppTheme.accent,
                width: 3,
              ),
            ),
            child: const Icon(
              Icons.mic,
              size: 36,
              color: AppTheme.accent,
            ),
          )
              .animate(onPlay: (controller) => controller.repeat())
              .scale(
                begin: const Offset(1, 1),
                end: const Offset(1.1, 1.1),
                duration: 500.ms,
              )
              .then()
              .scale(
                begin: const Offset(1.1, 1.1),
                end: const Offset(1, 1),
                duration: 500.ms,
              ),
        ),
        const SizedBox(height: 16),
        Text(
          'Speak your answer...',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppTheme.accent,
              ),
        ),
        const SizedBox(height: 12),
        if (state.clarificationVoiceText != null && state.clarificationVoiceText!.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.surfaceElevated,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              state.clarificationVoiceText!,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ).animate().fadeIn(),
        const SizedBox(height: 16),
        Text(
          'Pause for 2.5 seconds when done',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            OutlinedButton(
              onPressed: () {
                context.read<VoiceInputBloc>().add(const VoiceInputClarificationVoiceModeEnded());
              },
              child: const Text('Cancel'),
            ),
            const SizedBox(width: 12),
            ElevatedButton.icon(
              onPressed: () {
                // Manual submit with current voice text
                final voiceText = state.clarificationVoiceText;
                final sessionId = state.clarificationSessionId;
                if (voiceText != null && voiceText.isNotEmpty && sessionId != null) {
                  context.read<VoiceInputBloc>().add(
                        VoiceInputClarificationVoiceSubmitted(
                          spokenResponse: voiceText,
                          sessionId: sessionId,
                        ),
                      );
                } else {
                  context.read<VoiceInputBloc>().add(const VoiceInputClarificationVoiceModeEnded());
                }
              },
              icon: const Icon(Icons.check, size: 18),
              label: const Text('Done'),
            ),
          ],
        ),
      ],
    );
  }

  void _submitClarification(VoiceTaskDraft draft) {
    if (_clarificationController.text.trim().isEmpty) return;
    context.read<VoiceInputBloc>().add(
          VoiceInputClarificationProvided(
            response: _clarificationController.text.trim(),
            sessionId: draft.sessionId,
          ),
        );
    _clarificationController.clear();
  }

  Widget _buildSuccessState(BuildContext context, VoiceInputState state) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.check_circle,
          size: 64,
          color: AppTheme.success,
        ),
        const SizedBox(height: 16),
        Text(
          'Task Created!',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        if (state.createdTask != null) ...[
          const SizedBox(height: 8),
          Text(
            state.createdTask!.name,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ],
    );
  }

  Widget _buildErrorState(BuildContext context, VoiceInputState state) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.error_outline,
          size: 48,
          color: AppTheme.error,
        ),
        const SizedBox(height: 16),
        Text(
          'Something went wrong',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Text(
          state.error ?? 'Please try again.',
          style: Theme.of(context).textTheme.bodySmall,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: () {
            context.read<VoiceInputBloc>().add(const VoiceInputReset());
          },
          child: const Text('Try Again'),
        ),
      ],
    );
  }

  Widget _buildPreviewField(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppTheme.textMuted),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppTheme.textMuted,
                      ),
                ),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDueTime(String isoString) {
    try {
      final dateTime = DateTime.parse(isoString);
      return DateFormat.yMMMd().add_jm().format(dateTime);
    } catch (_) {
      return isoString;
    }
  }

  List<String> _parseSubtasks(String json) {
    try {
      final list = jsonDecode(json) as List;
      return list.map((e) => e.toString()).toList();
    } catch (_) {
      return [];
    }
  }
}
