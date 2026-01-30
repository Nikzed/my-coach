import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_coach_serverpod_challenge_client/my_coach_serverpod_challenge_client.dart';

import '../bloc/bloc_exports.dart';
import '../main.dart';
import '../services/stt_session_manager.dart';
import '../theme/app_theme.dart';
import '../widgets/task_card.dart';
import '../widgets/voice_input_sheet.dart';
import 'create_task_screen.dart';
import 'default_coach_screen.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback? onSignOut;

  const HomeScreen({super.key, this.onSignOut});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            _buildTabBar(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _TaskListView(filter: TaskFilter.pending),
                  _TaskListView(filter: TaskFilter.all),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Mic button for voice input
          FloatingActionButton(
            heroTag: 'voice_fab',
            onPressed: () => _showVoiceInputSheet(context),
            tooltip: 'Voice Input',
            backgroundColor: AppTheme.surfaceElevated,
            child: const Icon(Icons.mic, color: AppTheme.accent),
          )
              .animate()
              .fadeIn(delay: 250.ms)
              .slideY(begin: 0.5, curve: Curves.easeOutBack),
          const SizedBox(width: 12),
          // Plus button for manual task creation
          FloatingActionButton(
            heroTag: 'add_fab',
            onPressed: () => _navigateToCreateTask(context),
            tooltip: 'New Task',
            child: const Icon(Icons.add),
          )
              .animate()
              .fadeIn(delay: 300.ms)
              .slideY(begin: 0.5, curve: Curves.easeOutBack),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'My Coach',
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        color: AppTheme.accent,
                      ),
                ).animate().fadeIn().slideX(begin: -0.2),
                const SizedBox(height: 4),
                Text(
                  'Stay accountable, stay motivated',
                  style: Theme.of(context).textTheme.bodyMedium,
                ).animate(delay: 100.ms).fadeIn().slideX(begin: -0.2),
              ],
            ),
          ),
          PopupMenuButton<String>(
            icon: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.surfaceElevated,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.person, size: 20),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'default_coach',
                padding: EdgeInsets.zero,
                child: Ink(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8),
                    splashFactory: NoSplash.splashFactory,
                    highlightColor: AppTheme.surfaceElevated,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const DefaultCoachScreen(),
                        ),
                      );
                    },
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Row(
                        children: [
                          Icon(Icons.person_pin, size: 18),
                          SizedBox(width: 12),
                          Text('Default Coach'),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const PopupMenuDivider(),
              PopupMenuItem(
                value: 'signout',
                padding: EdgeInsets.zero,
                child: Ink(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8),
                    splashFactory: NoSplash.splashFactory,
                    highlightColor: AppTheme.surfaceElevated,
                    onTap: () {
                      Navigator.pop(context);
                      widget.onSignOut?.call();
                    },
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Row(
                        children: [
                          Icon(Icons.logout, size: 18),
                          SizedBox(width: 12),
                          Text('Sign Out'),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ).animate(delay: 200.ms).fadeIn().scale(begin: const Offset(0.8, 0.8)),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceElevated,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: AppTheme.accent,
          borderRadius: BorderRadius.circular(10),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        indicatorPadding: const EdgeInsets.all(4),
        labelColor: AppTheme.background,
        unselectedLabelColor: AppTheme.textSecondary,
        dividerHeight: 0,
        tabs: const [
          Tab(text: 'Pending'),
          Tab(text: 'All Tasks'),
        ],
      ),
    ).animate(delay: 150.ms).fadeIn().slideY(begin: -0.2);
  }

  void _navigateToCreateTask(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const CreateTaskScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 1),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            )),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  void _showVoiceInputSheet(BuildContext context) {
    final elevenLabsApiKey = appConfig.elevenLabsApiKey;
    if (elevenLabsApiKey == null || elevenLabsApiKey.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Voice input not configured. Please add elevenLabsApiKey to config.json'),
          backgroundColor: AppTheme.error,
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => BlocProvider(
        create: (_) => VoiceInputBloc(
          client: client,
          sttSessionManager: SttSessionManager(apiKey: elevenLabsApiKey),
        )..add(const VoiceInputPermissionRequested()),
        child: const VoiceInputSheet(),
      ),
    );
  }
}

enum TaskFilter { pending, all }

class _TaskListView extends StatelessWidget {
  final TaskFilter filter;

  const _TaskListView({required this.filter});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TasksBloc, TasksState>(
      builder: (context, state) {
        if (state.isLoading && state.tasks.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(color: AppTheme.accent),
          );
        }

        if (state.hasError && state.tasks.isEmpty) {
          return _buildErrorState(context, state.error);
        }

        final filteredTasks = filter == TaskFilter.pending
            ? state.pendingTasks
            : state.tasks;

        if (filteredTasks.isEmpty) {
          return _buildEmptyState(context);
        }

        return RefreshIndicator(
          onRefresh: () async {
            context.read<TasksBloc>().add(const TasksLoadRequested());
          },
          color: AppTheme.accent,
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
            itemCount: filteredTasks.length,
            itemBuilder: (context, index) {
              final task = filteredTasks[index];
              return TaskCard(
                task: task,
                onComplete: () => _completeTask(context, task),
                onUncomplete: () => _uncompleteTask(context, task),
                onDelete: () => _deleteTask(context, task),
              )
                  .animate(delay: Duration(milliseconds: 50 * index))
                  .fadeIn()
                  .slideX(begin: 0.1);
            },
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final isAll = filter == TaskFilter.all;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.surfaceElevated,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isAll ? Icons.assignment : Icons.check_circle_outline,
              size: 48,
              color: AppTheme.textMuted,
            ),
          ).animate().fadeIn().scale(),
          const SizedBox(height: 24),
          Text(
            isAll ? 'No tasks yet' : 'All caught up!',
            style: Theme.of(context).textTheme.headlineSmall,
          ).animate(delay: 100.ms).fadeIn(),
          const SizedBox(height: 8),
          Text(
            isAll
                ? 'Create your first task to get started'
                : 'No pending tasks at the moment',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ).animate(delay: 150.ms).fadeIn(),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String? error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 48,
              color: AppTheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load tasks',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              error ?? 'Unknown error',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                context.read<TasksBloc>().add(const TasksLoadRequested());
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _completeTask(BuildContext context, Task task) async {
    context.read<TasksBloc>().add(TaskCompleteRequested(taskId: task.id!));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('"${task.name}" completed!'),
        backgroundColor: AppTheme.success,
      ),
    );
  }

  Future<void> _uncompleteTask(BuildContext context, Task task) async {
    context.read<TasksBloc>().add(TaskUncompleteRequested(taskId: task.id!));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('"${task.name}" moved to pending'),
        backgroundColor: AppTheme.surfaceElevated,
      ),
    );
  }

  Future<void> _deleteTask(BuildContext context, Task task) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Task'),
        content: Text('Are you sure you want to delete "${task.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      context.read<TasksBloc>().add(TaskDeleteRequested(taskId: task.id!));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Task deleted')),
      );
    }
  }
}
