# Example Configuration for Auto-Update System

This directory contains example configurations that demonstrate various use cases for the automatic update system.

## auto_update_config.json

The main configuration file with sensible defaults. This file is used by default when running `python3 scripts/auto_update.py`.

### Default Configuration

- **resource1-3**: Enabled by default (Kiwix, OpenZIM, OpenStreetMap)
- **resource4-5**: Disabled by default (IA Software, Manual Sources)
- **destination_path**: `/mnt/external_drive`
- **update_frequency**: Weekly for most resources
- **max_retries**: 3 attempts for failed updates

## Customizing Your Configuration

### Example 1: Enable All Resources

```json
{
  "resources": {
    "resource1": { "enabled": true, ... },
    "resource2": { "enabled": true, ... },
    "resource3": { "enabled": true, ... },
    "resource4": { "enabled": true, ... },
    "resource5": { "enabled": true, ... }
  }
}
```

### Example 2: Only Update Manual Sources Daily

```json
{
  "resources": {
    "resource1": { "enabled": false, ... },
    "resource2": { "enabled": false, ... },
    "resource3": { "enabled": false, ... },
    "resource4": { "enabled": false, ... },
    "resource5": {
      "enabled": true,
      "update_frequency": "daily",
      ...
    }
  }
}
```

### Example 3: Custom Destination Paths

To use different paths for different resources, you can:
1. Create multiple config files
2. Run the script separately for each resource with different configs

```bash
# Config 1: Kiwix to drive 1
python3 scripts/auto_update.py --config config1.json --resource1

# Config 2: OpenZIM to drive 2
python3 scripts/auto_update.py --config config2.json --resource2
```

### Example 4: Aggressive Retry Settings

```json
{
  "global_settings": {
    "retry_failed": true,
    "max_retries": 5,
    ...
  }
}
```

## Schedule Examples

### Cron Syntax Reference

Format: `minute hour day month day-of-week`

- `*` - Any value
- `*/n` - Every n units
- `n,m` - Specific values
- `n-m` - Range of values

### Common Schedules

```json
{
  "schedule": {
    "daily": "0 2 * * *",          // Daily at 02:00
    "weekly": "0 2 * * 0",         // Sunday at 02:00
    "monthly": "0 2 1 * *",        // 1st of month at 02:00
    "hourly": "0 * * * *",         // Every hour
    "every_6h": "0 */6 * * *",     // Every 6 hours
    "twice_daily": "0 6,18 * * *", // 06:00 and 18:00
    "weekdays": "0 2 * * 1-5",     // Weekdays at 02:00
    "weekend": "0 2 * * 0,6"       // Weekend at 02:00
  }
}
```

## Tips

1. **Start with dry-run**: Always test with `--dry-run` first
2. **Monitor logs**: Check `logs/auto_update.log` for issues
3. **Adjust frequencies**: Match update frequency to how often content changes
4. **Storage space**: Ensure adequate space before enabling all resources
5. **Network bandwidth**: Consider your bandwidth when scheduling frequent updates
6. **Restart persistence**: All scheduling methods (GitHub Actions, cron, systemd) automatically persist through system restarts

## See Also

- [AUTO_UPDATE.md](../docs/AUTO_UPDATE.md) - Full documentation
- [AUTO_UPDATE_QUICK_REF.md](../docs/AUTO_UPDATE_QUICK_REF.md) - Quick reference
