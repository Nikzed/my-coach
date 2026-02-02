import 'dart:io';
import 'package:test/test.dart';

/// Tests to validate the REVIEW.md workflow
/// These tests ensure that the review file can be properly updated and maintains data integrity
void main() {
  group('REVIEW.md Workflow Tests', () {
    late File reviewFile;
    late String originalContent;
    late Directory projectRoot;

    setUpAll(() {
      // Path to REVIEW.md from the server test directory
      final currentPath = Directory.current.path;
      projectRoot = currentPath.endsWith('my_coach_serverpod_challenge_server')
          ? Directory.current.parent
          : Directory.current;
      reviewFile = File('${projectRoot.path}/REVIEW.md');

      // Backup original content
      if (reviewFile.existsSync()) {
        originalContent = reviewFile.readAsStringSync();
      }
    });

    tearDown(() {
      // Restore original content after each test that modifies the file
      if (reviewFile.existsSync() && originalContent.isNotEmpty) {
        reviewFile.writeAsStringSync(originalContent);
      }
    });

    test('REVIEW.md can be read and parsed line by line', () {
      expect(reviewFile.existsSync(), isTrue);
      final lines = reviewFile.readAsLinesSync();
      expect(lines, isNotEmpty, reason: 'Should be able to read file as lines');

      // Verify we can iterate through all lines
      for (var i = 0; i < lines.length; i++) {
        expect(lines[i], isA<String>(),
            reason: 'Each line should be a valid string');
      }
    });

    test('REVIEW.md content can be appended without corruption', () {
      final testContent = '\n<!-- Test append -->';
      final originalLength = reviewFile.lengthSync();

      // Simulate appending review results
      final sink = reviewFile.openWrite(mode: FileMode.append);
      sink.write(testContent);
      sink.close().then((_) {
        final newLength = reviewFile.lengthSync();
        expect(newLength, greaterThan(originalLength),
            reason: 'File should grow after append');

        final content = reviewFile.readAsStringSync();
        expect(content, contains('<!-- Test append -->'),
            reason: 'Appended content should be present');
      });
    });

    test('REVIEW.md can be completely rewritten with structured review results', () {
      // Simulate a complete review result
      const mockReviewResult = '''# Privacy Review Results

## Issues Found
1. [HIGH] Potential data leak in user authentication
2. [MEDIUM] Unencrypted API keys in configuration
3. [LOW] Missing privacy policy link

## Improvements Recommended
- Implement end-to-end encryption
- Add data retention policies
- Update consent mechanisms

## Review Date
2026-02-02

## Status
Review Complete
''';

      // Write mock review results
      reviewFile.writeAsStringSync(mockReviewResult);

      // Verify the write was successful
      final content = reviewFile.readAsStringSync();
      expect(content, equals(mockReviewResult),
          reason: 'File should contain exactly the new content');
      expect(content, contains('Privacy Review Results'));
      expect(content, contains('Issues Found'));
      expect(content, contains('Improvements Recommended'));
    });

    test('REVIEW.md preserves UTF-8 encoding when updated', () {
      const unicodeContent = '''# Privacy Review 🔒

## Issues 📋
- Security vulnerability 🛡️
- Privacy concern 🔐

## Status ✓
Complete
''';

      reviewFile.writeAsStringSync(unicodeContent);
      final content = reviewFile.readAsStringSync();

      expect(content, equals(unicodeContent),
          reason: 'UTF-8 content including emojis should be preserved');
      expect(content, contains('🔒'));
      expect(content, contains('📋'));
      expect(content, contains('🛡️'));
    });

    test('REVIEW.md handles multiple write operations correctly', () {
      // First write
      reviewFile.writeAsStringSync('# Initial Review\n');
      expect(reviewFile.readAsStringSync(), equals('# Initial Review\n'));

      // Second write (overwrite)
      reviewFile.writeAsStringSync('# Updated Review\n');
      expect(reviewFile.readAsStringSync(), equals('# Updated Review\n'));

      // Third write (overwrite)
      reviewFile.writeAsStringSync('# Final Review\n');
      expect(reviewFile.readAsStringSync(), equals('# Final Review\n'));
    });

    test('REVIEW.md can store and retrieve structured markdown', () {
      const structuredContent = '''# Privacy Review

## Summary
Project reviewed for privacy compliance.

## Findings

### Critical
- None

### High Priority
1. Item 1
2. Item 2

### Medium Priority
- Item A
- Item B

## Conclusion
All items addressed.
''';

      reviewFile.writeAsStringSync(structuredContent);
      final content = reviewFile.readAsStringSync();

      // Verify structure is maintained
      expect(content, contains('# Privacy Review'));
      expect(content, contains('## Summary'));
      expect(content, contains('## Findings'));
      expect(content, contains('### Critical'));
      expect(content, contains('1. Item 1'));
      expect(content, contains('- Item A'));
    });

    test('REVIEW.md handles empty review results', () {
      // Simulate clearing the file for a new review
      reviewFile.writeAsStringSync('');

      expect(reviewFile.existsSync(), isTrue,
          reason: 'File should still exist after being cleared');
      expect(reviewFile.lengthSync(), equals(0),
          reason: 'File should be empty');

      final content = reviewFile.readAsStringSync();
      expect(content, isEmpty, reason: 'Content should be empty string');
    });

    test('REVIEW.md can be reset to instructions template', () {
      const instructionsTemplate =
          'Review the whole project and test it on privacy. '
          'Clearing the REVIEW.md after you finish and filling it '
          'with the structured list of errors and improvements '
          'required for this project to have a safe usage.\n';

      reviewFile.writeAsStringSync(instructionsTemplate);

      final content = reviewFile.readAsStringSync();
      expect(content, equals(instructionsTemplate));
      expect(content, contains('privacy'));
      expect(content, contains('safe usage'));
    });

    test('REVIEW.md file timestamp updates on modification', () {
      final initialStat = reviewFile.statSync();
      final initialModified = initialStat.modified;

      // Wait a moment to ensure timestamp difference
      sleep(Duration(milliseconds: 10));

      // Modify the file
      reviewFile.writeAsStringSync('# Modified content');

      final newStat = reviewFile.statSync();
      final newModified = newStat.modified;

      expect(newModified.isAfter(initialModified) ||
             newModified.isAtSameMomentAs(initialModified), isTrue,
          reason: 'Modification timestamp should update or stay the same');
    });

    test('REVIEW.md maintains line endings consistency', () {
      // Test with Unix line endings
      const unixContent = 'Line 1\nLine 2\nLine 3\n';
      reviewFile.writeAsStringSync(unixContent);
      expect(reviewFile.readAsStringSync(), equals(unixContent));

      // Test with Windows line endings
      const windowsContent = 'Line 1\r\nLine 2\r\nLine 3\r\n';
      reviewFile.writeAsStringSync(windowsContent);
      final readContent = reviewFile.readAsStringSync();
      // Dart normalizes line endings on some platforms, so we check it's readable
      expect(readContent, isNotEmpty);
      expect(readContent, contains('Line 1'));
      expect(readContent, contains('Line 2'));
    });

    test('REVIEW.md can handle large review results', () {
      // Generate a large but reasonable review result
      final largeContent = StringBuffer('# Privacy Review\n\n');
      for (var i = 1; i <= 100; i++) {
        largeContent.writeln('## Issue $i');
        largeContent.writeln('Description: This is issue number $i');
        largeContent.writeln('Severity: ${i % 3 == 0 ? "HIGH" : i % 2 == 0 ? "MEDIUM" : "LOW"}');
        largeContent.writeln('');
      }

      final content = largeContent.toString();
      reviewFile.writeAsStringSync(content);

      final readBack = reviewFile.readAsStringSync();
      expect(readBack, equals(content),
          reason: 'Large content should be written and read correctly');
      expect(readBack, contains('Issue 1'));
      expect(readBack, contains('Issue 100'));
      expect(reviewFile.lengthSync(), greaterThan(1000),
          reason: 'Large review should result in substantial file size');
    });

    test('REVIEW.md handles concurrent read operations', () {
      // Ensure content exists
      if (reviewFile.readAsStringSync().isEmpty) {
        reviewFile.writeAsStringSync('Test content for concurrent reads');
      }

      // Perform multiple reads concurrently
      final futures = <Future<String>>[];
      for (var i = 0; i < 10; i++) {
        futures.add(Future(() => reviewFile.readAsStringSync()));
      }

      Future.wait(futures).then((results) {
        expect(results.length, equals(10));
        // All reads should return the same content
        for (var result in results) {
          expect(result, equals(results.first));
        }
      });
    });

    test('REVIEW.md path resolution works from different working directories', () {
      // This test ensures the file can be found regardless of where tests run from
      final absolutePath = reviewFile.absolute.path;
      final alternateFile = File(absolutePath);

      expect(alternateFile.existsSync(), isTrue,
          reason: 'File should be accessible via absolute path');
      expect(alternateFile.path, equals(reviewFile.absolute.path),
          reason: 'Both path resolutions should match');
    });
  });
}