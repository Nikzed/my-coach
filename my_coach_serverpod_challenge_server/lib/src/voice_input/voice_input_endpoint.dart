import 'dart:convert';

import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';
import '../services/grok_service.dart';

/// Endpoint for handling voice input and AI task parsing.
class VoiceInputEndpoint extends Endpoint {
  /// Requires authentication for all methods.
  @override
  bool get requireLogin => true;

  static const _uuid = Uuid();

  /// Parses voice input using AI and creates/updates a draft task.
  ///
  /// [transcribedText] - The speech-to-text result
  /// [sessionId] - Optional session ID for multi-turn clarification
  ///
  /// Returns the created or updated VoiceTaskDraft.
  Future<VoiceTaskDraft> parseVoiceInput(
    Session session,
    String transcribedText, {
    String? sessionId,
  }) async {
    final auth = session.authenticated;
    if (auth == null) {
      throw Exception('User must be authenticated');
    }

    final userId = auth.userIdentifier;
    final now = DateTime.now();

    // Get or create session ID
    final effectiveSessionId = sessionId ?? _uuid.v4();

    // Check for existing draft in this session
    VoiceTaskDraft? existingDraft;
    if (sessionId != null) {
      existingDraft = await VoiceTaskDraft.db.findFirstRow(
        session,
        where: (d) =>
            d.sessionId.equals(sessionId) &
            d.userId.equals(userId) &
            d.status.notEquals('confirmed') &
            d.status.notEquals('expired'),
      );
    }

    // Build conversation history from existing draft
    List<Map<String, String>> conversationHistory = [];
    if (existingDraft != null && existingDraft.conversationHistory != null) {
      try {
        final parsed = jsonDecode(existingDraft.conversationHistory!) as List;
        conversationHistory =
            parsed.map((e) => Map<String, String>.from(e as Map)).toList();
      } catch (_) {}
    }

    // Add the new user message to history
    conversationHistory.add({'role': 'user', 'content': transcribedText});

    // Get available coaches for AI suggestion
    final coaches = await Coach.db.find(session);
    final coachData = coaches.map((c) {
      return {
        'id': c.id,
        'name': c.name,
        'description': c.description,
      };
    }).toList();

    // Parse with AI
    final grokService = GrokService.fromSession(session);
    Map<String, dynamic> parseResult;
    try {
      parseResult = await grokService.parseVoiceInput(
        transcribedText: transcribedText,
        conversationHistory:
            conversationHistory.length > 1 ? conversationHistory : null,
        availableCoaches: coachData,
      );
    } finally {
      grokService.dispose();
    }

    // Add AI response to history if there's a clarification question
    if (parseResult['status'] == 'needs_clarification' &&
        parseResult['clarificationQuestion'] != null) {
      conversationHistory.add({
        'role': 'assistant',
        'content': parseResult['clarificationQuestion'] as String,
      });
    }

    // Prepare parsed data
    final parsedSubtasks = parseResult['subtasks'] as List<dynamic>?;
    final parsedReminders = parseResult['reminders'] as List<dynamic>?;

    // Create or update draft
    if (existingDraft != null) {
      // Update existing draft
      existingDraft.transcribedText = transcribedText;
      existingDraft.parsedName = parseResult['name'] as String?;
      existingDraft.parsedDescription = parseResult['description'] as String?;
      existingDraft.parsedDueTime = parseResult['dueTime'] as String?;
      existingDraft.suggestedCoachId = parseResult['suggestedCoachId'] as int?;
      existingDraft.coachConfidence =
          parseResult['coachConfidence'] as double?;
      existingDraft.parsedSubtasks =
          parsedSubtasks != null ? jsonEncode(parsedSubtasks) : null;
      existingDraft.parsedReminders =
          parsedReminders != null ? jsonEncode(parsedReminders) : null;
      existingDraft.status = parseResult['status'] as String;
      existingDraft.clarificationQuestion =
          parseResult['clarificationQuestion'] as String?;
      existingDraft.conversationHistory = jsonEncode(conversationHistory);

      return await VoiceTaskDraft.db.updateRow(session, existingDraft);
    } else {
      // Create new draft
      final draft = VoiceTaskDraft(
        userId: userId,
        sessionId: effectiveSessionId,
        transcribedText: transcribedText,
        parsedName: parseResult['name'] as String?,
        parsedDescription: parseResult['description'] as String?,
        parsedDueTime: parseResult['dueTime'] as String?,
        suggestedCoachId: parseResult['suggestedCoachId'] as int?,
        coachConfidence: parseResult['coachConfidence'] as double?,
        parsedSubtasks:
            parsedSubtasks != null ? jsonEncode(parsedSubtasks) : null,
        parsedReminders:
            parsedReminders != null ? jsonEncode(parsedReminders) : null,
        status: parseResult['status'] as String,
        clarificationQuestion:
            parseResult['clarificationQuestion'] as String?,
        conversationHistory: jsonEncode(conversationHistory),
        createdAt: now,
        expiresAt: now.add(const Duration(hours: 1)),
      );

      return await VoiceTaskDraft.db.insertRow(session, draft);
    }
  }

  /// Confirms a draft and creates the actual task with reminders and subtasks.
  ///
  /// [draftId] - The ID of the draft to confirm
  /// [overrideCoachId] - Optional coach ID to override AI suggestion
  /// [overrideReminders] - Optional reminders to override AI suggestion (JSON array)
  ///
  /// Returns the created Task.
  Future<Task> confirmDraft(
    Session session,
    int draftId, {
    int? overrideCoachId,
    String? overrideReminders,
  }) async {
    final auth = session.authenticated;
    if (auth == null) {
      throw Exception('User must be authenticated');
    }

    final userId = auth.userIdentifier;

    // Get the draft
    final draft = await VoiceTaskDraft.db.findById(session, draftId);
    if (draft == null) {
      throw ArgumentError('Draft not found');
    }
    if (draft.userId != userId) {
      throw Exception('Not authorized to confirm this draft');
    }
    if (draft.status == 'confirmed') {
      throw Exception('Draft has already been confirmed');
    }
    if (draft.status == 'expired') {
      throw Exception('Draft has expired');
    }

    // Validate required fields
    if (draft.parsedName == null || draft.parsedName!.isEmpty) {
      throw ArgumentError('Task name is required');
    }

    // Determine coach ID
    final coachId = overrideCoachId ?? draft.suggestedCoachId;
    if (coachId == null) {
      throw ArgumentError('Coach selection is required');
    }

    // Parse due time if present
    DateTime? dueTime;
    if (draft.parsedDueTime != null && draft.parsedDueTime!.isNotEmpty) {
      try {
        dueTime = DateTime.parse(draft.parsedDueTime!);
      } catch (_) {
        // Invalid due time format, ignore
      }
    }

    // Create the task
    final task = Task(
      userId: userId,
      coachId: coachId,
      name: draft.parsedName!,
      description: draft.parsedDescription,
      dueTime: dueTime,
      isCompleted: false,
      completedAt: null,
      createdAt: DateTime.now(),
    );

    final createdTask = await Task.db.insertRow(session, task);

    // Create reminders if due time is set
    if (dueTime != null) {
      List<int> reminderMinutes = [0, 30]; // Default reminders

      // Parse reminders from override or draft
      final remindersJson = overrideReminders ?? draft.parsedReminders;
      if (remindersJson != null && remindersJson.isNotEmpty) {
        try {
          final parsed = jsonDecode(remindersJson) as List;
          reminderMinutes = parsed.map((e) => (e as num).toInt()).toList();
        } catch (_) {}
      }

      // Create reminder records
      for (final minutes in reminderMinutes) {
        final reminder = TaskReminder(
          taskId: createdTask.id!,
          minutesBefore: minutes,
          isSent: false,
          sentAt: null,
        );
        await TaskReminder.db.insertRow(session, reminder);
      }
    }

    // Create subtasks if present
    if (draft.parsedSubtasks != null && draft.parsedSubtasks!.isNotEmpty) {
      try {
        final subtaskNames = jsonDecode(draft.parsedSubtasks!) as List;
        for (int i = 0; i < subtaskNames.length; i++) {
          final subtask = Subtask(
            taskId: createdTask.id!,
            name: subtaskNames[i] as String,
            orderIndex: i,
            isCompleted: false,
            completedAt: null,
          );
          await Subtask.db.insertRow(session, subtask);
        }
      } catch (_) {}
    }

    // Mark draft as confirmed
    draft.status = 'confirmed';
    await VoiceTaskDraft.db.updateRow(session, draft);

    return createdTask;
  }

  /// Discards a draft.
  ///
  /// [draftId] - The ID of the draft to discard
  Future<void> discardDraft(Session session, int draftId) async {
    final auth = session.authenticated;
    if (auth == null) {
      throw Exception('User must be authenticated');
    }

    final userId = auth.userIdentifier;

    // Get the draft
    final draft = await VoiceTaskDraft.db.findById(session, draftId);
    if (draft == null) {
      throw ArgumentError('Draft not found');
    }
    if (draft.userId != userId) {
      throw Exception('Not authorized to discard this draft');
    }

    // Delete the draft
    await VoiceTaskDraft.db.deleteRow(session, draft);
  }

  /// Gets all pending drafts for the authenticated user.
  Future<List<VoiceTaskDraft>> getPendingDrafts(Session session) async {
    final auth = session.authenticated;
    if (auth == null) {
      throw Exception('User must be authenticated');
    }

    final userId = auth.userIdentifier;
    final now = DateTime.now();

    // Mark expired drafts
    final expiredDrafts = await VoiceTaskDraft.db.find(
      session,
      where: (d) =>
          d.userId.equals(userId) &
          (d.expiresAt < now) &
          d.status.notEquals('confirmed') &
          d.status.notEquals('expired'),
    );
    for (final draft in expiredDrafts) {
      draft.status = 'expired';
      await VoiceTaskDraft.db.updateRow(session, draft);
    }

    // Get pending and needs_clarification drafts
    return await VoiceTaskDraft.db.find(
      session,
      where: (d) =>
          d.userId.equals(userId) &
          (d.status.equals('pending') | d.status.equals('needs_clarification')),
      orderBy: (d) => d.createdAt,
      orderDescending: true,
    );
  }
}
