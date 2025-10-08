#!/bin/bash
# Test script for dynamic mirror loading

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "========================================"
echo "Testing Dynamic Mirror System"
echo "========================================"
echo

# Test 1: Check if JSON file exists
echo "Test 1: Checking if kiwix.json exists..."
if [ -f "data/mirrors/kiwix.json" ]; then
    echo "✓ kiwix.json exists"
else
    echo "✗ kiwix.json not found"
    exit 1
fi
echo

# Test 2: Validate JSON structure
echo "Test 2: Validating JSON structure..."
if python3 -c "
import json
with open('data/mirrors/kiwix.json', 'r') as f:
    data = json.load(f)
    assert 'mirrors' in data, 'mirrors key missing'
    assert 'rsync' in data['mirrors'], 'rsync mirrors missing'
    assert 'ftp' in data['mirrors'], 'ftp mirrors missing'
    assert 'https' in data['mirrors'], 'https mirrors missing'
    print(f\"✓ JSON structure valid\")
    print(f\"  - RSYNC mirrors: {len(data['mirrors']['rsync'])}\")
    print(f\"  - FTP mirrors: {len(data['mirrors']['ftp'])}\")
    print(f\"  - HTTPS mirrors: {len(data['mirrors']['https'])}\")
" 2>&1; then
    echo "✓ JSON validation passed"
else
    echo "✗ JSON validation failed"
    exit 1
fi
echo

# Test 3: Test mirror loading function
echo "Test 3: Testing mirror loading function..."
mirror_count=$(python3 -c "
import json
with open('data/mirrors/kiwix.json', 'r') as f:
    data = json.load(f)
    mirrors = data.get('mirrors', {}).get('https', [])
    print(len(mirrors))
")

if [ "$mirror_count" -gt 0 ]; then
    echo "✓ Successfully loaded $mirror_count HTTPS mirrors"
    python3 -c "
import json
with open('data/mirrors/kiwix.json', 'r') as f:
    data = json.load(f)
    mirrors = data.get('mirrors', {}).get('https', [])
    for i, mirror in enumerate(mirrors[:3], 1):
        print(f\"  {i}. {mirror}\")
    if len(mirrors) > 3:
        print(f\"  ... and {len(mirrors) - 3} more\")
"
else
    echo "✗ No mirrors loaded"
    exit 1
fi
echo

# Test 4: Check Python script syntax
echo "Test 4: Checking Python script syntax..."
if python3 -m py_compile scripts/update_mirrors.py 2>&1; then
    echo "✓ Python script syntax valid"
else
    echo "✗ Python script has syntax errors"
    exit 1
fi
echo

# Test 5: Check GitHub Actions workflow syntax
echo "Test 5: Checking GitHub Actions workflow..."
if [ -f ".github/workflows/update-mirrors.yml" ]; then
    echo "✓ GitHub Actions workflow exists"
else
    echo "✗ GitHub Actions workflow not found"
    exit 1
fi
echo

# Test 6: Test bash script syntax
echo "Test 6: Checking bash script syntax..."
if bash -n scripts/kiwix.sh; then
    echo "✓ kiwix.sh syntax valid"
else
    echo "✗ kiwix.sh has syntax errors"
    exit 1
fi
echo

echo "========================================"
echo "All tests passed! ✓"
echo "========================================"
