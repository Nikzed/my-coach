import 'dart:async';
import 'dart:io';

import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';
import '../services/elevenlabs_service.dart';
import '../services/fcm_service.dart';
import '../services/gcs_storage_service.dart';
import '../services/grok_service.dart';

/// Background task that periodically checks for due task reminders and sends coach calls.
///
/// The new reminder system works with individual TaskReminder records:
/// - Each task can have multiple reminders (e.g., 1 day before, 1 hour before, at due time)
/// - Each reminder is processed independently
/// - Reminders are triggered when: task.dueTime - reminder.minutesBefore <= now
class TaskDueChecker {
  /// Interval between checks (1 minute).
  static const Duration checkInterval = Duration(minutes: 1);

  Timer? _timer;

  /// Starts the periodic task checking.
  void start(Serverpod pod) {
    _timer = Timer.periodic(checkInterval, (_) async {
      final session = await pod.createSession();
      try {
        await _checkDueReminders(session);
      } catch (e, stackTrace) {
        session.log(
          'TaskDueChecker: Error during check - $e',
          level: LogLevel.error,
          stackTrace: stackTrace,
        );
      } finally {
        await session.close();
      }
    });

    // Also run an initial check after a short delay
    Future.delayed(const Duration(seconds: 10), () async {
      final session = await pod.createSession();
      try {
        await _checkDueReminders(session);
      } catch (e, stackTrace) {
        session.log(
          'TaskDueChecker: Error during initial check - $e',
          level: LogLevel.error,
          stackTrace: stackTrace,
        );
      } finally {
        await session.close();
      }
    });
  }

  /// Stops the periodic task checking.
  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  /// Checks for due reminders and processes them.
  ///
  /// Query logic:
  /// - Find all TaskReminder records where isSent = false
  /// - Join with Task where isCompleted = false and dueTime is not null
  /// - Filter where (dueTime - minutesBefore minutes) <= now
  Future<void> _checkDueReminders(Session session) async {
    session.log('TaskDueChecker: Starting reminder check');

    final now = DateTime.now();

    // First, get all unsent reminders
    final unsentReminders = await TaskReminder.db.find(
      session,
      where: (r) => r.isSent.equals(false),
    );

    if (unsentReminders.isEmpty) {
      session.log('TaskDueChecker: No unsent reminders found');
      return;
    }

    session.log('TaskDueChecker: Found ${unsentReminders.length} unsent reminders');

    // For each reminder, check if it's due
    for (final reminder in unsentReminders) {
      final task = await Task.db.findById(session, reminder.taskId);

      if (task == null) {
        session.log(
          'TaskDueChecker: Task not found for reminder ${reminder.id}, marking as sent',
          level: LogLevel.warning,
        );
        reminder.isSent = true;
        await TaskReminder.db.updateRow(session, reminder);
        continue;
      }

      // Skip completed tasks
      if (task.isCompleted) {
        session.log(
          'TaskDueChecker: Task ${task.id} is completed, marking reminder ${reminder.id} as sent',
        );
        reminder.isSent = true;
        await TaskReminder.db.updateRow(session, reminder);
        continue;
      }

      // Skip tasks without due time
      if (task.dueTime == null) {
        session.log(
          'TaskDueChecker: Task ${task.id} has no due time, marking reminder ${reminder.id} as sent',
        );
        reminder.isSent = true;
        await TaskReminder.db.updateRow(session, reminder);
        continue;
      }

      // Calculate when this reminder should trigger
      final triggerTime = task.dueTime!.subtract(Duration(minutes: reminder.minutesBefore));

      if (now.isBefore(triggerTime)) {
        // Not yet time for this reminder
        continue;
      }

      // This reminder is due - process it
      session.log(
        'TaskDueChecker: Processing reminder ${reminder.id} for task ${task.id} '
        '(${reminder.minutesBefore} minutes before)',
      );

      await _processReminder(session, reminder, task, now);
    }
  }

  /// Processes a single due reminder: generates message, TTS, and sends notification.
  Future<void> _processReminder(
    Session session,
    TaskReminder reminder,
    Task task,
    DateTime now,
  ) async {
    try {
      // Skip tasks without a coach assigned
      if (task.coachId == null) {
        session.log(
          'TaskDueChecker: Task ${task.id} has no coach assigned, skipping reminder',
        );
        reminder.isSent = true;
        await TaskReminder.db.updateRow(session, reminder);
        return;
      }

      // Validate coach exists
      final coach = await Coach.db.findById(session, task.coachId!);
      if (coach == null) {
        session.log(
          'TaskDueChecker: Coach not found for task ${task.id}, coachId=${task.coachId}',
          level: LogLevel.error,
        );
        reminder.isSent = true;
        await TaskReminder.db.updateRow(session, reminder);
        return;
      }

      // Validate coach has required fields
      if (coach.elevenLabsVoiceId.isEmpty) {
        session.log(
          'TaskDueChecker: Coach ${coach.id} has no voice ID configured',
          level: LogLevel.error,
        );
        reminder.isSent = true;
        await TaskReminder.db.updateRow(session, reminder);
        return;
      }

      // Get user's device for FCM
      final userDevice = await UserDevice.db.findFirstRow(
        session,
        where: (d) => d.userId.equals(task.userId),
      );

      if (userDevice == null) {
        session.log(
          'TaskDueChecker: No device registered for user ${task.userId}',
          level: LogLevel.warning,
        );
        // Don't mark as sent - user might register a device later
        return;
      }

      // Validate FCM token format
      if (userDevice.fcmToken.isEmpty || userDevice.fcmToken.length < 20) {
        session.log(
          'TaskDueChecker: Invalid FCM token for user ${task.userId}',
          level: LogLevel.warning,
        );
        return;
      }

      // Generate contextual message based on reminder timing
      final messageContext = _getMessageContext(reminder.minutesBefore, task.name);

      // Generate coach message via Grok
      String messageText;
      try {
        final grokService = GrokService.fromSession(session);
        messageText = await grokService.generateCoachMessage(
          systemPrompt: coach.personalityPrompt,
          taskName: task.name,
          taskDescription: task.description,
          coachName: coach.name,
          additionalContext: messageContext,
        );
        grokService.dispose();
      } catch (e) {
        session.log(
          'TaskDueChecker: Failed to generate message via Grok for task ${task.id}: $e',
          level: LogLevel.error,
        );
        // Don't mark as sent - retry on next check
        return;
      }

      session.log('TaskDueChecker: Generated message: $messageText');

      // Create the coach message record
      var coachMessage = CoachMessage(
        taskId: task.id!,
        coachId: coach.id!,
        textContent: messageText,
        generatedAt: now,
      );
      coachMessage = await CoachMessage.db.insertRow(session, coachMessage);

      // Convert to speech via ElevenLabs
      String audioPath;
      try {
        // Use GCS on Cloud Run, local filesystem otherwise
        final isCloudRun =
            Platform.environment.containsKey('K_SERVICE');
        final gcsService = isCloudRun
            ? GcsStorageService(
                bucketName: 'my-coach-flutter-audio',
              )
            : null;

        final elevenLabsService =
            ElevenLabsService.fromSession(session);
        audioPath = await elevenLabsService.textToSpeech(
          text: messageText,
          voiceId: coach.elevenLabsVoiceId,
          messageId: coachMessage.id!,
          modelId: coach.elevenLabsModelId,
          stability: coach.voiceStability,
          similarity: coach.voiceSimilarity,
          style: coach.voiceStyle,
          speed: coach.voiceSpeed,
          speakerBoost: coach.useSpeakerBoost,
          gcsService: gcsService,
        );
        elevenLabsService.dispose();
      } catch (e) {
        session.log(
          'TaskDueChecker: Failed to generate audio via ElevenLabs for task ${task.id}: $e',
          level: LogLevel.error,
        );
        // Don't mark as sent - retry on next check
        return;
      }

      // Update message with audio path
      coachMessage.audioStoragePath = audioPath;
      await CoachMessage.db.updateRow(session, coachMessage);

      session.log('TaskDueChecker: Audio saved to $audioPath');

      // Build audio URL for the client
      final serverConfig = Serverpod.instance.config.apiServer;
      final audioUrl =
          '${serverConfig.publicScheme}://${serverConfig.publicHost}:${serverConfig.publicPort}/audio/getAudio?messageId=${coachMessage.id}';

      // Send FCM notification
      bool sent = false;
      try {
        final fcmService = FCMService.fromSession(session);
        sent = await fcmService.sendCoachCallNotification(
          fcmToken: userDevice.fcmToken,
          messageId: coachMessage.id!,
          coachName: coach.name,
          taskId: task.id!,
          taskName: task.name,
          audioUrl: audioUrl,
        );
        fcmService.dispose();
      } catch (e) {
        session.log(
          'TaskDueChecker: FCM service error for task ${task.id}: $e',
          level: LogLevel.error,
        );
        // Don't mark as sent - retry on next check
        return;
      }

      // ONLY mark reminder as sent if FCM succeeded
      if (sent) {
        session.log('TaskDueChecker: FCM notification sent successfully');
        reminder.isSent = true;
        reminder.sentAt = now;
        await TaskReminder.db.updateRow(session, reminder);
        session.log('TaskDueChecker: Completed processing reminder ${reminder.id}');
      } else {
        session.log(
          'TaskDueChecker: FCM notification failed for reminder ${reminder.id}, will retry',
          level: LogLevel.warning,
        );
      }
    } catch (e, stackTrace) {
      session.log(
        'TaskDueChecker: Error processing reminder ${reminder.id} - $e',
        level: LogLevel.error,
        stackTrace: stackTrace,
      );
    }
  }

  /// Returns contextual information for the message based on reminder timing.
  String _getMessageContext(int minutesBefore, String taskName) {
    if (minutesBefore == 0) {
      return 'This is a reminder that the task is due RIGHT NOW. Be urgent and motivating!';
    } else if (minutesBefore <= 15) {
      return 'This is a reminder that the task is due in just $minutesBefore minutes. Be urgent!';
    } else if (minutesBefore <= 60) {
      return 'This is a heads-up that the task is due in $minutesBefore minutes. Be encouraging!';
    } else if (minutesBefore < 1440) {
      final hours = minutesBefore ~/ 60;
      final mins = minutesBefore % 60;
      final timeStr = mins > 0 ? '$hours hours and $mins minutes' : '$hours hours';
      return 'This is an advance notice that the task is due in $timeStr. Be motivating and help them prepare!';
    } else {
      final days = minutesBefore ~/ 1440;
      return 'This is an early reminder that the task is due in $days day(s). Be encouraging and help them plan ahead!';
    }
  }
}
