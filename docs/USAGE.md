# Usage Guide

## Main Script Usage

The main `emergency_storage.sh` script coordinates all individual scripts and provides a unified interface.

### Simple Usage (Recommended)

```bash
# Download all sources to current directory (default behavior)
./emergency_storage.sh

# Download all sources to specific directory
./emergency_storage.sh /mnt/external_drive
```

### Advanced Usage

```bash
# Specify sources explicitly
./emergency_storage.sh --[sources] [drive_address]
```

### Available Sources

- `--all` - Download from all sources (default when no flags specified, includes git repositories, excludes manual-sources)
- `--kiwix` - Download Kiwix mirror only
- `--openzim` - Download OpenZIM files only
- `--openstreetmap` - Download OpenStreetMap data only
- `--ia-software` - Download Internet Archive software collection only
- `--ia-music` - Download Internet Archive music collection only
- `--ia-movies` - Download Internet Archive movies collection only
- `--ia-texts` - Download Internet Archive scientific texts only
- `--git` - Clone/update Git repositories from JSON configuration
- `--manual-sources` - Download from manually configured JSON sources (must be selected explicitly, not part of --all)  

### Examples

```bash
# Simple: Download everything to current directory (includes git repos)
./emergency_storage.sh

# Simple: Download everything to external drive (includes git repos)
./emergency_storage.sh /mnt/external_drive

# Advanced: Download only Kiwix mirror to external drive
./emergency_storage.sh --kiwix /mnt/external_drive

# Advanced: Download only OpenZIM files to external drive
./emergency_storage.sh --openzim /mnt/external_drive

# Advanced: Download only OpenStreetMap data to external drive
./emergency_storage.sh --openstreetmap /mnt/external_drive

# Advanced: Download only Internet Archive software to external drive  
./emergency_storage.sh --ia-software /mnt/external_drive

# Advanced: Download only Internet Archive music to external drive
./emergency_storage.sh --ia-music /mnt/external_drive

# Advanced: Download only Internet Archive movies to external drive
./emergency_storage.sh --ia-movies /mnt/external_drive

# Advanced: Download only Internet Archive texts to external drive
./emergency_storage.sh --ia-texts /mnt/external_drive

# Advanced: Download from manual sources JSON configuration
./emergency_storage.sh --manual-sources /mnt/external_drive

# Advanced: Clone/update Git repositories only
./emergency_storage.sh --git /mnt/external_drive

# Advanced: Explicitly download everything to external drive (includes git repos)
./emergency_storage.sh --all /mnt/external_drive

# Show help
./emergency_storage.sh --help
```

## Individual Script Usage

Each data source can be downloaded independently using its dedicated script:

```bash
# Make scripts executable (if needed)
chmod +x scripts/*.sh

# Individual script usage examples
./scripts/kiwix.sh /mnt/external_drive true        # Kiwix with mirror fallback
./scripts/openzim.sh /mnt/external_drive           # OpenZIM files
./scripts/openstreetmap.sh /mnt/external_drive     # OpenStreetMap data
./scripts/ia-software.sh /mnt/external_drive       # IA Software collection
./scripts/ia-music.sh /mnt/external_drive          # IA Music collection
./scripts/ia-movies.sh /mnt/external_drive         # IA Movies collection
./scripts/ia-texts.sh /mnt/external_drive          # IA Texts collection

# Python scripts for Git repos and manual sources
python3 scripts/download_git_repos.py --dest /mnt/external_drive/git_repos
python3 scripts/download_manual_sources.py
```

## Manual Sources Usage

Download from manually configured sources:

```bash
# Download all configured sources
python3 scripts/download_manual_sources.py

# Dry run to see what would be downloaded
python3 scripts/download_manual_sources.py --dry-run

# Use custom configuration file
python3 scripts/download_manual_sources.py --config /path/to/config.json
```

**Configuration**: Edit `data/manual_sources.json` to add your custom download sources.

See [Manual Sources Documentation](MANUAL_SOURCES.md) for full details on configuration and usage.

The `--manual-sources` flag allows you to download files from manually configured sources defined in `data/manual_sources.json`. This feature:

- **Must be explicitly selected** - It is NOT part of `--all` to prevent accidental downloads
- **Uses Python virtual environment** - Automatically creates and manages a Python venv
- **Supports multiple download methods** - wget, curl, rsync, git, and more
- **Smart fallback** - Tries alternative URLs if the main URL fails

### Setup and Prerequisites

The script automatically:
1. Creates a Python virtual environment (`.venv/`) in the repository root
2. Installs any required Python packages from `requirements.txt`
3. Validates that `python3` and `python3-venv` are installed

### Using Manual Sources

```bash
# Download from manual sources to external drive
./emergency_storage.sh --manual-sources /mnt/external_drive

# Configure your sources in data/manual_sources.json
# See docs/MANUAL_SOURCES.md for configuration details
```

### Manual Sources Configuration

Edit `data/manual_sources.json` to configure your download sources. Example:

```json
{
  "wget": {
    "url": "-c https://example.com/file.zip",
    "updateFile": false,
    "downloaded": false,
    "alternative": ["https://mirror.example.com/file.zip"]
  }
}
```

For detailed documentation on configuring manual sources, see:
- [Manual Sources Documentation](MANUAL_SOURCES.md)
- [Manual Sources Quick Reference](MANUAL_SOURCES_QUICK_REF.md)

## Automatic Updates Usage

The automatic update system allows you to schedule and automate resource downloads with configurable frequency and resource selection.

### Quick Start with Automatic Updates

```bash
# Update all enabled resources
python3 scripts/auto_update.py

# Update specific resources using flags
python3 scripts/auto_update.py --resource1
python3 scripts/auto_update.py --resource1 --resource2 --resource5

# Test configuration without executing
python3 scripts/auto_update.py --dry-run

# Use custom configuration
python3 scripts/auto_update.py --config /path/to/config.json
```

### Resource Flags

- `--resource1` - Kiwix Mirror
- `--resource2` - OpenZIM Files
- `--resource3` - OpenStreetMap Data
- `--resource4` - Internet Archive Software
- `--resource5` - Manual Sources

### Configuration

Edit `data/auto_update_config.json` to:
- Enable/disable specific resources
- Set update frequencies (daily, weekly, monthly)
- Configure destination path
- Enable retry logic and logging

Example configuration:
```json
{
  "resources": {
    "resource1": {
      "enabled": true,
      "name": "Kiwix Mirror",
      "update_frequency": "weekly"
    }
  },
  "global_settings": {
    "destination_path": "/mnt/external_drive",
    "retry_failed": true,
    "max_retries": 3
  }
}
```

### Scheduling Automatic Updates

**Using GitHub Actions (Automatic):**
- Workflow runs based on schedule in `.github/workflows/auto-update-resources.yml`
- Default: Daily at 02:00 UTC
- Can be manually triggered from GitHub Actions tab

**Using Local Cron:**
```bash
# Edit crontab
crontab -e

# Add line for daily updates at 02:00
0 2 * * * cd /path/to/EmergencyStorage && python3 scripts/auto_update.py
```

For detailed documentation on automatic updates, see:
- [Automatic Updates Documentation](AUTO_UPDATE.md)
- [Automatic Updates Quick Reference](AUTO_UPDATE_QUICK_REF.md)

## Tips for Optimal Usage

### For Large Downloads

1. **Use Ethernet**: WiFi may be unreliable for multi-terabyte downloads
2. **Check Free Space**: Verify you have sufficient storage before starting
3. **Monitor Progress**: Check logs to ensure downloads are progressing
4. **Allow Time**: Large datasets may take hours or days to complete

### For Selective Downloads

1. **Start Small**: Test with one source before downloading everything
2. **Prioritize**: Download the most important sources first
3. **Space Management**: Be aware of storage requirements for each source

### For Network Issues

1. **Mirror Fallback**: Kiwix automatically falls back to alternative mirrors
2. **Resume Support**: Most downloads support resuming after interruption
3. **Retry**: Re-run the script if downloads fail; it will resume where it left off
