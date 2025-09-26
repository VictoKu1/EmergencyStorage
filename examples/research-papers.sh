#!/bin/bash

# Research Papers Download Script - EXAMPLE
# Part of EmergencyStorage - Downloads scientific research paper collections
#
# This is an EXAMPLE showing how to use the new_resource.sh template
# 
# Usage: ./research-papers.sh <drive_path>
# 
# Arguments:
#   drive_path - Target directory for research papers

set -e  # Exit on any error

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source common utilities
# shellcheck source=../scripts/common.sh
source "$SCRIPT_DIR/../scripts/common.sh"

# Resource-specific configuration
declare -r RESOURCE_PRIMARY_URL="https://arxiv.org/help/bulk_data"
declare -r RESOURCE_BACKUP_URL="https://export.arxiv.org/"
declare -r RESOURCE_API_ENDPOINT="https://export.arxiv.org/api/query"

# Define collections
RESOURCE_COLLECTIONS=(
    "cs_papers"
    "physics_papers"
    "math_papers"
)

declare -A COLLECTION_SIZES=(
    ["cs_papers"]="50-200 GB"
    ["physics_papers"]="100-400 GB"
    ["math_papers"]="30-150 GB"
)

declare -A COLLECTION_DESCRIPTIONS=(
    ["cs_papers"]="Computer Science research papers from arXiv"
    ["physics_papers"]="Physics research papers from arXiv"
    ["math_papers"]="Mathematics research papers from arXiv"
)

# Main function to download research papers
download_research_papers() {
    local drive_path="$1"
    local papers_path="$drive_path/research-papers"
    
    log_info "Starting Research Papers collection download..."
    log_info "Target directory: $papers_path"
    
    # Validate drive path
    if ! validate_drive_path "$drive_path"; then
        return 1
    fi
    
    # Create directory
    mkdir -p "$papers_path"
    
    # Check requirements
    if ! check_command "curl" "curl"; then
        return 1
    fi
    
    # Change to target directory
    if ! safe_cd "$papers_path"; then
        return 1
    fi
    
    # Create README
    cat > README_RESEARCH_PAPERS.txt << 'EOF'
EmergencyStorage - Research Papers Collection
============================================

This directory contains scientific research papers, primarily from arXiv.

The arXiv (pronounced "archive") is a repository of electronic preprints 
(known as e-prints) approved for publication after moderation.

Key Collections:
- Computer Science papers
- Physics papers  
- Mathematics papers

Usage Instructions:
- Papers are in PDF format
- Organized by subject classification
- Search and access tools available at arxiv.org

For more information: https://arxiv.org/
EOF

    # Create placeholders
    for collection in "${RESOURCE_COLLECTIONS[@]}"; do
        create_download_placeholder "$collection" "https://arxiv.org/list/${collection}/recent"
        echo "${COLLECTION_DESCRIPTIONS[$collection]}" > "${collection}_description.txt"
    done
    
    log_success "Research Papers collection setup completed!"
    return 0
}

# Main execution
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    if [ $# -lt 1 ]; then
        log_error "Usage: $0 <drive_path>"
        log_info "Example: $0 /mnt/external_drive"
        exit 1
    fi
    
    download_research_papers "$@"
fi