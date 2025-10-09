#!/usr/bin/env python3
"""
Manual Sources Downloader
Part of EmergencyStorage - Downloads files from manually configured sources

This script reads a JSON file containing manual download sources structured as a recursive dictionary
with operators and flags, and downloads the files according to their configuration.
"""

import json
import os
import sys
import urllib.request
from pathlib import Path
from typing import Dict, Any, Tuple, List


def normalize_tree_depth(data: Dict, current_depth: int = 0, max_depth: int = None) -> Tuple[Dict, int]:
    """
    Analyze and normalize tree depth to ensure all URLs are at the same level.
    
    Args:
        data: The data structure to normalize
        current_depth: Current depth in the recursion
        max_depth: Maximum depth to normalize to
        
    Returns:
        Tuple of (normalized data, max depth found)
    """
    if max_depth is None:
        # First pass: find maximum depth
        max_depth = find_max_depth(data)
    
    return data, max_depth


def find_max_depth(data: Any, current_depth: int = 0) -> int:
    """
    Find the maximum depth of the tree structure.
    
    Args:
        data: The data structure to analyze
        current_depth: Current depth in recursion
        
    Returns:
        Maximum depth found
    """
    if not isinstance(data, dict):
        return current_depth
    
    # Check if this is a leaf node (contains url)
    if "url" in data and "updateFile" in data:
        return current_depth
    
    # Recurse into children
    max_child_depth = current_depth
    for key, value in data.items():
        child_depth = find_max_depth(value, current_depth + 1)
        max_child_depth = max(max_child_depth, child_depth)
    
    return max_child_depth


def traverse_sources(data: Dict, path: List[str] = None) -> List[Tuple[List[str], Dict]]:
    """
    Traverse the recursive dictionary structure and extract all download sources.
    
    Args:
        data: The data structure to traverse
        path: Current path in the tree (list of keys)
        
    Returns:
        List of tuples containing (path, source_info) where source_info has url, updateFile, downloaded
    """
    if path is None:
        path = []
    
    results = []
    
    # Check if this is a leaf node (contains url)
    if isinstance(data, dict) and "url" in data and "updateFile" in data:
        return [(path, data)]
    
    # Recurse into children
    if isinstance(data, dict):
        for key, value in data.items():
            results.extend(traverse_sources(value, path + [key]))
    
    return results


def should_download(source_info: Dict, filepath: Path) -> bool:
    """
    Determine if a file should be downloaded based on updateFile flag and downloaded status.
    
    Args:
        source_info: Dictionary containing url, updateFile, and downloaded flags
        filepath: Path where the file would be saved
        
    Returns:
        True if file should be downloaded, False otherwise
    """
    update_file = source_info.get("updateFile", False)
    already_downloaded = source_info.get("downloaded", False)
    
    # If updateFile is True, always download
    if update_file:
        return True
    
    # If updateFile is False and file was already downloaded, skip
    if not update_file and already_downloaded:
        return False
    
    # If updateFile is False but file wasn't downloaded yet, download it
    if not update_file and not already_downloaded:
        return True
    
    return False


def download_file(url: str, filepath: Path, timeout: int = 30) -> bool:
    """
    Download a file from URL to filepath.
    
    Args:
        url: URL to download from
        filepath: Path to save the file
        timeout: Connection timeout in seconds
        
    Returns:
        True if download successful, False otherwise
    """
    try:
        print(f"  Downloading: {url}")
        print(f"  Saving to: {filepath}")
        
        # Ensure directory exists
        filepath.parent.mkdir(parents=True, exist_ok=True)
        
        # Download with progress indication
        with urllib.request.urlopen(url, timeout=timeout) as response:
            total_size = response.headers.get('Content-Length')
            if total_size:
                print(f"  Size: {int(total_size) / (1024*1024):.2f} MB")
            
            with open(filepath, 'wb') as f:
                chunk_size = 8192
                downloaded = 0
                while True:
                    chunk = response.read(chunk_size)
                    if not chunk:
                        break
                    f.write(chunk)
                    downloaded += len(chunk)
                    if total_size:
                        progress = (downloaded / int(total_size)) * 100
                        print(f"\r  Progress: {progress:.1f}%", end='', flush=True)
        
        print()  # New line after progress
        return True
        
    except Exception as e:
        print(f"  Error downloading {url}: {e}", file=sys.stderr)
        return False


def update_downloaded_status(config_path: Path, path: List[str], status: bool):
    """
    Update the downloaded status for a specific source in the JSON config.
    
    Args:
        config_path: Path to the JSON configuration file
        path: Path to the source in the tree structure
        status: Downloaded status (True/False)
    """
    try:
        with open(config_path, 'r') as f:
            config = json.load(f)
        
        # Navigate to the source
        current = config
        for key in path:
            if key in current:
                current = current[key]
            else:
                print(f"Warning: Could not find path {path} in config", file=sys.stderr)
                return
        
        # Update downloaded status
        current["downloaded"] = status
        
        # Save back to file
        with open(config_path, 'w') as f:
            json.dump(config, f, indent=2)
        
        print(f"  Updated downloaded status to {status}")
        
    except Exception as e:
        print(f"  Warning: Could not update downloaded status: {e}", file=sys.stderr)


def process_manual_sources(config_path: Path, download_dir: Path, dry_run: bool = False):
    """
    Process manual sources configuration and download files.
    
    Args:
        config_path: Path to the manual sources JSON configuration
        download_dir: Directory to save downloaded files
        dry_run: If True, only show what would be downloaded without actually downloading
    """
    try:
        with open(config_path, 'r') as f:
            config = json.load(f)
        
        # Get sources section
        sources = config.get("sources", {})
        
        if not sources:
            print("No sources found in configuration")
            return
        
        # Traverse and extract all download sources
        all_sources = traverse_sources(sources, ["sources"])
        
        print(f"Found {len(all_sources)} download sources")
        print()
        
        # Process each source
        downloaded_count = 0
        skipped_count = 0
        failed_count = 0
        
        for path, source_info in all_sources:
            # Create a readable path string (skip 'sources' root and empty strings)
            readable_path = " > ".join([p for p in path[1:] if p.strip()])
            print(f"Processing: {readable_path}")
            
            url = source_info.get("url", "")
            if not url:
                print("  No URL specified, skipping")
                skipped_count += 1
                continue
            
            # Determine filename from URL
            filename = url.split("/")[-1]
            if not filename:
                filename = "download"
            
            # Create subdirectory based on path
            subdir = download_dir / "/".join([p for p in path[1:] if p.strip()])
            filepath = subdir / filename
            
            # Check if should download
            if not should_download(source_info, filepath):
                print(f"  Skipping (already downloaded, updateFile=false)")
                skipped_count += 1
                print()
                continue
            
            if dry_run:
                print(f"  [DRY RUN] Would download: {url}")
                print(f"  [DRY RUN] Would save to: {filepath}")
                print()
                continue
            
            # Attempt download
            success = download_file(url, filepath, timeout=30)
            
            if success:
                print("  ✓ Download successful")
                downloaded_count += 1
                # Update downloaded status in config
                update_downloaded_status(config_path, path, True)
            else:
                print("  ✗ Download failed")
                failed_count += 1
            
            print()
        
        # Summary
        print("="*50)
        print("Download Summary")
        print("="*50)
        print(f"  Downloaded: {downloaded_count}")
        print(f"  Skipped: {skipped_count}")
        print(f"  Failed: {failed_count}")
        print(f"  Total: {len(all_sources)}")
        
    except FileNotFoundError:
        print(f"Error: Configuration file not found: {config_path}", file=sys.stderr)
        sys.exit(1)
    except json.JSONDecodeError as e:
        print(f"Error: Invalid JSON in configuration file: {e}", file=sys.stderr)
        sys.exit(1)
    except Exception as e:
        print(f"Error processing manual sources: {e}", file=sys.stderr)
        sys.exit(1)


def main():
    """Main execution function"""
    import argparse
    
    parser = argparse.ArgumentParser(
        description="Download files from manually configured sources"
    )
    parser.add_argument(
        "--config",
        type=str,
        default=None,
        help="Path to manual sources JSON configuration file"
    )
    parser.add_argument(
        "--output",
        type=str,
        default=None,
        help="Output directory for downloads"
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Show what would be downloaded without actually downloading"
    )
    
    args = parser.parse_args()
    
    # Get script directory
    script_dir = Path(__file__).parent
    repo_root = script_dir.parent
    
    # Default paths
    config_path = Path(args.config) if args.config else repo_root / "data" / "manual_sources.json"
    download_dir = Path(args.output) if args.output else repo_root / "downloads" / "manual"
    
    print("Manual Sources Downloader")
    print("="*50)
    print(f"Configuration: {config_path}")
    print(f"Download directory: {download_dir}")
    if args.dry_run:
        print("Mode: DRY RUN (no actual downloads)")
    print("="*50)
    print()
    
    # Process downloads
    process_manual_sources(config_path, download_dir, dry_run=args.dry_run)


if __name__ == "__main__":
    main()
