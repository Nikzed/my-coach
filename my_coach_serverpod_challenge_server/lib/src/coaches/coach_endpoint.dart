import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';

/// Endpoint for retrieving coach characters.
class CoachEndpoint extends Endpoint {
  /// Gets all available coach characters.
  Future<List<Coach>> getCoaches(Session session) async {
    return await Coach.db.find(session);
  }

  /// Gets a specific coach by ID.
  Future<Coach?> getCoach(Session session, int id) async {
    return await Coach.db.findById(session, id);
  }
}
