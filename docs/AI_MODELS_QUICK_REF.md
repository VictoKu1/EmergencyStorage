# AI Models Quick Reference

**Purpose:** Download and manage local AI models using Ollama for offline usage in emergency situations.

**Key Feature:** Models are automatically stored on your specified drive (e.g., external HDD) to prevent system storage overflow on Raspberry Pi. Helper script makes models portable across PCs.

## Quick Commands

```bash
# Download all AI models (automatically uses external drive)
./emergency_storage.sh --models /mnt/external_drive

# Download as part of everything
./emergency_storage.sh --all /mnt/external_drive

# Use portable helper script (created automatically)
cd /mnt/external_drive/ai_models
./run_ollama.sh

# List downloaded models
ollama list

# Test a model
ollama run llama3.1

# Update models
./emergency_storage.sh --models /mnt/external_drive

# Remove a model
ollama rm model-name:tag
```

## Configuration

**File:** `data/Ollama.json`

```json
{
  "models": {
    "model-name": {
      "enabled": true,
      "default_tag": "7b"
    }
  },
  "settings": {
    "download_all_tags": false,
    "check_for_updates": true
  }
}
```

## Storage

**Important:** EmergencyStorage automatically stores models on your target drive to prevent system storage overflow.

**Automatic Location:** `/path/to/drive/ai_models` (e.g., `/mnt/external_drive/ai_models`)

**Portable Usage:**
```bash
# Use helper script on any PC
cd /mnt/external_drive/ai_models
./run_ollama.sh
```

**Sizes:**
- Small (1-3B): 1-3 GB
- Medium (7-9B): 4-7 GB
- Large (13-32B): 8-20 GB
- XLarge (70B+): 40-200 GB

## Troubleshooting

| Issue | Solution |
|-------|----------|
| Ollama not installed | Run `./emergency_storage.sh --models /path` to auto-install |
| Service not running | Run `ollama serve &` or use `run_ollama.sh` helper script |
| Model download fails | Check internet, try `ollama pull model-name` |
| Insufficient space | Remove unused models with `ollama rm model-name`. Models stored on external drive. |
| Permission errors | Check drive permissions. Helper script handles paths automatically. |
| Models on system drive | Script automatically uses external drive. Check `echo $OLLAMA_MODELS` |

## Usage Examples

```bash
# Download models to external drive (prevents SD card overflow on Raspberry Pi)
./emergency_storage.sh --models /mnt/external_drive

# Use portable helper script on any PC
cd /mnt/external_drive/ai_models
./run_ollama.sh

# Interactive chat
ollama run llama3.1
> Hello, how are you?
> /bye

# API call
curl http://localhost:11434/api/generate -d '{
  "model": "llama3.1",
  "prompt": "Explain quantum computing"
}'

# Verify storage location
echo $OLLAMA_MODELS
# Should show: /mnt/external_drive/ai_models
```

## Features

- ✅ Automatic Ollama installation
- ✅ Multi-model support
- ✅ Update checking
- ✅ JSON configuration
- ✅ Storage tracking
- ✅ Integrated with `--all` flag
- ✅ External storage support (prevents system overflow)
- ✅ Portable across PCs (helper script included)

## See Also

- [Full Documentation](AI_MODELS.md)
- [Main README](../README.md)
- [Ollama Official Docs](https://github.com/ollama/ollama/tree/main/docs)
