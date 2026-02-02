# Quick Test Reference - REVIEW.md Tests

## 🚀 Quick Start

### Run All Tests
```bash
cd my_coach_serverpod_challenge_server
dart test
```

### Run REVIEW.md Tests Only
```bash
# Validation tests
dart test test/documentation_validation_test.dart

# Workflow tests
dart test test/review_workflow_test.dart
```

### Quick Bash Check (No Dart needed)
```bash
cd my_coach_serverpod_challenge_server/test
bash manual_test_validator.sh
```

---

## 📊 Test Files Overview

| File | Tests | What It Tests |
|------|-------|---------------|
| `documentation_validation_test.dart` | 22 | File integrity, content, security |
| `review_workflow_test.dart` | 13 | Read/write operations, workflows |
| `manual_test_validator.sh` | 12 | Quick validation checks |

**Total: 35+ tests**

---

## ✅ What's Tested

### Basic Checks
- ✅ File exists
- ✅ File is readable/writable
- ✅ Contains expected content
- ✅ Proper markdown format

### Security
- ✅ No leaked credentials
- ✅ No binary corruption
- ✅ Valid UTF-8 encoding
- ✅ No null bytes

### Workflows
- ✅ Can append content
- ✅ Can overwrite content
- ✅ Preserves data integrity
- ✅ Handles large files
- ✅ Concurrent reads work

---

## 🔧 Common Commands

```bash
# Verbose output
dart test --reporter=expanded

# Run specific test
dart test test/documentation_validation_test.dart

# Run with coverage (if available)
dart test --coverage=coverage

# Install dependencies first
dart pub get
```

---

## 🐛 Troubleshooting

### "Package 'test' not found"
```bash
cd my_coach_serverpod_challenge_server
dart pub get
```

### "REVIEW.md file must exist"
- Check you're in the right directory
- REVIEW.md should be in project root

### Tests fail after modifying REVIEW.md
- Check content contains required keywords
- Ensure file isn't corrupt or binary
- Verify UTF-8 encoding

---

## 📝 Test Results Location

Tests write to standard output. Look for:
- ✅ Green checks = Passing
- ❌ Red X = Failing
- 💡 Detailed error messages on failure

---

## 🎯 CI/CD Integration

### GitHub Actions Example
```yaml
- name: Run tests
  run: |
    cd my_coach_serverpod_challenge_server
    dart pub get
    dart test
```

### GitLab CI Example
```yaml
test:
  script:
    - cd my_coach_serverpod_challenge_server
    - dart pub get
    - dart test
```

---

## 📚 More Information

- Full details: See `TEST_SUMMARY.md` (project root)
- Complete guide: See `TESTING_COMPLETE.md` (project root)
- Run instructions: See `RUN_TESTS.md` (this directory)

---

*Quick reference for REVIEW.md test suite - Last updated: 2026-02-02*