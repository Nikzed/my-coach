#!/bin/bash
# Manual validation script to verify REVIEW.md meets test criteria
# This script simulates what the Dart tests check

echo "=== Manual REVIEW.md Validation ==="
echo ""

PROJECT_ROOT="../.."
REVIEW_FILE="$PROJECT_ROOT/REVIEW.md"

# Color codes for output
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

pass_count=0
fail_count=0

# Test 1: File exists
echo -n "Test 1: REVIEW.md exists... "
if [ -f "$REVIEW_FILE" ]; then
    echo -e "${GREEN}PASS${NC}"
    ((pass_count++))
else
    echo -e "${RED}FAIL${NC}"
    ((fail_count++))
    exit 1
fi

# Test 2: File is readable
echo -n "Test 2: REVIEW.md is readable... "
if [ -r "$REVIEW_FILE" ]; then
    echo -e "${GREEN}PASS${NC}"
    ((pass_count++))
else
    echo -e "${RED}FAIL${NC}"
    ((fail_count++))
fi

# Test 3: File is not empty
echo -n "Test 3: REVIEW.md is not empty... "
if [ -s "$REVIEW_FILE" ]; then
    echo -e "${GREEN}PASS${NC}"
    ((pass_count++))
else
    echo -e "${RED}FAIL${NC}"
    ((fail_count++))
fi

# Test 4: Contains "privacy"
echo -n "Test 4: Contains 'privacy'... "
if grep -iq "privacy" "$REVIEW_FILE"; then
    echo -e "${GREEN}PASS${NC}"
    ((pass_count++))
else
    echo -e "${RED}FAIL${NC}"
    ((fail_count++))
fi

# Test 5: Contains "review"
echo -n "Test 5: Contains 'review'... "
if grep -iq "review" "$REVIEW_FILE"; then
    echo -e "${GREEN}PASS${NC}"
    ((pass_count++))
else
    echo -e "${RED}FAIL${NC}"
    ((fail_count++))
fi

# Test 6: Contains "test"
echo -n "Test 6: Contains 'test'... "
if grep -iq "test" "$REVIEW_FILE"; then
    echo -e "${GREEN}PASS${NC}"
    ((pass_count++))
else
    echo -e "${RED}FAIL${NC}"
    ((fail_count++))
fi

# Test 7: File size is reasonable
echo -n "Test 7: File size is reasonable (< 1MB)... "
file_size=$(ls -l "$REVIEW_FILE" | awk '{print $5}')
if [ -n "$file_size" ] && [ "$file_size" -lt 1048576 ]; then
    echo -e "${GREEN}PASS${NC}"
    ((pass_count++))
else
    echo -e "${RED}FAIL${NC}"
    ((fail_count++))
fi

# Test 8: Contains "clear" or "fill"
echo -n "Test 8: Contains 'clear' or 'fill'... "
if grep -iq "clear\|fill" "$REVIEW_FILE"; then
    echo -e "${GREEN}PASS${NC}"
    ((pass_count++))
else
    echo -e "${RED}FAIL${NC}"
    ((fail_count++))
fi

# Test 9: Contains "error" or "improvement"
echo -n "Test 9: Contains 'error' or 'improvement'... "
if grep -iq "error\|improvement" "$REVIEW_FILE"; then
    echo -e "${GREEN}PASS${NC}"
    ((pass_count++))
else
    echo -e "${RED}FAIL${NC}"
    ((fail_count++))
fi

# Test 10: Contains "safe"
echo -n "Test 10: Contains 'safe'... "
if grep -iq "safe" "$REVIEW_FILE"; then
    echo -e "${GREEN}PASS${NC}"
    ((pass_count++))
else
    echo -e "${RED}FAIL${NC}"
    ((fail_count++))
fi

# Test 11: No null bytes
echo -n "Test 11: No null bytes in file... "
original_size=$(wc -c < "$REVIEW_FILE")
filtered_size=$(cat "$REVIEW_FILE" | tr -d '\0' | wc -c)
if [ "$original_size" -eq "$filtered_size" ]; then
    echo -e "${GREEN}PASS${NC}"
    ((pass_count++))
else
    echo -e "${RED}FAIL${NC}"
    ((fail_count++))
fi

# Test 12: File is writable
echo -n "Test 12: File is writable... "
if [ -w "$REVIEW_FILE" ]; then
    echo -e "${GREEN}PASS${NC}"
    ((pass_count++))
else
    echo -e "${RED}FAIL${NC}"
    ((fail_count++))
fi

echo ""
echo "=== Test Results ==="
echo "Passed: $pass_count"
echo "Failed: $fail_count"
echo ""

if [ $fail_count -eq 0 ]; then
    echo -e "${GREEN}All tests passed!${NC}"
    exit 0
else
    echo -e "${RED}Some tests failed.${NC}"
    exit 1
fi