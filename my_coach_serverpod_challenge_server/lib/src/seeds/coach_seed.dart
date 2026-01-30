import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';

/// Seeds the database with initial coach characters.
class CoachSeed {
  /// The Sergeant coach - a tough drill instructor style.
  static final Coach sergeant = Coach(
    name: 'Sergeant',
    description:
        'A military drill instructor who believes in tough love and discipline.',
    personalityPrompt:
        '''You are Sergeant, a foul-mouthed but caring military drill instructor who is helping someone stay on top of their tasks. Your communication style is:

- Direct and commanding, using military jargon like "soldier", "mission", "objective"
- Motivational through tough love with colorful language - you swear freely (damn, hell, ass, shit, etc.)
- Short, punchy sentences with exclamation points
- References to discipline, honor, and getting the damn job done
- Occasional drill sergeant catchphrases mixed with profanity
- Deep down you care about the person's success, which comes through occasionally despite the swearing
- ALWAYS end your message with an offer to help followed by a strong push, like "Now go do fucking something!"

Example: "Listen up, soldier! That damn task isn't going to complete itself! Get your ass in gear and get this mission done! I don't give a shit about your excuses - your future self will thank you. Now move your ass!"''',
    elevenLabsVoiceId: 'DGzg6RaUqxGRTHSBjfgF', // Brock - deep authoritative male voice
    elevenLabsModelId: 'eleven_multilingual_v2',
    voiceStability: 0.45,
    voiceSimilarity: 0.70,
    voiceStyle: 0.50,
    voiceSpeed: 1.05,
    useSpeakerBoost: true,
  );

  /// The Melly coach - a supportive friend style.
  static final Coach melly = Coach(
    name: 'Melly',
    description: 'A warm and supportive friend who encourages you gently.',
    personalityPrompt:
        '''You are Melly, a warm and supportive friend who helps people stay organized and motivated. Your communication style is:

- Gentle and encouraging, using terms of endearment like "hey friend", "sweetie"
- Empathetic and understanding of challenges
- Positive and uplifting, focusing on small wins
- Uses soft encouragement rather than pressure
- Acknowledges feelings while gently motivating action
- Warm humor and relatable observations about life

Example: "Hey friend! I noticed you have something on your plate that needs a little attention. I know things get busy, but I believe in you! Maybe just take that first small step? You've got this, and I'm cheering you on!"''',
    elevenLabsVoiceId: 'BZgkqPqms7Kj9ulSkVzn', // Eve - warm friendly female voice
    elevenLabsModelId: 'eleven_v3',
    // voiceStability: 0.5,
    // voiceSimilarity: 0.75,
    // voiceStyle: 0.0,
    // useSpeakerBoost: true,
  );

  /// Seeds the coach data into the database.
  /// Only inserts coaches if they don't already exist.
  static Future<void> seed(Session session) async {
    session.log('CoachSeed: Checking for existing coaches...');

    // Check if coaches already exist
    final existingCoaches = await Coach.db.find(session);

    if (existingCoaches.isEmpty) {
      session.log('CoachSeed: No coaches found, seeding database...');

      await Coach.db.insertRow(session, sergeant);
      session.log('CoachSeed: Created Sergeant coach');

      await Coach.db.insertRow(session, melly);
      session.log('CoachSeed: Created Melly coach');

      session.log('CoachSeed: Database seeding complete');
    } else {
      session.log(
        'CoachSeed: ${existingCoaches.length} coaches already exist, skipping seed',
      );
    }
  }

  /// Updates existing coaches with new data (for development).
  /// This will update the personality prompts and voice IDs.
  static Future<void> updateCoaches(Session session) async {
    session.log('CoachSeed: Updating coach data...');

    final existingCoaches = await Coach.db.find(session);

    for (final coach in existingCoaches) {
      if (coach.name == 'Sergeant') {
        coach.personalityPrompt = sergeant.personalityPrompt;
        coach.elevenLabsVoiceId = sergeant.elevenLabsVoiceId;
        coach.elevenLabsModelId = sergeant.elevenLabsModelId;
        coach.voiceStability = sergeant.voiceStability;
        coach.voiceSimilarity = sergeant.voiceSimilarity;
        coach.voiceStyle = sergeant.voiceStyle;
        coach.voiceSpeed = sergeant.voiceSpeed;
        coach.useSpeakerBoost = sergeant.useSpeakerBoost;
        coach.description = sergeant.description;
        await Coach.db.updateRow(session, coach);
        session.log('CoachSeed: Updated Sergeant coach');
      } else if (coach.name == 'Milla' || coach.name == 'Melly') {
        // Handle both old 'Milla' name and new 'Melly' name
        coach.name = melly.name; // Rename to Melly if it was Milla
        coach.personalityPrompt = melly.personalityPrompt;
        coach.elevenLabsVoiceId = melly.elevenLabsVoiceId;
        coach.elevenLabsModelId = melly.elevenLabsModelId;
        coach.voiceStability = melly.voiceStability;
        coach.voiceSimilarity = melly.voiceSimilarity;
        coach.voiceStyle = melly.voiceStyle;
        coach.voiceSpeed = melly.voiceSpeed;
        coach.useSpeakerBoost = melly.useSpeakerBoost;
        coach.description = melly.description;
        await Coach.db.updateRow(session, coach);
        session.log('CoachSeed: Updated Melly coach');
      }
    }

    session.log('CoachSeed: Coach update complete');
  }
}
