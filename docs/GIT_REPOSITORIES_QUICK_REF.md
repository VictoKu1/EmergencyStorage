# Git Repositories Quick Reference

**Purpose:** Clone and update Git repositories in parallel with error logging.

**Configuration:** JSON file with list of repository URLs and clone settings.

## Quick Commands

```bash
# Clone all repositories
python3 scripts/download_git_repos.py --operation clone

# Update existing repositories
python3 scripts/download_git_repos.py --operation update

# Both clone and update (default)
python3 scripts/download_git_repos.py

# Dry run (test configuration)
python3 scripts/download_git_repos.py --dry-run

# Custom destination
python3 scripts/download_git_repos.py --dest /mnt/external/repos

# Adjust parallel workers
python3 scripts/download_git_repos.py --max-workers 8
```

## Configuration Template

```json
{
  "repositories": [
    {
      "url": "https://github.com/user/repo.git",
      "name": "repo-name",
      "clone_args": ["--depth", "1"],
      "enabled": true
    }
  ]
}
```

## Key Fields

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `url` | string | Yes | Full Git repository URL |
| `name` | string | Yes | Directory name (must be unique) |
| `clone_args` | array | Yes | Git clone arguments (use `[]` for defaults) |
| `enabled` | boolean | Yes | Whether to process this repository |

## Common Clone Arguments

```json
// Shallow clone (faster, saves space)
"clone_args": ["--depth", "1"]

// Single branch only
"clone_args": ["--single-branch"]

// Both shallow and single branch
"clone_args": ["--depth", "1", "--single-branch"]

// Full clone
"clone_args": []

// Mirror clone
"clone_args": ["--mirror"]
```

## Example Configurations

### Minimal Example

```json
{
  "repositories": [
    {
      "url": "https://github.com/torvalds/linux.git",
      "name": "linux",
      "clone_args": ["--depth", "1"],
      "enabled": true
    }
  ]
}
```

### Multiple Repositories

```json
{
  "repositories": [
    {
      "url": "https://github.com/torvalds/linux.git",
      "name": "linux",
      "clone_args": ["--depth", "1", "--single-branch"],
      "enabled": true
    },
    {
      "url": "https://github.com/python/cpython.git",
      "name": "cpython",
      "clone_args": ["--depth", "1"],
      "enabled": true
    },
    {
      "url": "https://github.com/nodejs/node.git",
      "name": "nodejs",
      "clone_args": [],
      "enabled": false
    }
  ]
}
```

## Operations

### Clone
- Clones repositories that don't exist yet
- Skips repositories that are already cloned
- Creates destination directory automatically

### Update
- Updates (pulls) existing repositories
- Skips repositories not yet cloned
- Runs `git pull` in each repository

### Both (Default)
- Runs clone first, then update
- Efficient for maintaining repository collection

## Error Handling

- **Parallel Processing**: Multiple repos processed simultaneously
- **Error Isolation**: Failed repos don't affect others
- **Detailed Logging**: All errors logged to `gitlog.txt` with timestamps
- **Non-Breaking**: Process continues even if some repos fail

## Log File Location

Default: `{destination}/gitlog.txt`

Example:
```
[2025-10-12 18:55:44] Starting clone operation
[2025-10-12 18:55:44] SUCCESS: Cloned https://github.com/user/repo.git to repo
[2025-10-12 18:55:45] ERROR: Failed to clone https://github.com/bad/url.git - repository not found
[2025-10-12 18:55:45] Operation completed: 1 successful, 1 failed
```

## Performance Tips

1. **Use shallow clones** for large repos:
   ```json
   "clone_args": ["--depth", "1"]
   ```

2. **Adjust worker count** based on network:
   - Fast network: `--max-workers 8`
   - Slow network: `--max-workers 2`

3. **Disable unused repos** instead of deleting:
   ```json
   "enabled": false
   ```

## Troubleshooting

| Issue | Solution |
|-------|----------|
| JSON parse error | Validate JSON syntax, check quotes and brackets |
| Clone fails | Check URL validity, network connection, disk space |
| Update fails | Ensure repository was cloned, check for local changes |
| Slow performance | Reduce `--max-workers` or use `--depth 1` |

## Testing

```bash
# Run test suite
bash tests/test_git_repos.sh

# Validate JSON only
python3 -c "import json; json.load(open('data/git_repositories.json'))"

# Test with dry run
python3 scripts/download_git_repos.py --dry-run
```

## File Structure

```
data/git_repositories.json          - Configuration file
scripts/download_git_repos.py       - Main script
docs/GIT_REPOSITORIES.md            - Full documentation
tests/test_git_repos.sh             - Test suite
git_repos/                          - Default destination
git_repos/gitlog.txt                - Operation log file
```

## See Also

- [Full Documentation](GIT_REPOSITORIES.md)
- [Main README](../README.md)
- [Manual Sources](MANUAL_SOURCES.md)
