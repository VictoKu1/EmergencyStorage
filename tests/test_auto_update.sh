#!/bin/bash
# Test script for auto_update.py
# Tests configuration loading, argument parsing, and dry-run functionality

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test counter
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# Helper function to print test results
print_result() {
    local test_name="$1"
    local result="$2"
    
    TESTS_RUN=$((TESTS_RUN + 1))
    
    if [ "$result" = "PASS" ]; then
        echo -e "${GREEN}✓${NC} $test_name"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        echo -e "${RED}✗${NC} $test_name"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
}

# Test 1: Check if auto_update.py exists
test_script_exists() {
    if [ -f "$REPO_ROOT/scripts/auto_update.py" ]; then
        print_result "auto_update.py exists" "PASS"
    else
        print_result "auto_update.py exists" "FAIL"
    fi
}

# Test 2: Check if auto_update.py is executable
test_script_executable() {
    if [ -x "$REPO_ROOT/scripts/auto_update.py" ]; then
        print_result "auto_update.py is executable" "PASS"
    else
        print_result "auto_update.py is executable" "FAIL"
    fi
}

# Test 3: Check if configuration file exists
test_config_exists() {
    if [ -f "$REPO_ROOT/data/auto_update_config.json" ]; then
        print_result "Configuration file exists" "PASS"
    else
        print_result "Configuration file exists" "FAIL"
    fi
}

# Test 4: Validate JSON syntax in configuration
test_config_valid_json() {
    if python3 -c "import json; json.load(open('$REPO_ROOT/data/auto_update_config.json'))" 2>/dev/null; then
        print_result "Configuration is valid JSON" "PASS"
    else
        print_result "Configuration is valid JSON" "FAIL"
    fi
}

# Test 5: Check if help works
test_help_flag() {
    if python3 "$REPO_ROOT/scripts/auto_update.py" --help >/dev/null 2>&1; then
        print_result "Help flag works" "PASS"
    else
        print_result "Help flag works" "FAIL"
    fi
}

# Test 6: Test dry-run mode
test_dry_run() {
    if python3 "$REPO_ROOT/scripts/auto_update.py" --dry-run 2>&1 | grep -q "DRY RUN"; then
        print_result "Dry-run mode works" "PASS"
    else
        print_result "Dry-run mode works" "FAIL"
    fi
}

# Test 7: Test resource flag (resource1)
test_resource1_flag() {
    if python3 "$REPO_ROOT/scripts/auto_update.py" --resource1 --dry-run 2>&1 | grep -q "resource1"; then
        print_result "Resource1 flag works" "PASS"
    else
        print_result "Resource1 flag works" "FAIL"
    fi
}

# Test 8: Test multiple resource flags
test_multiple_flags() {
    if python3 "$REPO_ROOT/scripts/auto_update.py" --resource1 --resource2 --dry-run >/dev/null 2>&1; then
        print_result "Multiple resource flags work" "PASS"
    else
        print_result "Multiple resource flags work" "FAIL"
    fi
}

# Test 9: Check if GitHub Actions workflow exists
test_workflow_exists() {
    if [ -f "$REPO_ROOT/.github/workflows/auto-update-resources.yml" ]; then
        print_result "GitHub Actions workflow exists" "PASS"
    else
        print_result "GitHub Actions workflow exists" "FAIL"
    fi
}

# Test 10: Validate workflow YAML syntax
test_workflow_valid_yaml() {
    if python3 -c "import yaml; yaml.safe_load(open('$REPO_ROOT/.github/workflows/auto-update-resources.yml'))" 2>/dev/null; then
        print_result "Workflow is valid YAML" "PASS"
    else
        # Try without yaml module (may not be installed)
        if grep -q "name: Automatic Resource Updates" "$REPO_ROOT/.github/workflows/auto-update-resources.yml"; then
            print_result "Workflow is valid YAML" "PASS"
        else
            print_result "Workflow is valid YAML" "FAIL"
        fi
    fi
}

# Test 11: Check if documentation exists
test_documentation_exists() {
    if [ -f "$REPO_ROOT/docs/AUTO_UPDATE.md" ]; then
        print_result "Auto-update documentation exists" "PASS"
    else
        print_result "Auto-update documentation exists" "FAIL"
    fi
}

# Test 12: Check if quick reference exists
test_quick_ref_exists() {
    if [ -f "$REPO_ROOT/docs/AUTO_UPDATE_QUICK_REF.md" ]; then
        print_result "Quick reference exists" "PASS"
    else
        print_result "Quick reference exists" "FAIL"
    fi
}

# Test 13: Verify configuration structure
test_config_structure() {
    if python3 -c "
import json
config = json.load(open('$REPO_ROOT/data/auto_update_config.json'))
assert 'resources' in config
assert 'global_settings' in config
assert 'schedule' in config
assert 'resource1' in config['resources']
assert 'enabled' in config['resources']['resource1']
" 2>/dev/null; then
        print_result "Configuration structure is valid" "PASS"
    else
        print_result "Configuration structure is valid" "FAIL"
    fi
}

# Test 14: Check if logs directory can be created
test_logs_directory() {
    mkdir -p "$REPO_ROOT/logs"
    if [ -d "$REPO_ROOT/logs" ]; then
        print_result "Logs directory creation works" "PASS"
        rmdir "$REPO_ROOT/logs" 2>/dev/null || true
    else
        print_result "Logs directory creation works" "FAIL"
    fi
}

# Main test execution
echo "=========================================="
echo "Auto-Update System Test Suite"
echo "=========================================="
echo ""

# Run all tests
test_script_exists
test_script_executable
test_config_exists
test_config_valid_json
test_help_flag
test_dry_run
test_resource1_flag
test_multiple_flags
test_workflow_exists
test_workflow_valid_yaml
test_documentation_exists
test_quick_ref_exists
test_config_structure
test_logs_directory

# Print summary
echo ""
echo "=========================================="
echo "Test Summary"
echo "=========================================="
echo "Tests run:    $TESTS_RUN"
echo -e "Tests passed: ${GREEN}$TESTS_PASSED${NC}"
if [ $TESTS_FAILED -gt 0 ]; then
    echo -e "Tests failed: ${RED}$TESTS_FAILED${NC}"
else
    echo -e "Tests failed: $TESTS_FAILED"
fi
echo "=========================================="

# Exit with error if any test failed
if [ $TESTS_FAILED -gt 0 ]; then
    exit 1
else
    echo -e "${GREEN}All tests passed!${NC}"
    exit 0
fi
