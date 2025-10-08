# Architecture

EmergencyStorage uses a **modular architecture** with individual scripts for each data source.

## Core Components

- **`emergency_storage.sh`** - Main coordinator script that calls individual source scripts
- **`scripts/common.sh`** - Shared utility functions and colored logging system
- **`scripts/kiwix.sh`** - Kiwix mirror download functionality
- **`scripts/openzim.sh`** - OpenZIM files download functionality  
- **`scripts/openstreetmap.sh`** - OpenStreetMap data download functionality
- **`scripts/ia-software.sh`** - Internet Archive software collection
- **`scripts/ia-music.sh`** - Internet Archive music collection
- **`scripts/ia-movies.sh`** - Internet Archive movies collection
- **`scripts/ia-texts.sh`** - Internet Archive texts/academic papers collection

## Project Structure

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
│   ├── ia-texts.sh               # Internet Archive texts
│   └── update_mirrors.py         # Dynamic mirror scraper script
├── data/
│   └── mirrors/
│       ├── kiwix.json            # Kiwix mirror list (auto-updated)
│       └── README.md             # Mirror system documentation
├── .github/
│   └── workflows/
│       └── update-mirrors.yml    # Automated mirror update workflow
├── docs/                         # Documentation
├── README.md                     # Main documentation
└── LICENSE                       # MIT License
```

## Design Benefits

### Better Maintainability
Each source has its own focused script, making it easier to update and maintain individual components.

### Independent Testing
Individual scripts can be tested and debugged separately from the main coordinator.

### Professional Code Structure
Clean separation of concerns with shared utilities for common functionality.

### Enhanced Logging
Colored output with consistent formatting across all scripts using `scripts/common.sh`.

### Easier Contributions
Developers can work on individual components without understanding the entire codebase.

## How It Works

1. **Main Script** (`emergency_storage.sh`) parses command-line arguments
2. **Coordinator** determines which data sources to download
3. **Individual Scripts** are called with the target directory path
4. **Common Utilities** provide shared logging and validation functions
5. **Error Handling** ensures graceful failure and continues with other sources
6. **Mirror System** provides automatic fallback to alternative mirrors
