# Manual Sources Download System

The Manual Sources Download System allows you to configure and download files from specific URLs organized in a hierarchical structure. This is **separate from existing resource scripts** (Kiwix, OpenZIM, OpenStreetMap, Internet Archive) and is designed for **user-specified URLs** that are not covered by the automated download scripts.

## Overview

The system provides:
- Hierarchical organization of download sources by operator and flags
- Configurable update behavior (download every time vs. download once)
- Automatic tracking of downloaded files
- Tree structure normalization for consistent depth
- Support for custom URLs using wget, curl, rsync, transmission-cli, git, or other download tools

## When to Use This System

**Use manual sources for:**
- Custom datasets or files from non-standard sources
- Personal backups or configurations
- Research data or private repositories
- Any URL-based resource not covered by existing scripts

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
  "description": "Manual download sources with recursive flag structure",
  "sources": {
    "operator1": {
      "flag1": {
        "flag2": {
          "url": "https://example.com/file1",
          "updateFile": true,
          "downloaded": false
        }
      },
      "flag3": {
        " ": {
          "url": "https://example.com/file2",
          "updateFile": false,
          "downloaded": false
        }
      }
    }
  }
}
```

### Structure Elements

#### Operators
The top-level keys under `sources` represent different operators or providers (e.g., "kiwix", "archive").

#### Flags
Flags create a hierarchical structure beneath each operator. They can be nested to any depth, representing different categorizations or options.

#### Space Keys (" ")
When different sources under the same operator have different depths of flags, use `" "` (space) as a placeholder key. This ensures all URLs end up at the same level in the tree structure.

**Example:**
```json
{
  "sources": {
    "kiwix": {
      "wikipedia": {
        "en": {
          "all": {
            "url": "...",
            "updateFile": true,
            "downloaded": false
          }
        }
      },
      "wiktionary": {
        "en": {
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

In this example, `wiktionary` has fewer flag levels than `wikipedia`, so a space key is used to maintain consistent tree depth.

#### Source Properties

Each source (leaf node) must have three properties:

- **url** (string): The URL to download the file from
- **updateFile** (boolean): 
  - `true`: Download this file every time the script runs
  - `false`: Only download if not already downloaded
- **downloaded** (boolean): 
  - Automatically managed by the script
  - Set to `true` when download completes successfully
  - Set to `false` initially

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
  ├─→ updateFile = true → Download file → Update downloaded = true
  │
  └─→ updateFile = false
        ↓
      Check downloaded flag
        ↓
        ├─→ downloaded = false → Download file → Update downloaded = true
        │
        └─→ downloaded = true → Skip (already downloaded)
```

### Example Scenario

**First Run:**
```json
{
  "url": "https://example.com/file.zip",
  "updateFile": false,
  "downloaded": false
}
```
→ Downloads file, sets `downloaded = true`

**Second Run:**
```json
{
  "url": "https://example.com/file.zip",
  "updateFile": false,
  "downloaded": true
}
```
→ Skips (already downloaded)

**With updateFile = true:**
```json
{
  "url": "https://example.com/news.json",
  "updateFile": true,
  "downloaded": true
}
```
→ Always downloads regardless of `downloaded` flag

## File Organization

Downloaded files are organized in directories matching their hierarchical structure:

```
downloads/manual/
├── operator1/
│   ├── flag1/
│   │   └── flag2/
│   │       └── downloaded_file
│   └── flag3/
│       └── another_file
└── operator2/
    └── flag1/
        └── yet_another_file
```

Space keys (" ") are filtered out from the directory structure.

## Adding New Sources

To add a new download source:

1. Edit `data/manual_sources.json`
2. Add your source following the hierarchical structure
3. Ensure all sources at the same depth have the same number of flag levels (use " " keys if needed)
4. Set appropriate `updateFile` flag
5. Set `downloaded` to `false` initially
6. Run the download script

**Example:**

```json
{
  "sources": {
    "new-operator": {
      "category": {
        "subcategory": {
          "url": "https://example.com/file.zip",
          "updateFile": false,
          "downloaded": false
        }
      }
    }
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
- Tree depth consistency

## Examples

### Example 1: Always Update

```json
{
  "sources": {
    "news": {
      "daily": {
        "feed": {
          "url": "https://example.com/news.json",
          "updateFile": true,
          "downloaded": false
        }
      }
    }
  }
}
```

This will download the news feed every time the script runs.

### Example 2: Download Once

```json
{
  "sources": {
    "datasets": {
      "large": {
        "archive": {
          "url": "https://example.com/dataset.tar.gz",
          "updateFile": false,
          "downloaded": false
        }
      }
    }
  }
}
```

This will download the dataset only once. After successful download, `downloaded` becomes `true` and subsequent runs will skip it.

### Example 3: Mixed Depths

```json
{
  "sources": {
    "content": {
      "type1": {
        "lang": {
          "format": {
            "url": "https://example.com/file1.zip",
            "updateFile": false,
            "downloaded": false
          }
        }
      },
      "type2": {
        "lang": {
          " ": {
            "url": "https://example.com/file2.zip",
            "updateFile": false,
            "downloaded": false
          }
        }
      },
      "type3": {
        " ": {
          " ": {
            "url": "https://example.com/file3.zip",
            "updateFile": false,
            "downloaded": false
          }
        }
      }
    }
  }
}
```

This shows how to use space keys to normalize tree depth when different sources have different numbers of categorization levels.

## Differences from Mirror System

| Feature | Manual Sources | Mirror System |
|---------|---------------|---------------|
| Configuration | Static, manually curated | Dynamic, auto-updated |
| Updates | Manual edits | Automated scraping |
| Structure | Hierarchical with flags | Flat protocol lists |
| Download Control | Per-file updateFile flag | N/A |
| Tracking | Downloaded flag per source | N/A |

## Best Practices

1. **Organize Logically**: Use meaningful operator and flag names
2. **Consistent Depth**: Use space keys to maintain uniform tree depth within each operator
3. **Update Flags**: Set `updateFile=true` for frequently changing content, `false` for static archives
4. **Documentation**: Add descriptions to help understand the source organization
5. **Testing**: Always run with `--dry-run` first to verify configuration

## Troubleshooting

### Issue: Downloads fail

**Solution**: Check URL validity and internet connection. Review error messages for specific issues.

### Issue: File downloads every time despite updateFile=false

**Solution**: Check if `downloaded` flag is being persisted. Ensure write permissions on the configuration file.

### Issue: Inconsistent tree depth

**Solution**: Add space keys (" ") to sources with fewer flags to normalize depth.

### Issue: Script fails to parse JSON

**Solution**: Validate JSON syntax using a JSON validator. Ensure all quotes and brackets are properly closed.

## Related Documentation

- [Mirror System Documentation](MIRROR_SYSTEM.md) - For dynamic mirror management
- [New Resource Guide](../NEW_RESOURCE_README.md) - For adding new data sources
