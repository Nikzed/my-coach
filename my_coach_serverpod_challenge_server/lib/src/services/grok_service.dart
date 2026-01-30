import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:serverpod/serverpod.dart';

/// Service for integrating with xAI's Grok API for text generation.
class GrokService {
  static const String _baseUrl = 'https://api.x.ai/v1';

  final String _apiKey;
  final http.Client _httpClient;

  GrokService({
    required String apiKey,
    http.Client? httpClient,
  }) : _apiKey = apiKey,
       _httpClient = httpClient ?? http.Client();

  /// Factory constructor to create GrokService from Serverpod session passwords.
  factory GrokService.fromSession(Session session) {
    final apiKey = session.passwords['grokApiKey'];
    if (apiKey == null || apiKey.isEmpty) {
      throw StateError('Grok API key not configured in passwords.yaml');
    }
    return GrokService(apiKey: apiKey);
  }

  /// Generates a coach message based on the task context and coach personality.
  ///
  /// [systemPrompt] - The coach's personality prompt (from Coach.personalityPrompt)
  /// [taskName] - The name of the overdue task
  /// [taskDescription] - Optional description of the task
  /// [coachName] - The coach's name for context
  /// [additionalContext] - Optional additional context for the message (e.g., timing info)
  Future<String> generateCoachMessage({
    required String systemPrompt,
    required String taskName,
    String? taskDescription,
    required String coachName,
    String? additionalContext,
  }) async {
    final userPrompt = _buildUserPrompt(
      taskName: taskName,
      taskDescription: taskDescription,
      additionalContext: additionalContext,
    );

    final response = await _httpClient.post(
      Uri.parse('$_baseUrl/chat/completions'),
      headers: {
        'Authorization': 'Bearer $_apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'model': 'grok-3-mini',
        'messages': [
          {
            'role': 'system',
            'content': systemPrompt,
          },
          {
            'role': 'user',
            'content': userPrompt,
          },
        ],
        'temperature': 0.8,
        'max_tokens': 300,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Grok API error: ${response.statusCode} - ${response.body}',
      );
    }

    final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
    final choices = jsonResponse['choices'] as List<dynamic>;
    if (choices.isEmpty) {
      throw Exception('No response generated from Grok API');
    }

    final message = choices[0]['message'] as Map<String, dynamic>;
    return message['content'] as String;
  }

  String _buildUserPrompt({
    required String taskName,
    String? taskDescription,
    String? additionalContext,
  }) {
    final buffer = StringBuffer();
    buffer.writeln(
      'The user has an overdue task that they haven\'t completed yet.',
    );
    buffer.writeln('Task: $taskName');
    if (taskDescription != null && taskDescription.isNotEmpty) {
      buffer.writeln('Description: $taskDescription');
    }
    if (additionalContext != null && additionalContext.isNotEmpty) {
      buffer.writeln();
      buffer.writeln('Context: $additionalContext');
    }
    buffer.writeln();
    buffer.writeln(
      'Generate a short, motivational message (2-3 sentences) to remind them '
      'about this task in your character\'s unique style. Make it personal, '
      'engaging, and memorable. The message will be converted to speech, '
      'so keep it conversational.',
    );
    return buffer.toString();
  }

  /// Parses voice input to extract task information using AI.
  ///
  /// [transcribedText] - The speech-to-text result from the user
  /// [conversationHistory] - Optional previous conversation for clarification
  /// [availableCoaches] - List of available coaches for suggestion
  ///
  /// Returns a Map with:
  /// - status: "complete" or "needs_clarification"
  /// - name: Parsed task name
  /// - description: Parsed task description (optional)
  /// - dueTime: Parsed due time as ISO string (optional)
  /// - suggestedCoachId: Suggested coach ID based on tone
  /// - coachConfidence: Confidence score (0-1) for coach suggestion
  /// - subtasks: List of subtask strings (optional)
  /// - reminders: List of minutesBefore values (optional)
  /// - clarificationQuestion: Question to ask if status is "needs_clarification"
  Future<Map<String, dynamic>> parseVoiceInput({
    required String transcribedText,
    List<Map<String, String>>? conversationHistory,
    required List<Map<String, dynamic>> availableCoaches,
  }) async {
    final systemPrompt = _buildVoiceParsingSystemPrompt(availableCoaches);
    final userPrompt = _buildVoiceParsingUserPrompt(
      transcribedText,
      conversationHistory,
    );

    final response = await _httpClient
        .post(
          Uri.parse('$_baseUrl/chat/completions'),
          headers: {
            'Authorization': 'Bearer $_apiKey',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'model': 'grok-3-mini',
            'messages': [
              {
                'role': 'system',
                'content': systemPrompt,
              },
              {
                'role': 'user',
                'content': userPrompt,
              },
            ],
            'temperature': 0.3,
            'max_tokens': 1000,
          }),
        )
        .timeout(const Duration(seconds: 30));

    if (response.statusCode != 200) {
      throw Exception(
        'Grok API error: ${response.statusCode} - ${response.body}',
      );
    }

    final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
    final choices = jsonResponse['choices'] as List<dynamic>;
    if (choices.isEmpty) {
      throw Exception('No response generated from Grok API');
    }

    final message = choices[0]['message'] as Map<String, dynamic>;
    final content = message['content'] as String;

    // Parse the JSON response from the AI
    return _parseVoiceInputResponse(content);
  }

  String _buildVoiceParsingSystemPrompt(
    List<Map<String, dynamic>> availableCoaches,
  ) {
    final coachList = availableCoaches.map((c) {
      return '- ID: ${c['id']}, Name: ${c['name']}, Description: ${c['description']}';
    }).join('\n');

    return '''You are a task parsing assistant. Your job is to extract task information from natural language voice input.

Available coaches for assignment:
$coachList

PARSING RULES:
1. Extract the task name - the main action or goal
2. Extract description if there are additional details
3. Extract due time if mentioned (convert relative times like "tomorrow at 3pm" to ISO 8601 format)
4. Suggest a coach based on the task tone:
   - Tough/strict/discipline tasks → Sergeant
   - Gentle/supportive/emotional tasks → Melly (or similar gentle coach)
   - Default to the first available coach if unclear
5. Extract subtasks if the user mentions steps or sub-items
6. Parse reminders:
   - "remind me" with no time → [0, 30] (at due time + 30 min before)
   - "remind me X before" → [X in minutes]
   - "remind me X before and Y before" → [X, Y in minutes]
   - "no reminders" → []
   - No mention of reminders → [0, 30] (default)

TIME CONVERSION EXAMPLES:
- "1 hour before" → 60
- "2 hours before" → 120
- "30 minutes before" → 30
- "1 day before" → 1440
- "at due time" or "when it's due" → 0

RESPONSE FORMAT:
Always respond with valid JSON only, no markdown or other text:
{
  "status": "complete" or "needs_clarification",
  "name": "task name",
  "description": "optional description",
  "dueTime": "ISO 8601 datetime string or null",
  "suggestedCoachId": coach_id_number,
  "coachConfidence": 0.0-1.0,
  "subtasks": ["subtask1", "subtask2"],
  "reminders": [0, 30],
  "clarificationQuestion": "question if status is needs_clarification"
}

If you cannot determine the task name, set status to "needs_clarification" and ask what task the user wants to create.''';
  }

  String _buildVoiceParsingUserPrompt(
    String transcribedText,
    List<Map<String, String>>? conversationHistory,
  ) {
    final buffer = StringBuffer();

    if (conversationHistory != null && conversationHistory.isNotEmpty) {
      buffer.writeln('Previous conversation:');
      for (final entry in conversationHistory) {
        buffer.writeln('${entry['role']}: ${entry['content']}');
      }
      buffer.writeln();
    }

    buffer.writeln('User voice input: "$transcribedText"');
    buffer.writeln();
    buffer.writeln('Parse this voice input and extract task information. Respond with JSON only.');

    return buffer.toString();
  }

  Map<String, dynamic> _parseVoiceInputResponse(String content) {
    // Try to extract JSON from the response
    String jsonStr = content.trim();

    // Remove markdown code blocks if present
    if (jsonStr.startsWith('```json')) {
      jsonStr = jsonStr.substring(7);
    } else if (jsonStr.startsWith('```')) {
      jsonStr = jsonStr.substring(3);
    }
    if (jsonStr.endsWith('```')) {
      jsonStr = jsonStr.substring(0, jsonStr.length - 3);
    }
    jsonStr = jsonStr.trim();

    try {
      final parsed = jsonDecode(jsonStr) as Map<String, dynamic>;

      // Ensure required fields have defaults
      return {
        'status': parsed['status'] ?? 'needs_clarification',
        'name': parsed['name'],
        'description': parsed['description'],
        'dueTime': parsed['dueTime'],
        'suggestedCoachId': parsed['suggestedCoachId'],
        'coachConfidence': (parsed['coachConfidence'] as num?)?.toDouble() ?? 0.5,
        'subtasks': parsed['subtasks'] ?? [],
        'reminders': parsed['reminders'] ?? [0, 30],
        'clarificationQuestion': parsed['clarificationQuestion'],
      };
    } catch (e) {
      // If parsing fails, return a needs_clarification response
      return {
        'status': 'needs_clarification',
        'name': null,
        'description': null,
        'dueTime': null,
        'suggestedCoachId': null,
        'coachConfidence': 0.0,
        'subtasks': [],
        'reminders': [0, 30],
        'clarificationQuestion':
            'I had trouble understanding that. Could you tell me what task you want to create?',
      };
    }
  }

  /// Closes the HTTP client.
  void dispose() {
    _httpClient.close();
  }
}
