# EmergencyStorage

A modular project designed to run on Raspberry Pi (or Linux) with a connected HDD, providing scripts that download/mirror emergency data from multiple sources.

## Architecture

EmergencyStorage now uses a **modular architecture** with individual scripts for each data source:

- **`emergency_storage.sh`** - Main coordinator script that calls individual source scripts
- **`scripts/common.sh`** - Shared utility functions and colored logging system
- **`scripts/kiwix.sh`** - Kiwix mirror download functionality
- **`scripts/openzim.sh`** - OpenZIM files download functionality  
- **`scripts/openstreetmap.sh`** - OpenStreetMap data download functionality
- **`scripts/ia-software.sh`** - Internet Archive software collection
- **`scripts/ia-music.sh`** - Internet Archive music collection
- **`scripts/ia-movies.sh`** - Internet Archive movies collection
- **`scripts/ia-texts.sh`** - Internet Archive texts/academic papers collection

This modular design allows for:
- **Better maintainability** - Each source has its own focused script
- **Independent testing** - Individual scripts can be tested and debugged separately
- **Professional code structure** - Clean separation of concerns
- **Enhanced logging** - Colored output with consistent formatting
- **Easier contributions** - Developers can work on individual components

## Features

- **Modular Architecture**: Each data source has its own specialized script for better maintainability
- **Professional Logging**: Color-coded output with consistent formatting across all scripts
- **Kiwix Mirror**: Downloads the complete Kiwix library mirror using rsync with fallback mirrors
- **OpenZIM**: Downloads ZIM files from OpenZIM containing offline content (Wikipedia, educational content, etc.)
- **OpenStreetMap Data**: Downloads the latest planet OSM data file (~70GB+)
- **Internet Archive Software**: Downloads software preservation collections (games, applications, historical software)
- **Internet Archive Music**: Downloads music collections (Creative Commons, public domain, live concerts)
- **Internet Archive Movies**: Downloads movie collections (public domain films, documentaries, educational content)
- **Internet Archive Texts**: Downloads scientific texts and academic papers (books, research papers, government documents)
- **All Sources**: Downloads from all sources in sequence with error handling and reporting

## Prerequisites

- Linux system (tested on Raspberry Pi)
- Connected external drive with sufficient storage space (Recommended 10TB-15TB or more)
- Stable Connection (Using Ethernet Cable Highly Recommended)
- Required tools:
  - `rsync` (for Kiwix mirror and OpenZIM)
  - `curl` (for OpenStreetMap download and Internet Archive collections)
  - `wget` (optional, for HTTP/FTP mirror fallback)

Install dependencies on Debian/Ubuntu:
```bash
sudo apt-get update
sudo apt-get install rsync curl wget
```

## Individual Script Usage

Each data source can be downloaded independently using its dedicated script:

```bash
# Make scripts executable (if needed)
chmod +x scripts/*.sh

# Individual script usage examples
./scripts/kiwix.sh /mnt/external_drive true        # Kiwix with mirror fallback
./scripts/openzim.sh /mnt/external_drive           # OpenZIM files
./scripts/openstreetmap.sh /mnt/external_drive     # OpenStreetMap data
./scripts/ia-software.sh /mnt/external_drive       # IA Software collection
./scripts/ia-music.sh /mnt/external_drive          # IA Music collection
./scripts/ia-movies.sh /mnt/external_drive         # IA Movies collection
./scripts/ia-texts.sh /mnt/external_drive          # IA Texts collection
```

## Main Script Usage

The main `emergency_storage.sh` script coordinates all individual scripts and provides a unified interface:

Make the script executable:
```bash
chmod +x emergency_storage.sh
```

**Simple Usage (Recommended):**
```bash
# Download all sources to current directory (default behavior)
./emergency_storage.sh

# Download all sources to specific directory
./emergency_storage.sh /mnt/external_drive
```

**Advanced Usage:**
```bash
# Specify sources explicitly
./emergency_storage.sh --[sources] [drive_address]
```

### Available Sources

- `--all` - Download from all sources (default when no flags specified)
- `--kiwix` - Download Kiwix mirror only
- `--openzim` - Download OpenZIM files only
- `--openstreetmap` - Download OpenStreetMap data only
- `--ia-software` - Download Internet Archive software collection only
- `--ia-music` - Download Internet Archive music collection only
- `--ia-movies` - Download Internet Archive movies collection only
- `--ia-texts` - Download Internet Archive scientific texts only  

### Examples

```bash
# Simple: Download everything to current directory
./emergency_storage.sh

# Simple: Download everything to external drive
./emergency_storage.sh /mnt/external_drive

# Advanced: Download only Kiwix mirror to external drive
./emergency_storage.sh --kiwix /mnt/external_drive

# Advanced: Download only OpenZIM files to external drive
./emergency_storage.sh --openzim /mnt/external_drive

# Advanced: Download only OpenStreetMap data to external drive
./emergency_storage.sh --openstreetmap /mnt/external_drive

# Advanced: Download only Internet Archive software to external drive  
./emergency_storage.sh --ia-software /mnt/external_drive

# Advanced: Download only Internet Archive music to external drive
./emergency_storage.sh --ia-music /mnt/external_drive

# Advanced: Download only Internet Archive movies to external drive
./emergency_storage.sh --ia-movies /mnt/external_drive

# Advanced: Download only Internet Archive texts to external drive
./emergency_storage.sh --ia-texts /mnt/external_drive

# Advanced: Explicitly download everything to external drive
./emergency_storage.sh --all /mnt/external_drive

# Show help
./emergency_storage.sh --help
```

## Storage Requirements

- **Kiwix Mirror**: Usually +7TB for all ZIM files (typically several GB to TB depending on content)
- **OpenZIM**: Varies (typically several GB to TB, includes Wikipedia and educational content)
- **OpenStreetMap Planet**: ~70GB+ (compressed PBF format)
- **Internet Archive Software**: 50GB - 500GB (depending on collections selected)
- **Internet Archive Music**: 100GB - 1TB (depending on collections selected)
- **Internet Archive Movies**: 500GB - 5TB (depending on collections selected)
- **Internet Archive Texts**: 100GB - 2TB (depending on collections selected)
- **Recommended**: At least 1TB+ free space for comfortable operation with all sources

## What Gets Downloaded

### Kiwix Mirror
The script creates a `kiwix-mirror/` directory and syncs content from:
```
master.download.kiwix.org::download.kiwix.org/
```

### OpenZIM
The script creates an `openzim/` directory and syncs content from:
```
download.openzim.org::download.openzim.org/
```
This includes ZIM files containing offline content such as Wikipedia, educational materials, and other reference content in compressed format.

### OpenStreetMap
The script creates an `openstreetmap/` directory and downloads:
```
https://planet.openstreetmap.org/pbf/planet-latest.osm.pbf
```

### Internet Archive Software
The script creates an `internet-archive-software/` directory and downloads:
- MS-DOS Games and Software
- Windows 3.x Software Library
- Historical Software Collections
- Open Source Software
- Console Living Room (Game Console Software)

### Internet Archive Music  
The script creates an `internet-archive-music/` directory and downloads:
- Open Source Audio Collections
- Community Audio
- Net Labels
- Live Concert Archive (etree.org)
- Radio Programs
- Audio Books & Poetry

### Internet Archive Movies
The script creates an `internet-archive-movies/` directory and downloads:
- Prelinger Archives (industrial/educational films)
- Classic TV Shows
- Public Domain Feature Films
- Animation Films
- Documentaries

### Internet Archive Texts
The script creates an `internet-archive-texts/` directory and downloads:
- Project Gutenberg (public domain literature)
- Biodiversity Heritage Library (biological sciences)
- Medical Heritage Library (historical medical texts)
- Academic papers and research materials
- Open access texts and technical documentation
- Government documents (public domain)
- Subject-specific collections (mathematics, physics, chemistry, biology, etc.)

## Development and Contribution

### Project Structure
```
EmergencyStorage/
├── emergency_storage.sh          # Main coordinator script
├── scripts/
│   ├── common.sh                 # Shared utilities and logging
│   ├── kiwix.sh                  # Kiwix mirror functionality
│   ├── openzim.sh                # OpenZIM functionality
│   ├── openstreetmap.sh          # OpenStreetMap functionality
│   ├── ia-software.sh            # Internet Archive software
│   ├── ia-music.sh               # Internet Archive music
│   ├── ia-movies.sh              # Internet Archive movies
│   └── ia-texts.sh               # Internet Archive texts
├── README.md                     # This documentation
└── LICENSE                       # MIT License
```

### Adding New Data Sources
To add a new data source:

1. Create a new script in the `scripts/` directory (e.g., `scripts/new-source.sh`)
2. Follow the existing script pattern:
   - Source `scripts/common.sh` for utilities
   - Use the logging functions (`log_info`, `log_success`, `log_warning`, `log_error`)
   - Validate the drive path using `validate_drive_path`
   - Create comprehensive README files for the collection
3. Add the new source to the main `emergency_storage.sh` script
4. Update this README with information about the new source
5. Test thoroughly before submitting a pull request

### Code Style Guidelines
- Use `#!/bin/bash` shebang
- Include `set -e` for error handling
- Source `scripts/common.sh` for utilities
- Use consistent logging with color-coded output
- Validate inputs and provide helpful error messages
- Create informative README files for each collection
- Add comprehensive comments explaining complex logic

## Error Handling and Logging

The refactored scripts include comprehensive error handling and professional logging:

### Logging Features
- **Color-coded output**: Different colors for info, success, warning, and error messages
- **Consistent formatting**: All scripts use the same logging system from `scripts/common.sh`
- **Progress reporting**: Clear indication of what each script is doing
- **Error reporting**: Detailed error messages with suggestions for resolution

### Error Handling
- **Individual script failures**: Main script continues with other sources if one fails
- **Network connectivity**: Graceful handling of internet connection issues
- **Missing dependencies**: Clear messages about required tools
- **Invalid paths**: Validation and creation of target directories
- **Insufficient permissions**: Permission checks before attempting operations
- **Mirror fallback**: Automatic fallback to alternative mirrors for Kiwix

### Script Architecture Benefits
- **Modularity**: Each script handles one specific data source
- **Maintainability**: Easy to update individual components
- **Testability**: Scripts can be tested independently
- **Reusability**: Individual scripts can be used in other projects
- **Professional structure**: Clean code organization with proper documentation

## License

MIT License - see LICENSE file for details.
