# Contributing to EmergencyStorage

We welcome contributions! Whether you're fixing bugs, adding new data sources, improving documentation, or enhancing existing features, your contributions help make emergency preparedness more accessible.

## Ways to Contribute

### 🐛 Bug Reports and Feature Requests

- **Bug Reports**: Open an issue with detailed steps to reproduce, expected vs actual behavior, and system information
- **Feature Requests**: Propose new data sources, improvements, or tools that would benefit emergency preparedness
- **Documentation**: Help improve documentation, fix typos, or add examples

### 💻 Code Contributions

#### Adding New Data Sources

The easiest way to contribute a new data source:
1. Use the `new_resource.sh` template system (see [Adding Data Sources](ADDING_SOURCES.md))
2. Follow the integration guide and testing procedures
3. Submit a pull request with your new data source

#### Improving Existing Features

- Enhance download reliability and error handling
- Add new mirror sources for existing data sources
- Improve performance and efficiency
- Add new command-line options or features

#### Code Quality Improvements

- Fix bugs in existing scripts
- Improve error messages and user experience
- Add unit tests or integration tests
- Refactor code for better maintainability

## Development Setup

### Prerequisites

```bash
# Install development dependencies
sudo apt-get update
sudo apt-get install rsync curl wget git shellcheck

# Optional: Install development tools
sudo apt-get install tree jq
```

### Getting Started

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

## Development Workflow

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

## Code Style Guidelines

- Use `#!/bin/bash` shebang
- Include `set -e` for error handling
- Source `scripts/common.sh` for utilities
- Use consistent logging with color-coded output
- Validate inputs and provide helpful error messages
- Create informative README files for each collection
- Add comprehensive comments explaining complex logic

## Pull Request Guidelines

### Before Submitting

- [ ] Changes are tested on a Linux system (preferably Raspberry Pi or similar)
- [ ] All scripts execute without errors
- [ ] New data sources follow the template pattern
- [ ] Integration with main script works correctly
- [ ] Documentation is updated (README.md, script comments)
- [ ] Error handling is comprehensive
- [ ] Network failures are handled gracefully

### Pull Request Description

Include in your PR description:
- **What**: Brief summary of changes
- **Why**: Reason for the change or problem being solved
- **Testing**: How you tested the changes
- **Breaking Changes**: Any changes that might affect existing users
- **Documentation**: What documentation was added or updated

### Example PR Description

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

## Code Review Process

1. **Automated checks**: PRs are reviewed for basic functionality
2. **Manual review**: Core maintainers review code quality and adherence to patterns
3. **Testing**: Changes are tested in various environments
4. **Feedback**: Constructive feedback is provided for improvements
5. **Merge**: Once approved, changes are merged into the main branch

## Community Guidelines

- **Be respectful**: Treat all contributors with respect and courtesy
- **Be constructive**: Provide helpful feedback and suggestions
- **Be patient**: Reviews and responses may take time
- **Be collaborative**: Work together to improve the project
- **Stay focused**: Keep discussions relevant to the project and specific issues

## Getting Help

If you need help contributing:
- **Issues**: Check existing issues for similar problems or questions
- **Discussions**: Use GitHub Discussions for general questions
- **Template Documentation**: See [Adding Data Sources](ADDING_SOURCES.md) for comprehensive guidance
- **Examples**: Review existing scripts in the `scripts/` directory and `examples/` folder

## Recognition

Contributors are recognized through:
- GitHub contributor statistics
- Credit in commit messages and release notes
- Recognition in project documentation for significant contributions

Thank you for helping make emergency preparedness more accessible to everyone!
