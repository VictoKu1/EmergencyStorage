# EmergencyStorage

A modular project to download and mirror critical knowledge from multiple sources for emergency preparedness. Designed for Raspberry Pi or any Linux PC with external storage


## ✨ Features

- **Multiple Data Sources**: Kiwix, OpenZIM, OpenStreetMap, Internet Archive (Software, Music, Movies, Texts)
- **Modular Design**: Each source has its own script for easy maintenance
- **Automatic Updates**: Schedule automatic resource updates with configurable frequency and resource selection
- **Dynamic Mirror Management**: Auto-updated mirror lists every 24 hours via GitHub Actions
- **Manual Source Downloads**: Configure and download from specific URLs with smart update control
- **Git Repositories Manager**: Clone and update multiple Git repositories in parallel with error isolation
- **Professional Logging**: Color-coded output with comprehensive error handling
- **Flexible Usage**: Download all sources or select specific ones
- **Resume Support**: Picks up where it left off if interrupted

## 🚀 Quick Start

### Recommended hardware

This project is designed to run reliably on a Raspberry Pi with large external storage. The following hardware is recommended:

- Raspberry Pi
  - Raspberry Pi 5 (recommended for best I/O performance) or Raspberry Pi 4 Model B (4GB+)
  - Official documentation:
    - Raspberry Pi 5 product page: [Raspberry Pi 5](https://www.raspberrypi.com/products/raspberry-pi-5/)
    - Raspberry Pi 4 Model B product page: [Raspberry Pi 4 Model B](https://www.raspberrypi.com/products/raspberry-pi-4-model-b/)
    - General documentation: [Raspberry Pi Documentation](https://www.raspberrypi.com/documentation/)
  - Power:
    - Pi 5: [27W USB‑C Power Supply](https://www.raspberrypi.com/products/27w-power-supply/)
    - Pi 4: [5.1V 3A USB‑C Power Supply](https://www.raspberrypi.com/products/type-c-power-supply/)
  - Boot/storage notes:
    - USB mass‑storage boot (optional): [USB mass storage boot docs](https://www.raspberrypi.com/documentation/computers/configuration.html#usb-mass-storage-boot)

- External storage (primary data drive)
  - 15TB or larger 3.5" SATA HDD from a reputable vendor (CMR drives preferred for sustained writes)
  - Use GPT partitioning and a Linux filesystem (e.g., ext4). Ensure adequate ventilation for 3.5" drives.

- Option A: USB 3.0 SATA docking station (for 3.5" HDDs)
  - Requirements:
    - Native 12V/5V power supply for the dock (do not bus‑power 3.5" drives from the Pi)
    - USB 3.x and UASP support for better throughput/latency
  - References:
    - Linux UAS overview: [USB Attached SCSI (UAS)](https://www.kernel.org/doc/html/latest/scsi/uas.html)
    - Raspberry Pi USB storage/boot guidance: [Mass storage boot](https://www.raspberrypi.com/documentation/computers/configuration.html#usb-mass-storage-boot)
  - Example vendor documentation (non‑endorsement):
    - StarTech single‑bay USB 3.0 SATA dock: [SDOCKU33** series](https://www.startech.com/en-us/hdd/sdocku33ef)

- Option B: Raspberry Pi SATA expansion boards/HATs
  - For multi‑drive or neater integration, a Pi‑compatible SATA expansion board can be used. Ensure the board provides independent power for 3.5" drives
  - Popular boards and documentation (non‑endorsement):
    - Geekworm 3.5" SATA board (for Pi 4): [X828 Wiki](https://wiki.geekworm.com/X828)
    - Geekworm dual 2.5" SATA HAT (for Pi 4): [X829 Wiki](https://wiki.geekworm.com/X829)
    - Radxa SATA HAT (for Pi 4): [SATA HAT Wiki](https://wiki.radxa.com/SATA_HAT)
  - Notes:
    - Many SATA HATs for Pi 4 use USB 3.x bridges internally; performance and stability depend on the bridge chipset and firmware.
    - For Raspberry Pi 5, consider PCIe‑based storage via the official M.2 HAT+ (for NVMe SSDs) if your workload suits SSDs:
      - [M.2 HAT+](https://www.raspberrypi.com/documentation/computers/raspberry-pi-5.html#m-2-hat-plus)

- Cables and cooling
  - High‑quality USB 3.x cable (short, shielded) if using a USB dock/enclosure
  - Adequate cooling for the Raspberry Pi (heatsink + fan or active case), especially under sustained I/O

Notes and compatibility tips:
- Prefer UASP‑capable docks/bridges; fall back to BOT if stability issues occur
- Some USB‑SATA bridges may require “quirks” to disable UAS for stability; consult your bridge vendor documentation and Raspberry Pi USB storage guidance
- Use a reliable power source for both the Pi and the drives; brownouts can cause I/O errors and filesystem corruption
  
### Installation

```bash
# Install dependencies
sudo apt update
sudo apt upgrade
sudo apt install rsync curl wget python3 python3-venv python3-pip

# Clone the repository
git clone https://github.com/VictoKu1/EmergencyStorage.git
cd EmergencyStorage

# Make scripts executable
chmod +x emergency_storage.sh scripts/*.sh

# Optional: Set up automatic updates (recommended)
./scripts/setup_auto_update.sh
```

The optional automatic update setup will:
- Configure daily automatic resource updates (persists through system restarts)
- Let you choose your preferred update schedule
- Use systemd timers for reliable scheduling on Linux

### Basic Usage

```bash
# Download all sources to current directory (includes git repositories)
./emergency_storage.sh

# Download all sources to external drive (includes git repositories)
./emergency_storage.sh /mnt/external_drive

# Download specific source only
./emergency_storage.sh --kiwix /mnt/external_drive
./emergency_storage.sh --openzim /mnt/external_drive
./emergency_storage.sh --openstreetmap /mnt/external_drive

# Clone/update Git repositories only
./emergency_storage.sh --git /mnt/external_drive

# Download from manual sources configuration (must be explicitly selected)
./emergency_storage.sh --manual-sources /mnt/external_drive

# Or use the manual sources script directly
python3 scripts/download_manual_sources.py

# Clone/update Git repositories directly
python3 scripts/download_git_repos.py

# Show help
./emergency_storage.sh --help
```

### Automatic Updates

Set up automatic resource updates that persist through system restarts:

```bash
# Run the automated setup (one-time)
./scripts/setup_auto_update.sh

# Or run updates manually
python3 scripts/auto_update.py

# Update specific resources
python3 scripts/auto_update.py --resource1 --resource2

# Dry run to test configuration
python3 scripts/auto_update.py --dry-run
```

The setup script configures systemd timers that:
- ✅ Run automatically on your chosen schedule
- ✅ Persist through system restarts
- ✅ Start automatically on boot
- ✅ Catch up on missed runs if system was off

See [Automatic Updates Documentation](docs/AUTO_UPDATE.md) for more details.

## 📖 Documentation

Comprehensive documentation is available in the [`docs/`](docs/) folder:

- **[Installation Guide](docs/INSTALLATION.md)** - Detailed setup instructions and prerequisites
- **[Usage Guide](docs/USAGE.md)** - Complete usage examples and tips
- **[Automatic Updates](docs/AUTO_UPDATE.md)** - Schedule and automate resource updates
- **[Architecture](docs/ARCHITECTURE.md)** - System design and project structure
- **[Storage Requirements](docs/STORAGE.md)** - Size estimates and content descriptions
- **[Contributing](docs/CONTRIBUTING.md)** - How to contribute and development workflow
- **[Adding Data Sources](docs/ADDING_SOURCES.md)** - Template system for new sources
- **[Error Handling](docs/ERROR_HANDLING.md)** - Logging and error management
- **[Mirror System](docs/MIRROR_SYSTEM.md)** - Dynamic mirror management details
- **[Manual Sources](docs/MANUAL_SOURCES.md)** - Configure manual download sources
- **[Git Repositories](docs/GIT_REPOSITORIES.md)** - Clone and manage Git repositories in parallel

## 📦 Available Data Sources

| Source | Size | Description |
|--------|------|-------------|
| **Kiwix** | ~7TB (10TB for complete repository) | Complete offline Wikipedia and educational content |
| **OpenZIM** | ~1TB | Compressed offline content (Wikipedia, educational materials) |
| **OpenStreetMap** | ~70GB | Complete planet mapping data |
| **IA Software** | 50GB-500GB | Preserved software, games, and applications |
| **IA Music** | 100GB-1TB | Music, podcasts, and live concerts |
| **IA Movies** | 500GB-5TB | Public domain films and documentaries |
| **IA Texts** | 100GB-2TB | Books, research papers, and academic texts |

**Recommended Storage**: 10-17TB+ for all sources

## 🛠️ Available Options

```bash
--all              # Download from all sources (default, includes git repositories)
--kiwix            # Kiwix mirror only
--openzim          # OpenZIM files only
--openstreetmap    # OpenStreetMap data only
--ia-software      # Internet Archive software only
--ia-music         # Internet Archive music only
--ia-movies        # Internet Archive movies only
--ia-texts         # Internet Archive texts only
--git              # Git repositories only
--manual-sources   # Manual JSON sources only (must be explicitly selected)
```

## 🤝 Contributing

We welcome contributions! See [CONTRIBUTING.md](docs/CONTRIBUTING.md) for:
- How to add new data sources using our template system
- Development setup and workflow
- Code style guidelines
- Pull request process

## 📄 License

MIT License - see [LICENSE](LICENSE) file for details.

---

**Need Help?** Check the [documentation](docs/) or [open an issue](https://github.com/VictoKu1/EmergencyStorage/issues).







