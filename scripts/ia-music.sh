#!/bin/bash

# Internet Archive Music Collection Download Script
# Part of EmergencyStorage - Downloads music preservation collections
# 
# Usage: ./ia-music.sh <drive_path>
# 
# Arguments:
#   drive_path - Target directory for Internet Archive music

set -e  # Exit on any error

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source common utilities
# shellcheck source=common.sh
source "$SCRIPT_DIR/common.sh"

# Main function to download Internet Archive music collection
download_ia_music() {
    local drive_path="$1"
    local ia_music_path="$drive_path/internet-archive-music"
    
    log_info "Starting Internet Archive music collection download..."
    log_info "Target directory: $ia_music_path"
    
    # Validate drive path
    if ! validate_drive_path "$drive_path"; then
        return 1
    fi
    
    # Create directory
    mkdir -p "$ia_music_path"
    
    # Check if curl is available
    if ! check_command "curl" "curl"; then
        return 1
    fi
    
    # Change to the target directory
    if ! safe_cd "$ia_music_path"; then
        return 1
    fi
    
    log_info "Setting up music collection metadata and samples (this may take a long time)..."
    
    # Create a comprehensive README file
    cat > README_MUSIC.txt << 'EOF'
EmergencyStorage - Internet Archive Music Collection
====================================================

This directory contains music collections from the Internet Archive.

The Internet Archive hosts a vast collection of music, including:
- Creative Commons licensed music
- Public domain recordings  
- Live concert archives
- Community contributions
- Educational audio content

Key Collections:
- Open Source Audio - Creative Commons and open licensed music
- Community Audio - User-contributed audio content
- Net Labels - Digital record labels offering free music
- Audio Books & Poetry - Spoken word and literary recordings
- Radio Programs - Historical radio broadcasts
- Live Concert Archive (etree.org) - Live concert recordings

Legal Note:
Focus is on Creative Commons, public domain, and freely distributable content
to ensure compliance with copyright laws.

Collection Details:
1. opensource_audio - Creative Commons and open source music
2. community_audio - Community contributed audio content
3. netlabels - Digital music labels with free distribution
4. audio_bookspoetry - Audiobooks and poetry readings
5. radio_programs - Historical and educational radio content
6. etree - Live concert recordings (with artist permission)

Total estimated size: 100GB - 1TB depending on selection

Audio Formats:
- MP3 (most common)
- FLAC (lossless)
- OGG Vorbis
- Various historical formats

For more information about Internet Archive audio:
https://archive.org/details/audio

This collection was prepared by EmergencyStorage.
EOF
    
    # Try to download music catalog
    log_info "Attempting to download music catalog..."
    local catalog_url="https://archive.org/advancedsearch.php?q=collection%3Aetree&fl=identifier,title,creator&rows=100&output=json"
    
    if check_internet "$catalog_url" 10; then
        if curl -s --connect-timeout 10 "$catalog_url" > music_catalog.json 2>/dev/null; then
            log_success "Music catalog downloaded successfully"
        else
            log_warning "Failed to download music catalog"
        fi
    else
        log_warning "Could not connect to Internet Archive (no internet or server unavailable)"
        log_info "Catalog download would be attempted when internet is available"
    fi
    
    # Create placeholder files for key music collections
    local music_collections=(
        "opensource_audio"
        "community_audio"
        "netlabels"
        "audio_bookspoetry"
        "radio_programs"
        "etree"
        "librivox"
        "podcast"
    )
    
    log_info "Creating download placeholders for music collections..."
    
    for collection in "${music_collections[@]}"; do
        create_download_placeholder "$collection" "https://archive.org/details/$collection"
        
        # Create a brief description for each collection
        case "$collection" in
            "opensource_audio")
                echo "Creative Commons and open source licensed music" >> "${collection}_description.txt"
                ;;
            "community_audio")
                echo "Community contributed audio content and recordings" >> "${collection}_description.txt"
                ;;
            "netlabels")
                echo "Digital music labels offering free music distribution" >> "${collection}_description.txt"
                ;;
            "audio_bookspoetry")
                echo "Audiobooks, poetry readings, and spoken word content" >> "${collection}_description.txt"
                ;;
            "radio_programs")
                echo "Historical radio broadcasts and educational programs" >> "${collection}_description.txt"
                ;;
            "etree")
                echo "Live concert recordings with artist permission (etree.org)" >> "${collection}_description.txt"
                ;;
            "librivox")
                echo "Public domain audiobooks read by volunteers" >> "${collection}_description.txt"
                ;;
            "podcast")
                echo "Podcast archives and audio programming" >> "${collection}_description.txt"
                ;;
        esac
    done
    
    # Create a manifest of what would be downloaded
    log_info "Creating download manifest..."
    cat > download_manifest.txt << 'EOF'
Internet Archive Music Collection Download Manifest
==================================================

This manifest lists the music collections that would be downloaded:

Collection Name          | Estimated Size | License/Legal Status
------------------------|----------------|--------------------
opensource_audio        | 20-100 GB      | Creative Commons/Open Source
community_audio         | 30-200 GB      | Various (mostly free to share)
netlabels              | 15-80 GB       | Free distribution labels
audio_bookspoetry      | 10-50 GB       | Mix of public domain and CC
radio_programs         | 20-100 GB      | Historical/educational content
etree                  | 50-500 GB      | Artist-permitted live recordings
librivox               | 5-25 GB        | Public domain audiobooks
podcast                | 10-50 GB       | Various podcast content

Total Range: 160-1105 GB (varies based on selection and filtering)

Legal Compliance Notes:
- Prioritize Creative Commons and public domain content
- Verify licensing before downloading copyrighted material
- etree collection follows taper/artist permission protocols
- Community content should be reviewed for copyright compliance

Audio Quality Information:
- Most content available in multiple formats (MP3, FLAC, OGG)
- Live recordings may vary in quality
- Audiobooks typically in MP3 format
EOF
    
    log_success "Internet Archive music collection setup completed!"
    log_info "Download URLs and descriptions have been prepared"
    log_info "Review the README_MUSIC.txt file for detailed information"
    log_warning "Please ensure compliance with copyright laws when downloading"
    
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
    
    download_ia_music "$@"
fi