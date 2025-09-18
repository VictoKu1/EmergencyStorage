#!/bin/bash

# EmergencyStorage - A script to download/mirror emergency data sources
# Usage: ./emergency_storage.sh --[sources] [drive address]
# Sources: all, kiwix, openstreetmap

set -e  # Exit on any error

# Function to display usage information
show_usage() {
    echo "Usage: $0 --[sources] [drive_address]"
    echo ""
    echo "Sources:"
    echo "  --all            Download from all sources"
    echo "  --kiwix          Download Kiwix mirror"
    echo "  --openstreetmap  Download OpenStreetMap data"
    echo ""
    echo "Examples:"
    echo "  $0 --kiwix /mnt/external_drive"
    echo "  $0 --openstreetmap /mnt/external_drive"
    echo "  $0 --all /mnt/external_drive"
    echo ""
}

# Function to validate drive path
validate_drive_path() {
    local drive_path="$1"
    
    if [ -z "$drive_path" ]; then
        echo "Error: Drive address is required"
        show_usage
        exit 1
    fi
    
    # Create directory if it doesn't exist
    if [ ! -d "$drive_path" ]; then
        echo "Creating directory: $drive_path"
        mkdir -p "$drive_path" || {
            echo "Error: Cannot create directory $drive_path"
            exit 1
        }
    fi
    
    # Check if directory is writable
    if [ ! -w "$drive_path" ]; then
        echo "Error: Directory $drive_path is not writable"
        exit 1
    fi
}

# Function to download Kiwix mirror
download_kiwix() {
    local drive_path="$1"
    local kiwix_path="$drive_path/kiwix-mirror"
    
    echo "Starting Kiwix mirror download..."
    echo "Target directory: $kiwix_path"
    
    # Create kiwix mirror directory
    mkdir -p "$kiwix_path"
    
    # Check if rsync is available
    if ! command -v rsync &> /dev/null; then
        echo "Error: rsync is required but not installed"
        echo "Please install rsync: sudo apt-get install rsync"
        exit 1
    fi
    
    echo "Downloading Kiwix mirror (this may take a long time)..."
    rsync -vzrlptD --delete --info=progress2 master.download.kiwix.org::download.kiwix.org/ "$kiwix_path/"
    
    echo "Kiwix mirror download completed successfully!"
}

# Function to download OpenStreetMap data
download_openstreetmap() {
    local drive_path="$1"
    local osm_path="$drive_path/openstreetmap"
    
    echo "Starting OpenStreetMap download..."
    echo "Target directory: $osm_path"
    
    # Create openstreetmap directory
    mkdir -p "$osm_path"
    
    # Check if curl is available
    if ! command -v curl &> /dev/null; then
        echo "Error: curl is required but not installed"
        echo "Please install curl: sudo apt-get install curl"
        exit 1
    fi
    
    # Change to the target directory
    cd "$osm_path"
    
    echo "Downloading OpenStreetMap planet file (this may take a very long time)..."
    curl -OL https://planet.openstreetmap.org/pbf/planet-latest.osm.pbf
    
    echo "OpenStreetMap download completed successfully!"
}

# Function to download all sources
download_all() {
    local drive_path="$1"
    
    echo "Downloading from all sources..."
    download_kiwix "$drive_path"
    download_openstreetmap "$drive_path"
    echo "All downloads completed successfully!"
}

# Main script logic
main() {
    # Check if no arguments provided
    if [ $# -eq 0 ]; then
        echo "Error: No arguments provided"
        show_usage
        exit 1
    fi
    
    # Parse command line arguments
    case "$1" in
        --kiwix)
            if [ $# -ne 2 ]; then
                echo "Error: Drive address is required for --kiwix option"
                show_usage
                exit 1
            fi
            validate_drive_path "$2"
            download_kiwix "$2"
            ;;
        --openstreetmap)
            if [ $# -ne 2 ]; then
                echo "Error: Drive address is required for --openstreetmap option"
                show_usage
                exit 1
            fi
            validate_drive_path "$2"
            download_openstreetmap "$2"
            ;;
        --all)
            if [ $# -ne 2 ]; then
                echo "Error: Drive address is required for --all option"
                show_usage
                exit 1
            fi
            validate_drive_path "$2"
            download_all "$2"
            ;;
        --help|-h)
            show_usage
            exit 0
            ;;
        *)
            echo "Error: Unknown option $1"
            show_usage
            exit 1
            ;;
    esac
}

# Run main function with all arguments
main "$@"