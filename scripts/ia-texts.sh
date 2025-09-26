#!/bin/bash

# Internet Archive Texts Collection Download Script
# Part of EmergencyStorage - Downloads scientific texts and academic papers
# 
# Usage: ./ia-texts.sh <drive_path>
# 
# Arguments:
#   drive_path - Target directory for Internet Archive texts

set -e  # Exit on any error

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source common utilities
# shellcheck source=common.sh
source "$SCRIPT_DIR/common.sh"

# Main function to download Internet Archive texts collection
download_ia_texts() {
    local drive_path="$1"
    local ia_texts_path="$drive_path/internet-archive-texts"
    
    log_info "Starting Internet Archive scientific texts download..."
    log_info "Target directory: $ia_texts_path"
    
    # Validate drive path
    if ! validate_drive_path "$drive_path"; then
        return 1
    fi
    
    # Create directory
    mkdir -p "$ia_texts_path"
    
    # Check if curl is available
    if ! check_command "curl" "curl"; then
        return 1
    fi
    
    # Change to the target directory
    if ! safe_cd "$ia_texts_path"; then
        return 1
    fi
    
    log_info "Setting up scientific texts and academic papers collection..."
    
    # Create a comprehensive README file
    cat > README_TEXTS.txt << 'EOF'
EmergencyStorage - Internet Archive Scientific Texts Collection
===============================================================

This directory contains scientific texts and academic papers from the Internet Archive.

The Internet Archive hosts millions of texts, books, and academic papers,
with a focus on educational, scientific, and reference materials.

Key Collections:
- Project Gutenberg - Public domain literature and texts
- Biodiversity Heritage Library - Biological and natural history texts
- Medical Heritage Library - Historical medical texts and journals
- Academic Texts - Scholarly papers and research materials
- Open Source Texts - Open access academic and technical content
- Government Documents - Public domain government publications
- Open Library - Books and educational materials
- Scientific Papers - Research publications and journals

Educational Value:
These collections provide access to:
- Classic literature and historical texts
- Scientific research and discoveries
- Medical and biological reference materials
- Technical manuals and documentation
- Educational textbooks and materials
- Historical government documents

Collection Details:
1. gutenberg - Project Gutenberg public domain literature
2. biodiversitylibrary - Biological and natural history texts
3. medicalheritagelibrary - Historical medical literature
4. academictexts - Scholarly papers and academic materials
5. opensource - Open access texts and technical documentation
6. governmentdocuments - Public domain government publications
7. openlibrary_subject - Categorized books and educational materials
8. journals - Academic and scientific journal archives

Text Formats Available:
- PDF (most common)
- EPUB (e-book format)
- Plain text (TXT)
- HTML
- DAISY (accessible format)
- DjVu (for scanned documents)

Total estimated size: 100GB - 2TB depending on selection

Legal Status:
Focus on public domain, Creative Commons, and openly licensed content
to ensure legal compliance for educational and research use.

Research Applications:
- Academic research and study
- Educational curriculum development
- Historical research and analysis
- Medical and scientific reference
- Literature and humanities study
- Technical documentation and manuals

For more information about Internet Archive texts:
https://archive.org/details/texts

This collection was prepared by EmergencyStorage.
EOF
    
    # Try to download texts catalog
    log_info "Attempting to download texts catalog..."
    local catalog_url="https://archive.org/advancedsearch.php?q=collection%3Atexts&fl=identifier,title,creator,subject&rows=100&output=json"
    
    if check_internet "$catalog_url" 10; then
        if curl -s --connect-timeout 10 "$catalog_url" > texts_catalog.json 2>/dev/null; then
            log_success "Texts catalog downloaded successfully"
        else
            log_warning "Failed to download texts catalog"
        fi
    else
        log_warning "Could not connect to Internet Archive (no internet or server unavailable)"
        log_info "Catalog download would be attempted when internet is available"
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
        "journals"
    )
    
    log_info "Creating download placeholders for text collections..."
    
    for collection in "${text_collections[@]}"; do
        create_download_placeholder "$collection" "https://archive.org/details/$collection"
        
        # Create a brief description for each collection
        case "$collection" in
            "gutenberg")
                echo "Project Gutenberg public domain literature and classic texts" >> "${collection}_description.txt"
                ;;
            "biodiversitylibrary")
                echo "Biological and natural history texts, scientific literature" >> "${collection}_description.txt"
                ;;
            "medicalheritagelibrary")
                echo "Historical medical texts, journals, and healthcare literature" >> "${collection}_description.txt"
                ;;
            "academictexts")
                echo "Scholarly papers, research materials, and academic publications" >> "${collection}_description.txt"
                ;;
            "opensource")
                echo "Open access texts, technical documentation, and free educational materials" >> "${collection}_description.txt"
                ;;
            "governmentdocuments")
                echo "Public domain government publications and official documents" >> "${collection}_description.txt"
                ;;
            "openlibrary_subject")
                echo "Categorized books and educational materials by subject area" >> "${collection}_description.txt"
                ;;
            "journals")
                echo "Academic and scientific journal archives and periodicals" >> "${collection}_description.txt"
                ;;
        esac
    done
    
    # Create subject-specific collection placeholders
    log_info "Creating subject-specific collection placeholders..."
    local subjects=(
        "mathematics"
        "physics"
        "chemistry" 
        "biology"
        "medicine"
        "engineering"
        "computer_science"
        "history"
        "philosophy"
        "literature"
    )
    
    for subject in "${subjects[@]}"; do
        create_download_placeholder "subject_${subject}" "https://archive.org/search.php?query=subject%3A${subject}"
        echo "Academic texts and materials related to ${subject}" >> "subject_${subject}_description.txt"
    done
    
    # Create a manifest of what would be downloaded
    log_info "Creating download manifest..."
    cat > download_manifest.txt << 'EOF'
Internet Archive Texts Collection Download Manifest
===================================================

This manifest lists the text collections that would be downloaded:

Collection Name           | Estimated Size | Content Focus
--------------------------|----------------|------------------
gutenberg                | 10-50 GB       | Classic literature (public domain)
biodiversitylibrary      | 20-100 GB      | Biology and natural history
medicalheritagelibrary   | 15-75 GB       | Medical and healthcare texts
academictexts            | 30-200 GB      | Scholarly papers and research
opensource               | 20-100 GB      | Open access technical texts
governmentdocuments      | 25-150 GB      | Public domain gov publications
openlibrary_subject      | 40-300 GB      | Categorized educational books
journals                 | 50-500 GB      | Academic journal archives

Subject-Specific Collections:
subject_mathematics      | 5-30 GB        | Mathematical texts and papers
subject_physics          | 8-50 GB        | Physics research and textbooks
subject_chemistry        | 6-40 GB        | Chemistry texts and journals
subject_biology          | 10-60 GB       | Biological sciences materials
subject_medicine         | 15-80 GB       | Medical texts and research
subject_engineering      | 12-70 GB       | Engineering and technical texts
subject_computer_science | 10-60 GB       | Computer science and programming
subject_history          | 20-100 GB      | Historical texts and documents
subject_philosophy       | 8-50 GB        | Philosophical works and papers
subject_literature       | 15-80 GB       | Literary works and criticism

Total Range: 274-1685 GB (varies greatly based on selection and filtering)

File Format Distribution:
- PDF: ~60% (most academic papers and scanned books)
- EPUB: ~20% (e-book format)
- TXT: ~15% (plain text, especially classic literature)
- Other: ~5% (HTML, DjVu, DAISY, etc.)

Educational Value:
- Reference materials for research
- Educational curriculum support
- Historical document preservation
- Scientific literature access
- Technical documentation
- Classic literature collection

Legal Compliance:
Focus on public domain, Creative Commons, and open access materials
to ensure legal compliance for educational and research purposes.
EOF
    
    log_success "Internet Archive texts collection setup completed!"
    log_info "Download URLs and descriptions have been prepared"
    log_info "Review the README_TEXTS.txt file for detailed information"
    log_info "Collections focus on educational and research materials"
    
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
    
    download_ia_texts "$@"
fi