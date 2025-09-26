#!/bin/bash

# OpenStreetMap Download Script
# Part of EmergencyStorage - Downloads OpenStreetMap planet data
# 
# Usage: ./openstreetmap.sh <drive_path>
# 
# Arguments:
#   drive_path - Target directory for OpenStreetMap data

set -e  # Exit on any error

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source common utilities
# shellcheck source=common.sh
source "$SCRIPT_DIR/common.sh"

# Main function to download OpenStreetMap data
download_openstreetmap() {
    local drive_path="$1"
    local osm_path="$drive_path/openstreetmap"
    
    log_info "Starting OpenStreetMap download..."
    log_info "Target directory: $osm_path"
    
    # Validate drive path
    if ! validate_drive_path "$drive_path"; then
        return 1
    fi
    
    # Create openstreetmap directory
    mkdir -p "$osm_path"
    
    # Check if curl is available
    if ! check_command "curl" "curl"; then
        return 1
    fi
    
    # Change to the target directory
    if ! safe_cd "$osm_path"; then
        return 1
    fi
    
    log_info "Downloading OpenStreetMap planet file (this may take a very long time)..."
    log_info "Source: https://planet.openstreetmap.org/pbf/planet-latest.osm.pbf"
    log_info "Expected size: ~70GB+ (compressed PBF format)"
    
    # Test connectivity to OpenStreetMap server
    if ! check_internet "https://planet.openstreetmap.org/pbf/planet-latest.osm.pbf" 30; then
        log_error "Cannot connect to OpenStreetMap server"
        log_error "Please check your internet connection and try again later"
        return 1
    fi
    
    # Download the planet file with resume support
    if curl -C - -L -o planet-latest.osm.pbf https://planet.openstreetmap.org/pbf/planet-latest.osm.pbf; then
        log_success "OpenStreetMap download completed successfully!"
        
        # Create a README file with information about the download
        create_collection_readme "OpenStreetMap" \
            "This directory contains OpenStreetMap planet data in PBF (Protocol Buffer Format) format." \
            "- Complete planet data snapshot
- Compressed binary format (PBF)
- Contains all geographical features
- Updated regularly (usually weekly)" \
            "~70GB+ compressed (varies by date)" \
            "The PBF format is a highly compressed binary format for OpenStreetMap data.
This file contains the complete OpenStreetMap database snapshot.

Tools for working with PBF files:
- osmosis: Command-line tool for processing OSM data
- osm2pgsql: Import tool for PostgreSQL/PostGIS
- JOSM: Java OpenStreetMap Editor
- QGIS: Geographic Information System

For more information, visit: https://planet.openstreetmap.org/"
        
        # Display file information
        if command -v ls &> /dev/null; then
            log_info "Download information:"
            ls -lh planet-latest.osm.pbf
        fi
        
        return 0
    else
        log_error "OpenStreetMap download failed"
        log_info "The download can be resumed by running this script again"
        return 1
    fi
}

# Main execution
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    # Script is being executed directly
    if [ $# -lt 1 ]; then
        log_error "Usage: $0 <drive_path>"
        log_info "Example: $0 /mnt/external_drive"
        exit 1
    fi
    
    download_openstreetmap "$@"
fi