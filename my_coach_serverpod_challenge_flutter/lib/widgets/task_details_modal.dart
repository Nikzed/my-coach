import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:just_audio/just_audio.dart';
import 'package:my_coach_serverpod_challenge_client/my_coach_serverpod_challenge_client.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';

import '../bloc/bloc_exports.dart';
import '../main.dart';
import '../theme/app_theme.dart';

/// Shows the task details modal using WoltModalSheet
void showTaskDetailsModal(BuildContext context, Task task) {
  // Load messages, subtasks, and reminders for the task
  context.read<CoachesBloc>().add(CoachMessagesLoadRequested(taskId: task.id!));
  context.read<TasksBloc>().add(SubtasksLoadRequested(taskId: task.id!));
  context.read<TasksBloc>().add(RemindersLoadRequested(taskId: task.id!));

  final editModeNotifier = ValueNotifier<bool>(false);
  final taskDataNotifier = ValueNotifier<_TaskEditData>(
    _TaskEditData(
      name: task.name,
      description: task.description ?? '',
      coachId: task.coachId,
      dueDate: task.dueTime != null
          ? DateTime(
              task.dueTime!.year,
              task.dueTime!.month,
              task.dueTime!.day,
            )
          : null,
      dueTime: task.dueTime != null
          ? TimeOfDay(
              hour: task.dueTime!.hour,
              minute: task.dueTime!.minute,
            )
          : null,
    ),
  );

  WoltModalSheet.show<void>(
    context: context,
    pageListBuilder: (bottomSheetContext) => [
      _buildTaskDetailsPage(
        bottomSheetContext,
        context,
        task,
        editModeNotifier,
        taskDataNotifier,
      ),
    ],
    onModalDismissedWithBarrierTap: () {
      Navigator.of(context).pop();
    },
    modalTypeBuilder: (context) => WoltModalType.bottomSheet(),
  );
}

SliverWoltModalSheetPage _buildTaskDetailsPage(
  BuildContext bottomSheetContext,
  BuildContext parentContext,
  Task task,
  ValueNotifier<bool> editModeNotifier,
  ValueNotifier<_TaskEditData> taskDataNotifier,
) {
  return SliverWoltModalSheetPage(
    hasTopBarLayer: true,
    // topBarTitle: Text(
    //   'Task Details',
    //   style: TextStyle(
    //     color: AppTheme.textPrimary,
    //     fontWeight: FontWeight.w600,
    //     fontSize: 18,
    //   ),
    // ),
    isTopBarLayerAlwaysVisible: true,
    leadingNavBarWidget: Padding(
      padding: const EdgeInsets.only(left: 16),
      child: ValueListenableBuilder<bool>(
        valueListenable: editModeNotifier,
        builder: (context, isEditMode, _) {
          if (isEditMode) {
            return const SizedBox.shrink();
          }
          return IconButton(
            onPressed: () => editModeNotifier.value = true,
            icon: const Icon(Icons.edit_outlined, size: 20),
            color: AppTheme.textMuted,
            tooltip: 'Edit task',
          );
        },
      ),
    ),
    trailingNavBarWidget: Padding(
      padding: const EdgeInsets.only(right: 16),
      child: ValueListenableBuilder<bool>(
        valueListenable: editModeNotifier,
        builder: (context, isEditMode, _) {
          if (isEditMode) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextButton(
                  onPressed: () {
                    // Reset to original values
                    taskDataNotifier.value = _TaskEditData(
                      name: task.name,
                      description: task.description ?? '',
                      coachId: task.coachId,
                      dueDate: task.dueTime != null
                          ? DateTime(
                              task.dueTime!.year,
                              task.dueTime!.month,
                              task.dueTime!.day,
                            )
                          : null,
                      dueTime: task.dueTime != null
                          ? TimeOfDay(
                              hour: task.dueTime!.hour,
                              minute: task.dueTime!.minute,
                            )
                          : null,
                    );
                    editModeNotifier.value = false;
                  },
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: AppTheme.textMuted),
                  ),
                ),
                const SizedBox(width: 8),
                _SaveButton(
                  parentContext: parentContext,
                  task: task,
                  taskDataNotifier: taskDataNotifier,
                  editModeNotifier: editModeNotifier,
                  bottomSheetContext: bottomSheetContext,
                ),
              ],
            );
          }
          // Complete/Undo button for task completion
          return _TaskCompletionButton(
            task: task,
            parentContext: parentContext,
            bottomSheetContext: bottomSheetContext,
          );
        },
      ),
    ),
    mainContentSliversBuilder: (context) => [
      SliverToBoxAdapter(
        child: _TaskDetailsContent(
          task: task,
          editModeNotifier: editModeNotifier,
          taskDataNotifier: taskDataNotifier,
          parentContext: parentContext,
        ),
      ),
    ],
  );
}

/// Save button widget that handles saving task changes
class _SaveButton extends StatefulWidget {
  final BuildContext parentContext;
  final Task task;
  final ValueNotifier<_TaskEditData> taskDataNotifier;
  final ValueNotifier<bool> editModeNotifier;
  final BuildContext bottomSheetContext;

  const _SaveButton({
    required this.parentContext,
    required this.task,
    required this.taskDataNotifier,
    required this.editModeNotifier,
    required this.bottomSheetContext,
  });

  @override
  State<_SaveButton> createState() => _SaveButtonState();
}

class _SaveButtonState extends State<_SaveButton> {
  bool _isSaving = false;

  Future<void> _saveChanges() async {
    final data = widget.taskDataNotifier.value;

    if (data.name.trim().isEmpty) {
      ScaffoldMessenger.of(widget.parentContext).showSnackBar(
        const SnackBar(
          content: Text('Task name cannot be empty'),
          backgroundColor: AppTheme.error,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    DateTime? dueDateTime;
    if (data.dueDate != null) {
      dueDateTime = DateTime(
        data.dueDate!.year,
        data.dueDate!.month,
        data.dueDate!.day,
        data.dueTime?.hour ?? 23,
        data.dueTime?.minute ?? 59,
      );
    }

    final updatedTask = Task(
      id: widget.task.id,
      userId: widget.task.userId,
      coachId: data.coachId,
      name: data.name.trim(),
      description: data.description.trim().isEmpty ? null : data.description.trim(),
      dueTime: dueDateTime,
      isCompleted: widget.task.isCompleted,
      completedAt: widget.task.completedAt,
      createdAt: widget.task.createdAt,
    );

    widget.parentContext.read<TasksBloc>().add(TaskUpdateRequested(task: updatedTask));

    // Sync reminders - remove deleted ones, add new ones
    for (final reminderId in data.removedReminderIds) {
      widget.parentContext.read<TasksBloc>().add(ReminderRemoveRequested(
        reminderId: reminderId,
        taskId: widget.task.id!,
      ));
    }
    for (final minutesBefore in data.addedReminderMinutes) {
      widget.parentContext.read<TasksBloc>().add(ReminderAddRequested(
        taskId: widget.task.id!,
        minutesBefore: minutesBefore,
      ));
    }

    widget.editModeNotifier.value = false;
    setState(() => _isSaving = false);

    Navigator.of(widget.bottomSheetContext).pop();

    ScaffoldMessenger.of(widget.parentContext).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white, size: 18),
            SizedBox(width: 8),
            Text('Task updated'),
          ],
        ),
        backgroundColor: AppTheme.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: _isSaving ? null : _saveChanges,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      child: _isSaving
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppTheme.background,
              ),
            )
          : const Text('Save'),
    );
  }
}

/// Button to complete or uncomplete a task
class _TaskCompletionButton extends StatelessWidget {
  final Task task;
  final BuildContext parentContext;
  final BuildContext bottomSheetContext;

  // Lighter, more elegant green
  static const _completeGreen = Color(0xFF66BB6A);

  const _TaskCompletionButton({
    required this.task,
    required this.parentContext,
    required this.bottomSheetContext,
  });

  @override
  Widget build(BuildContext context) {
    final isCompleted = task.isCompleted;

    return Material(
      color: isCompleted
          ? AppTheme.textMuted.withValues(alpha: 0.08)
          : _completeGreen.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(6),
      child: InkWell(
        onTap: () {
          if (isCompleted) {
            parentContext.read<TasksBloc>().add(
              TaskUncompleteRequested(taskId: task.id!),
            );
            ScaffoldMessenger.of(parentContext).showSnackBar(
              SnackBar(
                content: Text('"${task.name}" moved to pending'),
                backgroundColor: AppTheme.surfaceElevated,
              ),
            );
          } else {
            parentContext.read<TasksBloc>().add(
              TaskCompleteRequested(taskId: task.id!),
            );
            ScaffoldMessenger.of(parentContext).showSnackBar(
              SnackBar(
                content: Text('"${task.name}" completed!'),
                backgroundColor: AppTheme.success,
              ),
            );
          }
          Navigator.of(bottomSheetContext).pop();
        },
        borderRadius: BorderRadius.circular(6),
        splashColor: isCompleted
            ? AppTheme.textMuted.withValues(alpha: 0.15)
            : _completeGreen.withValues(alpha: 0.2),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isCompleted ? Icons.undo : Icons.check,
                size: 16,
                color: isCompleted ? AppTheme.textMuted : _completeGreen,
              ),
              const SizedBox(width: 6),
              Text(
                isCompleted ? 'Undo' : 'Complete',
                style: TextStyle(
                  color: isCompleted ? AppTheme.textMuted : _completeGreen,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Data class for task editing state
class _TaskEditData {
  final String name;
  final String description;
  final int? coachId;
  final DateTime? dueDate;
  final TimeOfDay? dueTime;
  final List<int> addedReminderMinutes;
  final List<int> removedReminderIds;

  _TaskEditData({
    required this.name,
    required this.description,
    this.coachId,
    this.dueDate,
    this.dueTime,
    this.addedReminderMinutes = const [],
    this.removedReminderIds = const [],
  });

  _TaskEditData copyWith({
    String? name,
    String? description,
    int? coachId,
    DateTime? dueDate,
    TimeOfDay? dueTime,
    bool clearCoachId = false,
    bool clearDueDate = false,
    bool clearDueTime = false,
    List<int>? addedReminderMinutes,
    List<int>? removedReminderIds,
  }) {
    return _TaskEditData(
      name: name ?? this.name,
      description: description ?? this.description,
      coachId: clearCoachId ? null : (coachId ?? this.coachId),
      dueDate: clearDueDate ? null : (dueDate ?? this.dueDate),
      dueTime: clearDueTime ? null : (dueTime ?? this.dueTime),
      addedReminderMinutes: addedReminderMinutes ?? this.addedReminderMinutes,
      removedReminderIds: removedReminderIds ?? this.removedReminderIds,
    );
  }
}

/// Main content widget for task details
class _TaskDetailsContent extends StatelessWidget {
  final Task task;
  final ValueNotifier<bool> editModeNotifier;
  final ValueNotifier<_TaskEditData> taskDataNotifier;
  final BuildContext parentContext;

  const _TaskDetailsContent({
    required this.task,
    required this.editModeNotifier,
    required this.taskDataNotifier,
    required this.parentContext,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CoachesBloc, CoachesState>(
      bloc: parentContext.read<CoachesBloc>(),
      builder: (context, coachesState) {
        final coach = task.coachId != null ? coachesState.getCoachById(task.coachId!) : null;
        final messages = coachesState.getMessagesForTask(task.id!);

        return BlocBuilder<TasksBloc, TasksState>(
          bloc: parentContext.read<TasksBloc>(),
          builder: (context, tasksState) {
            final subtasks = tasksState.getSubtasksForTask(task.id!);
            final progress = tasksState.getSubtaskProgress(task.id!);

            return ValueListenableBuilder<bool>(
              valueListenable: editModeNotifier,
              builder: (context, isEditMode, _) {
                return ValueListenableBuilder<_TaskEditData>(
                  valueListenable: taskDataNotifier,
                  builder: (context, taskData, _) {
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Task name
                          if (isEditMode) ...[
                            _EditableTextField(
                              initialValue: taskData.name,
                              hintText: 'Task name',
                              style: Theme.of(context).textTheme.headlineMedium,
                              onChanged: (value) {
                                taskDataNotifier.value = taskData.copyWith(name: value);
                              },
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                errorBorder: InputBorder.none,
                                disabledBorder: InputBorder.none,
                                contentPadding: EdgeInsets.zero,
                                fillColor: Colors.transparent,
                                filled: false,
                                isDense: true,
                              ),
                            ),
                            const SizedBox(height: 12),
                          ] else
                            Text(
                              task.name,
                              style: Theme.of(context).textTheme.headlineMedium,
                            ),
                          const SizedBox(height: 12),

                          // Description
                          if (isEditMode) ...[
                            Text(
                              'Description',
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                            const SizedBox(height: 8),
                            _EditableTextField(
                              initialValue: taskData.description,
                              hintText: 'Add description...',
                              style: Theme.of(context).textTheme.bodyMedium,
                              maxLines: 2,
                              onChanged: (value) {
                                taskDataNotifier.value = taskData.copyWith(description: value);
                              },
                            ),
                          ] else if (task.description != null && task.description!.isNotEmpty)
                            Text(
                              task.description!,
                              style: Theme.of(context).textTheme.bodyMedium,
                            )
                          else
                            Text(
                              'No description',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppTheme.textMuted,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          const SizedBox(height: 16),

                          // Coach section
                          if (isEditMode) ...[
                            Text(
                              'Coach',
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                            const SizedBox(height: 8),
                            _CompactCoachSelector(
                              coaches: coachesState.coaches,
                              selectedCoachId: taskData.coachId,
                              onChanged: (coachId) {
                                if (coachId == null) {
                                  taskDataNotifier.value = taskData.copyWith(clearCoachId: true);
                                } else {
                                  taskDataNotifier.value = taskData.copyWith(coachId: coachId);
                                }
                              },
                            ),
                          ] else ...[
                            // View mode - compact coach badge
                            _CompactCoachBadge(
                              coach: coach,
                              coachId: taskData.coachId,
                              coachesState: coachesState,
                            ),
                          ],
                          const SizedBox(height: 16),

                          // Due date/time
                          if (isEditMode) ...[
                            Text(
                              'Deadline',
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                            const SizedBox(height: 8),
                            _DateTimePickers(
                              dueDate: taskData.dueDate,
                              dueTime: taskData.dueTime,
                              onDateChanged: (date) {
                                // Use taskDataNotifier.value to get current state
                                // (not the captured taskData which may be stale)
                                final currentData = taskDataNotifier.value;
                                if (date == null) {
                                  taskDataNotifier.value = currentData.copyWith(
                                    clearDueDate: true,
                                    clearDueTime: true,
                                  );
                                } else {
                                  taskDataNotifier.value = currentData.copyWith(dueDate: date);
                                }
                              },
                              onTimeChanged: (time) {
                                // Use taskDataNotifier.value to get current state
                                // (not the captured taskData which may be stale after date selection)
                                final currentData = taskDataNotifier.value;
                                taskDataNotifier.value = currentData.copyWith(dueTime: time);
                              },
                            ),
                          ] else ...[
                            // View mode - due date row
                            if (task.dueTime != null)
                              _DetailRow(
                                icon: Icons.access_time,
                                label: 'Due',
                                value: DateFormat.yMMMd().add_jm().format(task.dueTime!),
                              )
                            else
                              _DetailRow(
                                icon: Icons.access_time,
                                label: 'Due',
                                value: 'No deadline',
                                valueColor: AppTheme.textMuted,
                              ),
                          ],

                          // Reminders section (only show when task has dueTime)
                          if (task.dueTime != null) ...[
                            const SizedBox(height: 16),
                            _RemindersSection(
                              task: task,
                              reminders: tasksState.getRemindersForTask(task.id!),
                              isEditMode: isEditMode,
                              taskDataNotifier: taskDataNotifier,
                            ),
                          ],

                          // Subtasks
                          if (subtasks != null && subtasks.isNotEmpty) ...[
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Text(
                                  'Subtasks',
                                  style: Theme.of(context).textTheme.titleSmall,
                                ),
                                if (progress != null) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: progress.$1 == progress.$2
                                          ? AppTheme.success.withValues(alpha: 0.2)
                                          : AppTheme.accent.withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      '${progress.$1}/${progress.$2}',
                                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                        color: progress.$1 == progress.$2 ? AppTheme.success : AppTheme.accent,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 8),
                            ...subtasks.map(
                              (subtask) => SubtaskItem(
                                subtask: subtask,
                                onToggle: () {
                                  if (subtask.isCompleted) {
                                    parentContext.read<TasksBloc>().add(
                                      SubtaskUncompleteRequested(subtaskId: subtask.id!),
                                    );
                                  } else {
                                    parentContext.read<TasksBloc>().add(
                                      SubtaskCompleteRequested(subtaskId: subtask.id!),
                                    );
                                  }
                                },
                                onNameChanged: isEditMode
                                    ? (newName) {
                                        parentContext.read<TasksBloc>().add(
                                          SubtaskUpdateRequested(
                                            subtaskId: subtask.id!,
                                            taskId: task.id!,
                                            name: newName,
                                          ),
                                        );
                                      }
                                    : null,
                              ),
                            ),
                          ],

                          // Coach messages (only in view mode)
                          if (!isEditMode && messages != null && messages.isNotEmpty) ...[
                            const SizedBox(height: 16),
                            Text(
                              'Coach Messages',
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                            const SizedBox(height: 8),
                            ...messages.map(
                              (msg) => CoachMessageCard(
                                message: msg,
                                coach: coach,
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}

/// Compact coach badge for view mode (28x28 avatar + name only)
class _CompactCoachBadge extends StatelessWidget {
  final Coach? coach;
  final int? coachId;
  final CoachesState coachesState;

  const _CompactCoachBadge({
    required this.coach,
    required this.coachId,
    required this.coachesState,
  });

  @override
  Widget build(BuildContext context) {
    if (coach == null) {
      return Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: AppTheme.textMuted.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.person_off,
              size: 16,
              color: AppTheme.textMuted,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            'No coach',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.textMuted,
            ),
          ),
        ],
      );
    }

    final color = coach!.name.coachPrimaryColor;

    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: color.withValues(alpha: 0.4),
              width: 1,
            ),
          ),
          child: Center(
            child: Text(
              coach!.name[0].toUpperCase(),
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          coach!.name,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppTheme.textPrimary,
          ),
        ),
      ],
    );
  }
}

/// Compact coach selector for edit mode
class _CompactCoachSelector extends StatelessWidget {
  final List<Coach> coaches;
  final int? selectedCoachId;
  final ValueChanged<int?> onChanged;

  const _CompactCoachSelector({
    required this.coaches,
    required this.selectedCoachId,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Coach options - tap selected coach to deselect
        ...coaches.map((coach) {
          final isSelected = selectedCoachId == coach.id;
          final color = coach.name.coachPrimaryColor;
          return _CompactCoachOption(
            isSelected: isSelected,
            color: color,
            onTap: () => onChanged(isSelected ? null : coach.id),
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: color.withValues(alpha: 0.4),
                      width: 1,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      coach.name[0].toUpperCase(),
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    coach.name,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: isSelected ? color : AppTheme.textPrimary,
                    ),
                  ),
                ),
                if (isSelected) Icon(Icons.check_circle, color: color, size: 18),
              ],
            ),
          );
        }),
      ],
    );
  }
}

/// Compact coach option card
class _CompactCoachOption extends StatelessWidget {
  final bool isSelected;
  final Color? color;
  final VoidCallback onTap;
  final Widget child;

  const _CompactCoachOption({
    required this.isSelected,
    this.color,
    required this.onTap,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? AppTheme.textMuted;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: isSelected ? effectiveColor.withValues(alpha: 0.15) : AppTheme.surfaceElevated,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? effectiveColor : const Color(0xFF2A2A30),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: child,
      ),
    );
  }
}

/// Editable text field for edit mode
class _EditableTextField extends StatefulWidget {
  final String initialValue;
  final String hintText;
  final TextStyle? style;
  final int maxLines;
  final ValueChanged<String> onChanged;
  final InputDecoration? decoration;

  const _EditableTextField({
    required this.initialValue,
    required this.hintText,
    this.style,
    this.maxLines = 1,
    required this.onChanged,
    this.decoration,
  });

  @override
  State<_EditableTextField> createState() => _EditableTextFieldState();
}

class _EditableTextFieldState extends State<_EditableTextField> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void didUpdateWidget(covariant _EditableTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialValue != widget.initialValue && _controller.text != widget.initialValue) {
      _controller.text = widget.initialValue;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textField = TextField(
      decoration: widget.decoration ?? const InputDecoration(),
      controller: _controller,
      style: widget.style,
      maxLines: widget.maxLines,
      textCapitalization: TextCapitalization.sentences,
      onChanged: widget.onChanged,
    );

    return textField;
  }
}

/// Date and time pickers for edit mode
class _DateTimePickers extends StatelessWidget {
  final DateTime? dueDate;
  final TimeOfDay? dueTime;
  final ValueChanged<DateTime?> onDateChanged;
  final ValueChanged<TimeOfDay?> onTimeChanged;

  const _DateTimePickers({
    required this.dueDate,
    required this.dueTime,
    required this.onDateChanged,
    required this.onTimeChanged,
  });

  Future<void> _pickDate(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: dueDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppTheme.accent,
              surface: AppTheme.surface,
            ),
          ),
          child: child!,
        );
      },
    );
    if (date != null) {
      onDateChanged(date);
      // Auto-open time picker after selecting date
      if (context.mounted) {
        await _pickTime(context);
      }
    }
  }

  Future<void> _pickTime(BuildContext context) async {
    final time = await showTimePicker(
      context: context,
      initialTime: dueTime ?? TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppTheme.accent,
              surface: AppTheme.surface,
            ),
          ),
          child: child!,
        );
      },
    );
    if (time != null) {
      onTimeChanged(time);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => _pickDate(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                color: AppTheme.surfaceElevated,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: dueDate != null ? AppTheme.accent.withValues(alpha: 0.5) : const Color(0xFF2A2A30),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: dueDate != null ? AppTheme.accent : AppTheme.textMuted,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    dueDate != null ? DateFormat.MMMd().format(dueDate!) : 'No date',
                    style: TextStyle(
                      color: dueDate != null ? AppTheme.textPrimary : AppTheme.textMuted,
                    ),
                  ),
                  if (dueDate != null) ...[
                    const Spacer(),
                    GestureDetector(
                      onTap: () => onDateChanged(null),
                      child: const Icon(
                        Icons.close,
                        size: 16,
                        color: AppTheme.textMuted,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: GestureDetector(
            onTap: dueDate != null ? () => _pickTime(context) : null,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                color: dueDate != null ? AppTheme.surfaceElevated : AppTheme.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: dueTime != null ? AppTheme.accent.withValues(alpha: 0.5) : const Color(0xFF2A2A30),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 16,
                    color: dueDate != null
                        ? (dueTime != null ? AppTheme.accent : AppTheme.textMuted)
                        : AppTheme.textMuted.withValues(alpha: 0.5),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    dueTime != null ? dueTime!.format(context) : 'No time',
                    style: TextStyle(
                      color: dueDate != null
                          ? (dueTime != null ? AppTheme.textPrimary : AppTheme.textMuted)
                          : AppTheme.textMuted.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Detail row for view mode
class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppTheme.textMuted),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}

/// Subtask item widget with editable name
class SubtaskItem extends StatefulWidget {
  final Subtask subtask;
  final VoidCallback onToggle;
  final ValueChanged<String>? onNameChanged;

  const SubtaskItem({
    super.key,
    required this.subtask,
    required this.onToggle,
    this.onNameChanged,
  });

  @override
  State<SubtaskItem> createState() => _SubtaskItemState();
}

class _SubtaskItemState extends State<SubtaskItem> {
  bool _isEditing = false;
  late TextEditingController _controller;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.subtask.name);
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void didUpdateWidget(covariant SubtaskItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.subtask.name != widget.subtask.name && !_isEditing) {
      _controller.text = widget.subtask.name;
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (!_focusNode.hasFocus && _isEditing) {
      _saveChanges();
    }
  }

  void _startEditing() {
    setState(() => _isEditing = true);
    _focusNode.requestFocus();
  }

  void _saveChanges() {
    final newName = _controller.text.trim();
    if (newName.isNotEmpty && newName != widget.subtask.name) {
      widget.onNameChanged?.call(newName);
    } else {
      _controller.text = widget.subtask.name;
    }
    setState(() => _isEditing = false);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.surfaceElevated,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: widget.onToggle,
            child: Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.subtask.isCompleted ? AppTheme.success : Colors.transparent,
                border: Border.all(
                  color: widget.subtask.isCompleted ? AppTheme.success : AppTheme.textMuted,
                  width: 2,
                ),
              ),
              child: widget.subtask.isCompleted
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : null,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _isEditing
                ? TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    style: Theme.of(context).textTheme.bodyMedium,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                    onSubmitted: (_) => _saveChanges(),
                  )
                : GestureDetector(
                    onTap: widget.onNameChanged != null ? _startEditing : null,
                    child: Text(
                      widget.subtask.name,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        decoration: widget.subtask.isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                        color: widget.subtask.isCompleted
                            ? AppTheme.textMuted
                            : AppTheme.textPrimary,
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

/// Widget to display a coach message with optional audio playback
class CoachMessageCard extends StatefulWidget {
  final CoachMessage message;
  final Coach? coach;

  const CoachMessageCard({
    super.key,
    required this.message,
    this.coach,
  });

  @override
  State<CoachMessageCard> createState() => _CoachMessageCardState();
}

class _CoachMessageCardState extends State<CoachMessageCard> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isLoading = false;
  bool _isPlaying = false;
  bool _hasError = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  @override
  void initState() {
    super.initState();

    // Listen to audio player state
    _audioPlayer.playerStateStream.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying = state.playing;
        });

        if (state.processingState == ProcessingState.completed) {
          // Audio finished playing - reset to beginning
          _audioPlayer.seek(Duration.zero);
          _audioPlayer.pause();
        }
      }
    });

    _audioPlayer.durationStream.listen((duration) {
      if (mounted && duration != null) {
        setState(() => _duration = duration);
      }
    });

    _audioPlayer.positionStream.listen((position) {
      if (mounted) {
        setState(() => _position = position);
      }
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _loadAndPlayAudio() async {
    if (_isPlaying) {
      await _audioPlayer.pause();
      return;
    }

    // If already loaded, just play
    if (_duration.inMilliseconds > 0) {
      await _audioPlayer.play();
      return;
    }

    // Load audio for the first time
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      // Get audio data (returned as base64 string from server)
      final audioBase64 = await client.audio.getAudio(widget.message.id!);

      if (audioBase64 != null && audioBase64.isNotEmpty) {
        // Decode base64 to bytes
        final audioData = base64Decode(audioBase64);
        final audioSource = BytesAudioSource(audioData);
        await _audioPlayer.setAudioSource(audioSource);
        await _audioPlayer.play();
      } else {
        setState(() {
          _hasError = true;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final hasAudio = widget.message.audioStoragePath != null;
    final coachColor = widget.coach?.name.coachPrimaryColor ?? AppTheme.accent;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceElevated,
        borderRadius: BorderRadius.circular(12),
        border: hasAudio && _isPlaying
            ? Border.all(
                color: coachColor.withValues(alpha: 0.5),
                width: 2,
              )
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Message text with play button
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (hasAudio)
                GestureDetector(
                  onTap: _loadAndPlayAudio,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _isPlaying ? coachColor.withValues(alpha: 0.2) : AppTheme.surface,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _isPlaying
                            ? coachColor.withValues(alpha: 0.5)
                            : AppTheme.textMuted.withValues(alpha: 0.3),
                        width: 2,
                      ),
                    ),
                    child: _isLoading
                        ? Padding(
                            padding: const EdgeInsets.all(8),
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation(coachColor),
                            ),
                          )
                        : Icon(
                            _isPlaying ? Icons.pause : Icons.play_arrow,
                            color: _isPlaying ? coachColor : AppTheme.textMuted,
                            size: 24,
                          ),
                  ),
                ),
              if (hasAudio) const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.message.textContent,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    if (_hasError) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Audio not available',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppTheme.error,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          // Audio progress bar (shown only when audio is loaded)
          if (hasAudio && _duration.inMilliseconds > 0) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  _formatDuration(_position),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppTheme.textMuted,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: SliderTheme(
                    data: SliderThemeData(
                      trackHeight: 2,
                      thumbShape: const RoundSliderThumbShape(
                        enabledThumbRadius: 4,
                      ),
                      overlayShape: const RoundSliderOverlayShape(
                        overlayRadius: 8,
                      ),
                      activeTrackColor: coachColor,
                      inactiveTrackColor: AppTheme.surface,
                      thumbColor: coachColor,
                    ),
                    child: Slider(
                      value: _position.inMilliseconds.toDouble().clamp(
                        0,
                        _duration.inMilliseconds.toDouble(),
                      ),
                      max: _duration.inMilliseconds.toDouble(),
                      onChanged: (value) {
                        _audioPlayer.seek(
                          Duration(milliseconds: value.toInt()),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  _formatDuration(_duration),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppTheme.textMuted,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// Custom audio source that reads from bytes
class BytesAudioSource extends StreamAudioSource {
  final Uint8List _bytes;

  BytesAudioSource(this._bytes);

  @override
  Future<StreamAudioResponse> request([int? start, int? end]) async {
    start ??= 0;
    end ??= _bytes.length;

    return StreamAudioResponse(
      sourceLength: _bytes.length,
      contentLength: end - start,
      offset: start,
      stream: Stream.value(_bytes.sublist(start, end)),
      contentType: 'audio/mpeg',
    );
  }
}

/// Widget to display and edit reminders for a task
class _RemindersSection extends StatelessWidget {
  final Task task;
  final List<TaskReminder>? reminders;
  final bool isEditMode;
  final ValueNotifier<_TaskEditData> taskDataNotifier;

  const _RemindersSection({
    required this.task,
    required this.reminders,
    required this.isEditMode,
    required this.taskDataNotifier,
  });

  static const _reminderOptions = [
    (0, 'At due time'),
    (15, '15 min before'),
    (30, '30 min before'),
    (60, '1 hour before'),
    (120, '2 hours before'),
    (1440, '1 day before'),
  ];

  String _formatMinutesBefore(int minutes) {
    if (minutes == 0) return 'At due time';
    if (minutes < 60) return '$minutes min before';
    if (minutes == 60) return '1 hour before';
    if (minutes < 1440) return '${minutes ~/ 60} hours before';
    if (minutes == 1440) return '1 day before';
    return '${minutes ~/ 1440} days before';
  }

  @override
  Widget build(BuildContext context) {
    if (isEditMode) {
      return _buildEditMode(context);
    } else {
      return _buildViewMode(context);
    }
  }

  Widget _buildViewMode(BuildContext context) {
    if (reminders == null || reminders!.isEmpty) {
      return Row(
        children: [
          const Icon(Icons.notifications_off, size: 18, color: AppTheme.textMuted),
          const SizedBox(width: 8),
          Text(
            'No reminders set',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.textMuted,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.notifications, size: 18, color: AppTheme.accent),
            const SizedBox(width: 8),
            Text(
              'Reminders',
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: reminders!.map((reminder) {
            final isSent = reminder.isSent;
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: isSent
                    ? AppTheme.success.withValues(alpha: 0.15)
                    : AppTheme.accent.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSent
                      ? AppTheme.success.withValues(alpha: 0.3)
                      : AppTheme.accent.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isSent)
                    const Icon(Icons.check, size: 14, color: AppTheme.success)
                  else
                    const Icon(Icons.schedule, size: 14, color: AppTheme.accent),
                  const SizedBox(width: 4),
                  Text(
                    _formatMinutesBefore(reminder.minutesBefore),
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: isSent ? AppTheme.success : AppTheme.accent,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildEditMode(BuildContext context) {
    return ValueListenableBuilder<_TaskEditData>(
      valueListenable: taskDataNotifier,
      builder: (context, taskData, _) {
        // Compute which minutes are currently active
        final existingMinutes = (reminders ?? [])
            .where((r) => !taskData.removedReminderIds.contains(r.id))
            .map((r) => r.minutesBefore)
            .toSet();
        final addedMinutes = taskData.addedReminderMinutes.toSet();
        final activeMinutes = {...existingMinutes, ...addedMinutes};

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Reminders',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _reminderOptions.map((option) {
                final minutes = option.$1;
                final label = option.$2;
                final isSelected = activeMinutes.contains(minutes);
                final existingReminder = (reminders ?? []).firstWhere(
                  (r) => r.minutesBefore == minutes,
                  orElse: () => TaskReminder(
                    taskId: task.id!,
                    minutesBefore: -1,
                    isSent: false,
                  ),
                );
                final isExisting = existingReminder.minutesBefore == minutes;
                final isSent = isExisting && existingReminder.isSent;

                return FilterChip(
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(label),
                      if (isSent) ...[
                        const SizedBox(width: 4),
                        const Icon(Icons.check, size: 14),
                      ],
                    ],
                  ),
                  selected: isSelected,
                  onSelected: isSent
                      ? null // Can't unselect sent reminders
                      : (selected) {
                          final currentData = taskDataNotifier.value;
                          if (selected) {
                            // Add reminder
                            if (isExisting) {
                              // Remove from removed list
                              final newRemoved = currentData.removedReminderIds
                                  .where((id) => id != existingReminder.id)
                                  .toList();
                              taskDataNotifier.value = currentData.copyWith(
                                removedReminderIds: newRemoved,
                              );
                            } else {
                              // Add to added list
                              final newAdded = [
                                ...currentData.addedReminderMinutes,
                                minutes,
                              ];
                              taskDataNotifier.value = currentData.copyWith(
                                addedReminderMinutes: newAdded,
                              );
                            }
                          } else {
                            // Remove reminder
                            if (isExisting) {
                              // Add to removed list
                              final newRemoved = [
                                ...currentData.removedReminderIds,
                                existingReminder.id!,
                              ];
                              taskDataNotifier.value = currentData.copyWith(
                                removedReminderIds: newRemoved,
                              );
                            } else {
                              // Remove from added list
                              final newAdded = currentData.addedReminderMinutes
                                  .where((m) => m != minutes)
                                  .toList();
                              taskDataNotifier.value = currentData.copyWith(
                                addedReminderMinutes: newAdded,
                              );
                            }
                          }
                        },
                  selectedColor: AppTheme.accent.withValues(alpha: 0.3),
                  checkmarkColor: AppTheme.accent,
                  disabledColor: isSent
                      ? AppTheme.success.withValues(alpha: 0.2)
                      : null,
                );
              }).toList(),
            ),
            if ((reminders ?? []).any((r) => r.isSent))
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Sent reminders cannot be removed',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textMuted,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
