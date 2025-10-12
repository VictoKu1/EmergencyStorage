# Automatic Updates Quick Reference

Quick reference for the EmergencyStorage automatic update system.

## Quick Commands

```bash
# Update all enabled resources
python3 scripts/auto_update.py

# Update specific resources
python3 scripts/auto_update.py --resource1
python3 scripts/auto_update.py --resource1 --resource2 --resource5

# Dry run (test without executing)
python3 scripts/auto_update.py --dry-run

# Use custom config
python3 scripts/auto_update.py --config path/to/config.json

# Show help
python3 scripts/auto_update.py --help
```

## Resource Flags

| Flag | Resource | Default Script |
|------|----------|---------------|
| `--resource1` | Kiwix Mirror | `scripts/kiwix.sh` |
| `--resource2` | OpenZIM Files | `scripts/openzim.sh` |
| `--resource3` | OpenStreetMap | `scripts/openstreetmap.sh` |
| `--resource4` | IA Software | `scripts/ia-software.sh` |
| `--resource5` | Manual Sources | `scripts/download_manual_sources.py` |

## Configuration File

**Location:** `data/auto_update_config.json`

### Enable/Disable Resource

```json
{
  "resources": {
    "resource1": {
      "enabled": true  // Change to false to disable
    }
  }
}
```

### Change Destination Path

```json
{
  "global_settings": {
    "destination_path": "/mnt/external_drive"  // Change this path
  }
}
```

### Change Update Frequency

```json
{
  "resources": {
    "resource1": {
      "update_frequency": "weekly"  // Options: daily, weekly, monthly
    }
  }
}
```

## Scheduling

### GitHub Actions Schedule

**File:** `.github/workflows/auto-update-resources.yml`

**Change update time:**
```yaml
on:
  schedule:
    - cron: '0 2 * * *'  # minute hour day month day-of-week
```

**Common schedules:**
- Daily at 02:00: `0 2 * * *`
- Weekly on Sunday: `0 2 * * 0`
- Monthly on 1st: `0 2 1 * *`
- Every 6 hours: `0 */6 * * *`

**Persistence:** Runs on GitHub's infrastructure - always persists through restarts.

### Local Cron Job

```bash
# Edit crontab
crontab -e

# Add line (daily at 02:00)
0 2 * * * cd /path/to/EmergencyStorage && python3 scripts/auto_update.py
```

**Persistence:** Cron jobs automatically persist through system restarts.

### systemd Timer

```bash
# Enable timer (persists through restarts)
sudo systemctl enable emergency-storage-update.timer
sudo systemctl start emergency-storage-update.timer

# Check status
systemctl status emergency-storage-update.timer
```

**Persistence:** With `systemctl enable`, timer starts automatically on every boot. `Persistent=true` in timer file ensures missed runs execute after restart.

## Common Settings

### Retry Failed Updates

```json
{
  "global_settings": {
    "retry_failed": true,
    "max_retries": 3
  }
}
```

### Enable Logging

```json
{
  "global_settings": {
    "log_file": "logs/auto_update.log"
  }
}
```

### Allow Mirror Fallback

```json
{
  "global_settings": {
    "allow_mirror_fallback": true  // For Kiwix alternative mirrors
  }
}
```

## Manual GitHub Actions Trigger

1. Go to repository on GitHub
2. Click "Actions" tab
3. Select "Automatic Resource Updates"
4. Click "Run workflow"
5. (Optional) Enter resources: `resource1,resource3`

## Troubleshooting Quick Fixes

| Problem | Solution |
|---------|----------|
| Config not found | Run from repo root or use `--config` flag |
| Permission denied | Check destination path permissions |
| Updates failing | Check logs: `cat logs/auto_update.log` |
| Wrong time | Remember: schedules are in UTC |
| Actions not running | Check if Actions enabled in repo settings |

## Examples

```bash
# Example 1: Update only Kiwix
python3 scripts/auto_update.py --resource1

# Example 2: Test configuration
python3 scripts/auto_update.py --dry-run

# Example 3: Update Kiwix and OpenZIM
python3 scripts/auto_update.py --resource1 --resource2

# Example 4: Update manual sources
python3 scripts/auto_update.py --resource5
```

## See Also

- [Full Documentation](AUTO_UPDATE.md)
- [Usage Guide](USAGE.md)
- [Main README](../README.md)
