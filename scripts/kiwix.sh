#!/bin/bash

# Kiwix Mirror Download Script
# Part of EmergencyStorage - Downloads/mirrors the complete Kiwix library
# 
# Usage: ./kiwix.sh <drive_path> [allow_mirrors]
# 
# Arguments:
#   drive_path    - Target directory for Kiwix mirror
#   allow_mirrors - Optional: "true" to enable mirror fallback, "false" (default)

set -e  # Exit on any error

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source common utilities
# shellcheck source=common.sh
source "$SCRIPT_DIR/common.sh"

# Path to mirrors JSON file
MIRRORS_JSON="$SCRIPT_DIR/../data/mirrors/kiwix.json"

# Function to load mirrors from JSON file
load_mirrors_from_json() {
    local protocol="$1"
    local mirrors=()
    
    if [ -f "$MIRRORS_JSON" ]; then
        # Use Python to parse JSON if available, otherwise fallback to hardcoded
        if command -v python3 &> /dev/null; then
            mapfile -t mirrors < <(python3 -c "
import json
import sys
try:
    with open('$MIRRORS_JSON', 'r') as f:
        data = json.load(f)
        mirrors = data.get('mirrors', {}).get('$protocol', [])
        for mirror in mirrors:
            print(mirror)
except Exception:
    sys.exit(1)
" 2>/dev/null)
        fi
    fi
    
    # Return the array
    printf '%s\n' "${mirrors[@]}"
}

# Function to download from master Kiwix mirror
download_from_master() {
    local kiwix_path="$1"
    
    log_info "Trying master mirror: master.download.kiwix.org::download.kiwix.org/"
    
    if timeout 60 rsync --dry-run -v "master.download.kiwix.org::download.kiwix.org/" &>/dev/null; then
        log_info "Master mirror is accessible, starting download..."
        
        if rsync -vzrlptD --delete --info=progress2 "master.download.kiwix.org::download.kiwix.org/" "$kiwix_path/"; then
            log_success "Kiwix mirror download completed successfully from master mirror!"
            return 0
        else
            log_warning "Download failed from master mirror."
            return 1
        fi
    else
        log_warning "Master mirror is not accessible."
        return 1
    fi
}

# Function to try alternative rsync mirrors
try_rsync_mirrors() {
    local kiwix_path="$1"
    
    # Load mirrors from JSON file
    local rsync_mirrors=()
    mapfile -t rsync_mirrors < <(load_mirrors_from_json "rsync")
    
    # Fallback to hardcoded mirrors if JSON loading failed
    if [ ${#rsync_mirrors[@]} -eq 0 ]; then
        log_warning "Could not load mirrors from JSON, using fallback list"
        rsync_mirrors=(
            "ftp.fau.de/kiwix/"
            "mirror-sites-fr.mblibrary.info/download.kiwix.org/"
            "ftp.mirrorservice.org/download.kiwix.org/"
            "ftp.nluug.nl/kiwix/"
            "mirror.accum.se/mirror/kiwix.org/"
            "mirror-sites-ca.mblibrary.info/download.kiwix.org/"
            "wi.mirror.driftle.ss/kiwix/"
            "ny.mirror.driftle.ss/kiwix/"
            "mirror.triplebit.org/download.kiwix.org/"
            "ftpmirror.your.org/pub/kiwix/"
            "mirrors.dotsrc.org/kiwix/"
            "rsyncd-service/self.download.kiwix.org/"
            "md.mirrors.hacktegic.com/kiwix-md/"
            "mirror-sites-in.mblibrary.info/download.kiwix.org/"
        )
    fi
    
    log_info "Trying rsync mirrors..."
    
    for mirror in "${rsync_mirrors[@]}"; do
        log_info "Trying rsync mirror: $mirror"
        
        if timeout 60 rsync --dry-run -v "$mirror" &>/dev/null; then
            log_info "Rsync mirror $mirror is accessible, starting download..."
            
            if rsync -vzrlptD --delete --info=progress2 "$mirror" "$kiwix_path/"; then
                log_success "Kiwix mirror download completed successfully from rsync mirror: $mirror"
                return 0
            else
                log_warning "Download failed from rsync mirror $mirror"
            fi
        else
            log_warning "Rsync mirror $mirror is not accessible"
        fi
    done
    
    return 1
}

# Function to try FTP mirrors
try_ftp_mirrors() {
    local kiwix_path="$1"
    
    # Check if curl is available for FTP/HTTP fallback
    if ! check_command "curl" "curl"; then
        return 1
    fi
    
    # Load mirrors from JSON file
    local ftp_mirrors=()
    mapfile -t ftp_mirrors < <(load_mirrors_from_json "ftp")
    
    # Fallback to hardcoded mirrors if JSON loading failed
    if [ ${#ftp_mirrors[@]} -eq 0 ]; then
        log_warning "Could not load FTP mirrors from JSON, using fallback list"
        ftp_mirrors=(
            "ftp://ftp.fau.de/kiwix/"
            "ftp://ftp.mirrorservice.org/sites/download.kiwix.org/"
            "ftp://ftp.nluug.nl/pub/kiwix/"
            "ftp://mirror.accum.se/mirror/kiwix.org/"
            "ftp://ftpmirror.your.org/pub/kiwix/"
            "ftp://mirrors.dotsrc.org/kiwix/"
            "ftp://mirror.download.kiwix.org/"
        )
    fi
    
    log_info "Rsync mirrors failed, trying FTP mirrors..."
    
    for mirror in "${ftp_mirrors[@]}"; do
        log_info "Trying FTP mirror: $mirror"
        
        if timeout 60 curl -s --connect-timeout 30 "$mirror" > /dev/null 2>&1; then
            log_info "FTP mirror $mirror is accessible, starting download..."
            
            # Use wget for recursive FTP download if available
            if command -v wget &> /dev/null; then
                if wget -r -np -nH --cut-dirs=1 -P "$kiwix_path" "$mirror"; then
                    log_success "Kiwix mirror download completed successfully from FTP mirror: $mirror"
                    return 0
                else
                    log_warning "Download failed from FTP mirror $mirror"
                fi
            else
                log_warning "wget not available for FTP recursive download, skipping FTP mirror $mirror"
            fi
        else
            log_warning "FTP mirror $mirror is not accessible"
        fi
    done
    
    return 1
}

# Function to try HTTP mirrors
try_http_mirrors() {
    local kiwix_path="$1"
    
    # Load mirrors from JSON file
    local http_mirrors=()
    mapfile -t http_mirrors < <(load_mirrors_from_json "https")
    
    # Fallback to hardcoded mirrors if JSON loading failed
    if [ ${#http_mirrors[@]} -eq 0 ]; then
        log_warning "Could not load HTTPS mirrors from JSON, using fallback list"
        http_mirrors=(
            "https://ftp.fau.de/kiwix/"
            "https://mirror-sites-fr.mblibrary.info/mirror-sites/download.kiwix.org/"
            "https://www.mirrorservice.org/sites/download.kiwix.org/"
            "https://ftp.nluug.nl/pub/kiwix/"
            "https://mirror.accum.se/mirror/kiwix.org/"
            "https://mirror-sites-ca.mblibrary.info/mirror-sites/download.kiwix.org/"
            "https://wi.mirror.driftle.ss/kiwix/"
            "https://ny.mirror.driftle.ss/kiwix/"
            "https://mirror.triplebit.org/download.kiwix.org/"
            "https://ftpmirror.your.org/pub/kiwix/"
            "https://mirrors.dotsrc.org/kiwix/"
            "https://mirror.download.kiwix.org/"
            "https://mirror.isoc.org.il/pub/kiwix/"
            "https://md.mirrors.hacktegic.com/kiwix-md/"
            "https://dumps.wikimedia.org/kiwix/"
            "https://mirror-sites-in.mblibrary.info/mirror-sites/download.kiwix.org/"
        )
    fi
    
    log_info "FTP mirrors failed, trying HTTP mirrors..."
    
    for mirror in "${http_mirrors[@]}"; do
        log_info "Trying HTTP mirror: $mirror"
        
        if timeout 60 curl -s --connect-timeout 30 "$mirror" > /dev/null 2>&1; then
            log_info "HTTP mirror $mirror is accessible, starting download..."
            
            if command -v wget &> /dev/null; then
                if wget -r -np -nH --cut-dirs=1 -P "$kiwix_path" "$mirror"; then
                    log_success "Kiwix mirror download completed successfully from HTTP mirror: $mirror"
                    return 0
                else
                    log_warning "Download failed from HTTP mirror $mirror"
                fi
            else
                log_warning "wget not available for HTTP recursive download, skipping HTTP mirror $mirror"
            fi
        else
            log_warning "HTTP mirror $mirror is not accessible"
        fi
    done
    
    return 1
}

# Main function to download Kiwix mirror
download_kiwix() {
    local drive_path="$1"
    local allow_mirrors="${2:-false}"
    local kiwix_path="$drive_path/kiwix-mirror"
    
    log_info "Starting Kiwix mirror download..."
    log_info "Target directory: $kiwix_path"
    log_info "Mirror fallback enabled: $allow_mirrors"
    
    # Validate drive path
    if ! validate_drive_path "$drive_path"; then
        return 1
    fi
    
    # Create kiwix mirror directory
    mkdir -p "$kiwix_path"
    
    # Check if rsync is available
    if ! check_command "rsync" "rsync"; then
        return 1
    fi
    
    log_info "Downloading Kiwix mirror (this may take a long time)..."
    
    # Try master mirror first
    if download_from_master "$kiwix_path"; then
        return 0
    fi
    
    # If master fails and mirrors are not allowed, exit
    if [ "$allow_mirrors" != "true" ]; then
        log_error "Master Kiwix mirror failed and mirror downloads are not enabled."
        log_info "To use alternative mirrors, enable mirror fallback option"
        return 1
    fi
    
    # Try mirror sources in priority order: rsync -> FTP -> HTTP
    log_info "Master mirror failed, trying alternative mirrors..."
    
    if try_rsync_mirrors "$kiwix_path"; then
        return 0
    fi
    
    if try_ftp_mirrors "$kiwix_path"; then
        return 0
    fi
    
    if try_http_mirrors "$kiwix_path"; then
        return 0
    fi
    
    log_error "All Kiwix mirrors failed (master, rsync, FTP, and HTTP)."
    log_error "Please check your internet connection and try again later."
    return 1
}

# Main execution
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    # Script is being executed directly
    if [ $# -lt 1 ]; then
        log_error "Usage: $0 <drive_path> [allow_mirrors]"
        log_info "Example: $0 /mnt/external_drive true"
        exit 1
    fi
    
    download_kiwix "$@"
fi