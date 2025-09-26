#!/bin/bash

# OpenZIM Download Script
# Part of EmergencyStorage - Downloads ZIM files containing offline content
# 
# Usage: ./openzim.sh <drive_path>
# 
# Arguments:
#   drive_path - Target directory for OpenZIM files

set -e  # Exit on any error

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source common utilities
# shellcheck source=common.sh
source "$SCRIPT_DIR/common.sh"

# Main function to download OpenZIM files
download_openzim() {
    local drive_path="$1"
    local openzim_path="$drive_path/openzim"
    
    log_info "Starting OpenZIM download..."
    log_info "Target directory: $openzim_path"
    
    # Validate drive path
    if ! validate_drive_path "$drive_path"; then
        return 1
    fi
    
    # Create openzim directory
    mkdir -p "$openzim_path"
    
    # Check if rsync is available
    if ! check_command "rsync" "rsync"; then
        return 1
    fi
    
    log_info "Downloading OpenZIM files (this may take a very long time)..."
    log_info "Syncing from: download.openzim.org::download.openzim.org/"
    
    # Test connectivity to OpenZIM server
    if ! timeout 60 rsync --dry-run -v "download.openzim.org::download.openzim.org/" &>/dev/null; then
        log_error "Cannot connect to OpenZIM rsync server"
        log_error "Please check your internet connection and try again later"
        return 1
    fi
    
    # Perform the actual sync
    if rsync -vzrlptD --delete --info=progress2 download.openzim.org::download.openzim.org/ "$openzim_path/"; then
        log_success "OpenZIM download completed successfully!"
        
        # Create a README file with information about the collection
        safe_cd "$openzim_path"
        create_collection_readme "OpenZIM" \
            "This directory contains ZIM files from OpenZIM, providing offline access to educational content." \
            "- Wikipedia in multiple languages
- Educational materials
- Reference content
- Technical documentation
- Medical and scientific resources" \
            "Several GB to TB (depends on content selected)" \
            "ZIM files are compressed archives that provide offline browsing capabilities.
These files can be opened with Kiwix or other ZIM readers.

For more information about ZIM files, visit: https://wiki.openzim.org/"
        
        return 0
    else
        log_error "OpenZIM download failed"
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
    
    download_openzim "$@"
fi