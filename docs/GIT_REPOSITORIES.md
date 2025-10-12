# Git Repositories Manager

A parallel Git repository cloning and updating system for EmergencyStorage.

## Overview

The Git Repositories Manager allows you to maintain a collection of Git repositories by cloning and updating them in parallel. It handles errors gracefully, logging issues to `gitlog.txt` without breaking the entire operation.

## Features

- **Parallel Processing**: Clones/updates multiple repositories simultaneously (default: 4 workers)
- **Error Isolation**: Failed repositories don't affect other operations
- **Comprehensive Logging**: All operations logged to `gitlog.txt` with timestamps
- **Flexible Operations**: Clone, update, or both
- **Enable/Disable Repos**: Control which repositories to process
- **Custom Clone Arguments**: Specify git clone flags per repository
- **Dry Run Support**: Test configuration before executing

## Quick Start

### Basic Usage

```bash
# Clone all configured repositories
python3 scripts/download_git_repos.py --operation clone

# Update all existing repositories
python3 scripts/download_git_repos.py --operation update

# Both clone and update (default)
python3 scripts/download_git_repos.py

# Dry run to see what would happen
python3 scripts/download_git_repos.py --dry-run
```

### Custom Configuration

```bash
# Use custom config file
python3 scripts/download_git_repos.py --config path/to/config.json

# Specify destination directory
python3 scripts/download_git_repos.py --dest /mnt/external/git_repos

# Set maximum parallel workers
python3 scripts/download_git_repos.py --max-workers 8

# Custom log file location
python3 scripts/download_git_repos.py --log /path/to/custom-log.txt
```

## Configuration File

Default location: `data/git_repositories.json`

### Structure

```json
{
  "repositories": [
    {
      "url": "https://github.com/user/repository.git",
      "name": "repository",
      "clone_args": ["--depth", "1"],
      "enabled": true
    }
  ]
}
```

### Field Descriptions

#### `url` (required)
The full Git repository URL. Supports HTTPS and SSH protocols.

**Examples:**
- `"https://github.com/user/repo.git"`
- `"git@github.com:user/repo.git"`
- `"https://gitlab.com/user/project.git"`

#### `name` (required)
The directory name for the cloned repository. Must be unique.

**Examples:**
- `"my-project"`
- `"linux-kernel"`
- `"config-files"`

#### `clone_args` (required)
Array of additional arguments to pass to `git clone`. Use an empty array `[]` for default behavior.

**Common examples:**
- `["--depth", "1"]` - Shallow clone (faster, saves space)
- `["--single-branch"]` - Clone only the default branch
- `["--depth", "1", "--single-branch"]` - Shallow clone of single branch
- `["--mirror"]` - Mirror clone (all refs)
- `[]` - Full clone (default)

#### `enabled` (required)
Boolean flag to control if the repository should be processed.

- `true`: Process this repository
- `false`: Skip this repository

## Example Configurations

### Minimal Configuration

```json
{
  "repositories": [
    {
      "url": "https://github.com/torvalds/linux.git",
      "name": "linux",
      "clone_args": [],
      "enabled": true
    }
  ]
}
```

### Production Configuration

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
      "clone_args": ["--depth", "1"],
      "enabled": false
    }
  ]
}
```

## Operations

### Clone Operation

Clones repositories that don't already exist in the destination directory.

- Checks if repository directory exists
- Skips if `.git` directory is present
- Creates destination directory if needed
- Logs all operations to `gitlog.txt`

```bash
python3 scripts/download_git_repos.py --operation clone
```

### Update Operation

Updates (pulls) repositories that already exist in the destination directory.

- Only processes repositories with existing `.git` directories
- Runs `git pull` in each repository
- Skips repositories not yet cloned
- Logs all operations to `gitlog.txt`

```bash
python3 scripts/download_git_repos.py --operation update
```

### Both Operations (Default)

Runs clone followed by update.

```bash
python3 scripts/download_git_repos.py --operation both
# or simply
python3 scripts/download_git_repos.py
```

## Error Handling

### Parallel Processing

Operations run in parallel using a thread pool. By default, 4 repositories are processed simultaneously. This can be adjusted:

```bash
python3 scripts/download_git_repos.py --max-workers 8
```

### Error Isolation

Failed operations don't affect other repositories:
- Clone failures are logged but don't stop other clones
- Update failures are logged but don't stop other updates
- All errors include full error messages in `gitlog.txt`

### Log File Format

The `gitlog.txt` file contains timestamped entries:

```
[2025-10-12 18:55:44] ============================================================
[2025-10-12 18:55:44] Starting clone operation
[2025-10-12 18:55:44] ============================================================
[2025-10-12 18:55:44] SUCCESS: Cloned https://github.com/user/repo.git to repo
[2025-10-12 18:55:45] ERROR: Failed to clone https://github.com/user/bad.git - repository not found
[2025-10-12 18:55:45] ============================================================
[2025-10-12 18:55:45] Operation completed: 1 successful, 1 failed
[2025-10-12 18:55:45] ============================================================
```

## Best Practices

### Repository Selection

1. **Use shallow clones** for large repositories:
   ```json
   "clone_args": ["--depth", "1"]
   ```

2. **Disable unused repositories** instead of removing them:
   ```json
   "enabled": false
   ```

3. **Use descriptive names** that don't conflict:
   ```json
   "name": "linux-kernel"  // Not just "linux"
   ```

### Performance Optimization

1. **Adjust worker count** based on network and CPU:
   - Fast network: `--max-workers 8`
   - Slow network: `--max-workers 2`
   - Many small repos: `--max-workers 8`
   - Few large repos: `--max-workers 2`

2. **Use shallow clones** to save bandwidth and time:
   ```json
   "clone_args": ["--depth", "1", "--single-branch"]
   ```

3. **Schedule regular updates** via cron or systemd timers:
   ```bash
   # Daily at 2 AM
   0 2 * * * cd /path/to/EmergencyStorage && python3 scripts/download_git_repos.py --operation update
   ```

### Troubleshooting

1. **Check the log file** for detailed error messages:
   ```bash
   tail -f git_repos/gitlog.txt
   ```

2. **Test with dry run** before executing:
   ```bash
   python3 scripts/download_git_repos.py --dry-run
   ```

3. **Verify repository URLs** are accessible:
   ```bash
   git ls-remote https://github.com/user/repo.git
   ```

4. **Check disk space** before cloning large repositories:
   ```bash
   df -h
   ```

## Command Reference

### Full Command Syntax

```bash
python3 scripts/download_git_repos.py \
  [--config CONFIG] \
  [--dest DEST] \
  [--log LOG] \
  [--operation {clone,update,both}] \
  [--max-workers MAX_WORKERS] \
  [--dry-run]
```

### Options

| Option | Default | Description |
|--------|---------|-------------|
| `--config` | `data/git_repositories.json` | Path to configuration file |
| `--dest` | `git_repos/` | Destination directory for repositories |
| `--log` | `{dest}/gitlog.txt` | Path to log file |
| `--operation` | `both` | Operation: clone, update, or both |
| `--max-workers` | `4` | Maximum parallel workers |
| `--dry-run` | `false` | Show what would be done without executing |
| `--help` | - | Show help message |

## Integration with EmergencyStorage

The Git Repositories Manager integrates with the main EmergencyStorage system:

```bash
# Via main script
./emergency_storage.sh --git-repos /mnt/external_drive

# Standalone
python3 scripts/download_git_repos.py --dest /mnt/external_drive/git_repos
```

## Testing

Run the test suite:

```bash
bash tests/test_git_repos.sh
```

The test suite validates:
- Configuration file structure
- Required fields
- Python script syntax
- Command-line interface
- Dry run functionality
- Operation parameters
- Parallel processing capability

## See Also

- [Main README](../README.md)
- [Manual Sources Documentation](MANUAL_SOURCES.md)
- [Error Handling Guide](ERROR_HANDLING.md)
