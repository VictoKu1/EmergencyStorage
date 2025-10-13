# Custom Configuration Examples

This directory contains example configuration files for different use cases.

## Example 1: Minimal Setup (Only Kiwix)

**File: `example_kiwix_only.json`**

```json
{
  "resources": {
    "resource1": {
      "enabled": true,
      "name": "Kiwix Mirror",
      "script": "scripts/kiwix.sh",
      "args": [],
      "update_frequency": "weekly",
      "description": "Kiwix offline Wikipedia and educational content"
    }
  },
  "global_settings": {
    "destination_path": "/mnt/external_drive",
    "allow_mirror_fallback": true,
    "log_file": "logs/auto_update_kiwix.log",
    "retry_failed": true,
    "max_retries": 3
  },
  "schedule": {
    "weekly": "0 2 * * 0"
  }
}
```

**Usage:**
```bash
python3 scripts/auto_update.py --config examples/example_kiwix_only.json
```

## Example 2: Daily Manual Sources Updates

**File: `example_manual_sources_daily.json`**

```json
{
  "resources": {
    "resource5": {
      "enabled": true,
      "name": "Manual Sources",
      "script": "scripts/download_manual_sources.py",
      "args": [],
      "update_frequency": "daily",
      "description": "User-configured download sources"
    }
  },
  "global_settings": {
    "destination_path": "/home/user/downloads",
    "log_file": "logs/auto_update_manual.log",
    "retry_failed": true,
    "max_retries": 2
  },
  "schedule": {
    "daily": "0 3 * * *"
  }
}
```

**Usage:**
```bash
python3 scripts/auto_update.py --config examples/example_manual_sources_daily.json
```

## Example 3: All Resources, Aggressive Updates

**File: `example_all_resources.json`**

```json
{
  "resources": {
    "resource1": {
      "enabled": true,
      "name": "Kiwix Mirror",
      "script": "scripts/kiwix.sh",
      "args": [],
      "update_frequency": "weekly",
      "description": "Kiwix offline Wikipedia and educational content"
    },
    "resource2": {
      "enabled": true,
      "name": "OpenZIM Files",
      "script": "scripts/openzim.sh",
      "args": [],
      "update_frequency": "weekly",
      "description": "OpenZIM compressed offline content"
    },
    "resource3": {
      "enabled": true,
      "name": "OpenStreetMap Data",
      "script": "scripts/openstreetmap.sh",
      "args": [],
      "update_frequency": "weekly",
      "description": "Complete planet mapping data"
    },
    "resource4": {
      "enabled": true,
      "name": "Internet Archive Software",
      "script": "scripts/ia-software.sh",
      "args": [],
      "update_frequency": "monthly",
      "description": "Preserved software and applications"
    },
    "resource5": {
      "enabled": true,
      "name": "Manual Sources",
      "script": "scripts/download_manual_sources.py",
      "args": [],
      "update_frequency": "daily",
      "description": "User-configured download sources"
    }
  },
  "global_settings": {
    "destination_path": "/mnt/large_storage",
    "allow_mirror_fallback": true,
    "log_file": "logs/auto_update_all.log",
    "retry_failed": true,
    "max_retries": 5
  },
  "schedule": {
    "daily": "0 2 * * *",
    "weekly": "0 3 * * 0",
    "monthly": "0 4 1 * *"
  }
}
```

**Usage:**
```bash
python3 scripts/auto_update.py --config examples/example_all_resources.json
```

## Example 4: Testing Configuration

**File: `example_test.json`**

Minimal config for testing the system:

```json
{
  "resources": {
    "resource5": {
      "enabled": true,
      "name": "Manual Sources (Test)",
      "script": "scripts/download_manual_sources.py",
      "args": ["--dry-run"],
      "update_frequency": "daily",
      "description": "Test configuration"
    }
  },
  "global_settings": {
    "destination_path": "/tmp/test_updates",
    "log_file": "logs/auto_update_test.log",
    "retry_failed": false,
    "max_retries": 1
  },
  "schedule": {
    "daily": "0 * * * *"
  }
}
```

**Usage:**
```bash
python3 scripts/auto_update.py --config examples/example_test.json --dry-run
```

## How to Use These Examples

1. **Copy the example** you want to use
2. **Customize** the settings for your needs
3. **Save** as a new JSON file
4. **Run** with `--config` flag pointing to your file

```bash
# Copy an example
cp examples/example_kiwix_only.json my_config.json

# Edit it
nano my_config.json

# Use it
python3 scripts/auto_update.py --config my_config.json --dry-run
```

## Configuration Tips

### Choosing Update Frequencies

- **daily**: For frequently changing content (news, manual sources)
- **weekly**: For regularly updated content (Kiwix, OpenZIM, OSM)
- **monthly**: For stable archives (IA collections)

### Setting Destination Paths

- Use absolute paths: `/mnt/external_drive`
- Ensure adequate space for the resources
- Check write permissions

### Retry Settings

- **max_retries: 3**: Good balance for most scenarios
- **max_retries: 1**: Quick failure, good for testing
- **max_retries: 5**: More persistent, good for unreliable connections

### Log Files

- Keep logs separate per configuration
- Use descriptive names: `logs/auto_update_kiwix.log`
- Rotate logs periodically to save space

## Combining with Cron

For each configuration, you can set up a separate cron job:

```bash
# Kiwix weekly
0 2 * * 0 cd /path/to/repo && python3 scripts/auto_update.py --config config_kiwix.json

# Manual sources daily
0 3 * * * cd /path/to/repo && python3 scripts/auto_update.py --config config_manual.json

# Full update monthly
0 4 1 * * cd /path/to/repo && python3 scripts/auto_update.py --config config_full.json
```

**Note:** Cron jobs persist through system restarts automatically. Once added to crontab, they continue running on schedule after reboots.

## Automated Setup for Local Installations

The easiest way to set up automatic updates on your local Linux system:

```bash
# Run the setup script
./scripts/setup_auto_update.sh
```

This creates a systemd timer that:
- Runs automatically on your chosen schedule
- Persists through system restarts
- Starts on boot
- Catches up on missed runs if system was off

### Verifying Persistence After Setup

After running the setup script, verify the timer will persist:

```bash
# Check if timer is enabled (will start on boot)
systemctl is-enabled emergency-storage-update.timer
# Should output: enabled

# View timer status
systemctl status emergency-storage-update.timer
# Should show: Active: active (waiting)

# See next scheduled run
systemctl list-timers emergency-storage-update.timer

# View timer configuration (includes Persistent=true)
systemctl cat emergency-storage-update.timer
```

### Testing Persistence

To test that updates will survive a system restart:

1. **Before restart:** Check the next scheduled run time
   ```bash
   systemctl list-timers emergency-storage-update.timer
   ```

2. **After restart:** Verify the timer is still running
   ```bash
   systemctl status emergency-storage-update.timer
   systemctl list-timers emergency-storage-update.timer
   ```

3. **Check logs** to see if missed updates ran:
   ```bash
   tail -f logs/auto_update.log
   ```

The `Persistent=true` setting in the timer ensures that if the system was off during a scheduled run, the update will execute immediately after boot.

## See Also

- [AUTO_UPDATE.md](../docs/AUTO_UPDATE.md) - Full documentation
- [AUTO_UPDATE_QUICK_REF.md](../docs/AUTO_UPDATE_QUICK_REF.md) - Quick reference
- [AUTO_UPDATE_CONFIG_README.md](../data/AUTO_UPDATE_CONFIG_README.md) - Config examples
