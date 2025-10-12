# EmergencyStorage

A modular project to download and mirror critical knowledge from multiple sources for emergency preparedness. Designed for Raspberry Pi or any Linux PC with external storage.


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
```

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

# Automatic updates with resource flags
python3 scripts/auto_update.py
python3 scripts/auto_update.py --resource1 --resource2

# Show help
./emergency_storage.sh --help
```

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







