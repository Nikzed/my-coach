import 'dart:io';
import 'package:test/test.dart';

/// Tests to validate the existence and integrity of project documentation files
/// These tests ensure that critical documentation is present and properly formatted
void main() {
  group('REVIEW.md Documentation Tests', () {
    late File reviewFile;
    late String reviewContent;

    setUpAll(() {
      // Path to REVIEW.md from the server test directory
      final projectRoot = Directory.current.path.endsWith('my_coach_serverpod_challenge_server')
          ? Directory.current.parent.path
          : Directory.current.path;
      reviewFile = File('$projectRoot/REVIEW.md');
    });

    test('REVIEW.md file should exist', () {
      expect(reviewFile.existsSync(), isTrue,
          reason: 'REVIEW.md file must exist in the project root');
    });

    test('REVIEW.md file should be readable', () {
      expect(() => reviewFile.readAsStringSync(), returnsNormally,
          reason: 'REVIEW.md file should be readable without errors');
    });

    test('REVIEW.md should not be empty', () {
      reviewContent = reviewFile.readAsStringSync();
      expect(reviewContent.trim().isNotEmpty, isTrue,
          reason: 'REVIEW.md should contain content');
    });

    test('REVIEW.md should contain privacy review instructions', () {
      reviewContent = reviewFile.readAsStringSync();
      expect(reviewContent.toLowerCase(), contains('privacy'),
          reason: 'REVIEW.md should mention privacy as it is a privacy review document');
    });

    test('REVIEW.md should mention project review', () {
      reviewContent = reviewFile.readAsStringSync();
      expect(reviewContent.toLowerCase(), contains('review'),
          reason: 'REVIEW.md should contain instructions about reviewing');
    });

    test('REVIEW.md should mention testing', () {
      reviewContent = reviewFile.readAsStringSync();
      expect(reviewContent.toLowerCase(), contains('test'),
          reason: 'REVIEW.md should mention testing as part of the review process');
    });

    test('REVIEW.md should have valid markdown structure', () {
      reviewContent = reviewFile.readAsStringSync();
      // Check for common markdown issues
      expect(reviewContent, isNot(startsWith(' ')),
          reason: 'REVIEW.md should not start with leading whitespace');
      expect(reviewContent, isNot(endsWith('  \n')),
          reason: 'REVIEW.md should not have trailing spaces before newlines');
    });

    test('REVIEW.md content should be appropriate length', () {
      reviewContent = reviewFile.readAsStringSync();
      final lines = reviewContent.split('\n');
      expect(lines.length, greaterThan(0),
          reason: 'REVIEW.md should have at least one line of content');
      expect(reviewContent.length, greaterThan(10),
          reason: 'REVIEW.md should have meaningful content (more than 10 characters)');
      expect(reviewContent.length, lessThan(10000),
          reason: 'REVIEW.md should be reasonably sized (less than 10000 characters)');
    });

    test('REVIEW.md should mention clearing or filling the document', () {
      reviewContent = reviewFile.readAsStringSync();
      final lowerContent = reviewContent.toLowerCase();
      expect(
          lowerContent.contains('clear') || lowerContent.contains('fill'),
          isTrue,
          reason: 'REVIEW.md should mention clearing or filling with review results');
    });

    test('REVIEW.md should reference errors or improvements', () {
      reviewContent = reviewFile.readAsStringSync();
      final lowerContent = reviewContent.toLowerCase();
      expect(
          lowerContent.contains('error') || lowerContent.contains('improvement'),
          isTrue,
          reason: 'REVIEW.md should mention errors or improvements as output of review');
    });

    test('REVIEW.md should mention safe usage', () {
      reviewContent = reviewFile.readAsStringSync();
      expect(reviewContent.toLowerCase(), contains('safe'),
          reason: 'REVIEW.md should mention safe usage as the goal of the review');
    });

    // Edge case tests
    group('Edge Cases and Boundary Conditions', () {
      test('REVIEW.md should not contain invalid UTF-8 sequences', () {
        expect(() => reviewFile.readAsStringSync(), returnsNormally,
            reason: 'REVIEW.md should contain valid UTF-8 encoding');
      });

      test('REVIEW.md should have Unix or Windows line endings', () {
        reviewContent = reviewFile.readAsStringSync();
        // Should contain either \n (Unix) or \r\n (Windows) line endings
        expect(reviewContent.contains('\n'), isTrue,
            reason: 'REVIEW.md should use standard line endings');
      });

      test('REVIEW.md should not contain null bytes', () {
        final bytes = reviewFile.readAsBytesSync();
        expect(bytes.contains(0), isFalse,
            reason: 'REVIEW.md should not contain null bytes');
      });

      test('REVIEW.md should be a regular file', () {
        expect(reviewFile.statSync().type, equals(FileSystemEntityType.file),
            reason: 'REVIEW.md should be a regular file, not a directory or link');
      });
    });

    // Negative test cases
    group('Negative Test Cases', () {
      test('REVIEW.md should not contain sensitive information patterns', () {
        reviewContent = reviewFile.readAsStringSync();
        // Check for common patterns that might indicate leaked secrets
        expect(reviewContent, isNot(contains(RegExp(r'password\s*[:=]\s*\S+', caseSensitive: false))),
            reason: 'REVIEW.md should not contain password assignments');
        expect(reviewContent, isNot(contains(RegExp(r'api[_-]?key\s*[:=]\s*[\'"][^\'"]{20,}[\'"]', caseSensitive: false))),
            reason: 'REVIEW.md should not contain API keys');
      });

      test('REVIEW.md should not be excessively large', () {
        final fileSize = reviewFile.lengthSync();
        expect(fileSize, lessThan(1024 * 1024),
            reason: 'REVIEW.md should not be larger than 1MB (likely an error if it is)');
      });

      test('REVIEW.md should not have binary content markers', () {
        reviewContent = reviewFile.readAsStringSync();
        // Check for common binary file markers
        expect(reviewContent, isNot(startsWith('\xFF\xFE')),
            reason: 'REVIEW.md should not start with UTF-16 LE BOM');
        expect(reviewContent, isNot(startsWith('\xFE\xFF')),
            reason: 'REVIEW.md should not start with UTF-16 BE BOM');
      });
    });

    // Regression test
    group('Regression Tests', () {
      test('REVIEW.md content structure matches expected format', () {
        reviewContent = reviewFile.readAsStringSync();
        // Regression test: Ensure the file maintains its instructional nature
        final hasInstructionalContent = reviewContent.contains('Review') ||
            reviewContent.contains('review');
        expect(hasInstructionalContent, isTrue,
            reason: 'REVIEW.md should maintain its instructional purpose');

        // Ensure it's not accidentally replaced with actual review results
        // (which would typically be longer and more structured)
        final lines = reviewContent.split('\n').where((line) => line.trim().isNotEmpty).toList();
        expect(lines.length, lessThan(20),
            reason: 'REVIEW.md should contain instructions, not a completed review (which would be longer)');
      });

      test('REVIEW.md should be writable for updates', () {
        // This test ensures the file can be updated with review results
        final stat = reviewFile.statSync();
        // On Unix-like systems, check if the file has write permissions
        if (Platform.isLinux || Platform.isMacOS) {
          final mode = stat.mode;
          // Check owner write permission (bit 7)
          final ownerCanWrite = (mode & 0x0080) != 0;
          expect(ownerCanWrite, isTrue,
              reason: 'REVIEW.md should be writable to store review results');
        }
      });
    });

    // Integration-style test
    group('Integration Tests', () {
      test('REVIEW.md is accessible from the expected project structure', () {
        // Test that the file is in the correct location relative to server package
        final serverDir = Directory('my_coach_serverpod_challenge_server');
        final flutterDir = Directory('my_coach_serverpod_challenge_flutter');
        final clientDir = Directory('my_coach_serverpod_challenge_client');

        // If running from project root
        if (serverDir.existsSync() && flutterDir.existsSync() && clientDir.existsSync()) {
          final rootReviewFile = File('REVIEW.md');
          expect(rootReviewFile.existsSync(), isTrue,
              reason: 'REVIEW.md should be in project root alongside server/client/flutter directories');
        }
      });

      test('REVIEW.md complements other documentation files', () {
        final projectRoot = Directory.current.path.endsWith('my_coach_serverpod_challenge_server')
            ? Directory.current.parent.path
            : Directory.current.path;

        // Check that other documentation exists
        final readme = File('$projectRoot/README.md');
        if (readme.existsSync()) {
          expect(reviewFile.existsSync(), isTrue,
              reason: 'REVIEW.md should exist alongside README.md as complementary documentation');
        }
      });
    });
  });
}