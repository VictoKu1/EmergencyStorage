# Installation Guide

## Prerequisites

### System Requirements

- Linux system (tested on Raspberry Pi)
- Connected external drive with sufficient storage space (Recommended 10TB-15TB or more)
- Stable Connection (Using Ethernet Cable Highly Recommended)

### Required Tools

- `rsync` - for Kiwix mirror and OpenZIM
- `curl` - for OpenStreetMap download and Internet Archive collections
- `wget` - optional, for HTTP/FTP mirror fallback
- `python3` - for dynamic mirror updates and manual sources (required)
- `python3-venv` - for Python virtual environment (required for manual sources)
- `python3-pip` - for installing Python packages (included with python3-venv)

## Installation Steps

### 1. Install Dependencies

#### Debian/Ubuntu
```bash
sudo apt-get update
sudo apt-get install rsync curl wget python3 python3-venv python3-pip
```

#### Other Linux Distributions
Use your distribution's package manager to install the required tools.

### 2. Clone the Repository

```bash
git clone https://github.com/VictoKu1/EmergencyStorage.git
cd EmergencyStorage
```

### 3. Make Scripts Executable

```bash
chmod +x emergency_storage.sh scripts/*.sh
```

### 4. Verify Installation

```bash
# Test main script help
./emergency_storage.sh --help

# Test individual scripts
./scripts/kiwix.sh --help 2>/dev/null || echo "Test basic execution"

# Verify Python and venv are installed
python3 --version
python3 -m venv --help
```

### 5. Setup Python Virtual Environment (Optional but Recommended)

For scripts that use Python (manual sources, Git repositories, automatic updates):

```bash
# Create virtual environment
python3 -m venv .venv

# Activate virtual environment
source .venv/bin/activate

# Install Python dependencies
pip install -r requirements.txt

# Deactivate when done (optional)
deactivate
```

**Note**: The main script automatically creates and manages the virtual environment for manual sources. This step is optional for manual usage of Python scripts.

The Python virtual environment will be automatically created when you first use the `--manual-sources` flag. However, you can set it up manually:

```bash
# The script will do this automatically, but you can also do it manually:
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
deactivate
```

**Note**: The virtual environment (`.venv/`) is automatically managed by the main script when using `--manual-sources`. You don't need to activate it manually.

### 6. Setup Automatic Updates (Optional but Recommended)

Configure automatic resource updates that persist through system restarts:

```bash
# Run the interactive setup script
./scripts/setup_auto_update.sh
```

This will:
- Create a systemd timer for automatic updates
- Let you choose your update schedule (daily, weekly, monthly, or custom)
- Configure the timer to start automatically on boot
- Enable persistence (catch up on missed runs if system was off)

**Features:**
- ✅ Runs automatically on your chosen schedule
- ✅ Persists through system restarts
- ✅ Starts automatically on boot
- ✅ Catches up on missed runs

**After Setup:**
```bash
# Check timer status
systemctl status emergency-storage-update.timer

# View next scheduled run
systemctl list-timers emergency-storage-update.timer

# View logs
tail -f logs/auto_update.log
```

See [Automatic Updates Documentation](AUTO_UPDATE.md) for more details.

## Optional Tools

### Development Dependencies

If you plan to contribute or develop new data sources:

```bash
sudo apt-get install git shellcheck tree jq
```

## Storage Setup

### Recommended Setup

1. Connect an external drive (USB HDD/SSD)
2. Mount it at a known location (e.g., `/mnt/external_drive`)
3. Ensure you have write permissions
4. Verify sufficient free space (check [Storage Requirements](STORAGE.md))

### Example Mount

```bash
# Create mount point
sudo mkdir -p /mnt/external_drive

# Mount the drive (replace /dev/sdX1 with your device)
sudo mount /dev/sdX1 /mnt/external_drive

# Change permissions if needed
sudo chown -R $USER:$USER /mnt/external_drive
```

## Troubleshooting

### Common Issues

**Missing Dependencies**
```bash
# Check if tools are installed
which rsync curl wget python3

# Check for Python venv module
python3 -m venv --help

# Check for pip
python3 -m pip --version
```

**Python Virtual Environment Issues**
```bash
# If venv creation fails, ensure python3-venv is installed
sudo apt-get install python3-venv python3-pip

# If .venv directory is corrupted, remove and recreate
rm -rf .venv
./emergency_storage.sh --manual-sources /mnt/external_drive
```

**Permission Issues**
```bash
# Make scripts executable
chmod +x emergency_storage.sh scripts/*.sh

# Check write permissions on target directory
touch /mnt/external_drive/test.txt && rm /mnt/external_drive/test.txt
```

**Mirror Issues**
See [Mirror System Documentation](MIRROR_SYSTEM.md) for troubleshooting mirror connectivity.
