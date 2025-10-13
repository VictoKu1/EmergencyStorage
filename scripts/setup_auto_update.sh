#!/bin/bash
#
# Setup Automatic Updates for EmergencyStorage
# This script configures automatic resource updates on a local Linux system
# using systemd timers (which persist through system restarts).
#

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Print colored message
print_msg() {
    local color=$1
    shift
    echo -e "${color}$@${NC}"
}

print_header() {
    echo
    print_msg "$BLUE" "=========================================="
    print_msg "$BLUE" "$@"
    print_msg "$BLUE" "=========================================="
    echo
}

print_success() {
    print_msg "$GREEN" "✓ $@"
}

print_error() {
    print_msg "$RED" "✗ $@"
}

print_warning() {
    print_msg "$YELLOW" "⚠ $@"
}

print_info() {
    print_msg "$BLUE" "ℹ $@"
}

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

print_header "EmergencyStorage - Automatic Update Setup"

print_info "This script will set up automatic resource updates on your Linux system."
print_info "Updates will run daily at 02:00 and persist through system restarts."
echo

# Check if running on Linux with systemd
if ! command -v systemctl &> /dev/null; then
    print_error "systemd not found. This script requires systemd."
    echo
    print_info "Alternative setup options:"
    print_info "  1. Use cron: Run 'crontab -e' and add:"
    print_info "     0 2 * * * cd $REPO_ROOT && python3 scripts/auto_update.py >> logs/cron.log 2>&1"
    echo
    print_info "See docs/AUTO_UPDATE.md for more information."
    exit 1
fi

# Get current user
CURRENT_USER=$(whoami)

# Check if running as root (for systemd setup we need sudo, but not as root)
if [ "$EUID" -eq 0 ]; then
    print_warning "This script should not be run as root. Run it as your regular user."
    print_warning "The script will prompt for sudo password when needed."
    exit 1
fi

# Verify Python3 is available
if ! command -v python3 &> /dev/null; then
    print_error "python3 not found. Please install Python 3."
    exit 1
fi

# Verify auto_update.py exists
if [ ! -f "$REPO_ROOT/scripts/auto_update.py" ]; then
    print_error "auto_update.py not found at $REPO_ROOT/scripts/auto_update.py"
    exit 1
fi

print_info "Repository location: $REPO_ROOT"
print_info "Current user: $CURRENT_USER"
echo

# Ask for confirmation
read -p "Do you want to set up automatic updates? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    print_info "Setup cancelled."
    exit 0
fi

# Ask for update schedule
echo
print_info "Choose update schedule:"
print_info "  1. Daily at 02:00 (recommended)"
print_info "  2. Weekly on Sunday at 02:00"
print_info "  3. Monthly on the 1st at 02:00"
print_info "  4. Custom time (daily)"
echo
read -p "Enter choice [1-4] (default: 1): " schedule_choice
schedule_choice=${schedule_choice:-1}

case $schedule_choice in
    1)
        SCHEDULE_DESC="daily at 02:00"
        TIMER_CALENDAR="*-*-* 02:00:00"
        ;;
    2)
        SCHEDULE_DESC="weekly on Sunday at 02:00"
        TIMER_CALENDAR="Sun *-*-* 02:00:00"
        ;;
    3)
        SCHEDULE_DESC="monthly on the 1st at 02:00"
        TIMER_CALENDAR="*-*-01 02:00:00"
        ;;
    4)
        read -p "Enter time (HH:MM format, e.g., 03:30): " custom_time
        SCHEDULE_DESC="daily at $custom_time"
        TIMER_CALENDAR="*-*-* $custom_time:00"
        ;;
    *)
        print_error "Invalid choice. Using default (daily at 02:00)."
        SCHEDULE_DESC="daily at 02:00"
        TIMER_CALENDAR="*-*-* 02:00:00"
        ;;
esac

print_info "Selected schedule: $SCHEDULE_DESC"
echo

# Create systemd service file content
SERVICE_FILE="/etc/systemd/system/emergency-storage-update.service"
SERVICE_CONTENT="[Unit]
Description=EmergencyStorage Automatic Resource Update
After=network-online.target
Wants=network-online.target

[Service]
Type=oneshot
User=$CURRENT_USER
WorkingDirectory=$REPO_ROOT
ExecStart=/usr/bin/python3 $REPO_ROOT/scripts/auto_update.py
StandardOutput=append:$REPO_ROOT/logs/auto_update.log
StandardError=append:$REPO_ROOT/logs/auto_update.log

[Install]
WantedBy=multi-user.target
"

# Create systemd timer file content
TIMER_FILE="/etc/systemd/system/emergency-storage-update.timer"
TIMER_CONTENT="[Unit]
Description=Run EmergencyStorage automatic updates $SCHEDULE_DESC
After=network-online.target

[Timer]
OnCalendar=$TIMER_CALENDAR
Persistent=true
RandomizedDelaySec=10min

[Install]
WantedBy=timers.target
"

# Create logs directory if it doesn't exist
print_info "Creating logs directory..."
mkdir -p "$REPO_ROOT/logs"
print_success "Logs directory created at $REPO_ROOT/logs"

# Create systemd files
print_info "Creating systemd service and timer files..."
print_info "This requires sudo privileges."
echo

# Write service file
echo "$SERVICE_CONTENT" | sudo tee "$SERVICE_FILE" > /dev/null
if [ $? -eq 0 ]; then
    print_success "Service file created: $SERVICE_FILE"
else
    print_error "Failed to create service file"
    exit 1
fi

# Write timer file
echo "$TIMER_CONTENT" | sudo tee "$TIMER_FILE" > /dev/null
if [ $? -eq 0 ]; then
    print_success "Timer file created: $TIMER_FILE"
else
    print_error "Failed to create timer file"
    exit 1
fi

# Reload systemd daemon
print_info "Reloading systemd daemon..."
sudo systemctl daemon-reload
if [ $? -eq 0 ]; then
    print_success "Systemd daemon reloaded"
else
    print_error "Failed to reload systemd daemon"
    exit 1
fi

# Enable the timer
print_info "Enabling timer to start on boot..."
sudo systemctl enable emergency-storage-update.timer
if [ $? -eq 0 ]; then
    print_success "Timer enabled (will start automatically on boot)"
else
    print_error "Failed to enable timer"
    exit 1
fi

# Start the timer
print_info "Starting timer..."
sudo systemctl start emergency-storage-update.timer
if [ $? -eq 0 ]; then
    print_success "Timer started"
else
    print_error "Failed to start timer"
    exit 1
fi

# Show timer status
echo
print_header "Setup Complete!"
echo

print_success "Automatic updates have been configured successfully!"
print_info "Schedule: $SCHEDULE_DESC"
print_info "The timer will persist through system restarts."
echo

print_info "Timer status:"
sudo systemctl status emergency-storage-update.timer --no-pager | head -20
echo

print_info "Next scheduled run:"
systemctl list-timers emergency-storage-update.timer --no-pager
echo

print_header "Useful Commands"
echo
print_info "Check timer status:"
echo "  systemctl status emergency-storage-update.timer"
echo
print_info "View logs:"
echo "  tail -f $REPO_ROOT/logs/auto_update.log"
echo
print_info "Run update manually:"
echo "  python3 $REPO_ROOT/scripts/auto_update.py"
echo
print_info "Disable automatic updates:"
echo "  sudo systemctl stop emergency-storage-update.timer"
echo "  sudo systemctl disable emergency-storage-update.timer"
echo
print_info "Re-enable automatic updates:"
echo "  sudo systemctl enable emergency-storage-update.timer"
echo "  sudo systemctl start emergency-storage-update.timer"
echo
print_info "View next scheduled runs:"
echo "  systemctl list-timers"
echo

print_success "Setup complete! Your system will now automatically update resources $SCHEDULE_DESC."
print_info "For more information, see: docs/AUTO_UPDATE.md"
