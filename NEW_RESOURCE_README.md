# new_resource.sh - EmergencyStorage Resource Template

This file provides a comprehensive template for adding new data sources to the EmergencyStorage project. It includes detailed documentation, placeholder code sections, and step-by-step integration instructions.

## Quick Start

1. **Copy the template:**
   ```bash
   cp new_resource.sh scripts/my-data-source.sh
   ```

2. **Replace placeholder names:**
   - Replace `NEW_RESOURCE` with your resource display name
   - Replace `new_resource` with your resource identifier (lowercase, hyphenated)
   - Replace `download_new_resource` with your function name

3. **Customize the sections marked with `CUSTOMIZE:` comments**

4. **Integrate with main script** (see Integration Guide below)

5. **Test your implementation**

## Template Features

### 📝 Comprehensive Documentation
- Detailed header with usage instructions
- Step-by-step integration guide for `emergency_storage.sh`
- Inline comments explaining each section
- Completion checklist to ensure nothing is missed

### 🔧 Structured Code Sections

1. **Resource-Specific Configuration**
   - Primary and backup URLs
   - Collections/datasets definitions
   - Size estimates and descriptions

2. **Helper Functions**
   - Requirements checking
   - README generation
   - Primary and alternative download methods
   - Placeholder creation
   - Manifest generation

3. **Main Download Function**
   - Path validation
   - Directory creation
   - Orchestrated download process
   - Error handling and fallbacks

4. **Script Execution**
   - Direct execution handling
   - Parameter validation
   - Usage examples

### 🛠 Built-in Best Practices
- Proper error handling with `set -e`
- Consistent logging using common utilities
- Path validation and safety checks
- Internet connectivity testing
- Fallback mechanisms for failed downloads
- Comprehensive documentation generation

## Integration Guide

To integrate your new resource into the main `emergency_storage.sh` script:

### Step A: Update Header Comment
In `emergency_storage.sh` around line 7, add your resource to the sources list:
```bash
# Sources: all, kiwix, openzim, openstreetmap, ia-software, ia-music, ia-movies, ia-texts, your-resource
```

### Step B: Add to Usage Display
In the `show_usage()` function around line 39:
```bash
echo "  --your-resource  Download Your Resource Name collection"
```

### Step C: Add Storage Requirements
Around line 61 in the storage requirements section:
```bash
echo "  Your Resource:    [SIZE] (your estimated size)"
```

### Step D: Add Download Function
Around line 121, add your download wrapper function:
```bash
# Function to download Your Resource collection using dedicated script
download_your_resource() {
    local drive_path="$1"
    
    log_info "Calling Your Resource download script..."
    "$SCRIPT_DIR/scripts/your-resource.sh" "$drive_path"
}
```

### Step E: Add to Sources Array
In the `download_all()` function around line 137:
```bash
local sources=("kiwix" "openzim" "openstreetmap" "ia-software" "ia-music" "ia-movies" "ia-texts" "your-resource")
```

### Step F: Add to Argument Parsing
Around line 191:
```bash
--all|--kiwix|--openzim|--openstreetmap|--ia-software|--ia-music|--ia-movies|--ia-texts|--your-resource)
```

### Step G: Add to Source Selection
Around line 277, add your case:
```bash
--your-resource)
    download_your_resource "$drive_path"
    ;;
```

## Template Customization Areas

### 🎯 Primary Customization Points

Look for `CUSTOMIZE:` comments throughout the template. Key areas include:

1. **URLs and Endpoints** - Replace example URLs with real ones
2. **Collections Definition** - Define your actual datasets/collections
3. **Size Estimates** - Provide realistic storage requirements  
4. **Descriptions** - Write meaningful descriptions for users
5. **Download Logic** - Implement actual download mechanisms
6. **README Content** - Create comprehensive user documentation
7. **Requirements** - Specify tools and dependencies needed

### 📋 Supported Download Methods

The template provides examples for:
- Direct file downloads (curl/wget)
- API-based downloads
- rsync mirroring
- Multiple mirror fallbacks
- Repository cloning
- Custom protocol handlers

## Example Implementation

See `examples/research-papers.sh` for a concrete example showing how to:
- Replace placeholder values
- Implement realistic download logic
- Create appropriate documentation
- Follow the established patterns

## File Structure Created

Your resource script will create the following structure:
```
target_directory/
└── your-resource-data/
    ├── README_YOUR_RESOURCE.txt      # Comprehensive user guide
    ├── download_manifest.txt         # Collection details and sizes
    ├── collection1_download_url.txt  # Download URL placeholders
    ├── collection1_description.txt   # Collection descriptions
    ├── collection1_metadata.txt      # Collection metadata
    └── ...                          # Additional collections and files
```

## Testing Your Implementation

1. **Test independently:**
   ```bash
   ./scripts/your-resource.sh /tmp/test_directory
   ```

2. **Test with main script:**
   ```bash
   ./emergency_storage.sh --your-resource /tmp/test_directory
   ```

3. **Test error handling:**
   ```bash
   ./scripts/your-resource.sh  # Should show usage
   ./scripts/your-resource.sh /invalid/path  # Should handle gracefully
   ```

## Best Practices

### ✅ Do:
- Follow the existing naming conventions
- Use the common logging functions
- Validate all inputs and paths
- Provide meaningful error messages
- Create comprehensive documentation
- Handle network failures gracefully
- Estimate storage requirements realistically
- Test with various network conditions

### ❌ Don't:
- Hardcode paths outside the target directory
- Skip error handling
- Assume network connectivity
- Create files in unexpected locations
- Override existing files without warning
- Skip the integration steps
- Forget to test edge cases

## Troubleshooting

### Common Issues:

1. **Path Problems**: Ensure you're using the correct path to `scripts/common.sh`
2. **Permission Errors**: Make sure your script is executable (`chmod +x`)
3. **Integration Issues**: Double-check all integration points in `emergency_storage.sh`
4. **Missing Dependencies**: Validate all required tools are available

### Debug Mode:
Add `set -x` after `set -e` to see detailed execution traces.

## Contributing

After implementing your resource:
1. Test thoroughly in various scenarios
2. Update the main `README.md` with your resource information
3. Update `docs/STORAGE.md` with storage requirements and content descriptions
4. Update `docs/USAGE.md` with usage examples
5. Consider contributing your resource back to the project
6. Document any special requirements or considerations

See [Contributing Guide](docs/CONTRIBUTING.md) for more information on the contribution process.

## Template Completion Checklist

- [ ] Copied template to appropriate location in `scripts/`
- [ ] Replaced all placeholder names (NEW_RESOURCE, new_resource, etc.)
- [ ] Updated header documentation with resource-specific information
- [ ] Customized resource-specific configuration section
- [ ] Implemented helper functions for your resource
- [ ] Defined collections/datasets and their metadata
- [ ] Implemented download logic for your resource
- [ ] Created comprehensive documentation in README section
- [ ] Added resource to `emergency_storage.sh` using integration guide
- [ ] Tested script independently with various inputs
- [ ] Tested script integration with main `emergency_storage.sh`
- [ ] Updated main `README.md` with resource information
- [ ] Updated `docs/STORAGE.md` with storage requirements
- [ ] Updated `docs/USAGE.md` with usage examples
- [ ] Verified error handling and edge cases
- [ ] Documented any special requirements or dependencies