# Data Directory

This directory contains configuration files for EmergencyStorage.

## Configuration Files

### manual_sources.json

Manually configured download sources where keys are download methods (wget, curl, rsync, git, etc.).

**Important:** This is for user-specified URLs that are NOT covered by existing resource scripts (Kiwix, OpenZIM, OpenStreetMap, Internet Archive). For those resources, use their dedicated scripts in the `scripts/` directory.

### auto_update_config.json

Configuration for the automatic resource update system. This file controls:
- Which resources to update automatically
- Update frequencies (daily, weekly, monthly)
- Destination paths
- Retry logic and logging

See [AUTO_UPDATE_CONFIG_README.md](AUTO_UPDATE_CONFIG_README.md) for examples and [docs/AUTO_UPDATE.md](../docs/AUTO_UPDATE.md) for full documentation.

## Manual Sources Configuration

### Structure

```json
{
  "method": {
    "url": "flags and URL as string",
    "updateFile": true|false,
    "downloaded": true|false,
    "alternative": ["alternative1", "alternative2"]
  }
}
```

## Fields

- **method**: The download tool/command (wget, curl, rsync, git, transmission-cli, etc.)
- **url**: Complete command arguments as string (flags + URL combined)
- **updateFile**: 
  - `true` = Download every time script runs
  - `false` = Download only once (skip if already downloaded)
- **downloaded**: Automatically managed flag indicating if file was successfully downloaded
- **alternative**: Array of alternative URLs or flag combinations for fallback

## Alternative Fallback

When the main URL fails, the script tries alternatives in order. If an alternative succeeds:
1. The working alternative becomes the new main URL
2. The failed main URL is moved to the end of alternatives
3. Config file is automatically updated

Example:
```json
{
  "wget": {
    "url": "-c https://example.com/file.zip",
    "updateFile": false,
    "downloaded": false,
    "alternative": [
      "https://example.com/file.zip",
      "--timeout=30 -c https://example.com/file.zip"
    ]
  }
}
```

## Usage

Download sources using:
```bash
python3 scripts/download_manual_sources.py
```

For more details, see [docs/MANUAL_SOURCES.md](../docs/MANUAL_SOURCES.md)
