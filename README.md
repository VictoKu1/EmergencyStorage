# EmergencyStorage

A project designed to run on Raspberry Pi (or Linux) with a connected HDD, providing a script that downloads/mirrors emergency data from multiple sources.

## Features

- **Kiwix Mirror**: Downloads the complete Kiwix library mirror using rsync
- **OpenStreetMap Data**: Downloads the latest planet OSM data file
- **Internet Archive Software**: Downloads software preservation collections (games, applications, historical software)
- **Internet Archive Music**: Downloads music collections (Creative Commons, public domain, live concerts)
- **Internet Archive Movies**: Downloads movie collections (public domain films, documentaries, educational content)
- **Internet Archive Texts**: Downloads scientific texts and academic papers (books, research papers, government documents)
- **All Sources**: Downloads from all sources in sequence

## Prerequisites

- Linux system (tested on Raspberry Pi)
- Connected external drive with sufficient storage space
- Required tools:
  - `rsync` (for Kiwix mirror)
  - `curl` (for OpenStreetMap download)

Install dependencies on Debian/Ubuntu:
```bash
sudo apt-get update
sudo apt-get install rsync curl
```

## Usage

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

- **Kiwix Mirror**: Varies (typically several GB to TB depending on content)
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
- Project Gutenberg (public domain books)
- Biodiversity Heritage Library
- Medical Heritage Library
- Scientific Papers and Academic Texts
- Government Documents

## Error Handling

The script includes comprehensive error handling for:
- Missing arguments
- Invalid drive paths
- Missing dependencies
- Network connectivity issues
- Insufficient permissions

## License

MIT License - see LICENSE file for details.