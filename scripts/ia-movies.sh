#!/bin/bash

# Internet Archive Movies Collection Download Script
# Part of EmergencyStorage - Downloads movie preservation collections
# 
# Usage: ./ia-movies.sh <drive_path>
# 
# Arguments:
#   drive_path - Target directory for Internet Archive movies

set -e  # Exit on any error

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source common utilities
# shellcheck source=common.sh
source "$SCRIPT_DIR/common.sh"

# Main function to download Internet Archive movies collection
download_ia_movies() {
    local drive_path="$1"
    local ia_movies_path="$drive_path/internet-archive-movies"
    
    log_info "Starting Internet Archive movies collection download..."
    log_info "Target directory: $ia_movies_path"
    
    # Validate drive path
    if ! validate_drive_path "$drive_path"; then
        return 1
    fi
    
    # Create directory
    mkdir -p "$ia_movies_path"
    
    # Check if curl is available
    if ! check_command "curl" "curl"; then
        return 1
    fi
    
    # Change to the target directory
    if ! safe_cd "$ia_movies_path"; then
        return 1
    fi
    
    log_info "Setting up movies collection metadata and public domain films..."
    
    # Create a comprehensive README file
    cat > README_MOVIES.txt << 'EOF'
EmergencyStorage - Internet Archive Movies Collection
=====================================================

This directory contains movie collections from the Internet Archive.

The Internet Archive's movie collection includes thousands of films,
with a focus on public domain content to ensure legal compliance.

Key Collections:
- Prelinger Archives - Industrial, educational, and ephemeral films
- Classic TV Shows - Public domain television programs
- Open Source Movies - Films distributed under open licenses
- Feature Films - Public domain feature-length films
- Animation Films - Classic animated content
- Documentaries - Educational and historical documentaries
- Silent Films - Early cinema from the silent era

Legal Compliance:
This collection focuses on PUBLIC DOMAIN content to avoid copyright issues.
All listed films have entered the public domain or are freely distributable.

Collection Details:
1. prelinger - Industrial and educational films (Prelinger Archives)
2. classic_tv - Public domain television shows
3. opensource_movies - Films with open distribution rights
4. feature_films - Public domain feature films
5. animation_films - Classic animation in public domain
6. documentaries - Educational and historical documentaries
7. silent_films - Silent era films
8. educational_films - Instructional and training films

Notable Public Domain Films Available:
- Night of the Living Dead (1968)
- Plan 9 from Outer Space (1957)
- Little Shop of Horrors (1960)
- The Cabinet of Dr. Caligari (1920)
- Metropolis (1927) - certain versions
- Nosferatu (1922)
- Charade (1963)
- His Girl Friday (1940)

Video Formats Available:
- MP4 (most common)
- AVI
- MPEG
- Various historical formats

Total estimated size: 500GB - 5TB depending on selection

Copyright Notice:
All content listed focuses on public domain works. Users should verify
the copyright status of any content before downloading or redistributing.

For more information about Internet Archive movies:
https://archive.org/details/movies

This collection was prepared by EmergencyStorage.
EOF
    
    # Try to download movies catalog
    log_info "Attempting to download movies catalog..."
    local catalog_url="https://archive.org/advancedsearch.php?q=collection%3Amovies&fl=identifier,title,creator,date&rows=100&output=json"
    
    if check_internet "$catalog_url" 10; then
        if curl -s --connect-timeout 10 "$catalog_url" > movies_catalog.json 2>/dev/null; then
            log_success "Movies catalog downloaded successfully"
        else
            log_warning "Failed to download movies catalog"
        fi
    else
        log_warning "Could not connect to Internet Archive (no internet or server unavailable)"
        log_info "Catalog download would be attempted when internet is available"
    fi
    
    # Create placeholder files for key movie collections (focusing on public domain)
    local movie_collections=(
        "prelinger"
        "classic_tv"
        "opensource_movies"
        "feature_films"
        "animation_films"
        "documentaries"
        "silent_films"
        "educational_films"
    )
    
    log_info "Creating download placeholders for movie collections..."
    
    for collection in "${movie_collections[@]}"; do
        create_download_placeholder "$collection" "https://archive.org/details/$collection"
        
        # Create a brief description for each collection
        case "$collection" in
            "prelinger")
                echo "Industrial, educational, and ephemeral films from Prelinger Archives" >> "${collection}_description.txt"
                ;;
            "classic_tv")
                echo "Public domain television shows and classic TV programming" >> "${collection}_description.txt"
                ;;
            "opensource_movies")
                echo "Films distributed under open licenses and Creative Commons" >> "${collection}_description.txt"
                ;;
            "feature_films")
                echo "Public domain feature-length films and cinema classics" >> "${collection}_description.txt"
                ;;
            "animation_films")
                echo "Classic animated films and cartoons in the public domain" >> "${collection}_description.txt"
                ;;
            "documentaries")
                echo "Educational and historical documentaries" >> "${collection}_description.txt"
                ;;
            "silent_films")
                echo "Silent era films and early cinema" >> "${collection}_description.txt"
                ;;
            "educational_films")
                echo "Instructional and training films for educational use" >> "${collection}_description.txt"
                ;;
        esac
    done
    
    # Create download URLs for notable public domain films
    log_info "Creating placeholders for notable public domain films..."
    local sample_films=(
        "night_of_the_living_dead"
        "plan_9_from_outer_space"
        "little_shop_of_horrors_1960"
        "the_cabinet_of_dr_caligari"
        "metropolis_1927"
        "nosferatu_1922"
        "charade_1963"
        "his_girl_friday"
    )
    
    for film in "${sample_films[@]}"; do
        create_download_placeholder "$film" "https://archive.org/download/$film/${film}.mp4"
        
        # Add film information
        case "$film" in
            "night_of_the_living_dead")
                echo "Classic 1968 zombie horror film by George A. Romero (Public Domain)" >> "${film}_info.txt"
                ;;
            "plan_9_from_outer_space")
                echo "1957 science fiction film by Ed Wood, famous B-movie (Public Domain)" >> "${film}_info.txt"
                ;;
            "little_shop_of_horrors_1960")
                echo "1960 comedy horror film, original version (Public Domain)" >> "${film}_info.txt"
                ;;
            "the_cabinet_of_dr_caligari")
                echo "1920 German silent horror film, classic expressionist cinema" >> "${film}_info.txt"
                ;;
            "metropolis_1927")
                echo "1927 German expressionist science-fiction film by Fritz Lang" >> "${film}_info.txt"
                ;;
            "nosferatu_1922")
                echo "1922 German silent horror film, classic vampire movie" >> "${film}_info.txt"
                ;;
            "charade_1963")
                echo "1963 romantic comedy thriller starring Cary Grant and Audrey Hepburn" >> "${film}_info.txt"
                ;;
            "his_girl_friday")
                echo "1940 screwball comedy directed by Howard Hawks" >> "${film}_info.txt"
                ;;
        esac
    done
    
    # Create a manifest of what would be downloaded
    log_info "Creating download manifest..."
    cat > download_manifest.txt << 'EOF'
Internet Archive Movies Collection Download Manifest
===================================================

This manifest lists the movie collections that would be downloaded:

Collection Name        | Estimated Size | Content Type
-----------------------|----------------|------------------
prelinger             | 50-200 GB      | Industrial/educational films
classic_tv            | 100-500 GB     | Public domain TV shows
opensource_movies     | 20-100 GB      | Open licensed films
feature_films         | 200-1000 GB    | Public domain features
animation_films       | 30-150 GB      | Classic animation
documentaries         | 50-300 GB      | Educational documentaries
silent_films          | 30-200 GB      | Silent era cinema
educational_films     | 40-200 GB      | Training/instructional

Notable Individual Films:
night_of_the_living_dead    | ~700 MB    | 1968 horror classic
plan_9_from_outer_space     | ~500 MB    | 1957 sci-fi B-movie
little_shop_of_horrors_1960 | ~600 MB    | 1960 comedy horror
the_cabinet_of_dr_caligari  | ~400 MB    | 1920 silent horror
metropolis_1927             | ~800 MB    | 1927 sci-fi classic
nosferatu_1922              | ~500 MB    | 1922 vampire classic
charade_1963                | ~1.2 GB    | 1963 romantic thriller
his_girl_friday             | ~900 MB    | 1940 screwball comedy

Total Range: 520-2650 GB (varies greatly based on selection)

Legal Status: PUBLIC DOMAIN FOCUS
All listed content is either in the public domain or freely distributable.
Users should still verify copyright status before distribution.

Video Quality Notes:
- Older films may have varying quality due to source material
- Multiple formats often available (MP4, AVI, MPEG)
- Some films available in different resolutions
EOF
    
    log_success "Internet Archive movies collection setup completed!"
    log_info "Download URLs and descriptions have been prepared"
    log_info "Review the README_MOVIES.txt file for detailed information"
    log_info "All content focuses on public domain films for legal compliance"
    
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
    
    download_ia_movies "$@"
fi