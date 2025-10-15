# AI Models Quick Reference

**Purpose:** Download and manage local AI models using Ollama for offline usage in emergency situations.

## Quick Commands

```bash
# Download all AI models
./emergency_storage.sh --models /mnt/external_drive

# Download as part of everything
./emergency_storage.sh --all /mnt/external_drive

# List downloaded models
ollama list

# Test a model
ollama run llama3.1

# Update models
./emergency_storage.sh --models /mnt/external_drive

# Remove a model
ollama rm model-name:tag
```

## Pre-configured Models

| Category | Models | Default Size |
|----------|--------|--------------|
| **Reasoning** | deepseek-r1, deepseek-v3 | 7b, latest |
| **General** | llama3.1, llama3.2, qwen2.5, mistral, mixtral, gemma2, phi3 | 8b, 3b, 7b, 7b, 8x7b, 9b, mini |
| **Code** | codellama | 7b |
| **Embeddings** | nomic-embed-text, mxbai-embed-large, all-minilm | latest, latest, l6-v2 |

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

**Default Location:** `~/.ollama/models`

**Custom Location:**
```bash
export OLLAMA_MODELS=/mnt/external_drive/ai_models
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
| Service not running | Run `ollama serve &` |
| Model download fails | Check internet, try `ollama pull model-name` |
| Insufficient space | Remove unused models with `ollama rm model-name` |
| Permission errors | Change storage location or fix permissions on `~/.ollama` |

## Usage Examples

```bash
# Interactive chat
ollama run llama3.1
> Hello, how are you?
> /bye

# API call
curl http://localhost:11434/api/generate -d '{
  "model": "llama3.1",
  "prompt": "Explain quantum computing"
}'

# Change storage location
export OLLAMA_MODELS=/mnt/external_drive/ai_models
./emergency_storage.sh --models /mnt/external_drive
```

## Features

- ✅ Automatic Ollama installation
- ✅ Multi-model support
- ✅ Update checking
- ✅ JSON configuration
- ✅ Storage tracking
- ✅ Integrated with `--all` flag

## See Also

- [Full Documentation](AI_MODELS.md)
- [Main README](../README.md)
- [Ollama Official Docs](https://github.com/ollama/ollama/tree/main/docs)
