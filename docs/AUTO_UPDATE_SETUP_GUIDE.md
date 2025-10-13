# Automatic Updates Setup Guide

This guide explains how the automatic update system works for **local Linux installations**.

## Problem Solved

Previously, the documentation emphasized GitHub Actions for automatic updates, which only works for repositories hosted on GitHub. Users who download this project to their PC need a local solution that:
- Runs automatically on a schedule
- Persists through system restarts
- Starts automatically when the system boots

## Solution: One-Command Setup

```bash
./scripts/setup_auto_update.sh
```

That's it! This single command sets up everything you need.

## What It Does

1. **Creates a systemd service** that runs the auto-update script
2. **Creates a systemd timer** with your chosen schedule
3. **Enables the timer** to start automatically on boot
4. **Starts the timer** immediately

## Interactive Setup

The script will ask you to choose a schedule:
- Daily at 02:00 (recommended)
- Weekly on Sunday at 02:00
- Monthly on the 1st at 02:00
- Custom time (daily)

## Persistence Features

The setup ensures updates persist through restarts:

1. **`Persistent=true`** in timer configuration
   - If system was off during scheduled update, it runs immediately on boot
   
2. **`systemctl enable`** makes timer start on boot
   - Timer automatically starts every time system boots
   
3. **Logs** track all update attempts
   - See what happened while you were away

## Verification

After setup, verify everything works:

```bash
# Check if enabled (will start on boot)
systemctl is-enabled emergency-storage-update.timer
# Output: enabled

# Check status
systemctl status emergency-storage-update.timer
# Output: Active: active (waiting)

# See next scheduled run
systemctl list-timers emergency-storage-update.timer

# View logs
tail -f logs/auto_update.log
```

## Testing Persistence

To prove it survives restarts:

1. **Before reboot:**
   ```bash
   systemctl list-timers emergency-storage-update.timer
   # Note the "NEXT" time
   ```

2. **Reboot your system:**
   ```bash
   sudo reboot
   ```

3. **After reboot:**
   ```bash
   systemctl status emergency-storage-update.timer
   # Should still be active
   
   systemctl list-timers emergency-storage-update.timer
   # Timer is still scheduled
   ```

## Managing Updates

```bash
# Stop updates temporarily
sudo systemctl stop emergency-storage-update.timer

# Disable automatic startup (but keep configuration)
sudo systemctl disable emergency-storage-update.timer

# Re-enable
sudo systemctl enable emergency-storage-update.timer
sudo systemctl start emergency-storage-update.timer

# Run update manually
python3 scripts/auto_update.py

# View timer configuration
systemctl cat emergency-storage-update.timer
```

## For Different Systems

### ✅ Linux with systemd (Recommended)
Use `./scripts/setup_auto_update.sh` - fully automated

### ✅ Linux with cron (Alternative)
```bash
crontab -e
# Add line:
0 2 * * * cd /path/to/EmergencyStorage && python3 scripts/auto_update.py
```

### ✅ GitHub-hosted repository
The included GitHub Actions workflow (`.github/workflows/auto-update-resources.yml`) runs automatically

## Configuration

Edit `data/auto_update_config.json` to:
- Enable/disable specific resources
- Change update frequency
- Set destination paths
- Configure logging

See [AUTO_UPDATE.md](../docs/AUTO_UPDATE.md) for full configuration details.

## Troubleshooting

**Timer not starting on boot?**
```bash
# Check if enabled
systemctl is-enabled emergency-storage-update.timer

# If disabled, enable it
sudo systemctl enable emergency-storage-update.timer
```

**Want to change schedule?**
1. Run setup script again: `./scripts/setup_auto_update.sh`
2. Or manually edit: `/etc/systemd/system/emergency-storage-update.timer`
3. Reload: `sudo systemctl daemon-reload`
4. Restart: `sudo systemctl restart emergency-storage-update.timer`

**Check logs for errors:**
```bash
# Update logs
tail -f logs/auto_update.log

# System journal
journalctl -u emergency-storage-update.service -f
```

## Summary

- **Setup**: One command (`./scripts/setup_auto_update.sh`)
- **Persistence**: Automatic (survives restarts and boots)
- **Schedule**: Your choice (daily, weekly, monthly, custom)
- **Management**: Standard systemd commands
- **Testing**: Built-in test suite validates everything

That's all you need to know! The system handles the rest automatically.
