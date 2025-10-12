#!/usr/bin/env python3
"""
Manual Sources Downloader
Part of EmergencyStorage - Downloads files from manually configured sources

This script reads a JSON file where keys are download methods (wget, curl, rsync, git, etc.)
and executes commands with smart fallback to alternative URLs/flags.
"""

import json
import os
import sys
import subprocess
from pathlib import Path
from typing import Dict, List, Tuple


def build_command(method: str, url_field: str) -> List[str]:
    """
    Build the command to execute based on method and url field.
    
    Args:
        method: Download method (wget, curl, rsync, git, etc.)
        url_field: The url field containing flags and URL
        
    Returns:
        List of command parts ready for subprocess
    """
    parts = url_field.strip().split()
    return [method] + parts


def execute_download(method: str, url_field: str, dry_run: bool = False) -> bool:
    """
    Execute the download command.
    
    Args:
        method: Download method (wget, curl, rsync, git, etc.)
        url_field: The url field containing flags and URL
        dry_run: If True, only show what would be executed
        
    Returns:
        True if successful, False otherwise
    """
    command = build_command(method, url_field)
    
    if dry_run:
        print(f"  [DRY RUN] Would execute: {' '.join(command)}")
        return True
    
    try:
        print(f"  Executing: {' '.join(command)}")
        result = subprocess.run(
            command,
            capture_output=True,
            text=True,
            timeout=300  # 5 minute timeout
        )
        
        if result.returncode == 0:
            print("  ✓ Command executed successfully")
            return True
        else:
            print(f"  ✗ Command failed with return code {result.returncode}")
            if result.stderr:
                print(f"  Error: {result.stderr[:200]}")
            return False
            
    except subprocess.TimeoutExpired:
        print("  ✗ Command timed out")
        return False
    except Exception as e:
        print(f"  ✗ Error executing command: {e}")
        return False


def try_alternatives(method: str, source_info: Dict, config: Dict, config_path: Path, dry_run: bool = False) -> bool:
    """
    Try alternative URLs/flags if the main URL fails.
    
    Args:
        method: Download method
        source_info: Dictionary containing url, updateFile, downloaded, alternative
        config: The already loaded configuration dictionary
        config_path: Path to the JSON configuration file
        dry_run: If True, only show what would be executed
        
    Returns:
        True if any attempt succeeded, False otherwise
    """
    alternatives = source_info.get("alternative", [])
    
    if not alternatives:
        return False
    
    print(f"  Trying {len(alternatives)} alternative(s)...")
    
    for i, alt_url in enumerate(alternatives):
        print(f"  Alternative {i+1}/{len(alternatives)}: {alt_url}")
        
        if execute_download(method, alt_url, dry_run):
            # Swap the working alternative with the failed main URL
            if not dry_run:
                print(f"  → Updating config: moving working alternative to main URL")
                old_url = source_info["url"]
                source_info["url"] = alt_url
                # Add failed URL to end of alternatives
                alternatives.remove(alt_url)
                alternatives.append(old_url)
                source_info["alternative"] = alternatives
                
                # Save updated config (config already passed in, no need to reload)
                save_config(config_path, config)
            
            return True
    
    return False


def load_config(config_path: Path) -> Dict:
    """Load the JSON configuration."""
    with open(config_path, 'r') as f:
        return json.load(f)


def save_config(config_path: Path, config: Dict):
    """Save the JSON configuration."""
    with open(config_path, 'w') as f:
        json.dump(config, f, indent=2)


def update_downloaded_status(config: Dict, config_path: Path, method: str, status: bool):
    """
    Update the downloaded status for a specific source.
    
    Args:
        config: The already loaded configuration dictionary
        config_path: Path to the JSON configuration file
        method: The download method key
        status: Downloaded status (True/False)
    """
    try:
        if method in config:
            config[method]["downloaded"] = status
            save_config(config_path, config)
            print(f"  Updated downloaded status to {status}")
        else:
            print(f"  Warning: Method '{method}' not found in config", file=sys.stderr)
            
    except Exception as e:
        print(f"  Warning: Could not update downloaded status: {e}", file=sys.stderr)


def should_download(source_info: Dict) -> bool:
    """
    Determine if a download should be executed.
    
    Args:
        source_info: Dictionary containing url, updateFile, and downloaded flags
        
    Returns:
        True if should download, False otherwise
    """
    update_file = source_info.get("updateFile", False)
    already_downloaded = source_info.get("downloaded", False)
    
    # If updateFile is True, always download
    if update_file:
        return True
    
    # If updateFile is False and already downloaded, skip
    if not update_file and already_downloaded:
        return False
    
    # If updateFile is False but not downloaded yet, download it
    return True


def process_manual_sources(config_path: Path, dry_run: bool = False):
    """
    Process manual sources configuration and execute downloads.
    
    Args:
        config_path: Path to the manual sources JSON configuration
        dry_run: If True, only show what would be downloaded without actually downloading
    """
    try:
        config = load_config(config_path)
        
        if not config:
            print("No sources found in configuration")
            return
        
        print(f"Found {len(config)} download source(s)")
        print()
        
        # Process each method
        downloaded_count = 0
        skipped_count = 0
        failed_count = 0
        
        for method, source_info in config.items():
            # Validate source_info structure
            if not isinstance(source_info, dict):
                print(f"Warning: Invalid structure for method '{method}', skipping")
                continue
            
            if "url" not in source_info:
                print(f"Warning: No URL for method '{method}', skipping")
                continue
            
            print(f"Processing: {method}")
            url_field = source_info.get("url", "")
            print(f"  URL field: {url_field}")
            
            # Check if should download
            if not should_download(source_info):
                print(f"  Skipping (already downloaded, updateFile=false)")
                skipped_count += 1
                print()
                continue
            
            # Try main URL
            success = execute_download(method, url_field, dry_run)
            
            # If failed, try alternatives
            if not success and not dry_run:
                print("  Main URL failed, trying alternatives...")
                success = try_alternatives(method, source_info, config, config_path, dry_run)
            
            if success:
                downloaded_count += 1
                if not dry_run:
                    update_downloaded_status(config, config_path, method, True)
            else:
                failed_count += 1
            
            print()
        
        # Summary
        print("="*50)
        print("Download Summary")
        print("="*50)
        print(f"  Downloaded: {downloaded_count}")
        print(f"  Skipped: {skipped_count}")
        print(f"  Failed: {failed_count}")
        print(f"  Total: {len(config)}")
        
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
        "--dry-run",
        action="store_true",
        help="Show what would be downloaded without actually downloading"
    )
    
    args = parser.parse_args()
    
    # Get script directory
    script_dir = Path(__file__).parent
    repo_root = script_dir.parent
    
    # Default path
    config_path = Path(args.config) if args.config else repo_root / "data" / "manual_sources.json"
    
    print("Manual Sources Downloader")
    print("="*50)
    print(f"Configuration: {config_path}")
    if args.dry_run:
        print("Mode: DRY RUN (no actual downloads)")
    print("="*50)
    print()
    
    # Process downloads
    process_manual_sources(config_path, dry_run=args.dry_run)


if __name__ == "__main__":
    main()
