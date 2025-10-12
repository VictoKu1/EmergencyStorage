# Manual Sources Quick Reference

**Purpose:** For user-specified URLs NOT covered by existing scripts (Kiwix, OpenZIM, OpenStreetMap, Internet Archive).

**Structure:** Flat JSON where keys are download methods (wget, curl, rsync, git, etc.)

## File Structure

```
data/manual_sources.json    - Configuration file
scripts/download_manual_sources.py    - Download script
docs/MANUAL_SOURCES.md      - Full documentation
tests/test_manual_sources.sh - Test suite
```

## Quick Commands

```bash
# Dry run (see what would be executed)
python3 scripts/download_manual_sources.py --dry-run

# Download all configured sources
python3 scripts/download_manual_sources.py

# Custom config
python3 scripts/download_manual_sources.py --config path/to/config.json

# Help
python3 scripts/download_manual_sources.py --help
```

## JSON Structure Template

```json
{
  "method_name": {
    "url": "flags and URL as string",
    "updateFile": true|false,
    "downloaded": false,
    "alternative": ["alternative1", "alternative2"]
  }
}
```

## Key Concepts

### Method Key
Top-level key is the download tool: `wget`, `curl`, `rsync`, `git`, `transmission-cli`, etc.

### URL Field
Contains complete command arguments (flags + URL) as a single string.

Examples:
- `"-c https://example.com/file.zip"` (wget with resume)
- `"-L -O https://example.com/file.tar.gz"` (curl with redirects)
- `"clone https://github.com/user/repo.git"` (git clone)

### updateFile Flag
- `true`: Always download (even if already downloaded)
- `false`: Download once, skip if already downloaded

### downloaded Flag
- Automatically managed by the script
- Set to `true` after successful download
- Initially set to `false`

### alternative Field
Array of alternative URLs or flag combinations to try if main URL fails.

**Smart Fallback:**
- If main URL fails, tries alternatives in order
- If alternative succeeds, it becomes the new main URL
- Failed main URL moved to end of alternatives
- Config file automatically updated

## Example Configurations

### wget with Resume
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

### curl for APIs (Always Update)
```json
{
  "curl": {
    "url": "-L -O https://api.example.com/data.json",
    "updateFile": true,
    "downloaded": false,
    "alternative": ["-O https://api.example.com/data.json"]
  }
}
```

### git Clone (One-Time)
```json
{
  "git": {
    "url": "clone --depth 1 https://github.com/user/repo.git",
    "updateFile": false,
    "downloaded": false,
    "alternative": ["clone https://github.com/user/repo.git"]
  }
}
```

### rsync Backup (Always Update)
```json
{
  "rsync": {
    "url": "-avz user@host:/data/ /backup/",
    "updateFile": true,
    "downloaded": false,
    "alternative": ["-az user@host:/data/ /backup/"]
  }
}
```

## Testing

```bash
# Run all tests
bash tests/test_manual_sources.sh

# Validate JSON only
python3 -c "import json; json.load(open('data/manual_sources.json'))"
```

## Troubleshooting

| Issue | Solution |
|-------|----------|
| JSON parse error | Validate JSON syntax, check quotes and brackets |
| Command not found | Install the required tool (wget, curl, rsync, etc.) |
| Downloads fail | Check URL validity, internet connection, error messages |
| Alternative not working | Ensure alternatives are properly formatted strings |

## See Also

- [Full Documentation](MANUAL_SOURCES.md)
- [Mirror System](MIRROR_SYSTEM.md)
- [Main README](../README.md)
