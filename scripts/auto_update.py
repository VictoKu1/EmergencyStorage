#!/usr/bin/env python3
"""
Automatic Resource Update Script
Part of EmergencyStorage - Automatically updates configured resources

This script reads a JSON configuration file and automatically updates specified
resources based on their configuration flags and schedule.
"""

import json
import os
import sys
import subprocess
import argparse
import logging
from pathlib import Path
from datetime import datetime
from typing import Dict, List, Optional

# Setup logging
def setup_logging(log_file: Optional[str] = None):
    """Configure logging to both file and console"""
    log_format = '%(asctime)s - %(levelname)s - %(message)s'
    date_format = '%Y-%m-%d %H:%M:%S'
    
    handlers = [logging.StreamHandler(sys.stdout)]
    
    if log_file:
        log_path = Path(log_file).parent
        log_path.mkdir(parents=True, exist_ok=True)
        handlers.append(logging.FileHandler(log_file))
    
    logging.basicConfig(
        level=logging.INFO,
        format=log_format,
        datefmt=date_format,
        handlers=handlers
    )


def load_config(config_path: Path) -> Dict:
    """Load the JSON configuration file"""
    try:
        with open(config_path, 'r') as f:
            return json.load(f)
    except FileNotFoundError:
        logging.error(f"Configuration file not found: {config_path}")
        sys.exit(1)
    except json.JSONDecodeError as e:
        logging.error(f"Invalid JSON in configuration file: {e}")
        sys.exit(1)


def save_config(config_path: Path, config: Dict):
    """Save the updated configuration"""
    try:
        with open(config_path, 'w') as f:
            json.dump(config, f, indent=2)
        logging.info(f"Configuration saved to {config_path}")
    except Exception as e:
        logging.error(f"Failed to save configuration: {e}")


def execute_resource_update(
    resource_id: str,
    resource_config: Dict,
    destination_path: str,
    allow_mirror_fallback: bool,
    dry_run: bool = False
) -> bool:
    """
    Execute update for a single resource
    
    Args:
        resource_id: Resource identifier (e.g., 'resource1')
        resource_config: Configuration dictionary for the resource
        destination_path: Where to download/update the resource
        allow_mirror_fallback: Whether to allow mirror fallback
        dry_run: If True, only show what would be executed
        
    Returns:
        True if successful, False otherwise
    """
    script = resource_config.get('script', '')
    args = resource_config.get('args', [])
    name = resource_config.get('name', resource_id)
    
    if not script:
        logging.error(f"No script defined for {resource_id}")
        return False
    
    # Build the command
    script_path = Path(__file__).parent.parent / script
    
    if not script_path.exists():
        logging.error(f"Script not found: {script_path}")
        return False
    
    # Determine command based on script type
    if script.endswith('.py'):
        command = ['python3', str(script_path)]
    elif script.endswith('.sh'):
        command = ['bash', str(script_path)]
    else:
        command = [str(script_path)]
    
    # Add destination path
    command.append(destination_path)
    
    # Add mirror fallback flag if applicable and script supports it
    if allow_mirror_fallback and 'kiwix' in script:
        command.append('--allow_download_from_mirror')
    
    # Add any additional arguments
    command.extend(args)
    
    if dry_run:
        logging.info(f"[DRY RUN] Would execute: {' '.join(command)}")
        return True
    
    logging.info(f"Starting update for: {name}")
    logging.info(f"Executing: {' '.join(command)}")
    
    try:
        result = subprocess.run(
            command,
            capture_output=False,
            text=True,
            timeout=3600  # 1 hour timeout
        )
        
        if result.returncode == 0:
            logging.info(f"✓ Successfully updated {name}")
            return True
        else:
            logging.error(f"✗ Failed to update {name} (exit code: {result.returncode})")
            return False
            
    except subprocess.TimeoutExpired:
        logging.error(f"✗ Update for {name} timed out")
        return False
    except Exception as e:
        logging.error(f"✗ Error updating {name}: {e}")
        return False


def process_resources(
    config: Dict,
    resource_list: Optional[List[str]] = None,
    dry_run: bool = False
) -> Dict[str, bool]:
    """
    Process all enabled resources or specified resources
    
    Args:
        config: Complete configuration dictionary
        resource_list: List of specific resources to update (None = all enabled)
        dry_run: If True, only show what would be executed
        
    Returns:
        Dictionary mapping resource IDs to success/failure status
    """
    resources = config.get('resources', {})
    global_settings = config.get('global_settings', {})
    
    destination_path = global_settings.get('destination_path', '/mnt/external_drive')
    allow_mirror_fallback = global_settings.get('allow_mirror_fallback', False)
    max_retries = global_settings.get('max_retries', 3)
    retry_failed = global_settings.get('retry_failed', True)
    
    results = {}
    
    # Filter resources
    if resource_list:
        resources_to_process = {k: v for k, v in resources.items() if k in resource_list}
    else:
        resources_to_process = {k: v for k, v in resources.items() if v.get('enabled', False)}
    
    if not resources_to_process:
        logging.warning("No resources to process")
        return results
    
    logging.info(f"Processing {len(resources_to_process)} resource(s)")
    logging.info(f"Destination path: {destination_path}")
    logging.info("="*60)
    
    for resource_id, resource_config in resources_to_process.items():
        logging.info("")
        logging.info(f"Resource: {resource_id} - {resource_config.get('name', 'Unknown')}")
        logging.info(f"Description: {resource_config.get('description', 'N/A')}")
        logging.info(f"Update frequency: {resource_config.get('update_frequency', 'N/A')}")
        
        success = False
        attempts = 1 if not retry_failed else max_retries
        
        for attempt in range(1, attempts + 1):
            if attempt > 1:
                logging.info(f"Retry attempt {attempt}/{attempts}")
            
            success = execute_resource_update(
                resource_id,
                resource_config,
                destination_path,
                allow_mirror_fallback,
                dry_run
            )
            
            if success:
                break
        
        results[resource_id] = success
        logging.info("-"*60)
    
    return results


def print_summary(results: Dict[str, bool]):
    """Print summary of update results"""
    total = len(results)
    successful = sum(1 for success in results.values() if success)
    failed = total - successful
    
    logging.info("")
    logging.info("="*60)
    logging.info("UPDATE SUMMARY")
    logging.info("="*60)
    logging.info(f"Total resources processed: {total}")
    logging.info(f"Successful: {successful}")
    logging.info(f"Failed: {failed}")
    
    if failed > 0:
        logging.info("")
        logging.info("Failed resources:")
        for resource_id, success in results.items():
            if not success:
                logging.info(f"  - {resource_id}")
    
    logging.info("="*60)


def main():
    """Main execution function"""
    parser = argparse.ArgumentParser(
        description="Automatic Resource Update Script for EmergencyStorage",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  # Update all enabled resources
  python3 scripts/auto_update.py
  
  # Update specific resources only
  python3 scripts/auto_update.py --resource1 --resource2
  
  # Dry run to see what would be executed
  python3 scripts/auto_update.py --dry-run
  
  # Use custom configuration file
  python3 scripts/auto_update.py --config /path/to/config.json
        """
    )
    
    parser.add_argument(
        '--config',
        type=str,
        default=None,
        help='Path to auto-update configuration JSON file'
    )
    
    parser.add_argument(
        '--resource1',
        action='store_true',
        help='Update resource1 only'
    )
    
    parser.add_argument(
        '--resource2',
        action='store_true',
        help='Update resource2 only'
    )
    
    parser.add_argument(
        '--resource3',
        action='store_true',
        help='Update resource3 only'
    )
    
    parser.add_argument(
        '--resource4',
        action='store_true',
        help='Update resource4 only'
    )
    
    parser.add_argument(
        '--resource5',
        action='store_true',
        help='Update resource5 only'
    )
    
    parser.add_argument(
        '--dry-run',
        action='store_true',
        help='Show what would be executed without actually executing'
    )
    
    args = parser.parse_args()
    
    # Get script directory
    script_dir = Path(__file__).parent
    repo_root = script_dir.parent
    
    # Default configuration path
    config_path = Path(args.config) if args.config else repo_root / 'data' / 'auto_update_config.json'
    
    # Load configuration
    config = load_config(config_path)
    
    # Setup logging
    log_file = config.get('global_settings', {}).get('log_file')
    if log_file:
        log_file = str(repo_root / log_file)
    setup_logging(log_file)
    
    logging.info("EmergencyStorage - Automatic Resource Updater")
    logging.info("="*60)
    logging.info(f"Configuration: {config_path}")
    if args.dry_run:
        logging.info("Mode: DRY RUN (no actual updates)")
    logging.info("="*60)
    
    # Determine which resources to update
    resource_list = None
    if any([args.resource1, args.resource2, args.resource3, args.resource4, args.resource5]):
        resource_list = []
        if args.resource1:
            resource_list.append('resource1')
        if args.resource2:
            resource_list.append('resource2')
        if args.resource3:
            resource_list.append('resource3')
        if args.resource4:
            resource_list.append('resource4')
        if args.resource5:
            resource_list.append('resource5')
    
    # Process resources
    results = process_resources(config, resource_list, args.dry_run)
    
    # Print summary
    print_summary(results)
    
    # Exit with error code if any updates failed
    if any(not success for success in results.values()):
        sys.exit(1)
    else:
        sys.exit(0)


if __name__ == '__main__':
    main()
