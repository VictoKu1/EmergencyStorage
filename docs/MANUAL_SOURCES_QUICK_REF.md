# Manual Sources Quick Reference

**Purpose:** For user-specified URLs NOT covered by existing scripts (Kiwix, OpenZIM, OpenStreetMap, Internet Archive).

## File Structure

```
data/manual_sources.json    - Configuration file
scripts/download_manual_sources.py    - Download script
docs/MANUAL_SOURCES.md      - Full documentation
tests/test_manual_sources.sh - Test suite
```

## Quick Commands

```bash
# Dry run (see what would be downloaded)
python3 scripts/download_manual_sources.py --dry-run

# Download all configured sources
python3 scripts/download_manual_sources.py

# Custom config and output
python3 scripts/download_manual_sources.py --config path/to/config.json --output /path/to/downloads

# Help
python3 scripts/download_manual_sources.py --help
```

## JSON Structure Template

```json
{
  "description": "Your description here",
  "sources": {
    "operator_name": {
      "flag1": {
        "flag2": {
          "url": "https://example.com/file.zip",
          "updateFile": true,
          "downloaded": false
        }
      }
    }
  }
}
```

## Key Concepts

### updateFile Flag
- `true`: Always download (even if already downloaded)
- `false`: Download once, skip if already downloaded

### downloaded Flag
- Automatically managed by the script
- Set to `true` after successful download
- Initially set to `false`

### Space Keys (" ")
Used to normalize tree depth when operators have different flag levels:

```json
{
  "operator": {
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
```

## Example Configurations

### Always Update (News/Feeds)
```json
{
  "sources": {
    "news": {
      "daily": {
        "url": "https://example.com/news.json",
        "updateFile": true,
        "downloaded": false
      }
    }
  }
}
```

### One-Time Download (Archives)
```json
{
  "sources": {
    "archive": {
      "dataset": {
        "url": "https://example.com/data.tar.gz",
        "updateFile": false,
        "downloaded": false
      }
    }
  }
}
```

### Mixed Depths
```json
{
  "sources": {
    "provider": {
      "type1": {
        "lang": {
          "format": {
            "url": "...",
            "updateFile": false,
            "downloaded": false
          }
        }
      },
      "type2": {
        "lang": {
          " ": {
            "url": "...",
            "updateFile": false,
            "downloaded": false
          }
        }
      }
    }
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
| JSON parse error | Validate JSON syntax with online validator |
| Downloads fail | Check URL validity and internet connection |
| File not updated despite updateFile=true | Check file permissions on config file |
| Tree depth inconsistent | Add space keys (" ") to normalize depth |

## See Also

- [Full Documentation](MANUAL_SOURCES.md)
- [Mirror System](MIRROR_SYSTEM.md)
- [Main README](../README.md)
