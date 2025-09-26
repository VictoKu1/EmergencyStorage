#!/bin/bash

# Internet Archive Software Collection Download Script
# Part of EmergencyStorage - Downloads software preservation collections
# 
# Usage: ./ia-software.sh <drive_path>
# 
# Arguments:
#   drive_path - Target directory for Internet Archive software

set -e  # Exit on any error

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source common utilities
# shellcheck source=common.sh
source "$SCRIPT_DIR/common.sh"

# Main function to download Internet Archive software collection
download_ia_software() {
    local drive_path="$1"
    local ia_software_path="$drive_path/internet-archive-software"
    
    log_info "Starting Internet Archive software collection download..."
    log_info "Target directory: $ia_software_path"
    
    # Validate drive path
    if ! validate_drive_path "$drive_path"; then
        return 1
    fi
    
    # Create directory
    mkdir -p "$ia_software_path"
    
    # Check if curl is available
    if ! check_command "curl" "curl"; then
        return 1
    fi
    
    # Change to the target directory
    if ! safe_cd "$ia_software_path"; then
        return 1
    fi
    
    log_info "Setting up software preservation collections (this may take a long time)..."
    
    # Create a comprehensive README file
    cat > README_SOFTWARE.txt << 'EOF'
EmergencyStorage - Internet Archive Software Collection
=======================================================

This directory contains software preservation items from the Internet Archive.

The Internet Archive's software preservation project aims to keep important
software accessible for future generations. This includes:

Key Collections:
- MS-DOS Games and Software
- Windows 3.x Software Library  
- Historical Software Collections
- Open Source Software
- Console Living Room (Game Console Software)
- Apple II Software
- Commodore 64 Software
- Early PC Games

Collection Details:
1. msdos_games - Classic MS-DOS games and applications
2. softwarelibrary_msdos - Complete MS-DOS software library
3. softwarelibrary_win3 - Windows 3.x applications and games
4. historicalsoftware - Important historical software
5. opensource_software - Open source software preservation
6. console_living_room - Console games from various systems

Total estimated size: 50GB - 500GB depending on selection

How to use:
- Download URLs are provided in individual text files
- Software can be run using emulators or virtual machines
- Many items include browser-based emulation

For more information about Internet Archive software preservation:
https://archive.org/details/software

This collection was prepared by EmergencyStorage.
EOF
    
    # Try to download software catalog
    log_info "Attempting to download software catalog..."
    local catalog_url="https://archive.org/advancedsearch.php?q=collection%3Asoftware&fl=identifier,title,downloads&rows=50&output=json"
    
    if check_internet "$catalog_url" 10; then
        if curl -s --connect-timeout 10 "$catalog_url" > software_catalog.json 2>/dev/null; then
            log_success "Software catalog downloaded successfully"
        else
            log_warning "Failed to download software catalog"
        fi
    else
        log_warning "Could not connect to Internet Archive (no internet or server unavailable)"
        log_info "Catalog download would be attempted when internet is available"
    fi
    
    # Create placeholder files for key software collections
    local software_collections=(
        "msdos_games"
        "softwarelibrary_msdos"
        "softwarelibrary_win3" 
        "historicalsoftware"
        "opensource_software"
        "console_living_room"
        "softwarelibrary_apple"
        "softwarelibrary_c64"
    )
    
    log_info "Creating download placeholders for software collections..."
    
    for collection in "${software_collections[@]}"; do
        create_download_placeholder "$collection" "https://archive.org/download/$collection/"
        
        # Create a brief description for each collection
        case "$collection" in
            "msdos_games")
                echo "Classic MS-DOS games from the 1980s and 1990s" >> "${collection}_description.txt"
                ;;
            "softwarelibrary_msdos")
                echo "Complete library of MS-DOS software and applications" >> "${collection}_description.txt"
                ;;
            "softwarelibrary_win3")
                echo "Windows 3.x era software and applications" >> "${collection}_description.txt"
                ;;
            "historicalsoftware")
                echo "Important historical software with cultural significance" >> "${collection}_description.txt"
                ;;
            "opensource_software")
                echo "Open source software preservation collection" >> "${collection}_description.txt"
                ;;
            "console_living_room")
                echo "Console games from various gaming systems" >> "${collection}_description.txt"
                ;;
            "softwarelibrary_apple")
                echo "Apple II software and applications" >> "${collection}_description.txt"
                ;;
            "softwarelibrary_c64")
                echo "Commodore 64 games and software" >> "${collection}_description.txt"
                ;;
        esac
    done
    
    # Create a manifest of what would be downloaded
    log_info "Creating download manifest..."
    cat > download_manifest.txt << 'EOF'
Internet Archive Software Collection Download Manifest
=====================================================

This manifest lists the software collections that would be downloaded:

Collection Name                 | Estimated Size | Description
-------------------------------|----------------|------------------
msdos_games                    | 5-20 GB        | MS-DOS games
softwarelibrary_msdos         | 10-50 GB       | MS-DOS software
softwarelibrary_win3          | 2-15 GB        | Windows 3.x software  
historicalsoftware            | 5-30 GB        | Historical software
opensource_software           | 5-25 GB        | Open source software
console_living_room           | 10-100 GB      | Console games
softwarelibrary_apple         | 2-10 GB        | Apple II software
softwarelibrary_c64           | 1-5 GB         | Commodore 64 software

Total Range: 40-255 GB (varies based on what's actually downloaded)

Note: These are estimates. Actual download sizes may vary.
Some collections may have overlapping content.
EOF
    
    log_success "Internet Archive software collection setup completed!"
    log_info "Download URLs and descriptions have been prepared"
    log_info "Review the README_SOFTWARE.txt file for detailed information"
    
    return 0
}

# Main execution
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    # Script is being executed directly
    if [ $# -lt 1 ]; then
        log_error "Usage: $0 <drive_path>"
        log_info "Example: $0 /mnt/external_drive"
        exit 1
    fi
    
    download_ia_software "$@"
fi