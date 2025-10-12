# Manual Sources Configuration

This file contains manually configured download sources organized in a hierarchical structure.

**Important:** This is for user-specified URLs that are NOT covered by existing resource scripts (Kiwix, OpenZIM, OpenStreetMap, Internet Archive). For those resources, use their dedicated scripts in the `scripts/` directory.

## Structure

```json
{
  "description": "Manual download sources with recursive flag structure",
  "sources": {
    "operator": {
      "flag1": {
        "flag2": {
          "url": "https://example.com/file",
          "updateFile": true|false,
          "downloaded": true|false
        }
      }
    }
  }
}
```

## Fields

- **operator**: Top-level key representing the data provider or source type
- **flags**: Hierarchical keys for categorization (can be nested)
- **url**: Direct download URL for the file
- **updateFile**: 
  - `true` = Download every time script runs
  - `false` = Download only once (skip if already downloaded)
- **downloaded**: Automatically managed flag indicating if file was successfully downloaded

## Space Keys

When operators have sources at different flag depths, use `" "` (space) as a placeholder key to normalize tree structure. This ensures all URLs are at the same depth level.

Example:
```json
{
  "sources": {
    "provider": {
      "category1": {
        "subcategory": {
          "url": "...",
          "updateFile": false,
          "downloaded": false
        }
      },
      "category2": {
        " ": {
          "url": "...",
          "updateFile": false,
          "downloaded": false
        }
      }
    }
  }
}
```

## Usage

Download sources using:
```bash
python3 scripts/download_manual_sources.py
```

For more details, see [docs/MANUAL_SOURCES.md](../docs/MANUAL_SOURCES.md)
