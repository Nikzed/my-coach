# Running Documentation Validation Tests

## Prerequisites
- Dart SDK 3.8.0 or higher
- All dependencies installed via `dart pub get`

## Running the Tests

### Run all tests including documentation validation
```bash
cd my_coach_serverpod_challenge_server
dart test
```

### Run only the documentation validation tests
```bash
cd my_coach_serverpod_challenge_server
dart test test/documentation_validation_test.dart
```

### Run tests with verbose output
```bash
cd my_coach_serverpod_challenge_server
dart test test/documentation_validation_test.dart --reporter=expanded
```

## Test Coverage

The `documentation_validation_test.dart` file includes comprehensive tests for REVIEW.md:

### Basic Functionality Tests
- ✅ File existence verification
- ✅ File readability check
- ✅ Non-empty content validation
- ✅ Privacy review content verification
- ✅ Project review mention check
- ✅ Testing mention verification
- ✅ Markdown structure validation
- ✅ Content length validation

### Edge Cases and Boundary Conditions
- ✅ UTF-8 encoding validation
- ✅ Line ending format check
- ✅ Null byte detection
- ✅ File type verification

### Negative Test Cases
- ✅ Sensitive information pattern detection
- ✅ Excessive file size check
- ✅ Binary content marker detection

### Regression Tests
- ✅ Content structure consistency
- ✅ File writability verification

### Integration Tests
- ✅ Project structure location verification
- ✅ Documentation complementarity check

## Expected Results

All tests should pass when:
1. REVIEW.md exists in the project root
2. REVIEW.md contains valid privacy review instructions
3. REVIEW.md is properly formatted as a markdown file
4. REVIEW.md does not contain sensitive information
5. REVIEW.md maintains its instructional purpose

## Troubleshooting

### Test fails: "REVIEW.md file must exist in the project root"
- Ensure you're running tests from the correct directory
- Verify REVIEW.md exists in the project root (parent of my_coach_serverpod_challenge_server)

### Test fails: File readability issues
- Check file permissions
- Verify file encoding (should be UTF-8)

### Test fails: Content validation
- Ensure REVIEW.md contains the expected privacy review instructions
- Verify the file hasn't been accidentally cleared or corrupted