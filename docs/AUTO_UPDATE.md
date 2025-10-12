# Automatic Resource Update System

The Automatic Resource Update System allows you to schedule and automate the update of various EmergencyStorage resources. This system provides flexible configuration for which resources to update, when to update them, and where to store the downloaded data.

## Table of Contents

- [Overview](#overview)
- [Quick Start](#quick-start)
- [Configuration](#configuration)
- [Usage](#usage)
- [Scheduling Updates](#scheduling-updates)
- [GitHub Actions Integration](#github-actions-integration)
- [Examples](#examples)
- [Troubleshooting](#troubleshooting)

## Overview

The automatic update system consists of:

1. **Configuration File** (`data/auto_update_config.json`) - Defines which resources to update and how
2. **Update Script** (`scripts/auto_update.py`) - Executes the updates based on configuration
3. **GitHub Actions Workflow** (`.github/workflows/auto-update-resources.yml`) - Automates scheduled updates
4. **Resource Flags** - Command-line flags (`--resource1`, `--resource2`, etc.) for selective updates

### Features

- ✅ **Selective Updates**: Choose which resources to update using command-line flags
- ✅ **Automatic Scheduling**: Use GitHub Actions or cron jobs for automated updates
- ✅ **Configurable Frequencies**: Set different update frequencies for each resource (daily, weekly, monthly)
- ✅ **Retry Logic**: Automatically retry failed updates
- ✅ **Dry Run Mode**: Test configuration without executing actual updates
- ✅ **Logging**: Comprehensive logging to file and console
- ✅ **Flexible Destination**: Configure where resources are downloaded

## Quick Start

### 1. Configure Resources

Edit `data/auto_update_config.json` to enable/disable resources and set preferences:

```json
{
  "resources": {
    "resource1": {
      "enabled": true,
      "name": "Kiwix Mirror",
      "script": "scripts/kiwix.sh",
      "update_frequency": "weekly"
    }
  }
}
```

### 2. Run Updates

```bash
# Update all enabled resources
python3 scripts/auto_update.py

# Update specific resources only
python3 scripts/auto_update.py --resource1 --resource2

# Dry run to see what would happen
python3 scripts/auto_update.py --dry-run
```

### 3. Enable Automatic Updates

The system automatically runs via GitHub Actions based on the schedule in the workflow file.

## Configuration

### Configuration File Structure

The `data/auto_update_config.json` file has three main sections:

#### 1. Resources Section

Define each resource with its properties:

```json
{
  "resources": {
    "resource1": {
      "enabled": true,                    // Enable/disable this resource
      "name": "Kiwix Mirror",            // Human-readable name
      "script": "scripts/kiwix.sh",     // Script to execute
      "args": [],                        // Additional arguments
      "update_frequency": "weekly",      // How often to update
      "description": "Description here"  // What this resource contains
    }
  }
}
```

**Available Resources:**

- **resource1**: Kiwix Mirror (offline Wikipedia)
- **resource2**: OpenZIM Files (compressed offline content)
- **resource3**: OpenStreetMap Data (mapping data)
- **resource4**: Internet Archive Software
- **resource5**: Manual Sources (user-configured downloads)

**Update Frequencies:**

- `daily`: Update every day
- `weekly`: Update once per week
- `monthly`: Update once per month

#### 2. Global Settings Section

Configure global behavior:

```json
{
  "global_settings": {
    "destination_path": "/mnt/external_drive",  // Where to save downloads
    "allow_mirror_fallback": false,             // Allow mirror fallback for Kiwix
    "log_file": "logs/auto_update.log",        // Log file location
    "notification_email": "",                   // Email for notifications (future)
    "retry_failed": true,                       // Retry failed updates
    "max_retries": 3                           // Maximum retry attempts
  }
}
```

**Key Settings:**

- **destination_path**: Directory where resources will be downloaded
- **allow_mirror_fallback**: If true, allows Kiwix to try alternative mirrors
- **log_file**: Path to log file (relative to repository root)
- **retry_failed**: Whether to retry failed updates
- **max_retries**: How many times to retry a failed update

#### 3. Schedule Section

Define update schedules using cron syntax:

```json
{
  "schedule": {
    "default_time": "02:00",           // Default update time
    "timezone": "UTC",                 // Timezone for schedules
    "daily": "0 2 * * *",             // Daily at 02:00 UTC
    "weekly": "0 2 * * 0",            // Weekly on Sunday at 02:00 UTC
    "monthly": "0 2 1 * *"            // Monthly on 1st at 02:00 UTC
  }
}
```

**Cron Format:** `minute hour day month day-of-week`

**Examples:**
- `0 2 * * *` - Daily at 02:00
- `0 2 * * 0` - Every Sunday at 02:00
- `0 2 1 * *` - 1st of every month at 02:00
- `0 */6 * * *` - Every 6 hours

## Usage

### Command-Line Interface

```bash
# Show help
python3 scripts/auto_update.py --help

# Update all enabled resources
python3 scripts/auto_update.py

# Update specific resources
python3 scripts/auto_update.py --resource1
python3 scripts/auto_update.py --resource2 --resource3

# Dry run (see what would be executed)
python3 scripts/auto_update.py --dry-run

# Use custom configuration file
python3 scripts/auto_update.py --config /path/to/config.json
```

### Resource Flags

Use these flags to update specific resources:

- `--resource1` - Update Kiwix Mirror
- `--resource2` - Update OpenZIM Files
- `--resource3` - Update OpenStreetMap Data
- `--resource4` - Update Internet Archive Software
- `--resource5` - Update Manual Sources

### Combining Flags

```bash
# Update multiple specific resources
python3 scripts/auto_update.py --resource1 --resource2 --resource5

# Dry run with specific resources
python3 scripts/auto_update.py --resource3 --dry-run
```

## Scheduling Updates

### Option 1: GitHub Actions (Recommended)

The system includes a GitHub Actions workflow that runs automatically.

**Default Schedule:** Daily at 02:00 UTC

**To Change the Schedule:**

1. Edit `.github/workflows/auto-update-resources.yml`
2. Modify the `cron` expression:

```yaml
on:
  schedule:
    # Change this line
    - cron: '0 2 * * *'  # minute hour day month day-of-week
```

**Examples:**

```yaml
# Run every 6 hours
- cron: '0 */6 * * *'

# Run weekly on Monday at 03:00
- cron: '0 3 * * 1'

# Run twice daily (06:00 and 18:00)
- cron: '0 6,18 * * *'
```

**Manual Triggering:**

You can also manually trigger updates from GitHub:
1. Go to your repository on GitHub
2. Click "Actions" tab
3. Select "Automatic Resource Updates"
4. Click "Run workflow"
5. Optionally specify resources to update (e.g., `resource1,resource3`)

### Option 2: Local Cron Job

For running on a local machine or server:

1. **Open crontab editor:**
   ```bash
   crontab -e
   ```

2. **Add a cron job:**
   ```bash
   # Run daily at 02:00
   0 2 * * * cd /path/to/EmergencyStorage && python3 scripts/auto_update.py >> logs/cron.log 2>&1
   
   # Run weekly on Sunday at 03:00
   0 3 * * 0 cd /path/to/EmergencyStorage && python3 scripts/auto_update.py >> logs/cron.log 2>&1
   ```

3. **Save and exit**

### Option 3: systemd Timer (Linux)

Create a systemd timer for more control:

1. **Create service file** (`/etc/systemd/system/emergency-storage-update.service`):
   ```ini
   [Unit]
   Description=EmergencyStorage Automatic Update
   
   [Service]
   Type=oneshot
   User=your-username
   WorkingDirectory=/path/to/EmergencyStorage
   ExecStart=/usr/bin/python3 scripts/auto_update.py
   ```

2. **Create timer file** (`/etc/systemd/system/emergency-storage-update.timer`):
   ```ini
   [Unit]
   Description=Run EmergencyStorage updates daily
   
   [Timer]
   OnCalendar=daily
   OnCalendar=02:00
   Persistent=true
   
   [Install]
   WantedBy=timers.target
   ```

3. **Enable and start:**
   ```bash
   sudo systemctl enable emergency-storage-update.timer
   sudo systemctl start emergency-storage-update.timer
   ```

## GitHub Actions Integration

### Workflow File

The workflow is located at `.github/workflows/auto-update-resources.yml`

### Customization

#### Change Update Time

Edit the cron schedule:

```yaml
on:
  schedule:
    - cron: '0 3 * * *'  # Run at 03:00 UTC instead
```

#### Add Notifications

Add a notification step:

```yaml
- name: Send notification
  if: failure()
  run: |
    # Send email or webhook notification
    echo "Update failed" | mail -s "EmergencyStorage Update Failed" your@email.com
```

#### Change Destination

Modify the configuration file or add environment variables:

```yaml
- name: Run automatic updates
  env:
    DESTINATION_PATH: /mnt/external_drive
  run: |
    python3 scripts/auto_update.py
```

## Examples

### Example 1: Enable Weekly Updates for Kiwix and OpenZIM

**Configuration:**

```json
{
  "resources": {
    "resource1": {
      "enabled": true,
      "name": "Kiwix Mirror",
      "script": "scripts/kiwix.sh",
      "update_frequency": "weekly"
    },
    "resource2": {
      "enabled": true,
      "name": "OpenZIM Files",
      "script": "scripts/openzim.sh",
      "update_frequency": "weekly"
    }
  },
  "global_settings": {
    "destination_path": "/mnt/backup_drive"
  }
}
```

**Manual Run:**

```bash
python3 scripts/auto_update.py
```

### Example 2: Update Only Manual Sources Daily

**Configuration:**

```json
{
  "resources": {
    "resource5": {
      "enabled": true,
      "name": "Manual Sources",
      "script": "scripts/download_manual_sources.py",
      "update_frequency": "daily"
    }
  }
}
```

**Command:**

```bash
python3 scripts/auto_update.py --resource5
```

### Example 3: Test Configuration Without Executing

```bash
python3 scripts/auto_update.py --dry-run
```

Output will show what would be executed without actually running the updates.

### Example 4: Custom Destination for Specific Update

Edit the configuration temporarily:

```json
{
  "global_settings": {
    "destination_path": "/mnt/external_drive_2"
  }
}
```

Then run:

```bash
python3 scripts/auto_update.py --resource1
```

## Troubleshooting

### Issue: Script Cannot Find Configuration File

**Problem:** `Configuration file not found: data/auto_update_config.json`

**Solution:**
1. Ensure you're running from the repository root
2. Or use `--config` flag to specify the path:
   ```bash
   python3 scripts/auto_update.py --config /full/path/to/config.json
   ```

### Issue: Permission Denied

**Problem:** Cannot write to destination path

**Solution:**
1. Check permissions on destination directory
2. Change ownership: `sudo chown -R $USER:$USER /mnt/external_drive`
3. Or update `destination_path` in configuration

### Issue: Updates Failing

**Problem:** Resources fail to update

**Solution:**
1. Check logs: `cat logs/auto_update.log`
2. Run in dry-run mode: `python3 scripts/auto_update.py --dry-run`
3. Verify scripts exist and are executable
4. Check internet connectivity
5. Ensure dependencies are installed

### Issue: GitHub Actions Not Running

**Problem:** Workflow doesn't execute on schedule

**Solution:**
1. Check if Actions are enabled in repository settings
2. Verify cron syntax in workflow file
3. Check workflow run history in Actions tab
4. Note: GitHub Actions may have slight delays

### Issue: Wrong Update Time

**Problem:** Updates run at unexpected times

**Solution:**
1. Remember schedules are in UTC by default
2. Convert your local time to UTC
3. Update cron expression in workflow file
4. Use tools like [crontab.guru](https://crontab.guru/) to verify syntax

## Advanced Configuration

### Add More Resources

To add resource6, resource7, etc.:

1. **Update configuration file:**
   ```json
   {
     "resources": {
       "resource6": {
         "enabled": true,
         "name": "Custom Resource",
         "script": "scripts/custom.sh",
         "update_frequency": "weekly"
       }
     }
   }
   ```

2. **Update script** (`scripts/auto_update.py`):
   Add argument parser entry:
   ```python
   parser.add_argument('--resource6', action='store_true', help='Update resource6 only')
   ```

3. **Update workflow** (optional):
   Document the new resource in workflow description

### Custom Scripts

Your resource script should:
1. Accept a destination path as first argument
2. Exit with code 0 on success, non-zero on failure
3. Handle its own error logging

Example:
```bash
#!/bin/bash
DEST_PATH="$1"
# Your download logic here
exit 0
```

## See Also

- [Main README](../README.md)
- [Usage Guide](USAGE.md)
- [Manual Sources Documentation](MANUAL_SOURCES.md)
- [Mirror System](MIRROR_SYSTEM.md)
