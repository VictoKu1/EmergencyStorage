#!/bin/bash
# Test script for AI models (Ollama) download functionality

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

cd "$REPO_ROOT"

echo "========================================"
echo "Testing AI Models (Ollama) Manager"
echo "========================================"
echo

# Test 1: Check if Ollama.json exists
echo "Test 1: Checking if Ollama.json exists..."
if [ -f "data/Ollama.json" ]; then
    echo "✓ Ollama.json exists"
else
    echo "✗ Ollama.json not found"
    exit 1
fi
echo

# Test 2: Validate JSON structure
echo "Test 2: Validating JSON structure..."
if python3 -c "
import json
with open('data/Ollama.json', 'r') as f:
    data = json.load(f)
    assert isinstance(data, dict), 'Root must be a dictionary'
    assert 'models' in data, 'Must have models key'
    assert 'settings' in data, 'Must have settings key'
    assert isinstance(data['models'], dict), 'models must be a dictionary'
    assert isinstance(data['settings'], dict), 'settings must be a dictionary'
    print(f'✓ JSON structure valid')
    print(f'  - Total models: {len(data["models"])}')
" 2>&1; then
    echo "✓ JSON validation passed"
else
    echo "✗ JSON validation failed"
    exit 1
fi
echo

# Test 3: Validate required fields in models
echo "Test 3: Validating required fields in models..."
if python3 -c "
import json

with open('data/Ollama.json', 'r') as f:
    data = json.load(f)
    
    for model_key, model_info in data['models'].items():
        assert isinstance(model_info, dict), f'Model {model_key} must be dict'
        assert 'name' in model_info, f'name missing for model {model_key}'
        assert 'tags' in model_info, f'tags missing for model {model_key}'
        assert 'description' in model_info, f'description missing for model {model_key}'
        assert 'default_tag' in model_info, f'default_tag missing for model {model_key}'
        assert 'enabled' in model_info, f'enabled missing for model {model_key}'
        assert isinstance(model_info['name'], str), f'name must be string for model {model_key}'
        assert isinstance(model_info['tags'], list), f'tags must be list for model {model_key}'
        assert isinstance(model_info['description'], str), f'description must be string for model {model_key}'
        assert isinstance(model_info['default_tag'], str), f'default_tag must be string for model {model_key}'
        assert isinstance(model_info['enabled'], bool), f'enabled must be bool for model {model_key}'
    
    print('✓ All models have required fields (name, tags, description, default_tag, enabled)')
" 2>&1; then
    echo "✓ Field validation passed"
else
    echo "✗ Field validation failed"
    exit 1
fi
echo

# Test 4: Test script syntax
echo "Test 4: Checking script syntax..."
if bash -n scripts/models.sh 2>&1; then
    echo "✓ Script syntax valid"
else
    echo "✗ Script has syntax errors"
    exit 1
fi
echo

# Test 5: Test OLLAMA_MODELS environment variable is set in script
echo "Test 5: Verifying OLLAMA_MODELS handling..."
if grep -q "export OLLAMA_MODELS=" scripts/models.sh; then
    echo "✓ Script sets OLLAMA_MODELS environment variable"
else
    echo "✗ Script does not set OLLAMA_MODELS"
    exit 1
fi

if grep -q "OLLAMA_MODELS=\"\$models_dir\"" scripts/models.sh; then
    echo "✓ Script sets OLLAMA_MODELS to models_dir"
else
    echo "✗ Script does not set OLLAMA_MODELS to models_dir"
    exit 1
fi
echo

# Test 6: Verify helper script is created
echo "Test 6: Verifying helper script creation..."
if grep -q "run_ollama.sh" scripts/models.sh; then
    echo "✓ Script creates run_ollama.sh helper script"
else
    echo "✗ Script does not create helper script"
    exit 1
fi

if grep -q "chmod +x \"\$helper_script\"" scripts/models.sh; then
    echo "✓ Helper script is made executable"
else
    echo "✗ Helper script is not made executable"
    exit 1
fi
echo

# Test 7: Test that ensure_ollama_service accepts models_dir parameter
echo "Test 7: Verifying ensure_ollama_service function..."
if grep -q "ensure_ollama_service \"\$models_dir\"" scripts/models.sh; then
    echo "✓ ensure_ollama_service is called with models_dir parameter"
else
    echo "✗ ensure_ollama_service is not called with models_dir"
    exit 1
fi

if grep -A 5 "^ensure_ollama_service()" scripts/models.sh | grep -q "local models_dir="; then
    echo "✓ ensure_ollama_service function accepts models_dir parameter"
else
    echo "✗ ensure_ollama_service function does not accept models_dir parameter"
    exit 1
fi
echo

# Test 8: Test get_models_from_config function
echo "Test 8: Testing get_models_from_config function..."
if python3 -c "
import sys
sys.path.insert(0, 'scripts')

# Source the function from the script
import subprocess
result = subprocess.run(['bash', '-c', 'source scripts/models.sh && get_models_from_config'], 
                       capture_output=True, text=True, cwd='$REPO_ROOT')

if result.returncode == 0 and result.stdout.strip():
    models = result.stdout.strip().split('\n')
    print(f'✓ get_models_from_config returned {len(models)} model(s)')
    for model in models[:3]:  # Show first 3 models
        print(f'  - {model}')
    sys.exit(0)
else:
    print('✗ get_models_from_config failed')
    sys.exit(1)
" 2>&1; then
    echo "✓ get_models_from_config works correctly"
else
    echo "✗ get_models_from_config test failed"
    exit 1
fi
echo

# Test 9: Verify manifest file includes storage location
echo "Test 9: Verifying manifest file format..."
if grep -q "echo \"Storage Location: \$models_dir\"" scripts/models.sh; then
    echo "✓ Manifest includes storage location"
else
    echo "✗ Manifest does not include storage location"
    exit 1
fi
echo

# Test 10: Test storage path configuration
echo "Test 10: Verifying storage path configuration..."
if python3 -c "
import json

with open('data/Ollama.json', 'r') as f:
    data = json.load(f)
    settings = data.get('settings', {})
    
    if 'storage_path_suffix' in settings:
        print(f\"✓ Storage path suffix configured: {settings['storage_path_suffix']}\")
    else:
        print('✗ Storage path suffix not configured')
        exit(1)
" 2>&1; then
    echo "✓ Storage path configuration verified"
else
    echo "✗ Storage path configuration failed"
    exit 1
fi
echo

# Test 11: Test that script creates ai_models directory
echo "Test 11: Verifying ai_models directory creation..."
if grep -q "models_dir=\"\$drive_path/ai_models\"" scripts/models.sh; then
    echo "✓ Script creates ai_models directory in drive_path"
else
    echo "✗ Script does not create ai_models directory"
    exit 1
fi

if grep -q "mkdir -p \"\$models_dir\"" scripts/models.sh; then
    echo "✓ Script uses mkdir -p to create directory"
else
    echo "✗ Script does not use mkdir -p"
    exit 1
fi
echo

echo "========================================"
echo "All tests passed! ✓"
echo "========================================"
