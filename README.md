# EmergencyStorage

A project designed to run on Raspberry Pi (or Linux) with a connected HDD, providing a script that downloads/mirrors emergency data from multiple sources.

## Features

- **Kiwix Mirror**: Downloads the complete Kiwix library mirror using rsync
- **OpenStreetMap Data**: Downloads the latest planet OSM data file
- **All Sources**: Downloads from both sources in sequence

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

Run with desired source and target drive:
```bash
./emergency_storage.sh --[sources] [drive_address]
```

### Available Sources

- `--kiwix` - Download Kiwix mirror only
- `--openstreetmap` - Download OpenStreetMap data only  
- `--all` - Download from all sources

### Examples

```bash
# Download Kiwix mirror to external drive
./emergency_storage.sh --kiwix /mnt/external_drive

# Download OpenStreetMap data to external drive
./emergency_storage.sh --openstreetmap /mnt/external_drive

# Download everything to external drive
./emergency_storage.sh --all /mnt/external_drive

# Show help
./emergency_storage.sh --help
```

## Storage Requirements

- **Kiwix Mirror**: Varies (typically several GB to TB depending on content)
- **OpenStreetMap Planet**: ~70GB+ (compressed PBF format)
- **Recommended**: At least 100GB+ free space for comfortable operation

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

## Error Handling

The script includes comprehensive error handling for:
- Missing arguments
- Invalid drive paths
- Missing dependencies
- Network connectivity issues
- Insufficient permissions

## License

MIT License - see LICENSE file for details.