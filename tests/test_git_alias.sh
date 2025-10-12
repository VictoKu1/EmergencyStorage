#!/bin/bash
# Test script to verify --git option and git inclusion in --all

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

cd "$REPO_ROOT"

echo "========================================"
echo "Testing --git Option and --all Integration"
echo "========================================"
echo

# Test 1: Verify --git option is accepted
echo "Test 1: Checking if --git option is accepted..."
if ./emergency_storage.sh --help 2>&1 | grep -q "\-\-git"; then
    echo "✓ --git option found in help output"
else
    echo "✗ --git option not found in help output"
    exit 1
fi
echo

# Test 2: Verify --git-repos is NOT in help (should only be --git)
echo "Test 2: Checking that --git-repos is not present..."
if ./emergency_storage.sh --help 2>&1 | grep -q "\-\-git-repos"; then
    echo "✗ --git-repos still found in help output (should be removed)"
    exit 1
else
    echo "✓ --git-repos not found (correctly removed)"
fi
echo

# Test 3: Verify --all includes git repositories in description
echo "Test 3: Checking if --all includes git repositories..."
if ./emergency_storage.sh --help 2>&1 | grep "\-\-all" | grep -q "includes git repositories"; then
    echo "✓ --all description includes git repositories"
else
    echo "✗ --all description doesn't mention git repositories"
    exit 1
fi
echo

# Test 4: Verify --git option is accepted by argument parser
echo "Test 4: Checking if --git option is accepted by script..."
# Create a temporary test directory
TEST_DIR="/tmp/test_git_alias_$$"
mkdir -p "$TEST_DIR"

# This should not fail with "Unknown option" error
if ./emergency_storage.sh --git "$TEST_DIR" 2>&1 | grep -q "Unknown option"; then
    echo "✗ --git option rejected as unknown"
    rm -rf "$TEST_DIR"
    exit 1
else
    echo "✓ --git option accepted by script"
fi

# Clean up
rm -rf "$TEST_DIR"
echo

# Test 5: Verify git-repos is in the sources array for download_all
echo "Test 5: Checking if git-repos is in the sources array for --all..."
if grep -A 1 'local sources=' emergency_storage.sh | grep -q "git-repos"; then
    echo "✓ git-repos is included in sources array for --all"
else
    echo "✗ git-repos is not in sources array for --all"
    exit 1
fi
echo

echo "========================================"
echo "All tests passed! ✓"
echo "========================================"
