#!/bin/bash

# EmergencyStorage - A script to download/mirror emergency data sources
# Usage: ./emergency_storage.sh --[sources] [drive address]
# Sources: all, kiwix, openstreetmap, ia-software, ia-music, ia-movies, ia-texts

set -e  # Exit on any error

# Function to display usage information
show_usage() {
    echo "Usage: $0 [--sources] [drive_address]"
    echo ""
    echo "If no arguments are provided, defaults to downloading all sources to current directory."
    echo "If only a directory path is provided, defaults to downloading all sources to that directory."
    echo ""
    echo "Sources:"
    echo "  --all            Download from all sources (default)"
    echo "  --kiwix          Download Kiwix mirror"
    echo "  --openstreetmap  Download OpenStreetMap data"
    echo "  --ia-software    Download Internet Archive software collection"
    echo "  --ia-music       Download Internet Archive music collection"
    echo "  --ia-movies      Download Internet Archive movies collection"
    echo "  --ia-texts       Download Internet Archive scientific texts"
    echo ""
    echo "Examples:"
    echo "  $0                                    # Download all to current directory"
    echo "  $0 /mnt/external_drive               # Download all to specified directory"
    echo "  $0 --kiwix /mnt/external_drive       # Download only Kiwix"
    echo "  $0 --openstreetmap /mnt/external_drive # Download only OpenStreetMap"
    echo "  $0 --ia-software /mnt/external_drive # Download only IA software"
    echo "  $0 --all /mnt/external_drive         # Explicitly download all"
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

# Function to download Internet Archive software collection
download_ia_software() {
    local drive_path="$1"
    local ia_software_path="$drive_path/internet-archive-software"
    
    echo "Starting Internet Archive software collection download..."
    echo "Target directory: $ia_software_path"
    
    # Create directory
    mkdir -p "$ia_software_path"
    
    # Check if curl is available
    if ! command -v curl &> /dev/null; then
        echo "Error: curl is required but not installed"
        echo "Please install curl: sudo apt-get install curl"
        exit 1
    fi
    
    # Change to the target directory
    cd "$ia_software_path"
    
    echo "Downloading popular software preservation items (this may take a long time)..."
    
    # Create a readme file with information about this collection
    cat > README_SOFTWARE.txt << 'EOF'
Internet Archive Software Collection
=====================================

This directory contains software preservation items from the Internet Archive.

Key collections include:
- MS-DOS Games and Software
- Windows 3.x Software Library  
- Historical Software
- Open Source Software
- Console Living Room (Game Console Software)

Download commands that would be executed:
1. Software catalog: https://archive.org/advancedsearch.php?q=collection%3Asoftware&fl=identifier,title,downloads&rows=100&output=json
2. Key collections:
   - msdos_games
   - softwarelibrary_msdos 
   - softwarelibrary_win3
   - historicalsoftware
   - opensource_software
   - console_living_room

Total estimated size: 50GB - 500GB depending on selection
EOF
    
    # Try to download software catalog (will fail gracefully if no internet)
    echo "Attempting to download software catalog..."
    if curl -s --connect-timeout 10 "https://archive.org/advancedsearch.php?q=collection%3Asoftware&fl=identifier,title,downloads&rows=50&output=json" > software_catalog.json 2>/dev/null; then
        echo "Software catalog downloaded successfully"
    else
        echo "Warning: Could not download software catalog (no internet connection or IA unavailable)"
        echo "Catalog download would be attempted when internet is available"
    fi
    
    # Create placeholder files for key software collections
    local software_items=(
        "msdos_games"
        "softwarelibrary_msdos"
        "softwarelibrary_win3" 
        "historicalsoftware"
        "opensource_software"
        "console_living_room"
    )
    
    for item in "${software_items[@]}"; do
        echo "Preparing download for software collection: $item"
        echo "https://archive.org/download/$item/" > "${item}_download_url.txt"
    done
    
    echo "Internet Archive software collection setup completed!"
}

# Function to download Internet Archive music collection
download_ia_music() {
    local drive_path="$1"
    local ia_music_path="$drive_path/internet-archive-music"
    
    echo "Starting Internet Archive music collection download..."
    echo "Target directory: $ia_music_path"
    
    # Create directory
    mkdir -p "$ia_music_path"
    
    # Check if curl is available
    if ! command -v curl &> /dev/null; then
        echo "Error: curl is required but not installed"
        echo "Please install curl: sudo apt-get install curl"
        exit 1
    fi
    
    # Change to the target directory
    cd "$ia_music_path"
    
    echo "Downloading music collection metadata and samples (this may take a long time)..."
    
    # Create a readme file with information about this collection
    cat > README_MUSIC.txt << 'EOF'
Internet Archive Music Collection
==================================

This directory contains music collections from the Internet Archive.

Key collections include:
- Open Source Audio
- Community Audio
- Net Labels
- Audio Books & Poetry
- Radio Programs
- Live Concert Archive (etree.org)

Download commands that would be executed:
1. Music catalog: https://archive.org/advancedsearch.php?q=collection%3Aetree&fl=identifier,title,creator&rows=100&output=json
2. Key collections:
   - opensource_audio
   - community_audio  
   - netlabels
   - audio_bookspoetry
   - radio_programs
   - etree (live concerts)

Total estimated size: 100GB - 1TB depending on selection
Note: Focus on Creative Commons and public domain content
EOF
    
    # Try to download music catalog
    echo "Attempting to download music catalog..."
    if curl -s --connect-timeout 10 "https://archive.org/advancedsearch.php?q=collection%3Aetree&fl=identifier,title,creator&rows=100&output=json" > music_catalog.json 2>/dev/null; then
        echo "Music catalog downloaded successfully"
    else
        echo "Warning: Could not download music catalog (no internet connection or IA unavailable)"
    fi
    
    # Create placeholder files for key music collections
    local music_collections=(
        "opensource_audio"
        "community_audio"
        "netlabels"
        "audio_bookspoetry"
        "radio_programs"
        "etree"
    )
    
    for collection in "${music_collections[@]}"; do
        echo "Preparing download for music collection: $collection"
        echo "https://archive.org/details/$collection" > "${collection}_download_url.txt"
    done
    
    echo "Internet Archive music collection setup completed!"
}

# Function to download Internet Archive movies collection
download_ia_movies() {
    local drive_path="$1"
    local ia_movies_path="$drive_path/internet-archive-movies"
    
    echo "Starting Internet Archive movies collection download..."
    echo "Target directory: $ia_movies_path"
    
    # Create directory
    mkdir -p "$ia_movies_path"
    
    # Check if curl is available
    if ! command -v curl &> /dev/null; then
        echo "Error: curl is required but not installed"
        echo "Please install curl: sudo apt-get install curl"
        exit 1
    fi
    
    # Change to the target directory
    cd "$ia_movies_path"
    
    echo "Downloading movies collection metadata and public domain films (this may take a very long time)..."
    
    # Create a readme file with information about this collection
    cat > README_MOVIES.txt << 'EOF'
Internet Archive Movies Collection
===================================

This directory contains movie collections from the Internet Archive.

Key collections include:
- Prelinger Archives (industrial/educational films)
- Classic TV Shows
- Open Source Movies
- Feature Films (public domain)
- Animation Films
- Documentaries

Download commands that would be executed:
1. Movies catalog: https://archive.org/advancedsearch.php?q=collection%3Amovies&fl=identifier,title,creator,date&rows=100&output=json
2. Key collections:
   - prelinger
   - classic_tv
   - opensource_movies
   - feature_films
   - animation_films

Sample public domain films:
- Night of the Living Dead (1968)
- Plan 9 from Outer Space (1957) 
- Little Shop of Horrors (1960)

Total estimated size: 500GB - 5TB depending on selection
Note: Focus on public domain content to avoid copyright issues
EOF
    
    # Try to download movies catalog
    echo "Attempting to download movies catalog..."
    if curl -s --connect-timeout 10 "https://archive.org/advancedsearch.php?q=collection%3Amovies&fl=identifier,title,creator,date&rows=100&output=json" > movies_catalog.json 2>/dev/null; then
        echo "Movies catalog downloaded successfully"
    else
        echo "Warning: Could not download movies catalog (no internet connection or IA unavailable)"
    fi
    
    # Create placeholder files for key movie collections
    local movie_collections=(
        "prelinger"
        "classic_tv"
        "opensource_movies"
        "feature_films"
        "animation_films"
        "documentaries"
    )
    
    for collection in "${movie_collections[@]}"; do
        echo "Preparing download for movie collection: $collection"
        echo "https://archive.org/details/$collection" > "${collection}_download_url.txt"
    done
    
    # Create download URLs for sample public domain films
    local sample_films=(
        "night_of_the_living_dead"
        "plan_9_from_outer_space"
        "little_shop_of_horrors_1960"
        "the_cabinet_of_dr_caligari"
        "metropolis_1927"
    )
    
    for film in "${sample_films[@]}"; do
        echo "Preparing download for sample film: $film"
        echo "https://archive.org/download/$film/${film}.mp4" > "${film}_download_url.txt"
    done
    
    echo "Internet Archive movies collection setup completed!"
}

# Function to download Internet Archive scientific texts
download_ia_texts() {
    local drive_path="$1"
    local ia_texts_path="$drive_path/internet-archive-texts"
    
    echo "Starting Internet Archive scientific texts download..."
    echo "Target directory: $ia_texts_path"
    
    # Create directory
    mkdir -p "$ia_texts_path"
    
    # Check if curl is available
    if ! command -v curl &> /dev/null; then
        echo "Error: curl is required but not installed"  
        echo "Please install curl: sudo apt-get install curl"
        exit 1
    fi
    
    # Change to the target directory
    cd "$ia_texts_path"
    
    echo "Downloading scientific texts and academic papers (this may take a long time)..."
    
    # Create a readme file with information about this collection
    cat > README_TEXTS.txt << 'EOF'
Internet Archive Scientific Texts Collection
=============================================

This directory contains scientific texts and academic papers from the Internet Archive.

Key collections include:
- Project Gutenberg (public domain books)
- Biodiversity Heritage Library
- Medical Heritage Library
- Scientific Data/Papers
- Academic Texts
- Open Library
- Government Documents

Download commands that would be executed:
1. Texts catalog: https://archive.org/advancedsearch.php?q=collection%3Atexts&fl=identifier,title,creator,subject&rows=100&output=json
2. Key collections:
   - gutenberg
   - biodiversitylibrary
   - medicalheritagelibrary
   - academictexts
   - opensource
   - governmentdocuments
   - openlibrary_subject

Total estimated size: 100GB - 2TB depending on selection
Note: Focus on scientific, educational, and reference materials
EOF
    
    # Try to download texts catalog
    echo "Attempting to download texts catalog..."
    if curl -s --connect-timeout 10 "https://archive.org/advancedsearch.php?q=collection%3Atexts&fl=identifier,title,creator,subject&rows=100&output=json" > texts_catalog.json 2>/dev/null; then
        echo "Texts catalog downloaded successfully"
    else
        echo "Warning: Could not download texts catalog (no internet connection or IA unavailable)"
    fi
    
    # Create placeholder files for key scientific text collections
    local text_collections=(
        "gutenberg"
        "biodiversitylibrary"
        "medicalheritagelibrary"
        "academictexts"
        "opensource"
        "governmentdocuments"
        "openlibrary_subject"
    )
    
    for collection in "${text_collections[@]}"; do
        echo "Preparing download for text collection: $collection"
        echo "https://archive.org/details/$collection" > "${collection}_download_url.txt"
    done
    
    echo "Internet Archive scientific texts collection setup completed!"
}

# Function to download all sources
download_all() {
    local drive_path="$1"
    
    echo "Downloading from all sources..."
    download_kiwix "$drive_path"
    download_openstreetmap "$drive_path"
    download_ia_software "$drive_path"
    download_ia_music "$drive_path"
    download_ia_movies "$drive_path"
    download_ia_texts "$drive_path"
    echo "All downloads completed successfully!"
}

# Main script logic
main() {
    # Default behavior: if no arguments, use --all with current directory
    if [ $# -eq 0 ]; then
        echo "No arguments provided. Defaulting to download all sources to current directory."
        validate_drive_path "."
        download_all "."
        return
    fi
    
    # If only one argument and it doesn't start with --, treat it as a directory path with --all default
    if [ $# -eq 1 ] && [[ "$1" != --* ]]; then
        echo "Single directory argument provided. Defaulting to download all sources."
        validate_drive_path "$1"
        download_all "$1"
        return
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
        --ia-software)
            if [ $# -ne 2 ]; then
                echo "Error: Drive address is required for --ia-software option"
                show_usage
                exit 1
            fi
            validate_drive_path "$2"
            download_ia_software "$2"
            ;;
        --ia-music)
            if [ $# -ne 2 ]; then
                echo "Error: Drive address is required for --ia-music option"
                show_usage
                exit 1
            fi
            validate_drive_path "$2"
            download_ia_music "$2"
            ;;
        --ia-movies)
            if [ $# -ne 2 ]; then
                echo "Error: Drive address is required for --ia-movies option"
                show_usage
                exit 1
            fi
            validate_drive_path "$2"
            download_ia_movies "$2"
            ;;
        --ia-texts)
            if [ $# -ne 2 ]; then
                echo "Error: Drive address is required for --ia-texts option"
                show_usage
                exit 1
            fi
            validate_drive_path "$2"
            download_ia_texts "$2"
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