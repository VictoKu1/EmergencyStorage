# EmergencyStorage

A modular project designed to run on Raspberry Pi (or any other Linux PC) with a connected HDD, providing scripts that download/mirror emergency data from multiple sources.

## Architecture

EmergencyStorage now uses a **modular architecture** with individual scripts for each data source:

- **`emergency_storage.sh`** - Main coordinator script that calls individual source scripts
- **`scripts/common.sh`** - Shared utility functions and colored logging system
- **`scripts/kiwix.sh`** - Kiwix mirror download functionality
- **`scripts/openzim.sh`** - OpenZIM files download functionality  
- **`scripts/openstreetmap.sh`** - OpenStreetMap data download functionality
- **`scripts/ia-software.sh`** - Internet Archive software collection
- **`scripts/ia-music.sh`** - Internet Archive music collection
- **`scripts/ia-movies.sh`** - Internet Archive movies collection
- **`scripts/ia-texts.sh`** - Internet Archive texts/academic papers collection

This modular design allows for:
- **Better maintainability** - Each source has its own focused script
- **Independent testing** - Individual scripts can be tested and debugged separately
- **Professional code structure** - Clean separation of concerns
- **Enhanced logging** - Colored output with consistent formatting
- **Easier contributions** - Developers can work on individual components

## Features

- **Modular Architecture**: Each data source has its own specialized script for better maintainability
- **Professional Logging**: Color-coded output with consistent formatting across all scripts
- **Kiwix Mirror**: Downloads the complete Kiwix library mirror using rsync with fallback mirrors
- **OpenZIM**: Downloads ZIM files from OpenZIM containing offline content (Wikipedia, educational content, etc.)
- **OpenStreetMap Data**: Downloads the latest planet OSM data file (~70GB+)
- **Internet Archive Software**: Downloads software preservation collections (games, applications, historical software)
- **Internet Archive Music**: Downloads music collections (Creative Commons, public domain, live concerts)
- **Internet Archive Movies**: Downloads movie collections (public domain films, documentaries, educational content)
- **Internet Archive Texts**: Downloads scientific texts and academic papers (books, research papers, government documents)
- **All Sources**: Downloads from all sources in sequence with error handling and reporting

## Prerequisites

- Linux system (tested on Raspberry Pi)
- Connected external drive with sufficient storage space (Recommended 10TB-15TB or more)
- Stable Connection (Using Ethernet Cable Highly Recommended)
- Required tools:
  - `rsync` (for Kiwix mirror and OpenZIM)
  - `curl` (for OpenStreetMap download and Internet Archive collections)
  - `wget` (optional, for HTTP/FTP mirror fallback)

Install dependencies on Debian/Ubuntu:
```bash
sudo apt-get update
sudo apt-get install rsync curl wget
```

## Individual Script Usage

Each data source can be downloaded independently using its dedicated script:

```bash
# Make scripts executable (if needed)
chmod +x scripts/*.sh

# Individual script usage examples
./scripts/kiwix.sh /mnt/external_drive true        # Kiwix with mirror fallback
./scripts/openzim.sh /mnt/external_drive           # OpenZIM files
./scripts/openstreetmap.sh /mnt/external_drive     # OpenStreetMap data
./scripts/ia-software.sh /mnt/external_drive       # IA Software collection
./scripts/ia-music.sh /mnt/external_drive          # IA Music collection
./scripts/ia-movies.sh /mnt/external_drive         # IA Movies collection
./scripts/ia-texts.sh /mnt/external_drive          # IA Texts collection
```

## Main Script Usage

The main `emergency_storage.sh` script coordinates all individual scripts and provides a unified interface:

Make the script executable:
```bash
chmod +x emergency_storage.sh
```

**Simple Usage (Recommended):**
```bash
# Download all sources to current directory (default behavior)
./emergency_storage.sh

# Download all sources to specific directory
./emergency_storage.sh /mnt/external_drive
```

**Advanced Usage:**
```bash
# Specify sources explicitly
./emergency_storage.sh --[sources] [drive_address]
```

### Available Sources

- `--all` - Download from all sources (default when no flags specified)
- `--kiwix` - Download Kiwix mirror only
- `--openzim` - Download OpenZIM files only
- `--openstreetmap` - Download OpenStreetMap data only
- `--ia-software` - Download Internet Archive software collection only
- `--ia-music` - Download Internet Archive music collection only
- `--ia-movies` - Download Internet Archive movies collection only
- `--ia-texts` - Download Internet Archive scientific texts only  

### Examples

```bash
# Simple: Download everything to current directory
./emergency_storage.sh

# Simple: Download everything to external drive
./emergency_storage.sh /mnt/external_drive

# Advanced: Download only Kiwix mirror to external drive
./emergency_storage.sh --kiwix /mnt/external_drive

# Advanced: Download only OpenZIM files to external drive
./emergency_storage.sh --openzim /mnt/external_drive

# Advanced: Download only OpenStreetMap data to external drive
./emergency_storage.sh --openstreetmap /mnt/external_drive

# Advanced: Download only Internet Archive software to external drive  
./emergency_storage.sh --ia-software /mnt/external_drive

# Advanced: Download only Internet Archive music to external drive
./emergency_storage.sh --ia-music /mnt/external_drive

# Advanced: Download only Internet Archive movies to external drive
./emergency_storage.sh --ia-movies /mnt/external_drive

# Advanced: Download only Internet Archive texts to external drive
./emergency_storage.sh --ia-texts /mnt/external_drive

# Advanced: Explicitly download everything to external drive
./emergency_storage.sh --all /mnt/external_drive

# Show help
./emergency_storage.sh --help
```

## Storage Requirements

- **Kiwix Mirror**: Usually +7TB for all ZIM files (typically several GB to TB depending on content)
- **OpenZIM**: Usually +1TB for all files (typically several GB to TB, includes Wikipedia and educational content)
- **OpenStreetMap Planet**: ~70GB+ (compressed PBF format)
- **Internet Archive Software**: 50GB - 500GB (depending on collections selected)
- **Internet Archive Music**: 100GB - 1TB (depending on collections selected)
- **Internet Archive Movies**: 500GB - 5TB (depending on collections selected)
- **Internet Archive Texts**: 100GB - 2TB (depending on collections selected)
- **Recommended**: At least 1TB+ free space for comfortable operation with all sources

## What Gets Downloaded

### Kiwix Mirror
The script creates a `kiwix-mirror/` directory and syncs content from:
```
master.download.kiwix.org::download.kiwix.org/
```

### OpenZIM
The script creates an `openzim/` directory and syncs content from:
```
download.openzim.org::download.openzim.org/
```
This includes ZIM files containing offline content such as Wikipedia, educational materials, and other reference content in compressed format.

### OpenStreetMap
The script creates an `openstreetmap/` directory and downloads:
```
https://planet.openstreetmap.org/pbf/planet-latest.osm.pbf
```

### Internet Archive Software
The script creates an `internet-archive-software/` directory and downloads:
- MS-DOS Games and Software
- Windows 3.x Software Library
- Historical Software Collections
- Open Source Software
- Console Living Room (Game Console Software)

### Internet Archive Music  
The script creates an `internet-archive-music/` directory and downloads:
- Open Source Audio Collections
- Community Audio
- Net Labels
- Live Concert Archive (etree.org)
- Radio Programs
- Audio Books & Poetry

### Internet Archive Movies
The script creates an `internet-archive-movies/` directory and downloads:
- Prelinger Archives (industrial/educational films)
- Classic TV Shows
- Public Domain Feature Films
- Animation Films
- Documentaries

### Internet Archive Texts
The script creates an `internet-archive-texts/` directory and downloads:
- Project Gutenberg (public domain literature)
- Biodiversity Heritage Library (biological sciences)
- Medical Heritage Library (historical medical texts)
- Academic papers and research materials
- Open access texts and technical documentation
- Government documents (public domain)
- Subject-specific collections (mathematics, physics, chemistry, biology, etc.)

## Development and Contribution

### Project Structure
```
EmergencyStorage/
├── emergency_storage.sh          # Main coordinator script
├── scripts/
│   ├── common.sh                 # Shared utilities and logging
│   ├── kiwix.sh                  # Kiwix mirror functionality
│   ├── openzim.sh                # OpenZIM functionality
│   ├── openstreetmap.sh          # OpenStreetMap functionality
│   ├── ia-software.sh            # Internet Archive software
│   ├── ia-music.sh               # Internet Archive music
│   ├── ia-movies.sh              # Internet Archive movies
│   └── ia-texts.sh               # Internet Archive texts
├── README.md                     # This documentation
└── LICENSE                       # MIT License
```

### Adding New Data Sources

EmergencyStorage provides a comprehensive template system for adding new data sources easily and consistently. The `new_resource.sh` template includes everything needed to implement a new data source without understanding the entire codebase structure.

#### Quick Start

1. **Copy and customize the template:**
   ```bash
   cp new_resource.sh scripts/my-data-source.sh
   ```

2. **Follow the CUSTOMIZE: comments** in the template file

3. **Integrate with the main script** using the embedded integration guide

4. **Test your implementation** independently and with the main script

#### Complete Documentation

**📖 For comprehensive instructions, examples, and best practices, see:**
- **[`NEW_RESOURCE_README.md`](NEW_RESOURCE_README.md)** - Complete template documentation with:
  - Detailed step-by-step guide
  - Template features and customization points
  - Integration guide with exact code snippets
  - Testing procedures and troubleshooting
  - Example implementations and best practices
  - Template completion checklist

- **`examples/research-papers.sh`** - Working example implementation

This detailed documentation contains everything you need to successfully add a new data source, including error handling patterns, integration points, and comprehensive testing procedures.

### Code Style Guidelines
- Use `#!/bin/bash` shebang
- Include `set -e` for error handling
- Source `scripts/common.sh` for utilities
- Use consistent logging with color-coded output
- Validate inputs and provide helpful error messages
- Create informative README files for each collection
- Add comprehensive comments explaining complex logic

## Contributing

We welcome contributions to EmergencyStorage! Whether you're fixing bugs, adding new data sources, improving documentation, or enhancing existing features, your contributions help make emergency preparedness more accessible.

### Ways to Contribute

#### 🐛 Bug Reports and Feature Requests
- **Bug Reports**: Open an issue with detailed steps to reproduce, expected vs actual behavior, and system information
- **Feature Requests**: Propose new data sources, improvements, or tools that would benefit emergency preparedness
- **Documentation**: Help improve documentation, fix typos, or add examples

#### 💻 Code Contributions

##### Adding New Data Sources
The easiest way to contribute a new data source:
1. Use the `new_resource.sh` template system (see "Adding New Data Sources" above and **[`NEW_RESOURCE_README.md`](NEW_RESOURCE_README.md)** for complete guidance)
2. Follow the integration guide and testing procedures
3. Submit a pull request with your new data source

##### Improving Existing Features
- Enhance download reliability and error handling
- Add new mirror sources for existing data sources
- Improve performance and efficiency
- Add new command-line options or features

##### Code Quality Improvements
- Fix bugs in existing scripts
- Improve error messages and user experience
- Add unit tests or integration tests
- Refactor code for better maintainability

### Development Setup

#### Prerequisites
```bash
# Install development dependencies
sudo apt-get update
sudo apt-get install rsync curl wget git shellcheck

# Optional: Install development tools
sudo apt-get install tree jq
```

#### Getting Started
1. **Fork and clone the repository:**
   ```bash
   git clone https://github.com/YOUR_USERNAME/EmergencyStorage.git
   cd EmergencyStorage
   ```

2. **Make scripts executable:**
   ```bash
   chmod +x emergency_storage.sh scripts/*.sh
   ```

3. **Test the existing functionality:**
   ```bash
   # Test main script help
   ./emergency_storage.sh --help
   
   # Test individual scripts
   ./scripts/kiwix.sh --help 2>/dev/null || echo "Test basic execution"
   ```

#### Development Workflow

1. **Create a feature branch:**
   ```bash
   git checkout -b feature/your-feature-name
   # or
   git checkout -b fix/bug-description
   ```

2. **Make your changes:**
   - Follow the existing code style and patterns
   - Test changes frequently during development
   - Use the template system for new data sources

3. **Test thoroughly:**
   ```bash
   # Test your changes with various scenarios
   ./scripts/your-script.sh /tmp/test_directory
   ./emergency_storage.sh --your-source /tmp/test_directory
   
   # Test error conditions
   ./scripts/your-script.sh /invalid/path
   ./scripts/your-script.sh  # No arguments
   ```

4. **Lint your code (if shellcheck is available):**
   ```bash
   shellcheck *.sh scripts/*.sh
   ```

5. **Commit your changes:**
   ```bash
   git add .
   git commit -m "Add: Brief description of changes"
   
   # Use conventional commit prefixes:
   # Add: New features or data sources
   # Fix: Bug fixes
   # Docs: Documentation changes
   # Refactor: Code improvements without functionality changes
   # Test: Adding or improving tests
   ```

6. **Push and create a pull request:**
   ```bash
   git push origin feature/your-feature-name
   ```
   Then create a pull request on GitHub with a clear description.

### Pull Request Guidelines

#### Before Submitting
- [ ] Changes are tested on a Linux system (preferably Raspberry Pi or similar)
- [ ] All scripts execute without errors
- [ ] New data sources follow the template pattern
- [ ] Integration with main script works correctly
- [ ] Documentation is updated (README.md, script comments)
- [ ] Error handling is comprehensive
- [ ] Network failures are handled gracefully

#### Pull Request Description
Include in your PR description:
- **What**: Brief summary of changes
- **Why**: Reason for the change or problem being solved
- **Testing**: How you tested the changes
- **Breaking Changes**: Any changes that might affect existing users
- **Documentation**: What documentation was added or updated

#### Example PR Description
```markdown
## Add Weather Data Source

### What
Adds a new data source for weather emergency data from NOAA.

### Why  
Weather data is crucial for emergency preparedness and disaster response.

### Changes
- Added `scripts/weather-data.sh` using the template system
- Integrated with main `emergency_storage.sh` script
- Added comprehensive README and documentation
- Includes fallback mirrors for reliability

### Testing
- Tested independent script execution
- Tested integration with main script
- Tested error handling with invalid paths and network issues
- Verified on Raspberry Pi 4 with external drive

### Documentation
- Updated README.md with weather data information
- Added detailed comments in the script
- Created collection-specific documentation
```

### Code Review Process

1. **Automated checks**: PRs are reviewed for basic functionality
2. **Manual review**: Core maintainers review code quality and adherence to patterns
3. **Testing**: Changes are tested in various environments
4. **Feedback**: Constructive feedback is provided for improvements
5. **Merge**: Once approved, changes are merged into the main branch

### Community Guidelines

- **Be respectful**: Treat all contributors with respect and courtesy
- **Be constructive**: Provide helpful feedback and suggestions
- **Be patient**: Reviews and responses may take time
- **Be collaborative**: Work together to improve the project
- **Stay focused**: Keep discussions relevant to the project and specific issues

### Getting Help

If you need help contributing:
- **Issues**: Check existing issues for similar problems or questions
- **Discussions**: Use GitHub Discussions for general questions
- **Template Documentation**: See **[`NEW_RESOURCE_README.md`](NEW_RESOURCE_README.md)** for comprehensive guidance on adding new data sources
- **Examples**: Review existing scripts in the `scripts/` directory and `examples/` folder

### Recognition

Contributors are recognized through:
- GitHub contributor statistics
- Credit in commit messages and release notes
- Recognition in project documentation for significant contributions

Thank you for helping make emergency preparedness more accessible to everyone!

## Error Handling and Logging

The refactored scripts include comprehensive error handling and professional logging:

### Logging Features
- **Color-coded output**: Different colors for info, success, warning, and error messages
- **Consistent formatting**: All scripts use the same logging system from `scripts/common.sh`
- **Progress reporting**: Clear indication of what each script is doing
- **Error reporting**: Detailed error messages with suggestions for resolution

### Error Handling
- **Individual script failures**: Main script continues with other sources if one fails
- **Network connectivity**: Graceful handling of internet connection issues
- **Missing dependencies**: Clear messages about required tools
- **Invalid paths**: Validation and creation of target directories
- **Insufficient permissions**: Permission checks before attempting operations
- **Mirror fallback**: Automatic fallback to alternative mirrors for Kiwix

### Script Architecture Benefits
- **Modularity**: Each script handles one specific data source
- **Maintainability**: Easy to update individual components
- **Testability**: Scripts can be tested independently
- **Reusability**: Individual scripts can be used in other projects
- **Professional structure**: Clean code organization with proper documentation

## License

MIT License - see LICENSE file for details.
