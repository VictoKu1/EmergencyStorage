# Mirror Configuration

This directory contains JSON files with dynamically updated mirror lists for various data sources.

## Structure

Each source has its own JSON file (e.g., `kiwix.json`) with the following structure:

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

## Automated Updates

Mirror lists are automatically updated every 24 hours via GitHub Actions workflow (`.github/workflows/update-mirrors.yml`).

The update process:
1. Scrapes the official mirrors page for the source
2. Extracts available mirrors by protocol (rsync, ftp, https)
3. Updates the JSON file with new mirrors
4. Commits changes back to the repository

## Manual Updates

To manually update mirrors for a source:

```bash
# Update Kiwix mirrors
python3 scripts/update_mirrors.py
```

## Adding New Sources

To add mirror automation for a new source:

1. Update `scripts/update_mirrors.py` to support the new source
2. Create a scraping function for the new source's mirror page
3. The script will automatically create the JSON file
4. Update the GitHub Actions workflow if needed

## Important Notes

- The JSON file is **required** for the scripts to function
- Ensure the JSON file is present and properly formatted
- Scripts will fail if the JSON file cannot be read or is missing
- The automated GitHub Actions workflow ensures the JSON file stays up-to-date
