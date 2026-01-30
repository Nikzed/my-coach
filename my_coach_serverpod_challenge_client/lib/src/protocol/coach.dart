/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod_client/serverpod_client.dart' as _i1;

/// Coach character model for AI coaching personas
abstract class Coach implements _i1.SerializableModel {
  Coach._({
    this.id,
    required this.name,
    required this.description,
    required this.personalityPrompt,
    required this.elevenLabsVoiceId,
    this.elevenLabsModelId,
    this.voiceStability,
    this.voiceSimilarity,
    this.voiceStyle,
    this.voiceSpeed,
    this.useSpeakerBoost,
  });

  factory Coach({
    int? id,
    required String name,
    required String description,
    required String personalityPrompt,
    required String elevenLabsVoiceId,
    String? elevenLabsModelId,
    double? voiceStability,
    double? voiceSimilarity,
    double? voiceStyle,
    double? voiceSpeed,
    bool? useSpeakerBoost,
  }) = _CoachImpl;

  factory Coach.fromJson(Map<String, dynamic> jsonSerialization) {
    return Coach(
      id: jsonSerialization['id'] as int?,
      name: jsonSerialization['name'] as String,
      description: jsonSerialization['description'] as String,
      personalityPrompt: jsonSerialization['personalityPrompt'] as String,
      elevenLabsVoiceId: jsonSerialization['elevenLabsVoiceId'] as String,
      elevenLabsModelId: jsonSerialization['elevenLabsModelId'] as String?,
      voiceStability: (jsonSerialization['voiceStability'] as num?)?.toDouble(),
      voiceSimilarity: (jsonSerialization['voiceSimilarity'] as num?)
          ?.toDouble(),
      voiceStyle: (jsonSerialization['voiceStyle'] as num?)?.toDouble(),
      voiceSpeed: (jsonSerialization['voiceSpeed'] as num?)?.toDouble(),
      useSpeakerBoost: jsonSerialization['useSpeakerBoost'] as bool?,
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  /// The name of the coach character (e.g., "Sergeant", "Melly")
  String name;

  /// A brief description of the coach's personality
  String description;

  /// System prompt for Grok LLM defining the coach's personality
  String personalityPrompt;

  /// ElevenLabs voice ID for text-to-speech
  String elevenLabsVoiceId;

  /// ElevenLabs model ID (e.g., eleven_multilingual_v2, eleven_v3)
  String? elevenLabsModelId;

  /// Voice stability setting (0.0-1.0)
  double? voiceStability;

  /// Voice similarity boost setting (0.0-1.0)
  double? voiceSimilarity;

  /// Voice style setting (0.0-1.0)
  double? voiceStyle;

  /// Voice speed setting (0.5-2.0)
  double? voiceSpeed;

  /// Whether to use speaker boost
  bool? useSpeakerBoost;

  /// Returns a shallow copy of this [Coach]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  Coach copyWith({
    int? id,
    String? name,
    String? description,
    String? personalityPrompt,
    String? elevenLabsVoiceId,
    String? elevenLabsModelId,
    double? voiceStability,
    double? voiceSimilarity,
    double? voiceStyle,
    double? voiceSpeed,
    bool? useSpeakerBoost,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'Coach',
      if (id != null) 'id': id,
      'name': name,
      'description': description,
      'personalityPrompt': personalityPrompt,
      'elevenLabsVoiceId': elevenLabsVoiceId,
      if (elevenLabsModelId != null) 'elevenLabsModelId': elevenLabsModelId,
      if (voiceStability != null) 'voiceStability': voiceStability,
      if (voiceSimilarity != null) 'voiceSimilarity': voiceSimilarity,
      if (voiceStyle != null) 'voiceStyle': voiceStyle,
      if (voiceSpeed != null) 'voiceSpeed': voiceSpeed,
      if (useSpeakerBoost != null) 'useSpeakerBoost': useSpeakerBoost,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CoachImpl extends Coach {
  _CoachImpl({
    int? id,
    required String name,
    required String description,
    required String personalityPrompt,
    required String elevenLabsVoiceId,
    String? elevenLabsModelId,
    double? voiceStability,
    double? voiceSimilarity,
    double? voiceStyle,
    double? voiceSpeed,
    bool? useSpeakerBoost,
  }) : super._(
         id: id,
         name: name,
         description: description,
         personalityPrompt: personalityPrompt,
         elevenLabsVoiceId: elevenLabsVoiceId,
         elevenLabsModelId: elevenLabsModelId,
         voiceStability: voiceStability,
         voiceSimilarity: voiceSimilarity,
         voiceStyle: voiceStyle,
         voiceSpeed: voiceSpeed,
         useSpeakerBoost: useSpeakerBoost,
       );

  /// Returns a shallow copy of this [Coach]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  Coach copyWith({
    Object? id = _Undefined,
    String? name,
    String? description,
    String? personalityPrompt,
    String? elevenLabsVoiceId,
    Object? elevenLabsModelId = _Undefined,
    Object? voiceStability = _Undefined,
    Object? voiceSimilarity = _Undefined,
    Object? voiceStyle = _Undefined,
    Object? voiceSpeed = _Undefined,
    Object? useSpeakerBoost = _Undefined,
  }) {
    return Coach(
      id: id is int? ? id : this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      personalityPrompt: personalityPrompt ?? this.personalityPrompt,
      elevenLabsVoiceId: elevenLabsVoiceId ?? this.elevenLabsVoiceId,
      elevenLabsModelId: elevenLabsModelId is String?
          ? elevenLabsModelId
          : this.elevenLabsModelId,
      voiceStability: voiceStability is double?
          ? voiceStability
          : this.voiceStability,
      voiceSimilarity: voiceSimilarity is double?
          ? voiceSimilarity
          : this.voiceSimilarity,
      voiceStyle: voiceStyle is double? ? voiceStyle : this.voiceStyle,
      voiceSpeed: voiceSpeed is double? ? voiceSpeed : this.voiceSpeed,
      useSpeakerBoost: useSpeakerBoost is bool?
          ? useSpeakerBoost
          : this.useSpeakerBoost,
    );
  }
}
