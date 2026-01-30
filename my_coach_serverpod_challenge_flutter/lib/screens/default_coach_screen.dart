import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_coach_serverpod_challenge_client/my_coach_serverpod_challenge_client.dart';

import '../bloc/bloc_exports.dart';
import '../services/settings_service.dart';
import '../theme/app_theme.dart';

class DefaultCoachScreen extends StatefulWidget {
  const DefaultCoachScreen({super.key});

  @override
  State<DefaultCoachScreen> createState() => _DefaultCoachScreenState();
}

class _DefaultCoachScreenState extends State<DefaultCoachScreen> {
  int? _selectedCoachId;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _selectedCoachId = SettingsService.instance.defaultCoachId;
  }

  Future<void> _saveDefaultCoach() async {
    setState(() => _isSaving = true);
    await SettingsService.instance.setDefaultCoachId(_selectedCoachId);
    setState(() => _isSaving = false);

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Text(_selectedCoachId != null
                  ? 'Default coach saved'
                  : 'Default coach cleared'),
            ],
          ),
          backgroundColor: AppTheme.success,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Default Coach'),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _saveDefaultCoach,
            child: _isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppTheme.accent,
                    ),
                  )
                : const Text('Save'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Choose your default coach',
              style: Theme.of(context).textTheme.titleMedium,
            ).animate().fadeIn().slideX(begin: -0.1),
            const SizedBox(height: 8),
            Text(
              'This coach will be pre-selected when creating new tasks.',
              style: Theme.of(context).textTheme.bodySmall,
            ).animate(delay: 50.ms).fadeIn().slideX(begin: -0.1),
            const SizedBox(height: 24),
            // No Default option
            _CoachOptionCard(
              title: 'No Default',
              subtitle: 'Select coach for each task',
              icon: Icons.person_off,
              isSelected: _selectedCoachId == null,
              onTap: () => setState(() => _selectedCoachId = null),
            ).animate(delay: 100.ms).fadeIn().slideX(begin: 0.1),
            const SizedBox(height: 12),
            // Coach options
            BlocBuilder<CoachesBloc, CoachesState>(
              builder: (context, state) {
                if (state.isLoading && state.coaches.isEmpty) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppTheme.accent),
                  );
                }

                return Column(
                  children: state.coaches.asMap().entries.map((entry) {
                    final index = entry.key;
                    final coach = entry.value;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _CoachOptionCard(
                        coach: coach,
                        isSelected: _selectedCoachId == coach.id,
                        onTap: () => setState(() => _selectedCoachId = coach.id),
                      ).animate(delay: Duration(milliseconds: 150 + (index * 50)))
                          .fadeIn()
                          .slideX(begin: 0.1),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _CoachOptionCard extends StatelessWidget {
  final Coach? coach;
  final String? title;
  final String? subtitle;
  final IconData? icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _CoachOptionCard({
    this.coach,
    this.title,
    this.subtitle,
    this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = coach?.name.coachPrimaryColor ?? AppTheme.textMuted;
    final secondaryColor = coach?.name.coachSecondaryColor ?? AppTheme.textMuted;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withValues(alpha: 0.15)
              : AppTheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color : const Color(0xFF2A2A30),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            // Avatar
            if (coach != null)
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
                    _getCoachEmoji(coach!.name),
                    style: const TextStyle(fontSize: 28),
                  ),
                ),
              )
            else
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppTheme.surfaceElevated,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  icon ?? Icons.person,
                  size: 28,
                  color: AppTheme.textMuted,
                ),
              ),
            const SizedBox(width: 16),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    coach?.name ?? title ?? '',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: isSelected ? color : AppTheme.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    coach?.description ?? subtitle ?? '',
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
