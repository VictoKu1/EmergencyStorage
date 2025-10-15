#!/bin/bash

# EmergencyStorage - Main script to download/mirror emergency data sources
# This script coordinates multiple specialized download scripts for different data sources
# 
# Usage: ./emergency_storage.sh [--sources] [--allow_download_from_mirror] [drive_address]
# Sources: all, kiwix, openzim, openstreetmap, ia-software, ia-music, ia-movies, ia-texts, manual-sources, git, models

set -e  # Exit on any error

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source common utilities
# shellcheck source=scripts/common.sh
source "$SCRIPT_DIR/scripts/common.sh"

# Function to display usage information
show_usage() {
    echo -e "${COLOR_BLUE}EmergencyStorage - Emergency Data Sources Downloader${COLOR_RESET}"
    echo ""
    echo "Usage: $0 [--sources] [--allow_download_from_mirror] [drive_address]"
    echo ""
    echo "If no arguments are provided, defaults to downloading all sources to current directory."
    echo "If only a directory path is provided, defaults to downloading all sources to that directory."
    echo ""
    echo -e "${COLOR_GREEN}Available Sources:${COLOR_RESET}"
    echo "  --all            Download from all sources (default, includes git repositories, excludes manual-sources)"
    echo "  --kiwix          Download Kiwix mirror (offline Wikipedia, etc.)"
    echo "  --openzim        Download OpenZIM files (educational content)"
    echo "  --openstreetmap  Download OpenStreetMap data (world map data)"
    echo "  --ia-software    Download Internet Archive software collection"
    echo "  --ia-music       Download Internet Archive music collection"
    echo "  --ia-movies      Download Internet Archive movies collection"
    echo "  --ia-texts       Download Internet Archive scientific texts"
    echo "  --git            Clone/update Git repositories from JSON configuration"
    echo "  --models         Download AI models using Ollama (installs Ollama if needed)"
    echo "  --manual-sources Download from manually configured JSON sources (not part of --all)"
    echo ""
    echo -e "${COLOR_GREEN}Options:${COLOR_RESET}"
    echo "  --allow_download_from_mirror  Allow downloading from alternative Kiwix mirrors"
    echo "                                if master mirror fails (rsync → FTP → HTTP fallback)"
    echo "  --help, -h                    Show this help message"
    echo ""
    echo -e "${COLOR_GREEN}Examples:${COLOR_RESET}"
    echo "  $0                                    # Download all to current directory"
    echo "  $0 /mnt/external_drive               # Download all to specified directory"
    echo "  $0 --kiwix /mnt/external_drive       # Download only Kiwix"
    echo "  $0 --openzim /mnt/external_drive     # Download only OpenZIM"
    echo "  $0 --models /mnt/external_drive      # Download AI models using Ollama"
    echo "  $0 --manual-sources /mnt/external_drive  # Download from manual sources JSON"
    echo "  $0 --git /mnt/external_drive             # Clone/update Git repositories"
    echo "  $0 --kiwix --allow_download_from_mirror /mnt/external_drive"
    echo "  $0 --all --allow_download_from_mirror /mnt/external_drive"
    echo ""
    echo -e "${COLOR_YELLOW}Storage Requirements:${COLOR_RESET}"
    echo "  Kiwix Mirror:     Several GB to TB"
    echo "  OpenZIM:          Several GB to TB"
    echo "  OpenStreetMap:    ~70GB+"
    echo "  IA Software:      50GB - 500GB"
    echo "  IA Music:         100GB - 1TB"
    echo "  IA Movies:        500GB - 5TB"
    echo "  IA Texts:         100GB - 2TB"
    echo "  AI Models:        5GB - 500GB (varies by model)"
    echo "  Recommended:      1TB+ free space"
    echo ""
}

# Function to download Kiwix mirror using dedicated script
download_kiwix() {
    local drive_path="$1"
    local allow_mirrors="$2"
    
    log_info "Calling Kiwix download script..."
    "$SCRIPT_DIR/scripts/kiwix.sh" "$drive_path" "$allow_mirrors"
}

# Function to download OpenZIM files using dedicated script
download_openzim() {
    local drive_path="$1"
    
    log_info "Calling OpenZIM download script..."
    "$SCRIPT_DIR/scripts/openzim.sh" "$drive_path"
}

# Function to download OpenStreetMap data using dedicated script
download_openstreetmap() {
    local drive_path="$1"
    
    log_info "Calling OpenStreetMap download script..."
    "$SCRIPT_DIR/scripts/openstreetmap.sh" "$drive_path"
}

# Function to download Internet Archive software collection using dedicated script
download_ia_software() {
    local drive_path="$1"
    
    log_info "Calling Internet Archive software download script..."
    "$SCRIPT_DIR/scripts/ia-software.sh" "$drive_path"
}

# Function to download Internet Archive music collection using dedicated script
download_ia_music() {
    local drive_path="$1"
    
    log_info "Calling Internet Archive music download script..."
    "$SCRIPT_DIR/scripts/ia-music.sh" "$drive_path"
}

# Function to download Internet Archive movies collection using dedicated script
download_ia_movies() {
    local drive_path="$1"
    
    log_info "Calling Internet Archive movies download script..."
    "$SCRIPT_DIR/scripts/ia-movies.sh" "$drive_path"
}

# Function to download Internet Archive texts collection using dedicated script
download_ia_texts() {
    local drive_path="$1"
    
    log_info "Calling Internet Archive texts download script..."
    "$SCRIPT_DIR/scripts/ia-texts.sh" "$drive_path"
}

# Function to setup Python virtual environment
setup_venv() {
    local venv_path="$SCRIPT_DIR/.venv"
    
    # Check if Python3 is available
    if ! command -v python3 &> /dev/null; then
        log_error "python3 is not installed. Please install it first:"
        log_info "  sudo apt-get install python3 python3-venv python3-pip"
        return 1
    fi
    
    # Check if venv module is available
    if ! python3 -c "import venv" &> /dev/null; then
        log_error "python3-venv is not installed. Please install it first:"
        log_info "  sudo apt-get install python3-venv"
        return 1
    fi
    
    # Create venv if it doesn't exist
    if [ ! -d "$venv_path" ]; then
        log_info "Creating Python virtual environment..."
        if python3 -m venv "$venv_path"; then
            log_success "Virtual environment created at $venv_path"
        else
            log_error "Failed to create virtual environment"
            return 1
        fi
    else
        log_info "Virtual environment already exists at $venv_path"
    fi
    
    # Install requirements if requirements.txt exists
    if [ -f "$SCRIPT_DIR/requirements.txt" ]; then
        log_info "Installing Python requirements..."
        if "$venv_path/bin/pip" install -q -r "$SCRIPT_DIR/requirements.txt"; then
            log_success "Requirements installed successfully"
        else
            log_warning "Failed to install requirements, but continuing (may use standard library only)"
        fi
    fi
    
    return 0
}

# Function to download from manual sources using JSON configuration
download_manual_sources() {
    local drive_path="$1"
    
    log_info "Downloading from manual sources (JSON configuration)..."
    
    # Setup virtual environment
    if ! setup_venv; then
        log_error "Failed to setup Python virtual environment"
        return 1
    fi
    
    # Change to the drive path
    local manual_dir="$drive_path/manual_sources"
    mkdir -p "$manual_dir"
    cd "$manual_dir" || {
        log_error "Failed to access directory: $manual_dir"
        return 1
    }
    
    log_info "Downloading to: $manual_dir"
    
    # Run the Python script with venv
    if "$SCRIPT_DIR/.venv/bin/python3" "$SCRIPT_DIR/scripts/download_manual_sources.py"; then
        log_success "Manual sources download completed"
        cd - > /dev/null || true
        return 0
    else
        log_error "Manual sources download failed"
        cd - > /dev/null || true
        return 1
    fi
}

# Function to download Git repositories
download_git_repos() {
    local drive_path="$1"
    
    log_info "Cloning/updating Git repositories..."
    
    # Setup virtual environment
    if ! setup_venv; then
        log_error "Failed to setup Python virtual environment"
        return 1
    fi
    
    # Define git repos directory
    local git_repos_dir="$drive_path/git_repos"
    
    log_info "Git repositories directory: $git_repos_dir"
    
    # Run the Python script with venv
    if "$SCRIPT_DIR/.venv/bin/python3" "$SCRIPT_DIR/scripts/download_git_repos.py" --dest "$git_repos_dir"; then
        log_success "Git repositories download completed"
        return 0
    else
        log_error "Git repositories download failed"
        return 1
    fi
}

# Function to download AI models using Ollama
download_models() {
    local drive_path="$1"
    
    log_info "Calling AI models download script..."
    "$SCRIPT_DIR/scripts/models.sh" "$drive_path"
}

# Function to download from all sources
download_all() {
    local drive_path="$1"
    local allow_mirrors="$2"
    
    log_info "Starting download from all sources..."
    log_info "Target directory: $drive_path"
    log_info "Mirror fallback enabled: $allow_mirrors"
    
    # Validate drive path
    if ! validate_drive_path "$drive_path"; then
        return 1
    fi
    
    local sources=("kiwix" "openzim" "openstreetmap" "ia-software" "ia-music" "ia-movies" "ia-texts" "git-repos" "models")
    local failed_sources=()
    
    for source in "${sources[@]}"; do
        log_info "Processing source: $source"
        
        case "$source" in
            "kiwix")
                if ! download_kiwix "$drive_path" "$allow_mirrors"; then
                    failed_sources+=("$source")
                    log_error "Failed to download from source: $source"
                fi
                ;;
            *)
                if ! "download_${source//-/_}" "$drive_path"; then
                    failed_sources+=("$source")
                    log_error "Failed to download from source: $source"
                fi
                ;;
        esac
    done
    
    # Report results
    if [ ${#failed_sources[@]} -eq 0 ]; then
        log_success "All downloads completed successfully!"
        return 0
    else
        log_warning "Some downloads failed:"
        for failed in "${failed_sources[@]}"; do
            log_warning "  - $failed"
        done
        log_info "Successful downloads can still be used."
        return 1
    fi
}

# Main script logic
main() {
    local allow_mirrors="false"
    local source=""
    local drive_path=""
    
    # Display banner
    log_info "EmergencyStorage - Emergency Data Sources Downloader"
    log_info "Project: https://github.com/VictoKu1/EmergencyStorage"
    log_info ""
    
    # Parse arguments
    while [ $# -gt 0 ]; do
        case "$1" in
            --allow_download_from_mirror)
                allow_mirrors="true"
                shift
                ;;
            --all|--kiwix|--openzim|--openstreetmap|--ia-software|--ia-music|--ia-movies|--ia-texts|--manual-sources|--git|--models)
                if [ -n "$source" ]; then
                    log_error "Multiple source options specified"
                    show_usage
                    exit 1
                fi
                source="$1"
                shift
                ;;
            --help|-h)
                show_usage
                exit 0
                ;;
            --*)
                log_error "Unknown option $1"
                show_usage
                exit 1
                ;;
            *)
                if [ -n "$drive_path" ]; then
                    log_error "Multiple drive paths specified"
                    show_usage
                    exit 1
                fi
                drive_path="$1"
                shift
                ;;
        esac
    done
    
    # Default behavior: if no arguments, use --all with current directory
    if [ -z "$source" ] && [ -z "$drive_path" ]; then
        log_info "No arguments provided. Defaulting to download all sources to current directory."
        if ! validate_drive_path "."; then
            exit 1
        fi
        download_all "." "$allow_mirrors"
        return
    fi
    
    # If only drive path provided, default to --all
    if [ -z "$source" ] && [ -n "$drive_path" ]; then
        log_info "Single directory argument provided. Defaulting to download all sources."
        if ! validate_drive_path "$drive_path"; then
            exit 1
        fi
        download_all "$drive_path" "$allow_mirrors"
        return
    fi
    
    # If source provided but no drive path, error
    if [ -n "$source" ] && [ -z "$drive_path" ]; then
        log_error "Drive address is required for $source option"
        show_usage
        exit 1
    fi
    
    # Validate drive path
    if ! validate_drive_path "$drive_path"; then
        exit 1
    fi
    
    # Execute the appropriate download function
    case "$source" in
        --kiwix)
            download_kiwix "$drive_path" "$allow_mirrors"
            ;;
        --openzim)
            download_openzim "$drive_path"
            ;;
        --openstreetmap)
            download_openstreetmap "$drive_path"
            ;;
        --all)
            download_all "$drive_path" "$allow_mirrors"
            ;;
        --ia-software)
            download_ia_software "$drive_path"
            ;;
        --ia-music)
            download_ia_music "$drive_path"
            ;;
        --ia-movies)
            download_ia_movies "$drive_path"
            ;;
        --ia-texts)
            download_ia_texts "$drive_path"
            ;;
        --manual-sources)
            download_manual_sources "$drive_path"
            ;;
        --git)
            download_git_repos "$drive_path"
            ;;
        --models)
            download_models "$drive_path"
            ;;
        *)
            log_error "Invalid source option $source"
            show_usage
            exit 1
            ;;
    esac
}

# Run main function with all arguments
main "$@"