#!/bin/bash
# Integration Test Runner
# Runs all validation and compliance tests

set -e

echo "╔════════════════════════════════════════════════════════════╗"
echo "║       Image Bakery - Complete Test Suite                  ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""

TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$TEST_DIR")"

cd "$PROJECT_ROOT"

# Color codes
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

TESTS_PASSED=0
TESTS_FAILED=0

# Function to run a test
run_test() {
  local test_name=$1
  local test_script=$2
  
  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "Running: $test_name"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  
  if bash "$test_script"; then
    echo -e "${GREEN}✅ PASSED${NC}: $test_name"
    ((TESTS_PASSED++))
  else
    echo -e "${RED}❌ FAILED${NC}: $test_name"
    ((TESTS_FAILED++))
  fi
}

# Run all tests
run_test "Terraform Validation" "$TEST_DIR/terraform-validation.sh"
run_test "Packer Validation" "$TEST_DIR/packer-validation.sh"
run_test "Shell Linting" "$TEST_DIR/shell-linting.sh"
run_test "Security Compliance" "$TEST_DIR/security-compliance.sh"

# Summary
echo ""
echo "╔════════════════════════════════════════════════════════════╗"
echo "║                    Test Summary                            ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""
echo -e "Tests Passed:  ${GREEN}$TESTS_PASSED${NC}"
echo -e "Tests Failed:  ${RED}$TESTS_FAILED${NC}"
echo ""

if [ $TESTS_FAILED -eq 0 ]; then
  echo -e "${GREEN}✅ ALL TESTS PASSED!${NC}"
  exit 0
else
  echo -e "${RED}❌ SOME TESTS FAILED${NC}"
  exit 1
fi
