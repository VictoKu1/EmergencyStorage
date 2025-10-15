#!/bin/bash

# AI Models Download Script
# Part of EmergencyStorage - Downloads and stores AI models using Ollama
# 
# Usage: ./models.sh <drive_path>
# 
# Arguments:
#   drive_path - Target directory for AI models storage
#
# Author: EmergencyStorage Project
# Project: https://github.com/VictoKu1/EmergencyStorage

set -e  # Exit on any error

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source common utilities
# shellcheck source=common.sh
source "$SCRIPT_DIR/common.sh"

# Path to Ollama configuration JSON file
OLLAMA_CONFIG="$SCRIPT_DIR/../data/Ollama.json"

# Function to check if Ollama is installed
check_ollama_installed() {
    if command -v ollama &> /dev/null; then
        log_success "Ollama is already installed"
        ollama --version
        return 0
    else
        log_warning "Ollama is not installed"
        return 1
    fi
}

# Function to install Ollama
install_ollama() {
    log_info "Installing Ollama..."
    
    # Get install command from config
    local install_cmd
    if command -v python3 &> /dev/null && [ -f "$OLLAMA_CONFIG" ]; then
        install_cmd=$(python3 -c "
import json
import sys
try:
    with open('$OLLAMA_CONFIG', 'r') as f:
        data = json.load(f)
        print(data.get('settings', {}).get('ollama_install_command', 'curl -fsSL https://ollama.com/install.sh | sh'))
except Exception as e:
    print('curl -fsSL https://ollama.com/install.sh | sh', file=sys.stderr)
    sys.exit(1)
" 2>/dev/null)
    else
        install_cmd="curl -fsSL https://ollama.com/install.sh | sh"
    fi
    
    log_info "Running installation command: $install_cmd"
    
    # Execute installation
    if eval "$install_cmd"; then
        log_success "Ollama installed successfully"
        return 0
    else
        log_error "Failed to install Ollama"
        return 1
    fi
}

# Function to ensure Ollama service is running
ensure_ollama_service() {
    log_info "Checking Ollama service status..."
    
    # Try to start Ollama in the background if not running
    if ! pgrep -x "ollama" > /dev/null; then
        log_info "Starting Ollama service..."
        ollama serve > /dev/null 2>&1 &
        sleep 3
        
        if pgrep -x "ollama" > /dev/null; then
            log_success "Ollama service started"
        else
            log_warning "Could not verify Ollama service is running, but continuing anyway"
        fi
    else
        log_success "Ollama service is already running"
    fi
}

# Function to get list of models from config
get_models_from_config() {
    if ! command -v python3 &> /dev/null; then
        log_error "Python3 is required to parse configuration"
        return 1
    fi
    
    if [ ! -f "$OLLAMA_CONFIG" ]; then
        log_error "Configuration file not found: $OLLAMA_CONFIG"
        return 1
    fi
    
    python3 -c "
import json
import sys

try:
    with open('$OLLAMA_CONFIG', 'r') as f:
        data = json.load(f)
    
    models = data.get('models', {})
    settings = data.get('settings', {})
    download_all_tags = settings.get('download_all_tags', False)
    
    for model_key, model_info in models.items():
        if not model_info.get('enabled', True):
            continue
        
        model_name = model_info.get('name', model_key)
        
        if download_all_tags:
            # Download all tags
            tags = model_info.get('tags', [])
            for tag in tags:
                print(f'{model_name}:{tag}')
        else:
            # Download only default tag
            default_tag = model_info.get('default_tag', 'latest')
            print(f'{model_name}:{default_tag}')
            
except Exception as e:
    print(f'Error parsing config: {e}', file=sys.stderr)
    sys.exit(1)
"
}

# Function to check if a model is already downloaded
is_model_downloaded() {
    local model_name="$1"
    
    # List local models and check if this one exists
    if ollama list 2>/dev/null | grep -q "^${model_name}"; then
        return 0
    else
        return 1
    fi
}

# Function to download a single model
download_model() {
    local model_name="$1"
    
    log_info "Processing model: $model_name"
    
    # Check if already downloaded
    if is_model_downloaded "$model_name"; then
        log_info "Model $model_name is already downloaded, checking for updates..."
        
        # Try to pull updates
        if ollama pull "$model_name" 2>&1 | tee /tmp/ollama_pull_${model_name//[:\/]/_}.log; then
            log_success "Model $model_name is up to date"
            return 0
        else
            log_warning "Failed to check updates for $model_name, but model exists locally"
            return 0
        fi
    else
        log_info "Downloading model: $model_name"
        
        # Download the model
        if ollama pull "$model_name" 2>&1 | tee /tmp/ollama_pull_${model_name//[:\/]/_}.log; then
            log_success "Model $model_name downloaded successfully"
            return 0
        else
            log_error "Failed to download model: $model_name"
            return 1
        fi
    fi
}

# Function to download all configured models
download_all_models() {
    local models_list
    
    log_info "Loading models from configuration..."
    
    # Get models list from config
    if ! models_list=$(get_models_from_config); then
        log_error "Failed to load models from configuration"
        return 1
    fi
    
    if [ -z "$models_list" ]; then
        log_warning "No models found in configuration"
        return 0
    fi
    
    local total_models=$(echo "$models_list" | wc -l)
    local current=0
    local failed_models=()
    
    log_info "Found $total_models model(s) to download/update"
    log_info ""
    
    # Download each model
    while IFS= read -r model_name; do
        current=$((current + 1))
        log_info "[$current/$total_models] Processing: $model_name"
        
        if ! download_model "$model_name"; then
            failed_models+=("$model_name")
        fi
        
        log_info ""
    done <<< "$models_list"
    
    # Report results
    log_info "========================================"
    log_info "Download Summary"
    log_info "========================================"
    log_info "Total models: $total_models"
    log_info "Successful: $((total_models - ${#failed_models[@]}))"
    log_info "Failed: ${#failed_models[@]}"
    
    if [ ${#failed_models[@]} -gt 0 ]; then
        log_warning "Failed models:"
        for model in "${failed_models[@]}"; do
            log_warning "  - $model"
        done
        return 1
    else
        log_success "All models downloaded/updated successfully!"
        return 0
    fi
}

# Function to list downloaded models
list_models() {
    log_info "Listing downloaded models..."
    
    if command -v ollama &> /dev/null; then
        ollama list
    else
        log_error "Ollama is not installed"
        return 1
    fi
}

# Function to get storage information
get_storage_info() {
    local models_path
    
    # Ollama stores models in ~/.ollama/models by default
    if [ -d "$HOME/.ollama/models" ]; then
        models_path="$HOME/.ollama/models"
    else
        log_warning "Could not find Ollama models directory"
        return 1
    fi
    
    log_info "Models storage location: $models_path"
    
    # Calculate storage usage
    local storage_used
    storage_used=$(du -sh "$models_path" 2>/dev/null | cut -f1)
    
    if [ -n "$storage_used" ]; then
        log_info "Storage used by models: $storage_used"
    fi
}

# Main download function
download_ai_models() {
    local drive_path="$1"
    
    log_info "========================================"
    log_info "AI Models Download - Ollama"
    log_info "========================================"
    log_info ""
    
    # Create models directory
    local models_dir="$drive_path/ai_models"
    mkdir -p "$models_dir"
    log_info "Models directory: $models_dir"
    log_info ""
    
    # Check if Ollama is installed
    if ! check_ollama_installed; then
        log_info "Ollama needs to be installed"
        
        if ! install_ollama; then
            log_error "Failed to install Ollama"
            return 1
        fi
        
        log_info ""
    fi
    
    # Ensure Ollama service is running
    ensure_ollama_service
    log_info ""
    
    # Download/update all models
    if ! download_all_models; then
        log_warning "Some models failed to download, but continuing"
    fi
    
    log_info ""
    
    # Display storage information
    get_storage_info
    log_info ""
    
    # List all models
    list_models
    log_info ""
    
    # Create a manifest file in the target directory
    local manifest_file="$models_dir/models_manifest.txt"
    log_info "Creating models manifest at: $manifest_file"
    {
        echo "AI Models Manifest"
        echo "Generated: $(date)"
        echo "========================================"
        echo ""
        ollama list 2>/dev/null || echo "Could not list models"
    } > "$manifest_file"
    
    log_success "AI models download completed!"
    log_info ""
    log_info "Note: Ollama stores models in ~/.ollama/models by default"
    log_info "To change the storage location, set the OLLAMA_MODELS environment variable"
    log_info "Example: export OLLAMA_MODELS=$models_dir"
    log_info ""
    
    return 0
}

# Main script execution
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    # Script is being executed directly
    if [ $# -lt 1 ]; then
        log_error "Usage: $0 <drive_path>"
        log_info "Example: $0 /mnt/external_drive"
        exit 1
    fi
    
    download_ai_models "$@"
fi
