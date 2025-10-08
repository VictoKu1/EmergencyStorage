# Dynamic Mirror Management System

EmergencyStorage features an automated system that keeps mirror lists up-to-date, ensuring reliable downloads through dynamic mirror discovery.

## Overview

The mirror management system automatically:
- Scrapes official mirror pages for current mirror lists
- Updates mirror lists every 24 hours via GitHub Actions
- Stores mirrors in JSON format for easy inspection
- Provides automatic fallback to alternative mirrors

## How It Works

### Automatic Updates

**Schedule**: Mirror lists are updated every 24 hours automatically

**Process**:
1. GitHub Actions workflow triggers (`update-mirrors.yml`)
2. Python script scrapes official mirror pages
3. Extracts available mirrors by protocol (rsync, ftp, https)
4. Updates JSON files in `data/mirrors/`
5. Commits changes back to the repository

**Result**: Scripts always use current, working mirrors

### JSON Storage

Mirrors are stored in `data/mirrors/[source].json` with this structure:

```json
{
  "source": "source-name",
  "last_updated": "2024-01-01T00:00:00Z",
  "mirrors": {
    "rsync": ["mirror1", "mirror2"],
    "ftp": ["ftp://mirror1", "ftp://mirror2"],
    "https": ["https://mirror1", "https://mirror2"]
  }
}
```

**Benefits**:
- Human-readable format
- Easy manual editing if needed
- Version controlled for change tracking
- Supports multiple protocols

### Dynamic Loading

Scripts load mirrors directly from JSON files at runtime:

**Process**:
1. Script reads `data/mirrors/[source].json`
2. Parses mirror list by protocol
3. Attempts connection to each mirror in order
4. Uses first successful mirror
5. Falls back to next mirror if connection fails

**Benefits**:
- Always uses latest mirror list
- No need to update scripts when mirrors change
- Automatic handling of dead mirrors
- Protocol-based fallback (rsync → ftp → https)

### Extensible Design

The system is designed to support multiple data sources:

**Current Support**:
- Kiwix mirrors (fully implemented)

**Future Support**:
- OpenZIM mirrors
- Additional data sources
- Custom mirror sources

## Manual Mirror Updates

### Update All Mirrors

```bash
python3 scripts/update_mirrors.py
```

This scrapes official mirror pages and updates all JSON files.

### Verify Mirror Files

Check the current mirror list:

```bash
cat data/mirrors/kiwix.json
```

### Manual Editing

You can manually edit mirror JSON files if needed:

1. Open `data/mirrors/[source].json`
2. Add or remove mirrors from the appropriate protocol array
3. Update `last_updated` timestamp
4. Save the file

**Example - Adding a Mirror**:
```json
{
  "source": "kiwix",
  "last_updated": "2024-01-15T12:00:00Z",
  "mirrors": {
    "rsync": [
      "master.download.kiwix.org::download.kiwix.org",
      "mirror.example.org::kiwix"  # Added mirror
    ],
    "ftp": ["ftp://ftpmirror.kiwix.org/"],
    "https": ["https://download.kiwix.org/"]
  }
}
```

## Mirror Fallback System

### How Fallback Works

1. **Primary Attempt**: Try first mirror in list (usually rsync)
2. **Secondary Attempts**: Try remaining rsync mirrors
3. **Protocol Fallback**: Try ftp mirrors if rsync fails
4. **Final Fallback**: Try https mirrors if ftp fails
5. **Error Reporting**: Clear error if all mirrors fail

### Protocol Preferences

**rsync** (Preferred):
- Most efficient for large datasets
- Supports resume and incremental sync
- Bandwidth efficient

**ftp** (Fallback):
- Widely supported
- Good for file downloads
- Less efficient than rsync

**https** (Last Resort):
- Universal availability
- Works through most firewalls
- Slowest for large syncs

## Adding Mirror Support for New Sources

### Step 1: Update Mirror Scraper

Edit `scripts/update_mirrors.py`:

```python
# Add your source
SOURCES = {
    'kiwix': 'https://wiki.kiwix.org/wiki/Content_in_all_languages',
    'your-source': 'https://your-source.org/mirrors'
}

# Add scraping function
def scrape_your_source_mirrors(url):
    # Implement scraping logic
    return {
        'rsync': [...],
        'ftp': [...],
        'https': [...]
    }
```

### Step 2: Create JSON File

The script will automatically create `data/mirrors/your-source.json` on first run.

### Step 3: Load in Your Script

In your resource script:

```bash
# Load mirrors from JSON
MIRROR_FILE="$SCRIPT_DIR/../data/mirrors/your-source.json"
if [ -f "$MIRROR_FILE" ]; then
    # Parse JSON and load mirrors
    # Implement fallback logic
fi
```

### Step 4: Update Workflow (Optional)

If needed, update `.github/workflows/update-mirrors.yml` to adjust schedule or add specific requirements.

## Troubleshooting

### JSON File Missing

**Problem**: Script can't find `data/mirrors/[source].json`

**Solution**: Run manual update:
```bash
python3 scripts/update_mirrors.py
```

### All Mirrors Failing

**Problem**: None of the mirrors are responding

**Possible Causes**:
- Network connectivity issues
- Mirrors are down (check official website)
- Firewall blocking rsync/ftp protocols
- Mirror list needs updating

**Solutions**:
1. Check internet connectivity
2. Try manual mirror update
3. Check mirror availability on official website
4. Try different protocol (edit JSON to prioritize https)

### Outdated Mirror List

**Problem**: Mirror list hasn't been updated recently

**Solution**: 
- Check GitHub Actions workflow status
- Run manual update
- Verify update script permissions

## For More Information

See `data/mirrors/README.md` for technical details about the mirror system structure and JSON format.
