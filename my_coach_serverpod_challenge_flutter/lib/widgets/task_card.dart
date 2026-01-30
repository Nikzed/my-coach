import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:my_coach_serverpod_challenge_client/my_coach_serverpod_challenge_client.dart';

import '../bloc/bloc_exports.dart';
import '../theme/app_theme.dart';
import 'task_details_modal.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback? onComplete;
  final VoidCallback? onUncomplete;
  final VoidCallback? onDelete;

  const TaskCard({
    super.key,
    required this.task,
    this.onComplete,
    this.onUncomplete,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isOverdue = task.dueTime != null && task.dueTime!.isBefore(DateTime.now());
    final isPending = !task.isCompleted;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Stack(
        children: [
          // Background that shows when sliding - slightly smaller radius to hide behind card
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.error,
                borderRadius: BorderRadius.circular(17),
              ),
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 24),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.delete_outline,
                    color: Colors.white,
                    size: 24,
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Delete',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Slidable card on top
          Slidable(
            key: Key('task_${task.id}'),
            endActionPane: ActionPane(
              motion: const BehindMotion(),
              extentRatio: 0.25,
              children: [
                // Transparent action to capture tap
                CustomSlidableAction(
                  onPressed: (_) => onDelete?.call(),
                  backgroundColor: Colors.transparent,
                  child: const SizedBox.shrink(),
                ),
              ],
            ),
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: task.isCompleted
                      ? AppTheme.success.withValues(alpha: 0.3)
                      : isOverdue && isPending
                          ? AppTheme.warning.withValues(alpha: 0.5)
                          : const Color(0xFF2A2A30),
                  width: 1,
                ),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _showTaskDetails(context),
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Completion checkbox (tappable in both states)
                            GestureDetector(
                              onTap: isPending ? onComplete : onUncomplete,
                              child: Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: task.isCompleted
                                      ? AppTheme.success
                                      : Colors.transparent,
                                  border: Border.all(
                                    color: task.isCompleted
                                        ? AppTheme.success
                                        : AppTheme.textMuted,
                                    width: 2,
                                  ),
                                ),
                                child: Icon(
                                  Icons.check,
                                  size: 14,
                                  color: task.isCompleted
                                      ? Colors.white
                                      : Colors.transparent,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Task content
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    task.name,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                          decoration: task.isCompleted
                                              ? TextDecoration.lineThrough
                                              : null,
                                          color: task.isCompleted
                                              ? AppTheme.textMuted
                                              : AppTheme.textPrimary,
                                        ),
                                  ),
                                  if (task.description != null &&
                                      task.description!.isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      task.description!,
                                      style:
                                          Theme.of(context).textTheme.bodySmall,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            // Coach avatar (only show if coach is assigned)
                            if (task.coachId != null)
                              BlocBuilder<CoachesBloc, CoachesState>(
                                builder: (context, state) {
                                  final coach = state.getCoachById(task.coachId!);

                                  // Request coach data if not cached
                                  if (coach == null && state.coachesById.isEmpty) {
                                    context.read<CoachesBloc>().add(
                                          CoachLoadByIdRequested(
                                              coachId: task.coachId!),
                                        );
                                    return const SizedBox(
                                      width: 32,
                                      height: 32,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: AppTheme.accent,
                                      ),
                                    );
                                  }

                                  return coach != null
                                      ? _CoachAvatar(coach: coach)
                                      : const SizedBox.shrink();
                                },
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Bottom row with due time and status
                        Row(
                          children: [
                            if (task.dueTime != null) ...[
                              Icon(
                                Icons.access_time,
                                size: 14,
                                color: isOverdue && isPending
                                    ? AppTheme.warning
                                    : AppTheme.textMuted,
                              ),
                              const SizedBox(width: 4),
                              _LiveTimeText(
                                dateTime: task.dueTime!,
                                style: Theme.of(context)
                                    .textTheme
                                    .labelSmall
                                    ?.copyWith(
                                      color: isOverdue && isPending
                                          ? AppTheme.warning
                                          : AppTheme.textMuted,
                                    ),
                              ),
                              const SizedBox(width: 12),
                            ],
                            const Spacer(),
                            if (task.isCompleted && task.completedAt != null)
                              _LiveTimeText(
                                dateTime: task.completedAt!,
                                prefix: 'Done ',
                                style: Theme.of(context)
                                    .textTheme
                                    .labelSmall
                                    ?.copyWith(
                                      color: AppTheme.success,
                                    ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showTaskDetails(BuildContext context) {
    showTaskDetailsModal(context, task);
  }
}

class _CoachAvatar extends StatelessWidget {
  final Coach coach;

  const _CoachAvatar({required this.coach});

  @override
  Widget build(BuildContext context) {
    final color = coach.name.coachPrimaryColor;

    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(10),
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
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}

/// A text widget that auto-updates its relative time display
/// every 30 seconds so "3m ago" becomes "4m ago" without
/// requiring a manual refresh.
class _LiveTimeText extends StatefulWidget {
  final DateTime dateTime;
  final TextStyle? style;
  final String prefix;

  const _LiveTimeText({
    required this.dateTime,
    this.style,
    this.prefix = '',
  });

  @override
  State<_LiveTimeText> createState() => _LiveTimeTextState();
}

class _LiveTimeTextState extends State<_LiveTimeText> {
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(
      const Duration(seconds: 30),
      (_) {
        if (mounted) setState(() {});
      },
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      '${widget.prefix}${_formatDueTime(widget.dateTime)}',
      style: widget.style,
    );
  }

  static String _formatDueTime(DateTime dateTime) {
    final now = DateTime.now();
    final diff = dateTime.difference(now);

    if (diff.isNegative) {
      if (diff.inDays.abs() == 0) {
        if (diff.inHours.abs() < 1) {
          return '${diff.inMinutes.abs()}m ago';
        }
        return '${diff.inHours.abs()}h ago';
      } else if (diff.inDays.abs() == 1) {
        return 'Yesterday ${DateFormat.jm().format(dateTime)}';
      } else {
        return DateFormat.MMMd().format(dateTime);
      }
    } else {
      if (diff.inDays == 0) {
        if (diff.inHours < 1) {
          return 'in ${diff.inMinutes}m';
        }
        return 'Today ${DateFormat.jm().format(dateTime)}';
      } else if (diff.inDays == 1) {
        return 'Tomorrow ${DateFormat.jm().format(dateTime)}';
      } else {
        return DateFormat.MMMd().format(dateTime);
      }
    }
  }
}
