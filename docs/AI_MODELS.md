# AI Models Documentation

## Overview

The AI Models functionality provides automatic installation and management of local AI models using [Ollama](https://ollama.com/). This feature enables you to download and store various open-source AI models for offline use, making them available for emergency situations or environments with limited internet connectivity.

## Features

- **Automatic Ollama Installation**: Automatically installs Ollama if not already present
- **Multi-Model Support**: Download multiple AI models in one operation
- **Update Management**: Checks for and downloads model updates
- **Flexible Configuration**: JSON-based configuration for easy model management
- **Storage Tracking**: Monitors and reports storage usage
- **Integrated with Emergency Storage**: Works seamlessly with the `--all` flag

## Supported Models

The following model families are pre-configured and ready to download:

### Language Models

| Model | Default Size | Description | Use Case |
|-------|--------------|-------------|----------|
| **deepseek-r1** | 7b | Reasoning model with exceptional performance in math, code, and logic | Complex problem solving, mathematical reasoning |
| **deepseek-v3** | latest | Large Mixture-of-Experts (MoE) model with 671B parameters | Advanced language tasks, research |
| **llama3.1** | 8b | Meta's Llama 3.1 with enhanced multilingual capabilities | General-purpose language tasks |
| **llama3.2** | 3b | Compact models optimized for edge deployment | Resource-constrained environments |
| **qwen2.5** | 7b | Alibaba's model with strong multilingual support | Multilingual applications |
| **mistral** | 7b | Efficient 7B parameter model | General-purpose, efficient inference |
| **mixtral** | 8x7b | Mixture of Experts model | Complex tasks requiring specialized knowledge |
| **gemma3** | 9b | Google's Gemma 3 with improved performance | Balanced performance and efficiency |
| **phi3** | mini | Microsoft's compact efficient models | Edge computing, mobile deployment |

### Code Models

| Model | Default Size | Description | Use Case |
|-------|--------------|-------------|----------|
| **codellama** | 7b | Meta's Code Llama specialized for programming | Code generation, debugging, documentation |

### Embedding Models

| Model | Description | Use Case |
|-------|-------------|----------|
| **nomic-embed-text** | High-quality text embeddings | Semantic search, RAG applications |
| **mxbai-embed-large** | Large embedding model | Advanced retrieval tasks |
| **all-minilm** | Compact sentence transformer | Efficient embeddings, similarity search |

## Quick Start

### Download All Models

```bash
# Download all configured AI models to external drive
./emergency_storage.sh --models /mnt/external_drive

# Download as part of all sources (includes AI models)
./emergency_storage.sh --all /mnt/external_drive

# Download to current directory
./emergency_storage.sh --models .
```

### Direct Script Usage

```bash
# Use the models script directly
./scripts/models.sh /mnt/external_drive
```

## Installation

### Prerequisites

- **Linux/macOS/WSL**: Ollama supports Linux, macOS, and Windows (via WSL)
- **Python 3**: Required for configuration parsing
- **curl**: Required for Ollama installation
- **Storage Space**: 5GB - 500GB depending on models selected

### Automatic Installation

The script automatically installs Ollama if it's not detected on your system:

```bash
./emergency_storage.sh --models /mnt/external_drive
```

The installation process:
1. Checks if Ollama is already installed
2. If not, downloads and runs the official Ollama installation script
3. Verifies the installation
4. Starts the Ollama service
5. Proceeds with model downloads

### Manual Installation

If you prefer to install Ollama manually:

```bash
# Official Ollama installation
curl -fsSL https://ollama.com/install.sh | sh

# Verify installation
ollama --version
```

## Configuration

### Configuration File: `data/Ollama.json`

The configuration file defines which models to download and how to manage them.

#### Structure

```json
{
  "models": {
    "model-name": {
      "name": "model-name",
      "tags": ["size1", "size2"],
      "description": "Model description",
      "default_tag": "size1",
      "enabled": true
    }
  },
  "settings": {
    "ollama_install_command": "curl -fsSL https://ollama.com/install.sh | sh",
    "download_all_tags": false,
    "check_for_updates": true,
    "parallel_downloads": false,
    "storage_path_suffix": "ai_models"
  }
}
```

#### Model Configuration Options

- **name**: Model identifier used by Ollama
- **tags**: Available model sizes/versions
- **description**: Human-readable description
- **default_tag**: Which size to download (when `download_all_tags` is false)
- **enabled**: Whether to include this model in downloads

#### Settings Options

- **ollama_install_command**: Command to install Ollama (default: official script)
- **download_all_tags**: If true, downloads all available sizes; if false, only default
- **check_for_updates**: Whether to check and download model updates
- **parallel_downloads**: Reserved for future use (sequential download recommended)
- **storage_path_suffix**: Subdirectory name for model storage

### Customizing Models

#### Disable a Model

```json
{
  "models": {
    "deepseek-v3": {
      "enabled": false
    }
  }
}
```

#### Change Default Size

```json
{
  "models": {
    "llama3.1": {
      "default_tag": "70b"
    }
  }
}
```

#### Download All Model Sizes

```json
{
  "settings": {
    "download_all_tags": true
  }
}
```

#### Add Custom Models

```json
{
  "models": {
    "your-custom-model": {
      "name": "your-custom-model",
      "tags": ["latest"],
      "description": "Your custom model description",
      "default_tag": "latest",
      "enabled": true
    }
  }
}
```

## Usage Examples

### Basic Usage

```bash
# Download all enabled models
./emergency_storage.sh --models /mnt/external_drive

# Check what models are installed
ollama list

# Test a model
ollama run llama3.1

# Update models (checks for new versions)
./emergency_storage.sh --models /mnt/external_drive
```

### Advanced Usage

```bash
# Download models with all other sources
./emergency_storage.sh --all /mnt/external_drive

# Use custom Ollama models directory
export OLLAMA_MODELS=/mnt/external_drive/ai_models
./emergency_storage.sh --models /mnt/external_drive

# Check specific model
ollama pull deepseek-r1:7b

# Remove a model to save space
ollama rm deepseek-v3
```

## Storage Management

### Storage Requirements

Model sizes vary significantly:

- **Small models (1-3B)**: 1-3 GB each
- **Medium models (7-9B)**: 4-7 GB each
- **Large models (13-32B)**: 8-20 GB each
- **Very large models (70B+)**: 40-200 GB each

**Recommended Storage**: At least 50GB for a basic collection, 200GB+ for comprehensive collection.

### Storage Location

By default, Ollama stores models in:
- **Linux**: `~/.ollama/models`
- **macOS**: `~/.ollama/models`
- **Windows (WSL)**: `~/.ollama/models`

#### Changing Storage Location

```bash
# Set custom storage location
export OLLAMA_MODELS=/mnt/external_drive/ai_models

# Make it permanent (add to ~/.bashrc or ~/.profile)
echo 'export OLLAMA_MODELS=/mnt/external_drive/ai_models' >> ~/.bashrc
```

### Checking Storage Usage

```bash
# View models and their sizes
ollama list

# Check storage usage of Ollama directory
du -sh ~/.ollama/models

# Or if using custom location
du -sh $OLLAMA_MODELS
```

### Cleaning Up Models

```bash
# Remove specific model
ollama rm model-name:tag

# Remove all versions of a model
ollama rm model-name

# List models to see what can be removed
ollama list
```

## Model Updates

The script automatically checks for updates when run:

1. For existing models, it runs `ollama pull` to check for updates
2. Downloads updates if available
3. Reports update status

To manually update a specific model:

```bash
ollama pull model-name:tag
```

## Troubleshooting

### Common Issues

#### Ollama Installation Fails

**Problem**: Installation script fails or Ollama is not accessible

**Solutions**:
```bash
# Check if curl is installed
which curl

# Manually download and run installation
curl -fsSL https://ollama.com/install.sh -o install-ollama.sh
chmod +x install-ollama.sh
./install-ollama.sh

# Check installation
ollama --version
```

#### Ollama Service Not Running

**Problem**: Models fail to download with connection errors

**Solutions**:
```bash
# Start Ollama service manually
ollama serve &

# Check if service is running
pgrep ollama

# Or use systemd (if available)
sudo systemctl start ollama
```

#### Model Download Fails

**Problem**: Specific model fails to download

**Solutions**:
```bash
# Check available models on Ollama website
# https://ollama.com/library

# Try downloading manually
ollama pull model-name:tag

# Check Ollama logs
ollama list

# Verify internet connection
ping ollama.com
```

#### Insufficient Storage Space

**Problem**: Downloads fail due to lack of space

**Solutions**:
```bash
# Check available space
df -h

# Remove unused models
ollama rm unused-model

# Disable large models in config
# Edit data/Ollama.json and set "enabled": false for large models

# Change storage location to larger drive
export OLLAMA_MODELS=/path/to/larger/drive
```

#### Permission Errors

**Problem**: Cannot write to models directory

**Solutions**:
```bash
# Check directory permissions
ls -ld ~/.ollama/models

# Fix permissions if needed
chmod -R 755 ~/.ollama

# Or change to a directory where you have permissions
export OLLAMA_MODELS=/tmp/ollama_models
mkdir -p $OLLAMA_MODELS
```

### Verification

Test that everything works:

```bash
# Verify Ollama installation
ollama --version

# List downloaded models
ollama list

# Test a small model
ollama run phi3:mini
# Type: "Hello, how are you?" and press Enter
# Exit with: /bye

# Check logs
cat /tmp/ollama_pull_*.log
```

## Integration with Emergency Storage

### Included in --all Flag

When you run:
```bash
./emergency_storage.sh --all /mnt/external_drive
```

The AI models are automatically downloaded along with:
- Kiwix mirror
- OpenZIM files
- OpenStreetMap data
- Internet Archive collections
- Git repositories

### Excluding from --all

If you want to skip AI models when using `--all`, temporarily disable them in the configuration:

```json
{
  "models": {
    "deepseek-r1": {
      "enabled": false
    }
  }
}
```

Or comment out the "models" entry in the sources array of `emergency_storage.sh`.

## Best Practices

### 1. Start Small

Begin with smaller models to test your setup:
- `phi3:mini` (1.9 GB)
- `llama3.2:3b` (2 GB)
- `mistral:7b` (4.1 GB)

### 2. Plan Your Storage

Before downloading:
```bash
# Check available space
df -h /mnt/external_drive

# Estimate storage needs based on enabled models
# Review data/Ollama.json and calculate required space
```

### 3. Use Update Checks

Regularly update models to get improvements:
```bash
# Weekly or monthly
./emergency_storage.sh --models /mnt/external_drive
```

### 4. Test Models After Download

Verify models work correctly:
```bash
ollama run model-name
# Run a simple test query
```

### 5. Backup Configuration

Keep a backup of your customized `data/Ollama.json`:
```bash
cp data/Ollama.json data/Ollama.json.backup
```

### 6. Document Your Setup

Keep notes about:
- Which models you're using
- Storage locations
- Custom configurations
- Use cases for each model

## Use Cases

### Emergency Offline AI

In emergency situations with limited internet:
- Code assistance and debugging
- Document generation
- Translation services
- Question answering
- Text analysis

### Development Environments

For developers without reliable internet:
- Code completion
- Documentation generation
- Bug analysis
- Code review assistance

### Research and Education

For educational institutions:
- Research assistance
- Student projects
- Offline language models
- Computational linguistics

### Private/Secure Environments

For sensitive environments:
- No data leaves your network
- Fully offline operation
- Privacy-preserving AI
- Compliance with data regulations

## API Usage

Once models are downloaded, you can use them via:

### Command Line
```bash
ollama run llama3.1
```

### REST API
```bash
curl http://localhost:11434/api/generate -d '{
  "model": "llama3.1",
  "prompt": "Why is the sky blue?"
}'
```

### Python
```python
import requests

response = requests.post('http://localhost:11434/api/generate',
    json={
        'model': 'llama3.1',
        'prompt': 'Why is the sky blue?'
    })
print(response.json())
```

## Additional Resources

- **Ollama Documentation**: https://github.com/ollama/ollama/tree/main/docs
- **Ollama Library**: https://ollama.com/library
- **Model Cards**: Check individual model pages for capabilities and limitations
- **Community**: https://discord.gg/ollama

## Support

For issues specific to:
- **Ollama**: Visit https://github.com/ollama/ollama/issues
- **EmergencyStorage AI Models**: Open an issue at https://github.com/VictoKu1/EmergencyStorage/issues
- **Model-specific problems**: Check the model's page on ollama.com/library

## License

The AI Models functionality is part of EmergencyStorage. Individual models have their own licenses - check each model's page on ollama.com/library for details.

---

**Last Updated**: 2025-10-15
**Version**: 1.0.0
**Maintainer**: EmergencyStorage Project
