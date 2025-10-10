#!/bin/bash
# Test script for manual sources download functionality

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

cd "$REPO_ROOT"

echo "========================================"
echo "Testing Manual Sources Download System"
echo "========================================"
echo

# Test 1: Check if manual_sources.json exists
echo "Test 1: Checking if manual_sources.json exists..."
if [ -f "data/manual_sources.json" ]; then
    echo "✓ manual_sources.json exists"
else
    echo "✗ manual_sources.json not found"
    exit 1
fi
echo

# Test 2: Validate JSON structure
echo "Test 2: Validating JSON structure..."
if python3 -c "
import json
with open('data/manual_sources.json', 'r') as f:
    data = json.load(f)
    assert 'sources' in data, 'sources key missing'
    print(f\"✓ JSON structure valid\")
    
    # Count sources
    def count_sources(d):
        count = 0
        if isinstance(d, dict):
            if 'url' in d and 'updateFile' in d and 'downloaded' in d:
                return 1
            for v in d.values():
                count += count_sources(v)
        return count
    
    source_count = count_sources(data['sources'])
    print(f\"  - Total sources: {source_count}\")
" 2>&1; then
    echo "✓ JSON validation passed"
else
    echo "✗ JSON validation failed"
    exit 1
fi
echo

# Test 3: Validate required fields in sources
echo "Test 3: Validating required fields in sources..."
if python3 -c "
import json

def validate_source(d, path=''):
    if isinstance(d, dict):
        if 'url' in d:
            # This is a leaf node, check required fields
            assert 'updateFile' in d, f'updateFile missing at {path}'
            assert 'downloaded' in d, f'downloaded missing at {path}'
            assert isinstance(d['updateFile'], bool), f'updateFile must be boolean at {path}'
            assert isinstance(d['downloaded'], bool), f'downloaded must be boolean at {path}'
            return True
        else:
            # Recurse into children
            for key, value in d.items():
                validate_source(value, f'{path}/{key}')
    return True

with open('data/manual_sources.json', 'r') as f:
    data = json.load(f)
    validate_source(data['sources'])
    print('✓ All sources have required fields (url, updateFile, downloaded)')
" 2>&1; then
    echo "✓ Field validation passed"
else
    echo "✗ Field validation failed"
    exit 1
fi
echo

# Test 4: Test Python script syntax
echo "Test 4: Checking Python script syntax..."
if python3 -m py_compile scripts/download_manual_sources.py 2>&1; then
    echo "✓ Python script syntax valid"
else
    echo "✗ Python script has syntax errors"
    exit 1
fi
echo

# Test 5: Test dry run execution
echo "Test 5: Testing dry run execution..."
if python3 scripts/download_manual_sources.py --dry-run > /tmp/manual_sources_test.log 2>&1; then
    echo "✓ Dry run executed successfully"
    # Check if output contains expected text
    if grep -q "Download Summary" /tmp/manual_sources_test.log; then
        echo "✓ Output contains expected summary"
    else
        echo "✗ Output missing expected summary"
        exit 1
    fi
else
    echo "✗ Dry run execution failed"
    cat /tmp/manual_sources_test.log
    exit 1
fi
echo

# Test 6: Test tree depth normalization
echo "Test 6: Testing tree depth with space keys..."
if python3 -c "
import json

def find_max_depth(d, current_depth=0):
    if isinstance(d, dict):
        if 'url' in d:
            return current_depth
        max_d = current_depth
        for v in d.values():
            max_d = max(max_d, find_max_depth(v, current_depth + 1))
        return max_d
    return current_depth

with open('data/manual_sources.json', 'r') as f:
    data = json.load(f)
    
    # Check each operator's depth
    operators = {}
    for op_key, op_value in data['sources'].items():
        depth = find_max_depth(op_value)
        operators[op_key] = depth
        print(f\"  Operator '{op_key}': max depth = {depth}\")
    
    print('✓ Tree depth analysis complete')
" 2>&1; then
    echo "✓ Tree depth validation passed"
else
    echo "✗ Tree depth validation failed"
    exit 1
fi
echo

# Test 7: Test help command
echo "Test 7: Testing help command..."
if python3 scripts/download_manual_sources.py --help > /tmp/help_test.log 2>&1; then
    echo "✓ Help command works"
else
    echo "✗ Help command failed"
    exit 1
fi
echo

# Test 8: Verify updateFile flag behavior
echo "Test 8: Verifying updateFile flag logic..."
if python3 -c "
import json

with open('data/manual_sources.json', 'r') as f:
    data = json.load(f)
    
    # Find sources with updateFile=True and updateFile=False
    has_update_true = False
    has_update_false = False
    
    def check_flags(d):
        global has_update_true, has_update_false
        if isinstance(d, dict):
            if 'updateFile' in d:
                if d['updateFile']:
                    has_update_true = True
                else:
                    has_update_false = True
            for v in d.values():
                check_flags(v)
    
    check_flags(data['sources'])
    
    assert has_update_true, 'No sources with updateFile=True found'
    assert has_update_false, 'No sources with updateFile=False found'
    
    print('✓ Found sources with both updateFile=True and updateFile=False')
" 2>&1; then
    echo "✓ updateFile flag verification passed"
else
    echo "✗ updateFile flag verification failed"
    exit 1
fi
echo

echo "========================================"
echo "All tests passed! ✓"
echo "========================================"
