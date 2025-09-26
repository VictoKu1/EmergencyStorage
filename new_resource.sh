#!/bin/bash

# NEW RESOURCE Download Script Template
# Part of EmergencyStorage - Template for adding new data sources
#
# ============================================================================
# INSTRUCTIONS FOR USING THIS TEMPLATE:
# ============================================================================
#
# 1. Copy this file to scripts/your-resource-name.sh
#    Example: cp new_resource.sh scripts/my-data-source.sh
#
# 2. Replace ALL instances of "NEW_RESOURCE" with your resource name:
#    - NEW_RESOURCE -> Your Resource Name (for display)
#    - new_resource -> your-resource-name (for file/directory names)
#    - download_new_resource -> download_your_resource_name (function name)
#
# 3. Update the header section with your resource-specific information
#
# 4. Customize the sections marked with "CUSTOMIZE:" comments
#
# 5. Add your resource to emergency_storage.sh (see INTEGRATION GUIDE below)
#
# 6. Test your script independently and then integrated with the main script
#
# ============================================================================
# INTEGRATION GUIDE FOR emergency_storage.sh:
# ============================================================================
#
# To integrate this new resource into the main emergency_storage.sh script:
#
# A. Add source description in header comment (around line 7):
#    Sources: all, kiwix, openzim, openstreetmap, ia-software, ia-music, ia-movies, ia-texts, your-resource
#
# B. Add to usage display in show_usage() function (around line 39):
#    echo "  --your-resource  Download Your Resource Name collection"
#
# C. Add to storage requirements display (around line 61):
#    echo "  Your Resource:    [SIZE] (your estimated size)"
#
# D. Add download function (around line 121):
#    # Function to download Your Resource collection using dedicated script
#    download_your_resource() {
#        local drive_path="$1"
#        
#        log_info "Calling Your Resource download script..."
#        "$SCRIPT_DIR/scripts/your-resource.sh" "$drive_path"
#    }
#
# E. Add to sources array in download_all() function (around line 137):
#    local sources=("kiwix" "openzim" "openstreetmap" "ia-software" "ia-music" "ia-movies" "ia-texts" "your-resource")
#
# F. Add to argument parsing (around line 191):
#    --all|--kiwix|--openzim|--openstreetmap|--ia-software|--ia-music|--ia-movies|--ia-texts|--your-resource)
#
# G. Add to source selection case statement (around line 277):
#    --your-resource)
#        download_your_resource "$drive_path"
#        ;;
#
# ============================================================================
# 
# Usage: ./your-resource.sh <drive_path> [optional_parameters]
# 
# Arguments:
#   drive_path         - Target directory for NEW_RESOURCE data
#   optional_parameters - CUSTOMIZE: Add your specific parameters here
#
# Author: [Your Name]
# Based on: EmergencyStorage template
# Project: https://github.com/VictoKu1/EmergencyStorage

set -e  # Exit on any error

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source common utilities
# shellcheck source=scripts/common.sh
source "$SCRIPT_DIR/scripts/common.sh"

# ============================================================================
# RESOURCE-SPECIFIC CONFIGURATION SECTION
# ============================================================================
# CUSTOMIZE: Define your resource-specific variables and configuration

# CUSTOMIZE: Define resource-specific URLs, endpoints, or mirror lists
declare -r RESOURCE_PRIMARY_URL="https://example.com/your-resource"
declare -r RESOURCE_BACKUP_URL="https://backup.example.com/your-resource"
declare -r RESOURCE_API_ENDPOINT="https://api.example.com/your-resource"

# CUSTOMIZE: Define collections, categories, or datasets available
RESOURCE_COLLECTIONS=(
    "collection1"
    "collection2"
    "collection3"
)

# CUSTOMIZE: Define estimated sizes for different collections/components
declare -A COLLECTION_SIZES=(
    ["collection1"]="10-50 GB"
    ["collection2"]="5-25 GB"
    ["collection3"]="2-15 GB"
)

# CUSTOMIZE: Define descriptions for collections
declare -A COLLECTION_DESCRIPTIONS=(
    ["collection1"]="Description of collection 1"
    ["collection2"]="Description of collection 2"
    ["collection3"]="Description of collection 3"
)

# ============================================================================
# RESOURCE-SPECIFIC HELPER FUNCTIONS SECTION
# ============================================================================
# CUSTOMIZE: Add your resource-specific helper functions here

# Function to check resource-specific requirements
check_new_resource_requirements() {
    log_info "Checking NEW_RESOURCE specific requirements..."
    
    # CUSTOMIZE: Add checks for required tools (curl, wget, rsync, etc.)
    if ! check_command "curl" "curl"; then
        return 1
    fi
    
    # CUSTOMIZE: Add checks for additional tools your resource needs
    # Example:
    # if ! check_command "wget" "wget"; then
    #     return 1
    # fi
    
    # CUSTOMIZE: Add connectivity checks to your resource
    if ! check_internet "$RESOURCE_PRIMARY_URL" 10; then
        log_warning "Cannot connect to primary NEW_RESOURCE server"
        
        # CUSTOMIZE: Try backup sources if needed
        if ! check_internet "$RESOURCE_BACKUP_URL" 10; then
            log_warning "Cannot connect to backup NEW_RESOURCE server"
            log_info "Downloads will be attempted when internet is available"
        else
            log_info "Backup NEW_RESOURCE server is accessible"
        fi
    else
        log_info "Primary NEW_RESOURCE server is accessible"
    fi
    
    return 0
}

# Function to create resource-specific README
create_new_resource_readme() {
    local resource_path="$1"
    
    log_info "Creating NEW_RESOURCE README..."
    
    # CUSTOMIZE: Create a comprehensive README for your resource
    cat > "$resource_path/README_NEW_RESOURCE.txt" << 'EOF'
EmergencyStorage - NEW_RESOURCE Collection
==========================================

CUSTOMIZE: Add a detailed description of your resource here.

This directory contains data from NEW_RESOURCE, which provides:
- CUSTOMIZE: List what your resource offers
- CUSTOMIZE: Explain the value and use cases
- CUSTOMIZE: Mention any special requirements or tools needed

Key Collections:
CUSTOMIZE: List and describe your main collections/datasets

Collection Details:
CUSTOMIZE: Provide detailed information about each collection

Estimated Storage Requirements:
CUSTOMIZE: Provide storage estimates for different scenarios

Usage Instructions:
CUSTOMIZE: Explain how to use the downloaded data
- How to access the data
- Required software or tools
- Configuration steps if needed

Important Notes:
CUSTOMIZE: Add any important warnings, limitations, or considerations
- License information
- Usage restrictions
- Update frequency
- Data freshness

For more information about NEW_RESOURCE:
CUSTOMIZE: Add official website/documentation links

This collection was prepared by EmergencyStorage.
For more information, visit: https://github.com/VictoKu1/EmergencyStorage
EOF
}

# Function to download/mirror primary data source
download_primary_source() {
    local resource_path="$1"
    
    log_info "Attempting to download from primary NEW_RESOURCE source..."
    
    # CUSTOMIZE: Implement your primary download method
    # This could be:
    # - Direct file downloads with curl/wget
    # - API calls to get file lists then download
    # - rsync from a mirror
    # - git clone for repositories
    # - Custom protocols
    
    # Example implementation:
    if curl -s --connect-timeout 30 -L "$RESOURCE_PRIMARY_URL" -o "$resource_path/primary_data.txt"; then
        log_success "Primary NEW_RESOURCE data downloaded successfully"
        return 0
    else
        log_warning "Failed to download from primary NEW_RESOURCE source"
        return 1
    fi
}

# Function to try alternative mirrors or backup sources
try_alternative_sources() {
    local resource_path="$1"
    
    log_info "Trying alternative NEW_RESOURCE sources..."
    
    # CUSTOMIZE: Define and try alternative sources
    local alternative_sources=(
        "$RESOURCE_BACKUP_URL"
        # Add more backup sources as needed
    )
    
    for source in "${alternative_sources[@]}"; do
        log_info "Trying alternative source: $source"
        
        # CUSTOMIZE: Implement alternative download logic
        if curl -s --connect-timeout 30 -L "$source" -o "$resource_path/alternative_data.txt"; then
            log_success "NEW_RESOURCE data downloaded from alternative source: $source"
            return 0
        else
            log_warning "Failed to download from alternative source: $source"
        fi
    done
    
    return 1
}

# Function to create download placeholders and metadata
create_download_placeholders() {
    local resource_path="$1"
    
    log_info "Creating download placeholders for NEW_RESOURCE collections..."
    
    # CUSTOMIZE: Create placeholders for your collections/datasets
    for collection in "${RESOURCE_COLLECTIONS[@]}"; do
        # Create download URL placeholder
        create_download_placeholder "$collection" "${RESOURCE_PRIMARY_URL}/${collection}"
        
        # Create collection description
        echo "${COLLECTION_DESCRIPTIONS[$collection]}" > "${collection}_description.txt"
        
        # CUSTOMIZE: Add any collection-specific metadata files
        cat > "${collection}_metadata.txt" << EOF
Collection: $collection
Estimated Size: ${COLLECTION_SIZES[$collection]}
Description: ${COLLECTION_DESCRIPTIONS[$collection]}
Source URL: ${RESOURCE_PRIMARY_URL}/${collection}
Last Updated: $(date)
EOF
    done
}

# Function to create download manifest
create_download_manifest() {
    local resource_path="$1"
    
    log_info "Creating NEW_RESOURCE download manifest..."
    
    # CUSTOMIZE: Create a manifest of what would be downloaded
    cat > "$resource_path/download_manifest.txt" << 'EOF'
NEW_RESOURCE Collection Download Manifest
=========================================

This manifest lists the NEW_RESOURCE collections that would be downloaded:

CUSTOMIZE: Create a table or list of your collections with details
Collection Name                 | Estimated Size | Description
-------------------------------|----------------|------------------

CUSTOMIZE: Add your collections here with sizes and descriptions

Total Estimated Range: CUSTOMIZE: Provide total size estimate

Note: These are estimates. Actual download sizes may vary.
CUSTOMIZE: Add any additional notes about size variations, dependencies, etc.

Download Priority:
CUSTOMIZE: If applicable, suggest download priority order
1. Most important collection
2. Secondary collections
3. Optional/large collections

Requirements:
CUSTOMIZE: List any special requirements
- Required disk space
- Network bandwidth recommendations  
- Required tools or dependencies
- Operating system compatibility
EOF
}

# ============================================================================
# MAIN DOWNLOAD FUNCTION
# ============================================================================

# Main function to download NEW_RESOURCE
download_new_resource() {
    local drive_path="$1"
    # CUSTOMIZE: Add additional parameters as needed
    # local additional_param="${2:-default_value}"
    
    local resource_path="$drive_path/new-resource-data"
    
    log_info "Starting NEW_RESOURCE collection download..."
    log_info "Target directory: $resource_path"
    # CUSTOMIZE: Log additional configuration
    
    # Validate drive path
    if ! validate_drive_path "$drive_path"; then
        return 1
    fi
    
    # Create resource directory
    mkdir -p "$resource_path"
    
    # Check resource-specific requirements
    if ! check_new_resource_requirements; then
        log_error "NEW_RESOURCE requirements not met"
        return 1
    fi
    
    # Change to the target directory
    if ! safe_cd "$resource_path"; then
        return 1
    fi
    
    # Create comprehensive README
    create_new_resource_readme "$resource_path"
    
    # Create download manifest
    create_download_manifest "$resource_path"
    
    # Create download placeholders
    create_download_placeholders "$resource_path"
    
    # CUSTOMIZE: Choose your download strategy
    log_info "Setting up NEW_RESOURCE data (this may take a long time)..."
    
    # Try primary source first
    if download_primary_source "$resource_path"; then
        log_success "NEW_RESOURCE primary download completed successfully!"
    elif try_alternative_sources "$resource_path"; then
        log_success "NEW_RESOURCE alternative download completed successfully!"
    else
        log_warning "NEW_RESOURCE live download failed, but placeholders have been created"
        log_info "Downloads will be attempted when connectivity to NEW_RESOURCE servers is available"
    fi
    
    # CUSTOMIZE: Add any post-download processing
    # - Verification of downloaded data
    # - Extraction or conversion
    # - Index generation
    # - Cleanup of temporary files
    
    log_success "NEW_RESOURCE collection setup completed!"
    log_info "Review the README_NEW_RESOURCE.txt file for detailed information"
    log_info "Check download_manifest.txt for collection details"
    
    return 0
}

# ============================================================================
# SCRIPT EXECUTION SECTION
# ============================================================================

# Main execution - only run if script is executed directly (not sourced)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    # Script is being executed directly
    if [ $# -lt 1 ]; then
        log_error "Usage: $0 <drive_path> [additional_parameters]"
        log_info "Example: $0 /mnt/external_drive"
        # CUSTOMIZE: Add examples with your specific parameters
        exit 1
    fi
    
    # CUSTOMIZE: Add parameter validation if you have additional parameters
    
    download_new_resource "$@"
fi

# ============================================================================
# TEMPLATE COMPLETION CHECKLIST
# ============================================================================
# 
# Before using this template, make sure you have:
# 
# □ Replaced all instances of "NEW_RESOURCE" with your resource name
# □ Replaced all instances of "new_resource" with your resource name (lowercase/hyphenated)
# □ Updated the header documentation with resource-specific information  
# □ Customized the resource-specific configuration section
# □ Implemented the helper functions for your resource
# □ Defined your collections/datasets and their metadata
# □ Implemented the download logic for your resource
# □ Created comprehensive documentation in the README section
# □ Added your resource to emergency_storage.sh using the integration guide
# □ Tested the script independently 
# □ Tested the script integration with the main emergency_storage.sh
# □ Updated the main README.md with information about your new resource
#
# ============================================================================