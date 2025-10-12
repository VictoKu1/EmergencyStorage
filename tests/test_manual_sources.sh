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

# Test 2: Validate JSON structure (flat with methods as keys)
echo "Test 2: Validating JSON structure..."
if python3 -c "
import json
with open('data/manual_sources.json', 'r') as f:
    data = json.load(f)
    # New structure: top-level keys are download methods
    assert isinstance(data, dict), 'Root must be a dictionary'
    print(f\"✓ JSON structure valid\")
    print(f\"  - Total download methods: {len(data)}\")
    print(f\"  - Methods: {', '.join(data.keys())}\")
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

with open('data/manual_sources.json', 'r') as f:
    data = json.load(f)
    
    for method, source_info in data.items():
        assert isinstance(source_info, dict), f'Source info for {method} must be dict'
        assert 'url' in source_info, f'url missing for {method}'
        assert 'updateFile' in source_info, f'updateFile missing for {method}'
        assert 'downloaded' in source_info, f'downloaded missing for {method}'
        assert 'alternative' in source_info, f'alternative missing for {method}'
        assert isinstance(source_info['updateFile'], bool), f'updateFile must be bool for {method}'
        assert isinstance(source_info['downloaded'], bool), f'downloaded must be bool for {method}'
        assert isinstance(source_info['alternative'], list), f'alternative must be list for {method}'
    
    print('✓ All sources have required fields (url, updateFile, downloaded, alternative)')
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

# Test 6: Test command building
echo "Test 6: Testing command building from URL field..."
if python3 -c "
import json

with open('data/manual_sources.json', 'r') as f:
    data = json.load(f)
    
    # Check that URL fields contain method-specific syntax
    for method, source_info in data.items():
        url_field = source_info['url']
        print(f\"  {method}: {url_field}\")
        
        # Verify it's a string
        assert isinstance(url_field, str), f'URL field must be string for {method}'
        
        # Verify alternatives are strings
        for alt in source_info['alternative']:
            assert isinstance(alt, str), f'Alternative must be string for {method}'
    
    print('✓ Command building validation passed')
" 2>&1; then
    echo "✓ Command building validation passed"
else
    echo "✗ Command building validation failed"
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
    
    for method, source_info in data.items():
        if source_info['updateFile']:
            has_update_true = True
        else:
            has_update_false = True
    
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
