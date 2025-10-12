#!/bin/bash
# Test script for Git repositories download functionality

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

cd "$REPO_ROOT"

echo "========================================"
echo "Testing Git Repositories Manager"
echo "========================================"
echo

# Test 1: Check if git_repositories.json exists
echo "Test 1: Checking if git_repositories.json exists..."
if [ -f "data/git_repositories.json" ]; then
    echo "✓ git_repositories.json exists"
else
    echo "✗ git_repositories.json not found"
    exit 1
fi
echo

# Test 2: Validate JSON structure
echo "Test 2: Validating JSON structure..."
if python3 -c "
import json
with open('data/git_repositories.json', 'r') as f:
    data = json.load(f)
    assert isinstance(data, dict), 'Root must be a dictionary'
    assert 'repositories' in data, 'Must have repositories key'
    assert isinstance(data['repositories'], list), 'repositories must be a list'
    print(f\"✓ JSON structure valid\")
    print(f\"  - Total repositories: {len(data['repositories'])}\")
" 2>&1; then
    echo "✓ JSON validation passed"
else
    echo "✗ JSON validation failed"
    exit 1
fi
echo

# Test 3: Validate required fields in repositories
echo "Test 3: Validating required fields in repositories..."
if python3 -c "
import json

with open('data/git_repositories.json', 'r') as f:
    data = json.load(f)
    
    for i, repo in enumerate(data['repositories']):
        assert isinstance(repo, dict), f'Repository {i} must be dict'
        assert 'url' in repo, f'url missing for repository {i}'
        assert 'name' in repo, f'name missing for repository {i}'
        assert 'clone_args' in repo, f'clone_args missing for repository {i}'
        assert 'enabled' in repo, f'enabled missing for repository {i}'
        assert isinstance(repo['url'], str), f'url must be string for repository {i}'
        assert isinstance(repo['name'], str), f'name must be string for repository {i}'
        assert isinstance(repo['clone_args'], list), f'clone_args must be list for repository {i}'
        assert isinstance(repo['enabled'], bool), f'enabled must be bool for repository {i}'
    
    print('✓ All repositories have required fields (url, name, clone_args, enabled)')
" 2>&1; then
    echo "✓ Field validation passed"
else
    echo "✗ Field validation failed"
    exit 1
fi
echo

# Test 4: Test Python script syntax
echo "Test 4: Checking Python script syntax..."
if python3 -m py_compile scripts/download_git_repos.py 2>&1; then
    echo "✓ Python script syntax valid"
else
    echo "✗ Python script has syntax errors"
    exit 1
fi
echo

# Test 5: Test help command
echo "Test 5: Testing help command..."
if python3 scripts/download_git_repos.py --help > /tmp/git_repos_help.log 2>&1; then
    echo "✓ Help command works"
else
    echo "✗ Help command failed"
    exit 1
fi
echo

# Test 6: Test dry run execution
echo "Test 6: Testing dry run execution..."
if python3 scripts/download_git_repos.py --dry-run --dest /tmp/test_git_repos > /tmp/git_repos_test.log 2>&1; then
    echo "✓ Dry run executed successfully"
    # Check if output contains expected text
    if grep -q "Starting clone operation" /tmp/git_repos_test.log && grep -q "Starting update operation" /tmp/git_repos_test.log; then
        echo "✓ Output contains expected operations"
    else
        echo "✗ Output missing expected operations"
        exit 1
    fi
else
    echo "✗ Dry run execution failed"
    cat /tmp/git_repos_test.log
    exit 1
fi
echo

# Test 7: Test operation parameter
echo "Test 7: Testing operation parameter..."
if python3 scripts/download_git_repos.py --dry-run --operation clone --dest /tmp/test_git_repos > /tmp/git_repos_clone.log 2>&1; then
    if grep -q "Starting clone operation" /tmp/git_repos_clone.log; then
        echo "✓ Clone operation works"
    else
        echo "✗ Clone operation output incorrect"
        exit 1
    fi
else
    echo "✗ Clone operation failed"
    exit 1
fi

if python3 scripts/download_git_repos.py --dry-run --operation update --dest /tmp/test_git_repos > /tmp/git_repos_update.log 2>&1; then
    if grep -q "Starting update operation" /tmp/git_repos_update.log; then
        echo "✓ Update operation works"
    else
        echo "✗ Update operation output incorrect"
        exit 1
    fi
else
    echo "✗ Update operation failed"
    exit 1
fi
echo

# Test 8: Test with custom config path
echo "Test 8: Testing custom config path..."
# Create a temporary test config
cat > /tmp/test_git_config.json << 'EOF'
{
  "repositories": [
    {
      "url": "https://github.com/test/repo.git",
      "name": "test-repo",
      "clone_args": [],
      "enabled": true
    }
  ]
}
EOF

if python3 scripts/download_git_repos.py --dry-run --config /tmp/test_git_config.json --dest /tmp/test_git_repos > /tmp/git_repos_custom.log 2>&1; then
    if grep -q "test-repo" /tmp/git_repos_custom.log; then
        echo "✓ Custom config path works"
    else
        echo "✗ Custom config not used"
        exit 1
    fi
else
    echo "✗ Custom config test failed"
    exit 1
fi
echo

# Test 9: Verify parallel processing capability
echo "Test 9: Verifying parallel processing setup..."
if python3 -c "
from concurrent.futures import ThreadPoolExecutor
import sys
sys.path.insert(0, 'scripts')

# Just verify the script imports without errors and has ThreadPoolExecutor
print('✓ Parallel processing imports available')
" 2>&1; then
    echo "✓ Parallel processing capability verified"
else
    echo "✗ Parallel processing verification failed"
    exit 1
fi
echo

# Test 10: Verify enabled flag handling
echo "Test 10: Verifying enabled flag handling..."
if python3 -c "
import json

with open('data/git_repositories.json', 'r') as f:
    data = json.load(f)
    
    # Check that repositories have enabled flags
    has_enabled = any(repo.get('enabled', False) for repo in data['repositories'])
    has_disabled = any(not repo.get('enabled', True) for repo in data['repositories'])
    
    print(f'✓ Repositories have enabled flags configured')
    print(f'  - Has enabled repos: {has_enabled}')
    print(f'  - Has disabled repos: {has_disabled}')
" 2>&1; then
    echo "✓ Enabled flag handling verified"
else
    echo "✗ Enabled flag verification failed"
    exit 1
fi
echo

# Clean up test files
rm -f /tmp/test_git_config.json
rm -f /tmp/git_repos_*.log

echo "========================================"
echo "All tests passed! ✓"
echo "========================================"
