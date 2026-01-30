import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/core.dart';
import 'package:serverpod_auth_idp_server/providers/google.dart';

import 'src/future_calls/task_due_checker.dart';
import 'src/generated/endpoints.dart';
import 'src/generated/protocol.dart';
import 'src/seeds/coach_seed.dart';

// Global task checker instance
final _taskDueChecker = TaskDueChecker();

// class RefreshJwtTokensEndpoint extends core.RefreshJwtTokensEndpoint {}

/// The starting point of the Serverpod server.
void run(List<String> args) async {
  // Initialize Serverpod and connect it with your generated code.
  final pod = Serverpod(args, Protocol(), Endpoints());

  // Initialize authentication services for the server.
  // Token managers will be used to validate and issue authentication keys,
  // and the identity providers will be the authentication options available for users.
  pod.initializeAuthServices(
    tokenManagerBuilders: [
      JwtConfigFromPasswords(),
      JwtConfig(
        refreshTokenHashPepper: pod.getPassword('jwtRefreshTokenHashPepper')!,
        algorithm: JwtAlgorithm.hmacSha512(
          SecretKey(pod.getPassword('jwtHmacSha512PrivateKey')!),
        ),
      ),
    ],
    identityProviderBuilders: [
      GoogleIdpConfig(
        clientSecret: GoogleClientSecret.fromJsonString(
          pod.getPassword('googleClientSecret')!,
        ),
      ),
    ],
  );

  // Start the server.
  await pod.start();

  // Seed the database with coach characters and update existing ones
  final session = await pod.createSession();
  try {
    await CoachSeed.seed(session);
    // Always update existing coaches with latest voice IDs and names
    await CoachSeed.updateCoaches(session);
  } finally {
    await session.close();
  }

  // // Start the periodic task due checker
  _taskDueChecker.start(pod);
}
