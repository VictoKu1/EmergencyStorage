# Error Handling and Logging

The refactored scripts include comprehensive error handling and professional logging to ensure reliable operation and helpful debugging.

## Logging Features

### Color-Coded Output

All scripts use a consistent color scheme for different message types:

- **Info** (Blue): General information and progress updates
- **Success** (Green): Successful completion of operations
- **Warning** (Yellow): Non-critical issues or important notices
- **Error** (Red): Critical errors that prevent operation

### Consistent Formatting

All scripts use the same logging system from `scripts/common.sh`, ensuring:
- Uniform message structure
- Timestamp information when needed
- Clear indication of the current operation
- Easy-to-read output

### Progress Reporting

Scripts provide clear indication of what they're doing:
- Starting operations
- Download progress (when supported by tools)
- Completion status
- Summary of operations

### Error Reporting

Detailed error messages with:
- Clear description of the problem
- Suggestions for resolution
- Context about what was being attempted
- Exit codes for automation

## Error Handling Mechanisms

### Individual Script Failures

**Behavior**: Main script continues with other sources if one fails

**Why**: One failing download shouldn't prevent other critical data from being downloaded

**Example**: If Kiwix mirror fails, OpenZIM, OpenStreetMap, and Internet Archive downloads continue

### Network Connectivity

**Behavior**: Graceful handling of internet connection issues

**Features**:
- Pre-download connectivity checks
- Timeout handling
- Resume capability for interrupted downloads
- Clear error messages about network issues

**Example**: If network is unavailable, script provides clear error message instead of hanging

### Missing Dependencies

**Behavior**: Clear messages about required tools

**Features**:
- Checks for required commands before starting
- Suggests installation commands for missing tools
- Exits gracefully if critical dependencies are missing

**Example**: 
```
ERROR: rsync command not found
Please install rsync: sudo apt-get install rsync
```

### Invalid Paths

**Behavior**: Validation and creation of target directories

**Features**:
- Path validation before operations
- Automatic directory creation when possible
- Clear error messages for permission issues
- Safe path handling to prevent accidental overwrites

**Example**: Creates target directory if it doesn't exist, or errors if permissions are insufficient

### Insufficient Permissions

**Behavior**: Permission checks before attempting operations

**Features**:
- Write permission verification
- Clear error messages about permission issues
- Suggestions for resolution (chmod, sudo, etc.)

**Example**:
```
ERROR: No write permission for /mnt/external_drive
Please check directory permissions
```

### Mirror Fallback

**Behavior**: Automatic fallback to alternative mirrors for Kiwix

**Features**:
- Dynamic mirror list from JSON file
- Attempts multiple mirrors in sequence
- Falls back to HTTP/FTP mirrors if rsync fails
- Reports which mirror was successful

**Example**: If primary rsync mirror fails, automatically tries secondary mirrors

## Script Architecture Benefits

### Modularity

Each script handles one specific data source, making it easier to:
- Debug individual components
- Update specific functionality
- Test isolated features
- Maintain clean code

### Maintainability

Easy to update individual components without affecting others:
- Isolated changes reduce risk
- Clear separation of concerns
- Reusable utility functions
- Consistent patterns across scripts

### Testability

Scripts can be tested independently:
- Unit testing of individual scripts
- Integration testing with main coordinator
- Mock testing with test directories
- Error scenario testing

### Reusability

Individual scripts can be used in other projects:
- Standalone functionality
- No hard dependencies on main script
- Self-contained logic
- Clear interfaces

### Professional Structure

Clean code organization with proper documentation:
- Header comments with usage
- Function documentation
- Clear variable names
- Consistent coding style
- Proper error propagation

### Using the Logging System

### In Your Scripts

When creating new data sources, use the logging functions from `scripts/common.sh`:

```bash
# Source the common utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

# Use logging functions
log_info "Starting download..."
log_success "Download completed!"
log_warning "Mirror may be slow"
log_error "Failed to connect"
```

### Log Levels

- **log_info**: For general information and progress
- **log_success**: For successful completion of operations
- **log_warning**: For non-critical issues
- **log_error**: For critical errors

### Best Practices

1. **Be descriptive**: Provide clear, actionable messages
2. **Include context**: Mention what was being attempted
3. **Suggest solutions**: When possible, guide users to resolution
4. **Use appropriate levels**: Don't use error for warnings
5. **Be consistent**: Follow existing patterns in other scripts

## Debugging Tips

### Enable Debug Mode

Add at the top of your script (after `set -e`):
```bash
set -x  # Print commands as they execute
```

### Check Logs

Review script output for:
- Error messages and their context
- Last successful operation
- Network connectivity issues
- Permission problems

### Test Error Conditions

Intentionally trigger errors to verify handling:
```bash
# Test with invalid path
./scripts/your-script.sh /invalid/path

# Test with no arguments
./scripts/your-script.sh

# Test with no network (disconnect network)
./scripts/your-script.sh /tmp/test
```

### Use Individual Scripts

Test data sources independently before using the main coordinator:
```bash
# More direct feedback from individual script
./scripts/kiwix.sh /tmp/test true
```
