#!/usr/bin/env python3
"""
Git Repositories Manager
Part of EmergencyStorage - Clones and updates Git repositories in parallel

This script reads a JSON file with a list of Git repository URLs and clones/updates them
in parallel, logging any errors to gitlog.txt.
"""

import json
import os
import sys
import subprocess
from pathlib import Path
from typing import Dict, List, Tuple
from concurrent.futures import ThreadPoolExecutor, as_completed
from datetime import datetime


def load_repositories(config_path: Path) -> Dict:
    """Load the Git repositories configuration."""
    with open(config_path, 'r') as f:
        return json.load(f)


def save_repositories(config_path: Path, config: Dict):
    """Save the Git repositories configuration."""
    with open(config_path, 'w') as f:
        json.dump(config, f, indent=2)


def log_to_file(log_path: Path, message: str):
    """Append a message to the log file."""
    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    with open(log_path, 'a') as f:
        f.write(f"[{timestamp}] {message}\n")


def repo_exists(dest_dir: Path, repo_name: str) -> bool:
    """Check if a repository already exists."""
    repo_path = dest_dir / repo_name
    git_dir = repo_path / ".git"
    return repo_path.exists() and git_dir.exists() and git_dir.is_dir()


def clone_repository(repo_info: Dict, dest_dir: Path, log_path: Path) -> Tuple[bool, str, str]:
    """
    Clone a Git repository.
    
    Args:
        repo_info: Dictionary containing url, name, clone_args, enabled
        dest_dir: Destination directory for cloning
        log_path: Path to the log file
        
    Returns:
        Tuple of (success, repo_url, error_message)
    """
    url = repo_info.get("url", "")
    name = repo_info.get("name", "")
    clone_args = repo_info.get("clone_args", [])
    enabled = repo_info.get("enabled", True)
    
    if not enabled:
        return (True, url, "Repository disabled, skipping")
    
    if not url or not name:
        error_msg = f"Invalid repository configuration: missing url or name"
        log_to_file(log_path, f"ERROR: {url} - {error_msg}")
        return (False, url, error_msg)
    
    try:
        # Build the clone command
        command = ["git", "clone"] + clone_args + [url, str(dest_dir / name)]
        
        print(f"  Cloning: {url}")
        result = subprocess.run(
            command,
            capture_output=True,
            text=True,
            timeout=600  # 10 minute timeout for clone
        )
        
        if result.returncode == 0:
            print(f"  ✓ Successfully cloned: {name}")
            log_to_file(log_path, f"SUCCESS: Cloned {url} to {name}")
            return (True, url, "")
        else:
            error_msg = result.stderr.strip() if result.stderr else f"Clone failed with return code {result.returncode}"
            print(f"  ✗ Failed to clone: {name} - {error_msg[:100]}")
            log_to_file(log_path, f"ERROR: Failed to clone {url} - {error_msg}")
            return (False, url, error_msg)
            
    except subprocess.TimeoutExpired:
        error_msg = "Clone operation timed out after 10 minutes"
        print(f"  ✗ Timeout: {name}")
        log_to_file(log_path, f"ERROR: {url} - {error_msg}")
        return (False, url, error_msg)
    except Exception as e:
        error_msg = str(e)
        print(f"  ✗ Error cloning {name}: {error_msg}")
        log_to_file(log_path, f"ERROR: {url} - {error_msg}")
        return (False, url, error_msg)


def update_repository(repo_info: Dict, dest_dir: Path, log_path: Path) -> Tuple[bool, str, str]:
    """
    Update (pull) a Git repository.
    
    Args:
        repo_info: Dictionary containing url, name, clone_args, enabled
        dest_dir: Destination directory containing repositories
        log_path: Path to the log file
        
    Returns:
        Tuple of (success, repo_url, error_message)
    """
    url = repo_info.get("url", "")
    name = repo_info.get("name", "")
    enabled = repo_info.get("enabled", True)
    
    if not enabled:
        return (True, url, "Repository disabled, skipping")
    
    if not url or not name:
        error_msg = f"Invalid repository configuration: missing url or name"
        log_to_file(log_path, f"ERROR: {url} - {error_msg}")
        return (False, url, error_msg)
    
    repo_path = dest_dir / name
    
    if not repo_exists(dest_dir, name):
        error_msg = f"Repository does not exist: {repo_path}"
        print(f"  ✗ Repository not found: {name}")
        log_to_file(log_path, f"ERROR: {url} - {error_msg}")
        return (False, url, error_msg)
    
    try:
        # Run git pull
        command = ["git", "-C", str(repo_path), "pull"]
        
        print(f"  Updating: {url}")
        result = subprocess.run(
            command,
            capture_output=True,
            text=True,
            timeout=300  # 5 minute timeout for pull
        )
        
        if result.returncode == 0:
            print(f"  ✓ Successfully updated: {name}")
            log_to_file(log_path, f"SUCCESS: Updated {url} ({name})")
            return (True, url, "")
        else:
            error_msg = result.stderr.strip() if result.stderr else f"Pull failed with return code {result.returncode}"
            print(f"  ✗ Failed to update: {name} - {error_msg[:100]}")
            log_to_file(log_path, f"ERROR: Failed to update {url} - {error_msg}")
            return (False, url, error_msg)
            
    except subprocess.TimeoutExpired:
        error_msg = "Pull operation timed out after 5 minutes"
        print(f"  ✗ Timeout: {name}")
        log_to_file(log_path, f"ERROR: {url} - {error_msg}")
        return (False, url, error_msg)
    except Exception as e:
        error_msg = str(e)
        print(f"  ✗ Error updating {name}: {error_msg}")
        log_to_file(log_path, f"ERROR: {url} - {error_msg}")
        return (False, url, error_msg)


def process_repositories(config_path: Path, dest_dir: Path, log_path: Path, 
                         operation: str = "clone", max_workers: int = 4, dry_run: bool = False):
    """
    Process Git repositories in parallel.
    
    Args:
        config_path: Path to the Git repositories JSON configuration
        dest_dir: Destination directory for repositories
        log_path: Path to the log file
        operation: Either "clone" or "update"
        max_workers: Maximum number of parallel workers
        dry_run: If True, only show what would be done
    """
    try:
        # Load configuration
        config = load_repositories(config_path)
        repositories = config.get("repositories", [])
        
        if not repositories:
            print("No repositories found in configuration")
            return
        
        # Initialize log file
        if not dry_run:
            log_to_file(log_path, f"{'='*60}")
            log_to_file(log_path, f"Starting {operation} operation")
            log_to_file(log_path, f"{'='*60}")
        
        print(f"Found {len(repositories)} repository/repositories")
        print(f"Operation: {operation}")
        print(f"Destination: {dest_dir}")
        print(f"Log file: {log_path}")
        print(f"Max parallel workers: {max_workers}")
        print()
        
        if dry_run:
            print("[DRY RUN] Would process the following repositories:")
            for repo_info in repositories:
                if repo_info.get("enabled", True):
                    print(f"  - {repo_info.get('name', 'unknown')}: {repo_info.get('url', 'unknown')}")
            return
        
        # Create destination directory if it doesn't exist
        dest_dir.mkdir(parents=True, exist_ok=True)
        
        # Determine which operation to perform
        if operation == "clone":
            # Filter out repositories that already exist
            repos_to_process = []
            for repo_info in repositories:
                if not repo_info.get("enabled", True):
                    continue
                name = repo_info.get("name", "")
                if repo_exists(dest_dir, name):
                    print(f"  Skipping (already exists): {name}")
                    log_to_file(log_path, f"INFO: Skipping {repo_info.get('url', '')} - already exists")
                else:
                    repos_to_process.append(repo_info)
            operation_func = clone_repository
        else:  # update
            # Only update repositories that exist
            repos_to_process = []
            for repo_info in repositories:
                if not repo_info.get("enabled", True):
                    continue
                name = repo_info.get("name", "")
                if repo_exists(dest_dir, name):
                    repos_to_process.append(repo_info)
                else:
                    print(f"  Skipping (not cloned yet): {name}")
                    log_to_file(log_path, f"INFO: Skipping {repo_info.get('url', '')} - not cloned yet")
            operation_func = update_repository
        
        if not repos_to_process:
            print(f"No repositories to {operation}")
            return
        
        print(f"Processing {len(repos_to_process)} repositories in parallel...")
        print()
        
        # Process repositories in parallel
        success_count = 0
        failed_count = 0
        errors = []
        
        with ThreadPoolExecutor(max_workers=max_workers) as executor:
            # Submit all tasks
            future_to_repo = {
                executor.submit(operation_func, repo_info, dest_dir, log_path): repo_info
                for repo_info in repos_to_process
            }
            
            # Process completed tasks
            for future in as_completed(future_to_repo):
                success, url, error_msg = future.result()
                if success:
                    success_count += 1
                else:
                    failed_count += 1
                    errors.append((url, error_msg))
        
        # Summary
        print()
        print("="*60)
        print(f"{operation.capitalize()} Operation Summary")
        print("="*60)
        print(f"  Successful: {success_count}")
        print(f"  Failed: {failed_count}")
        print(f"  Total processed: {len(repos_to_process)}")
        print()
        
        if errors:
            print("Failed repositories:")
            for url, error_msg in errors:
                print(f"  ✗ {url}")
                print(f"    Error: {error_msg[:200]}")
        
        # Log summary
        if not dry_run:
            log_to_file(log_path, f"{'='*60}")
            log_to_file(log_path, f"Operation completed: {success_count} successful, {failed_count} failed")
            log_to_file(log_path, f"{'='*60}")
        
    except FileNotFoundError:
        print(f"Error: Configuration file not found: {config_path}", file=sys.stderr)
        sys.exit(1)
    except json.JSONDecodeError as e:
        print(f"Error: Invalid JSON in configuration file: {e}", file=sys.stderr)
        sys.exit(1)
    except Exception as e:
        print(f"Error processing repositories: {e}", file=sys.stderr)
        if not dry_run:
            log_to_file(log_path, f"FATAL ERROR: {e}")
        sys.exit(1)


def main():
    """Main execution function"""
    import argparse
    
    parser = argparse.ArgumentParser(
        description="Clone and update Git repositories in parallel"
    )
    parser.add_argument(
        "--config",
        type=str,
        default=None,
        help="Path to Git repositories JSON configuration file"
    )
    parser.add_argument(
        "--dest",
        type=str,
        default=None,
        help="Destination directory for repositories"
    )
    parser.add_argument(
        "--log",
        type=str,
        default=None,
        help="Path to log file (default: gitlog.txt in destination directory)"
    )
    parser.add_argument(
        "--operation",
        type=str,
        choices=["clone", "update", "both"],
        default="both",
        help="Operation to perform: clone, update, or both (default: both)"
    )
    parser.add_argument(
        "--max-workers",
        type=int,
        default=4,
        help="Maximum number of parallel workers (default: 4)"
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Show what would be done without actually doing it"
    )
    
    args = parser.parse_args()
    
    # Get script directory
    script_dir = Path(__file__).parent
    repo_root = script_dir.parent
    
    # Default paths
    config_path = Path(args.config) if args.config else repo_root / "data" / "git_repositories.json"
    dest_dir = Path(args.dest) if args.dest else repo_root / "git_repos"
    log_path = Path(args.log) if args.log else dest_dir / "gitlog.txt"
    
    print("Git Repositories Manager")
    print("="*60)
    print(f"Configuration: {config_path}")
    print(f"Destination: {dest_dir}")
    print(f"Log file: {log_path}")
    print(f"Operation: {args.operation}")
    print(f"Max workers: {args.max_workers}")
    if args.dry_run:
        print("Mode: DRY RUN (no actual changes)")
    print("="*60)
    print()
    
    # Perform operation(s)
    if args.operation in ["clone", "both"]:
        print("Starting clone operation...")
        print()
        process_repositories(config_path, dest_dir, log_path, "clone", args.max_workers, args.dry_run)
        print()
    
    if args.operation in ["update", "both"]:
        print("Starting update operation...")
        print()
        process_repositories(config_path, dest_dir, log_path, "update", args.max_workers, args.dry_run)


if __name__ == "__main__":
    main()
