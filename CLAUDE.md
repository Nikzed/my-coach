# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build & Run Commands
```bash
dart analyze
dart pub get

flutter pub get

# Add packages
dart pub add 
# or
flutter pub add
```
### Server Setup & Development
```bash
# Start PostgreSQL and Redis (required before running server)
cd my_coach_serverpod_challenge_server
docker compose up --build --detach

# Run server with migrations
dart bin/main.dart --apply-migrations

# Stop database services
docker compose stop
```

### Code Generation (after modifying .spy.yaml models)
```bash
cd my_coach_serverpod_challenge_server
dart pub global run serverpod_cli generate
```

### Database Migrations
```bash
cd my_coach_serverpod_challenge_server
dart pub global run serverpod_cli create-migration
```

### IDE Setup (if serverpod command not found)
```bash
dart pub global activate serverpod_cli
```

### Flutter Development
```bash
cd my_coach_serverpod_challenge_flutter
flutter run

# Build for web (served by Serverpod at /app)
flutter build web --base-href /app/ --wasm
```

### Testing
```bash
# Server integration tests (requires test containers running)
cd my_coach_serverpod_challenge_server
dart test

# Run specific test file
dart test test/integration/some_test.dart

# Flutter tests
cd my_coach_serverpod_challenge_flutter
flutter test

# Run single Flutter test
flutter test test/widget_test.dart
```

## Project Architecture

This is a Serverpod tri-repo project:
- `my_coach_serverpod_challenge_server/` - Backend with Serverpod 3.2.3, Dart 3.8.0+
- `my_coach_serverpod_challenge_client/` - Auto-generated API client (do not modify)
- `my_coach_serverpod_challenge_flutter/` - Flutter app with BLoC pattern, Flutter 3.32.0

### Server Structure
- `lib/src/endpoints/` - API endpoints
- `lib/src/services/` - Core services (GrokService for LLM, ElevenLabsService for TTS, FCMService for push)
- `lib/src/models/` - Database schemas (.spy.yaml files)
- `lib/src/future_calls/` - Scheduled background jobs (TaskDueChecker)
- `migrations/` - Database migrations (auto-managed)
- `config/` - Environment configs (development.yaml, production.yaml, passwords.yaml)

### Flutter Structure
- `lib/bloc/` - BLoC classes (AuthBloc, TasksBloc, CoachesBloc, VoiceInputBloc)
- `lib/screens/` - Screen widgets
- `lib/services/` - CallService, AudioRecorderService, ElevenLabsSTTService
- `lib/config/app_config.dart` - Dynamic API URL detection (emulator vs physical device)
- `assets/config.json` - Runtime configuration

### Call Flow Architecture
Server FutureCall detects overdue task → GrokService generates message → ElevenLabsService creates audio → FCMService sends push → Flutter CallService receives via FirebaseMessaging → flutter_callkit_incoming shows native UI → User accepts → Navigate to CallScreen

## Serverpod Patterns

### Model Definition (.spy.yaml)
Use snake_case for file names and field names. Mark sensitive data with `scope: serverOnly`.

### Endpoints & Services
- Grok LLM calls: Use GrokService on server
- ElevenLabs TTS: Use ElevenLabsService on server, return audio URL to client
- API keys stored in `config/passwords.yaml`, never in Flutter app

### Future Calls
Schedule FutureCall when task is created. Handler triggers FCM notification on deadline.

## State Management (BLoC)

- Events: PascalCase with Event suffix (e.g., TasksLoadRequested)
- States: PascalCase with State suffix (e.g., TasksLoadSuccess)
- Inject Serverpod Client into BLoCs via constructors
- Use RepositoryProvider for Client, BlocProvider for state

## Code Style

- Classes: PascalCase
- Variables/Functions: camelCase
- Files: snake_case
- Max line length: 80 characters
- Use `dart:developer` log, avoid print statements

## Error Handling

- Server: Catch exceptions in endpoints, return meaningful errors
- Flutter: Try-catch in BLoCs, emit Failure states with error messages

## Testing Strategy

- Server: Test endpoints and FutureCalls using serverpod_test framework
- Flutter: BLoC state transitions (unit), widget isolation (widget), mock Client with mocktail

## Accessibility

- Text contrast: minimum 4.5:1
- Touch targets: at least 44x44 pixels
- Wrap custom call buttons in Semantics widgets
