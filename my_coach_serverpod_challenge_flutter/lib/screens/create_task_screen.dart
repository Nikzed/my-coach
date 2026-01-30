import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:my_coach_serverpod_challenge_client/my_coach_serverpod_challenge_client.dart';

import '../bloc/bloc_exports.dart';
import '../services/settings_service.dart';
import '../theme/app_theme.dart';

class CreateTaskScreen extends StatefulWidget {
  const CreateTaskScreen({super.key});

  @override
  State<CreateTaskScreen> createState() => _CreateTaskScreenState();
}

class _CreateTaskScreenState extends State<CreateTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _subtaskController = TextEditingController();

  DateTime? _dueDate;
  TimeOfDay? _dueTime;
  Coach? _selectedCoach;
  bool _isSubmitting = false;

  // Reminder settings (minutesBefore values)
  final List<int> _reminders = [0]; // Default: at due time only

  // Custom reminder times (absolute DateTime values)
  final List<DateTime> _customReminderTimes = [];

  // Subtasks
  final List<String> _subtasks = [];

  @override
  void initState() {
    super.initState();
    // Pre-select default coach if set
    final defaultCoachId = SettingsService.instance.defaultCoachId;
    if (defaultCoachId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final coachesState = context.read<CoachesBloc>().state;
        final defaultCoach = coachesState.getCoachById(defaultCoachId);
        if (defaultCoach != null && mounted) {
          setState(() => _selectedCoach = defaultCoach);
        }
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _subtaskController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('New Task'),
        actions: [
          TextButton(
            onPressed: _isSubmitting ? null : _submitTask,
            child: _isSubmitting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppTheme.accent,
                    ),
                  )
                : const Text('Create'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Task name
              _buildSectionTitle('Task Name', Icons.title)
                  .animate()
                  .fadeIn()
                  .slideX(begin: -0.1),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  hintText: 'What needs to be done?',
                ),
                textCapitalization: TextCapitalization.sentences,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a task name';
                  }
                  return null;
                },
              ).animate(delay: 50.ms).fadeIn().slideX(begin: -0.1),

              const SizedBox(height: 24),

              // Description
              _buildSectionTitle('Description (Optional)', Icons.notes)
                  .animate(delay: 100.ms)
                  .fadeIn()
                  .slideX(begin: -0.1),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  hintText: 'Add more details...',
                ),
                maxLines: 3,
                textCapitalization: TextCapitalization.sentences,
              ).animate(delay: 150.ms).fadeIn().slideX(begin: -0.1),

              const SizedBox(height: 24),

              // Due Date & Time
              _buildSectionTitle('Deadline (Optional)', Icons.calendar_today)
                  .animate(delay: 200.ms)
                  .fadeIn()
                  .slideX(begin: -0.1),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _DatePickerField(
                      value: _dueDate,
                      onChanged: (date) => setState(() {
                        _dueDate = date;
                        // Clear custom reminders when date changes
                        _customReminderTimes.clear();
                      }),
                      onDateSelected: _openTimePicker,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _TimePickerField(
                      value: _dueTime,
                      enabled: _dueDate != null,
                      onChanged: (time) => setState(() {
                        _dueTime = time;
                        // Clear custom reminders when time changes
                        _customReminderTimes.clear();
                      }),
                    ),
                  ),
                ],
              ).animate(delay: 250.ms).fadeIn().slideX(begin: -0.1),
              if (_dueDate == null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    'Tasks without a deadline won\'t trigger coach calls',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textMuted,
                          fontStyle: FontStyle.italic,
                        ),
                  ),
                ).animate(delay: 300.ms).fadeIn(),

              // Reminder settings (only shown when due date is set)
              if (_dueDate != null) ...[
                const SizedBox(height: 24),
                _buildSectionTitle('Coach Reminders', Icons.notifications)
                    .animate(delay: 300.ms)
                    .fadeIn()
                    .slideX(begin: -0.1),
                const SizedBox(height: 4),
                Text(
                  'When should your coach call you?',
                  style: Theme.of(context).textTheme.bodySmall,
                ).animate(delay: 300.ms).fadeIn(),
                const SizedBox(height: 12),
                _buildRemindersSection().animate(delay: 350.ms).fadeIn(),
              ],

              const SizedBox(height: 24),

              // Subtasks section
              _buildSectionTitle('Subtasks (Optional)', Icons.checklist)
                  .animate(delay: 400.ms)
                  .fadeIn()
                  .slideX(begin: -0.1),
              const SizedBox(height: 8),
              _buildSubtasksSection().animate(delay: 450.ms).fadeIn(),

              const SizedBox(height: 32),

              // Coach Selection
              _buildSectionTitle('Choose Your Coach', Icons.person)
                  .animate(delay: 350.ms)
                  .fadeIn()
                  .slideX(begin: -0.1),
              const SizedBox(height: 4),
              Text(
                'Your coach will motivate you if you miss the deadline',
                style: Theme.of(context).textTheme.bodySmall,
              ).animate(delay: 350.ms).fadeIn(),
              const SizedBox(height: 16),

              BlocBuilder<CoachesBloc, CoachesState>(
                builder: (context, state) {
                  if (state.isLoading && state.coaches.isEmpty) {
                    return const Center(
                      child: CircularProgressIndicator(color: AppTheme.accent),
                    );
                  }

                  if (state.status == CoachesStatus.failure) {
                    return Text('Error loading coaches: ${state.error}');
                  }

                  return Column(
                    children: [
                      // No Coach option
                      _NoCoachCard(
                        isSelected: _selectedCoach == null,
                        onTap: () => setState(() => _selectedCoach = null),
                      ).animate(delay: 400.ms).fadeIn().slideX(begin: 0.1),
                      // Coach options
                      ...state.coaches.asMap().entries.map((entry) {
                        final index = entry.key;
                        final coach = entry.value;
                        return CoachSelectionCard(
                          coach: coach,
                          isSelected: _selectedCoach?.id == coach.id,
                          onTap: () => setState(() => _selectedCoach = coach),
                        )
                            .animate(delay: Duration(milliseconds: 450 + (index * 100)))
                            .fadeIn()
                            .slideX(begin: 0.1);
                      }),
                    ],
                  );
                },
              ),

              const SizedBox(height: 32),

              // Submit button (alternative)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isSubmitting ? null : _submitTask,
                  icon: _isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppTheme.background,
                          ),
                        )
                      : const Icon(Icons.add),
                  label: Text(_isSubmitting ? 'Creating...' : 'Create Task'),
                ),
              ).animate(delay: 600.ms).fadeIn().slideY(begin: 0.2),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppTheme.accent),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: AppTheme.textPrimary,
              ),
        ),
      ],
    );
  }

  Widget _buildRemindersSection() {
    final reminderOptions = [
      (0, 'At due time'),
      (15, '15 min before'),
      (30, '30 min before'),
      (60, '1 hour before'),
      (120, '2 hours before'),
      (1440, '1 day before'),
    ];

    // Calculate minutes until due to disable past options
    final dueDateTime = _getDueDateTime();
    final now = DateTime.now();
    final minutesUntilDue = dueDateTime != null
        ? dueDateTime.difference(now).inMinutes
        : double.maxFinite.toInt();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ...reminderOptions.map((option) {
              final isSelected = _reminders.contains(option.$1);
              final isPast = option.$1 > minutesUntilDue;
              return FilterChip(
                label: Text(
                  option.$2,
                  style: isPast
                      ? const TextStyle(
                          decoration: TextDecoration.lineThrough,
                          color: AppTheme.textMuted,
                        )
                      : null,
                ),
                selected: isSelected && !isPast,
                onSelected: isPast
                    ? null
                    : (selected) {
                        setState(() {
                          if (selected) {
                            _reminders.add(option.$1);
                          } else {
                            _reminders.remove(option.$1);
                          }
                        });
                      },
                selectedColor: AppTheme.accent.withValues(alpha: 0.3),
                checkmarkColor: AppTheme.accent,
                disabledColor: AppTheme.surfaceElevated.withValues(alpha: 0.5),
              );
            }),
            // Custom reminder chip
            ActionChip(
              avatar: const Icon(Icons.add, size: 18, color: AppTheme.accent),
              label: const Text('Custom'),
              onPressed: _showCustomReminderPicker,
            ),
          ],
        ),
        // Display custom reminder times
        if (_customReminderTimes.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(
            'Custom reminders:',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _customReminderTimes.asMap().entries.map((entry) {
              final index = entry.key;
              final reminderTime = entry.value;
              return Chip(
                label: Text(
                  DateFormat.MMMd().add_jm().format(reminderTime),
                ),
                deleteIcon: const Icon(Icons.close, size: 16),
                onDeleted: () {
                  setState(() => _customReminderTimes.removeAt(index));
                },
                backgroundColor: AppTheme.accent.withValues(alpha: 0.2),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildSubtasksSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Existing subtasks
        ..._subtasks.asMap().entries.map((entry) {
          final index = entry.key;
          final subtask = entry.value;
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.surfaceElevated,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.check_box_outline_blank, size: 18, color: AppTheme.textMuted),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(subtask, style: Theme.of(context).textTheme.bodyMedium),
                ),
                GestureDetector(
                  onTap: () => setState(() => _subtasks.removeAt(index)),
                  child: const Icon(Icons.close, size: 18, color: AppTheme.textMuted),
                ),
              ],
            ),
          );
        }),
        // Add subtask input
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _subtaskController,
                decoration: const InputDecoration(
                  hintText: 'Add a subtask...',
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
                textCapitalization: TextCapitalization.sentences,
                onSubmitted: _addSubtask,
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.add_circle, color: AppTheme.accent),
              onPressed: () => _addSubtask(_subtaskController.text),
            ),
          ],
        ),
      ],
    );
  }

  void _addSubtask(String text) {
    if (text.trim().isEmpty) return;
    setState(() {
      _subtasks.add(text.trim());
      _subtaskController.clear();
    });
  }

  DateTime? _getDueDateTime() {
    if (_dueDate == null) return null;
    return DateTime(
      _dueDate!.year,
      _dueDate!.month,
      _dueDate!.day,
      _dueTime?.hour ?? 23,
      _dueTime?.minute ?? 59,
    );
  }

  Future<void> _showCustomReminderPicker() async {
    final dueDateTime = _getDueDateTime();
    if (dueDateTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please set a due date and time first'),
          backgroundColor: AppTheme.warning,
        ),
      );
      return;
    }

    // Show date picker (constrained: now to dueDateTime)
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: now.isBefore(dueDateTime) ? now : dueDateTime,
      firstDate: now,
      lastDate: dueDateTime,
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

    if (date == null || !mounted) return;

    // Show time picker
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
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

    if (time == null || !mounted) return;

    final reminderDateTime = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );

    // Validate reminder is before due time and after now
    if (reminderDateTime.isAfter(dueDateTime)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Reminder must be before the due time'),
          backgroundColor: AppTheme.error,
        ),
      );
      return;
    }

    if (reminderDateTime.isBefore(now)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Reminder time has already passed'),
          backgroundColor: AppTheme.error,
        ),
      );
      return;
    }

    setState(() {
      _customReminderTimes.add(reminderDateTime);
    });
  }

  Future<void> _openTimePicker() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _dueTime ?? TimeOfDay.now(),
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
    if (time != null && mounted) {
      setState(() => _dueTime = time);
    }
  }

  Future<void> _submitTask() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      DateTime? dueDateTime;
      List<int> validReminders = [];

      if (_dueDate != null) {
        dueDateTime = DateTime(
          _dueDate!.year,
          _dueDate!.month,
          _dueDate!.day,
          _dueTime?.hour ?? 23,
          _dueTime?.minute ?? 59,
        );

        // Convert custom reminder times to minutesBefore values
        for (final customTime in _customReminderTimes) {
          final minutesBefore =
              dueDateTime.difference(customTime).inMinutes;
          if (minutesBefore >= 0 && !_reminders.contains(minutesBefore)) {
            _reminders.add(minutesBefore);
          }
        }

        // Filter out reminders that would be in the past
        final now = DateTime.now();
        final minutesUntilDue = dueDateTime.difference(now).inMinutes;
        validReminders = _reminders
            .where((m) => m <= minutesUntilDue)
            .toList();

        // Ensure at least "at due time" (0) is included if task is in future
        if (validReminders.isEmpty && minutesUntilDue >= 0) {
          validReminders = [0];
        }
      }

      final task = Task(
        userId: '', // Will be set by server
        coachId: _selectedCoach?.id,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        dueTime: dueDateTime,
        isCompleted: false,
        createdAt: DateTime.now(),
      );

      // Use TaskCreateWithRemindersRequested to include reminders
      context.read<TasksBloc>().add(TaskCreateWithRemindersRequested(
        task: task,
        reminderMinutes: validReminders,
      ));

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white, size: 18),
                const SizedBox(width: 8),
                Text(_selectedCoach != null
                    ? 'Task created with Coach ${_selectedCoach!.name}'
                    : 'Task created'),
              ],
            ),
            backgroundColor: AppTheme.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create task: $e'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }
}

class _DatePickerField extends StatelessWidget {
  final DateTime? value;
  final ValueChanged<DateTime?> onChanged;
  final VoidCallback? onDateSelected;

  const _DatePickerField({
    required this.value,
    required this.onChanged,
    this.onDateSelected,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: value ?? DateTime.now(),
          firstDate: DateTime.now(),
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
          onChanged(date);
          if (context.mounted) {
            onDateSelected?.call();
          }
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: AppTheme.surfaceElevated,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: value != null
                ? AppTheme.accent.withValues(alpha: 0.5)
                : const Color(0xFF2A2A30),
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today,
              size: 18,
              color: value != null ? AppTheme.accent : AppTheme.textMuted,
            ),
            const SizedBox(width: 8),
            Text(
              value != null
                  ? DateFormat.MMMd().format(value!)
                  : 'Select date',
              style: TextStyle(
                color: value != null ? AppTheme.textPrimary : AppTheme.textMuted,
              ),
            ),
            if (value != null) ...[
              const Spacer(),
              GestureDetector(
                onTap: () => onChanged(null),
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
    );
  }
}

class _TimePickerField extends StatelessWidget {
  final TimeOfDay? value;
  final bool enabled;
  final ValueChanged<TimeOfDay?> onChanged;

  const _TimePickerField({
    required this.value,
    required this.enabled,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled
          ? () async {
              final time = await showTimePicker(
                context: context,
                initialTime: value ?? TimeOfDay.now(),
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
                onChanged(time);
              }
            }
          : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: enabled ? AppTheme.surfaceElevated : AppTheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: value != null
                ? AppTheme.accent.withValues(alpha: 0.5)
                : const Color(0xFF2A2A30),
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.access_time,
              size: 18,
              color: enabled
                  ? (value != null ? AppTheme.accent : AppTheme.textMuted)
                  : AppTheme.textMuted.withValues(alpha: 0.5),
            ),
            const SizedBox(width: 8),
            Text(
              value != null ? value!.format(context) : 'Select time',
              style: TextStyle(
                color: enabled
                    ? (value != null ? AppTheme.textPrimary : AppTheme.textMuted)
                    : AppTheme.textMuted.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CoachSelectionCard extends StatelessWidget {
  final Coach coach;
  final bool isSelected;
  final VoidCallback onTap;

  const CoachSelectionCard({
    super.key,
    required this.coach,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = coach.name.coachPrimaryColor;
    final secondaryColor = coach.name.coachSecondaryColor;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.15) : AppTheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color : const Color(0xFF2A2A30),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            // Coach avatar
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [color, secondaryColor],
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text(
                  _getCoachEmoji(coach.name),
                  style: const TextStyle(fontSize: 28),
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Coach info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    coach.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: isSelected ? color : AppTheme.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    coach.description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            // Selection indicator
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? color : Colors.transparent,
                border: Border.all(
                  color: isSelected ? color : AppTheme.textMuted,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(
                      Icons.check,
                      size: 14,
                      color: Colors.white,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  String _getCoachEmoji(String name) {
    switch (name.toLowerCase()) {
      case 'sergeant':
        return '🎖️';
      case 'melly':
        return '🌸';
      default:
        return '🏋️';
    }
  }
}

/// Card for "No Coach" selection option
class _NoCoachCard extends StatelessWidget {
  final bool isSelected;
  final VoidCallback onTap;

  const _NoCoachCard({
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.textMuted.withValues(alpha: 0.15)
              : AppTheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppTheme.textMuted : const Color(0xFF2A2A30),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            // No coach avatar
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppTheme.surfaceElevated,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Center(
                child: Icon(
                  Icons.person_off,
                  size: 28,
                  color: AppTheme.textMuted,
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'No Coach',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: isSelected
                              ? AppTheme.textMuted
                              : AppTheme.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Create task without coach reminders',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            // Selection indicator
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? AppTheme.textMuted : Colors.transparent,
                border: Border.all(
                  color: isSelected ? AppTheme.textMuted : AppTheme.textMuted,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(
                      Icons.check,
                      size: 14,
                      color: Colors.white,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
