#!/bin/bash
#
# Test script for setup_auto_update.sh
# This tests the logic without actually installing systemd services
#

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
SETUP_SCRIPT="$REPO_ROOT/scripts/setup_auto_update.sh"

echo "Testing setup_auto_update.sh logic..."
echo

# Test 1: Verify script exists and is executable
echo "Test 1: Check script exists and is executable"
if [ -f "$SETUP_SCRIPT" ]; then
    echo "✓ Script exists at $SETUP_SCRIPT"
else
    echo "✗ Script not found!"
    exit 1
fi

if [ -x "$SETUP_SCRIPT" ]; then
    echo "✓ Script is executable"
else
    echo "✗ Script is not executable!"
    exit 1
fi
echo

# Test 2: Check for bash syntax errors
echo "Test 2: Check bash syntax"
if bash -n "$SETUP_SCRIPT"; then
    echo "✓ No syntax errors found"
else
    echo "✗ Syntax errors found!"
    exit 1
fi
echo

# Test 3: Verify required dependencies in script
echo "Test 3: Check for required dependencies"
required_commands=("systemctl" "python3")
for cmd in "${required_commands[@]}"; do
    if grep -q "command -v $cmd" "$SETUP_SCRIPT"; then
        echo "✓ Script checks for $cmd"
    else
        echo "⚠ Script doesn't explicitly check for $cmd"
    fi
done
echo

# Test 4: Verify service file template is correct
echo "Test 4: Check service file template"
if grep -q "Type=oneshot" "$SETUP_SCRIPT"; then
    echo "✓ Service type is oneshot"
else
    echo "✗ Service type not found or incorrect"
    exit 1
fi

if grep -q "WorkingDirectory=" "$SETUP_SCRIPT"; then
    echo "✓ WorkingDirectory is set"
else
    echo "✗ WorkingDirectory not set"
    exit 1
fi

if grep -q "ExecStart=/usr/bin/python3" "$SETUP_SCRIPT"; then
    echo "✓ ExecStart points to python3"
else
    echo "✗ ExecStart not correct"
    exit 1
fi
echo

# Test 5: Verify timer file template is correct
echo "Test 5: Check timer file template"
if grep -q "Persistent=true" "$SETUP_SCRIPT"; then
    echo "✓ Timer has Persistent=true (survives restarts)"
else
    echo "✗ Persistent not set - timer won't catch up on missed runs"
    exit 1
fi

if grep -q "OnCalendar=" "$SETUP_SCRIPT"; then
    echo "✓ Timer has OnCalendar directive"
else
    echo "✗ OnCalendar not set"
    exit 1
fi

if grep -q "WantedBy=timers.target" "$SETUP_SCRIPT"; then
    echo "✓ Timer targets timers.target"
else
    echo "✗ Timer target not correct"
    exit 1
fi
echo

# Test 6: Verify systemctl commands are present
echo "Test 6: Check for systemctl commands"
systemctl_commands=("daemon-reload" "enable" "start")
for cmd in "${systemctl_commands[@]}"; do
    if grep -q "systemctl $cmd" "$SETUP_SCRIPT"; then
        echo "✓ Script uses systemctl $cmd"
    else
        echo "✗ systemctl $cmd not found"
        exit 1
    fi
done
echo

# Test 7: Verify auto_update.py exists
echo "Test 7: Check auto_update.py exists"
if [ -f "$REPO_ROOT/scripts/auto_update.py" ]; then
    echo "✓ auto_update.py exists"
else
    echo "✗ auto_update.py not found!"
    exit 1
fi
echo

# Test 8: Test auto_update.py can run
echo "Test 8: Test auto_update.py works"
if python3 "$REPO_ROOT/scripts/auto_update.py" --help > /dev/null 2>&1; then
    echo "✓ auto_update.py runs successfully"
else
    echo "✗ auto_update.py has errors!"
    exit 1
fi
echo

# Test 9: Test auto_update.py dry-run
echo "Test 9: Test auto_update.py dry-run mode"
if python3 "$REPO_ROOT/scripts/auto_update.py" --dry-run > /dev/null 2>&1; then
    echo "✓ auto_update.py dry-run works"
else
    echo "✗ auto_update.py dry-run failed!"
    exit 1
fi
echo

# Test 10: Verify logs directory creation
echo "Test 10: Check logs directory handling"
if grep -q "mkdir.*logs" "$SETUP_SCRIPT"; then
    echo "✓ Script creates logs directory"
else
    echo "⚠ Script doesn't explicitly create logs directory"
fi
echo

echo "=========================================="
echo "All tests passed!"
echo "=========================================="
echo
echo "Note: This test validates the script logic."
echo "Actual systemd installation requires:"
echo "  - Running on a Linux system with systemd"
echo "  - Sudo privileges"
echo "  - Interactive input for schedule selection"
