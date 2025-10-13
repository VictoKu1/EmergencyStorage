# EmergencyStorage Documentation

Welcome to the comprehensive documentation for EmergencyStorage! This documentation is organized to help you quickly find what you need.

## 📚 Documentation Index

### Getting Started

- **[Installation Guide](INSTALLATION.md)** - How to set up EmergencyStorage
  - System requirements and dependencies
  - Installation steps
  - Storage setup
  - Troubleshooting installation issues

- **[Usage Guide](USAGE.md)** - How to use EmergencyStorage
  - Main script usage with examples
  - Individual script usage
  - Automatic updates with resource flags
  - Tips for optimal usage
  - Command-line options

- **[Automatic Updates](AUTO_UPDATE.md)** - Schedule and automate resource updates
  - Configuration and setup
  - Resource flags (--resource1, --resource2, etc.)
  - Scheduling with GitHub Actions or cron
  - Changing update times and frequencies
  - Examples and troubleshooting

- **[Automatic Updates Setup Guide](AUTO_UPDATE_SETUP_GUIDE.md)** - Quick guide for local setup
  - One-command setup for Linux
  - How persistence works
  - Verification and testing
  - Troubleshooting common issues

- **[Automatic Updates Quick Reference](AUTO_UPDATE_QUICK_REF.md)** - Quick commands and settings
  - Common commands
  - Configuration examples
  - Scheduling quick reference

- **[Manual Sources Quick Reference](MANUAL_SOURCES_QUICK_REF.md)** - Quick manual sources configuration
  - Quick commands
  - JSON structure examples
  - Testing and troubleshooting

- **[Git Repositories Quick Reference](GIT_REPOSITORIES_QUICK_REF.md)** - Quick Git repository management
  - Quick commands
  - Configuration templates
  - Common clone arguments

### Understanding the System

- **[Architecture](ARCHITECTURE.md)** - System design and structure
  - Core components overview
  - Project file structure
  - Design benefits and rationale
  - How the system works

- **[Storage Requirements](STORAGE.md)** - Planning your storage
  - Size estimates for each data source
  - What content gets downloaded
  - Storage planning recommendations

- **[Manual Sources](MANUAL_SOURCES.md)** - Configure manual download sources
  - When to use manual sources
  - Configuration file structure
  - Download behavior and fallback
  - Examples for different tools

- **[Git Repositories](GIT_REPOSITORIES.md)** - Clone and manage Git repositories in parallel
  - Overview and features
  - Configuration file structure
  - Operations (clone, update, both)
  - Error handling and logging

- **[Mirror System](MIRROR_SYSTEM.md)** - Dynamic mirror management
  - How automatic mirror updates work
  - Manual mirror updates
  - Mirror fallback system
  - Troubleshooting mirror issues

- **[Error Handling](ERROR_HANDLING.md)** - Logging and error management
  - Color-coded logging system
  - Error handling mechanisms
  - Script architecture benefits
  - Debugging tips

### Contributing

- **[Contributing Guide](CONTRIBUTING.md)** - How to contribute
  - Ways to contribute
  - Development setup
  - Development workflow
  - Code style guidelines
  - Pull request process
  - Community guidelines

- **[Adding Data Sources](ADDING_SOURCES.md)** - Template system guide
  - Quick start with templates
  - Template features and customization
  - Integration guide
  - Testing your implementation
  - Best practices and examples

## 🔍 Quick Navigation

### I want to...

**...get started quickly**
→ Start with [Installation Guide](INSTALLATION.md), then [Usage Guide](USAGE.md)

**...set up automatic updates**
→ See [Setup Guide](AUTO_UPDATE_SETUP_GUIDE.md), [Automatic Updates](AUTO_UPDATE.md), or [Quick Reference](AUTO_UPDATE_QUICK_REF.md)

**...understand how it works**
→ Read [Architecture](ARCHITECTURE.md)

**...know storage requirements**
→ Check [Storage Requirements](STORAGE.md)

**...contribute code or add new sources**
→ See [Contributing Guide](CONTRIBUTING.md) and [Adding Data Sources](ADDING_SOURCES.md)

**...fix an error or debug issues**
→ Check [Error Handling](ERROR_HANDLING.md)

**...work with mirrors**
→ Read [Mirror System](MIRROR_SYSTEM.md)

**...configure manual downloads**
→ See [Manual Sources](MANUAL_SOURCES.md) or [Quick Reference](MANUAL_SOURCES_QUICK_REF.md)

**...manage Git repositories**
→ Read [Git Repositories](GIT_REPOSITORIES.md) or [Quick Reference](GIT_REPOSITORIES_QUICK_REF.md)

## 📝 Additional Resources

- **[Main README](../README.md)** - Project overview and quick start
- **[NEW_RESOURCE_README.md](../NEW_RESOURCE_README.md)** - Detailed template documentation
- **[License](../LICENSE)** - MIT License details

## 💡 Tips for Reading

- Documentation uses markdown format with clear headings
- Code examples are provided with bash syntax highlighting
- Links between documents help you navigate related topics
- Each document is self-contained but references related docs

## 🤝 Improving Documentation

Found an error or want to improve the docs? See [Contributing Guide](CONTRIBUTING.md) for how to submit improvements!

---

**Need more help?** [Open an issue](https://github.com/VictoKu1/EmergencyStorage/issues) on GitHub.
