# Manual Sources Download System

The Manual Sources Download System allows you to configure and download files using various download tools (wget, curl, rsync, git, transmission-cli, etc.). This is **separate from existing resource scripts** (Kiwix, OpenZIM, OpenStreetMap, Internet Archive) and is designed for **user-specified URLs** that are not covered by the automated download scripts.

## Overview

The system provides:
- Simple flat structure where keys are download methods (wget, curl, rsync, git, etc.)
- URL field contains both flags and URL in one string
- Alternative URLs/flags for automatic fallback
- Smart fallback: if main URL fails, tries alternatives and swaps the working one to main
- Configurable update behavior (download every time vs. download once)
- Automatic tracking of downloaded files

## When to Use This System

**Use manual sources for:**
- Custom datasets or files from non-standard sources
- Personal backups or configurations
- Research data or private repositories
- Any URL-based resource downloaded via wget, curl, rsync, transmission-cli, git, or other tools

**Do NOT use manual sources for:**
- Kiwix content (use `scripts/kiwix.sh`)
- OpenZIM files (use `scripts/openzim.sh`)
- OpenStreetMap data (use `scripts/openstreetmap.sh`)
- Internet Archive resources (use `scripts/ia-*.sh`)

These resources are already handled by dedicated scripts with optimized download logic.

## Configuration File

Manual sources are configured in `data/manual_sources.json` with the following structure:

```json
{
  "wget": {
    "url": "-c https://example.com/file.zip",
    "updateFile": false,
    "downloaded": false,
    "alternative": ["https://example.com/file.zip", "-O /tmp/file.zip https://example.com/file.zip"]
  },
  "curl": {
    "url": "-L -O https://example.com/file.tar.gz",
    "updateFile": true,
    "downloaded": false,
    "alternative": ["https://example.com/file.tar.gz", "-C - https://example.com/file.tar.gz"]
  }
}
```

### Structure Elements

#### Download Method Key
The top-level key is the download tool/method: `wget`, `curl`, `rsync`, `git`, `transmission-cli`, etc.

#### URL Field
Contains the complete command arguments (flags + URL) as a string.

**Examples:**
- `"-c https://example.com/file.zip"` - wget with resume capability
- `"-L -O https://example.com/file.tar.gz"` - curl with follow redirects
- `"clone https://github.com/user/repo.git"` - git clone command
- `"-avz user@host:/path/file.zip /local/path"` - rsync with flags

The script will automatically parse this to build: `{method} {url_field}`

#### updateFile Flag
- **true**: Download this file every time the script runs (useful for frequently updated content)
- **false**: Only download if not already downloaded (useful for static archives)

#### downloaded Flag
- Automatically managed by the script
- Set to **true** when download completes successfully
- Set to **false** initially
- Used with `updateFile` to determine if download should occur

#### alternative Field
An array of alternative URLs or flag combinations to try if the main URL fails.

**Examples:**
```json
"alternative": [
  "https://example.com/file.zip",
  "-O /tmp/file.zip https://example.com/file.zip",
  "https://mirror.example.com/file.zip"
]
```

**Smart Fallback Behavior:**
When the main URL fails:
1. Script tries each alternative in order
2. If an alternative succeeds, it becomes the new main URL
3. The failed main URL is moved to the end of alternatives
4. Configuration file is automatically updated

## Usage

### Download Files

```bash
# Download all configured sources
python3 scripts/download_manual_sources.py

# Dry run (show what would be downloaded without downloading)
python3 scripts/download_manual_sources.py --dry-run

# Specify custom configuration file
python3 scripts/download_manual_sources.py --config path/to/config.json

# Specify custom output directory
python3 scripts/download_manual_sources.py --output /path/to/downloads
```

### Command Line Options

- `--config PATH`: Path to manual sources JSON configuration file (default: `data/manual_sources.json`)
- `--output PATH`: Output directory for downloads (default: `downloads/manual`)
- `--dry-run`: Show what would be downloaded without actually downloading
- `--help`: Show help message

## Download Behavior

The script determines whether to download a file based on:

1. **updateFile = true**: Always download, even if already downloaded
2. **updateFile = false, downloaded = false**: Download once (first time)
3. **updateFile = false, downloaded = true**: Skip (already downloaded)

After successful download, the script automatically updates the `downloaded` flag to `true` in the configuration file.

### Behavior Flow Chart

```
Start
  ↓
Check updateFile flag
  ↓
  ├─→ updateFile = true → Execute command → Update downloaded = true
  │
  └─→ updateFile = false
        ↓
      Check downloaded flag
        ↓
        ├─→ downloaded = false → Execute command → Update downloaded = true
        │
        └─→ downloaded = true → Skip (already downloaded)
        
If command fails:
  ↓
Try alternatives in order
  ↓
  ├─→ Alternative succeeds → Swap to main URL → Save config
  │
  └─→ All fail → Report failure
```

### Example Scenario

**First Run:**
```json
{
  "wget": {
    "url": "-c https://example.com/file.zip",
    "updateFile": false,
    "downloaded": false,
    "alternative": ["https://example.com/file.zip"]
  }
}
```
→ Downloads file, sets `downloaded = true`

**Second Run:**
```json
{
  "wget": {
    "url": "-c https://example.com/file.zip",
    "updateFile": false,
    "downloaded": true,
    "alternative": ["https://example.com/file.zip"]
  }
}
```
→ Skips (already downloaded)

**With updateFile = true:**
```json
{
  "curl": {
    "url": "-L https://example.com/news.json",
    "updateFile": true,
    "downloaded": true,
    "alternative": []
  }
}
```
→ Always downloads regardless of `downloaded` flag

**Fallback Example:**
Main URL fails, alternative succeeds:
```json
// Before:
{
  "wget": {
    "url": "-c https://example.com/file.zip",
    "alternative": ["https://mirror.example.com/file.zip"]
  }
}

// After automatic update:
{
  "wget": {
    "url": "-c https://mirror.example.com/file.zip",
    "alternative": ["-c https://example.com/file.zip"]
  }
}
```

## Command Execution

The script builds commands by concatenating the method with the URL field:

- `wget` + `"-c https://example.com/file.zip"` → `wget -c https://example.com/file.zip`
- `curl` + `"-L -O https://example.com/file.tar.gz"` → `curl -L -O https://example.com/file.tar.gz`
- `git` + `"clone https://github.com/user/repo.git"` → `git clone https://github.com/user/repo.git`
- `rsync` + `"-avz user@host:/path /dest"` → `rsync -avz user@host:/path /dest`

## Adding New Sources

To add a new download source:

1. Edit `data/manual_sources.json`
2. Add a new entry with the download method as the key
3. Specify the URL field with any flags needed
4. Add alternative URLs/flags if available
5. Set `updateFile` to `false` for one-time downloads or `true` for repeated updates
6. Set `downloaded` to `false` initially
7. Run the download script

**Example - Adding a wget download:**

```json
{
  "wget": {
    "url": "-c --no-check-certificate https://example.com/dataset.tar.gz",
    "updateFile": false,
    "downloaded": false,
    "alternative": [
      "https://example.com/dataset.tar.gz",
      "--timeout=30 https://example.com/dataset.tar.gz"
    ]
  }
}
```

**Example - Adding a git clone:**

```json
{
  "git": {
    "url": "clone --depth 1 https://github.com/user/repo.git",
    "updateFile": true,
    "downloaded": false,
    "alternative": [
      "clone https://github.com/user/repo.git",
      "clone --mirror https://github.com/user/repo.git"
    ]
  }
}
```

**Example - Adding a curl download:**

```json
{
  "curl": {
    "url": "-L -O --retry 3 https://example.com/file.zip",
    "updateFile": false,
    "downloaded": false,
    "alternative": [
      "-O https://example.com/file.zip",
      "-C - -O https://example.com/file.zip"
    ]
  }
}
```

## Testing

Run tests to verify the system:

```bash
bash tests/test_manual_sources.sh
```

This validates:
- JSON file structure
- Required fields presence
- Script functionality
- Command building

## Examples

### Example 1: wget with resume capability

```json
{
  "wget": {
    "url": "-c --no-check-certificate https://example.com/large-file.iso",
    "updateFile": false,
    "downloaded": false,
    "alternative": [
      "https://example.com/large-file.iso",
      "--timeout=30 -c https://example.com/large-file.iso"
    ]
  }
}
```

This will download once with resume capability. If the main command fails, it tries alternatives.

### Example 2: curl for API updates

```json
{
  "curl": {
    "url": "-L -O https://api.example.com/data/latest.json",
    "updateFile": true,
    "downloaded": false,
    "alternative": [
      "-O https://api.example.com/data/latest.json",
      "--retry 5 -L -O https://api.example.com/data/latest.json"
    ]
  }
}
```

This downloads every time the script runs (useful for frequently updated APIs).

### Example 3: git repository clone

```json
{
  "git": {
    "url": "clone --depth 1 https://github.com/user/config-repo.git",
    "updateFile": false,
    "downloaded": false,
    "alternative": [
      "clone https://github.com/user/config-repo.git",
      "clone --single-branch https://github.com/user/config-repo.git"
    ]
  }
}
```

Clones a repository once with shallow clone for efficiency.

### Example 4: rsync for backups

```json
{
  "rsync": {
    "url": "-avz --delete user@backup-server:/data/ /local/backup/",
    "updateFile": true,
    "downloaded": false,
    "alternative": [
      "-az user@backup-server:/data/ /local/backup/",
      "-avz user@backup-server:/data/ /local/backup/"
    ]
  }
}
```

Syncs backup every time with deletion of removed files.

### Example 5: transmission-cli for torrents

```json
{
  "transmission-cli": {
    "url": "-w /downloads magnet:?xt=urn:btih:example",
    "updateFile": false,
    "downloaded": false,
    "alternative": [
      "magnet:?xt=urn:btih:example"
    ]
  }
}
```

Downloads a torrent once.

## Differences from Mirror System

| Feature | Manual Sources | Mirror System |
|---------|---------------|---------------|
| Configuration | Static, manually curated | Dynamic, auto-updated |
| Updates | Manual edits | Automated scraping |
| Structure | Flat with methods as keys | Hierarchical by protocol |
| Download Control | Per-source updateFile flag + alternatives | N/A |
| Tracking | Downloaded flag per source | N/A |
| Fallback | Smart alternative swapping | Mirror rotation |

## Best Practices

1. **Use Appropriate Methods**: Choose the right tool (wget for HTTP, rsync for syncing, git for repos)
2. **Add Alternatives**: Provide fallback URLs or flag combinations
3. **Update Flags**: Set `updateFile=true` for frequently changing content, `false` for static archives
4. **Test First**: Always run with `--dry-run` first to verify commands
5. **Flag Safety**: Ensure flags are compatible with the download method

## Troubleshooting

### Issue: Downloads fail

**Solution**: Check URL validity, internet connection, and that the download method is installed. Review error messages for specific issues.

### Issue: Command not found

**Solution**: Install the required download tool (e.g., `apt install wget curl rsync git transmission-cli`)

### Issue: File downloads every time despite updateFile=false

**Solution**: Check if `downloaded` flag is being persisted. Ensure write permissions on the configuration file.

### Issue: Alternative fallback not working

**Solution**: Ensure alternatives are properly formatted strings. Check that alternatives contain valid commands.

### Issue: Script fails to parse JSON

**Solution**: Validate JSON syntax using a JSON validator. Ensure all quotes and brackets are properly closed. Make sure the `alternative` field is an array.

## Related Documentation

- [Mirror System Documentation](MIRROR_SYSTEM.md) - For dynamic mirror management
- [New Resource Guide](../NEW_RESOURCE_README.md) - For adding new data sources
