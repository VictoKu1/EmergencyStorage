# Adding New Data Sources

EmergencyStorage provides a comprehensive template system for adding new data sources easily and consistently. The `new_resource.sh` template includes everything needed to implement a new data source without understanding the entire codebase structure.

## Quick Start

1. **Copy and customize the template:**
   ```bash
   cp new_resource.sh scripts/my-data-source.sh
   ```

2. **Follow the CUSTOMIZE: comments** in the template file

3. **Integrate with the main script** using the embedded integration guide

4. **Test your implementation** independently and with the main script

## Complete Template Documentation

**📖 For comprehensive instructions, examples, and best practices, see:**
- **[`NEW_RESOURCE_README.md`](../NEW_RESOURCE_README.md)** - Complete template documentation with:
  - Detailed step-by-step guide
  - Template features and customization points
  - Integration guide with exact code snippets
  - Testing procedures and troubleshooting
  - Example implementations and best practices
  - Template completion checklist

- **`examples/research-papers.sh`** - Working example implementation

This detailed documentation contains everything you need to successfully add a new data source, including error handling patterns, integration points, and comprehensive testing procedures.

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

## Integration Guide (Quick Reference)

To integrate your new resource into the main `emergency_storage.sh` script:

### Step A: Update Header Comment
In `emergency_storage.sh` around line 7, add your resource to the sources list.

### Step B: Add to Usage Display
In the `show_usage()` function around line 39, add your resource option.

### Step C: Add Storage Requirements
Around line 61 in the storage requirements section, add size estimates.

### Step D: Add Download Function
Around line 121, add your download wrapper function.

### Step E: Add to Sources Array
In the `download_all()` function around line 137, add to the sources array.

### Step F: Add to Argument Parsing
Around line 191, add to argument parsing logic.

### Step G: Add to Source Selection
Around line 277, add your case statement.

**See [`NEW_RESOURCE_README.md`](../NEW_RESOURCE_README.md) for detailed code examples and complete integration instructions.**

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

## Example Implementation

See `examples/research-papers.sh` for a concrete example showing how to:
- Replace placeholder values
- Implement realistic download logic
- Create appropriate documentation
- Follow the established patterns

## Next Steps

After implementing your resource:
1. Test thoroughly in various scenarios
2. Update the main `README.md` with your resource information
3. Update `docs/STORAGE.md` with storage requirements
4. Update `docs/USAGE.md` with usage examples
5. Consider contributing your resource back to the project
6. Document any special requirements or considerations
