#!/usr/bin/env python3
"""
Kiwix Mirror Scraper
Part of EmergencyStorage - Dynamically updates mirror lists from official sources

This script scrapes the Kiwix mirrors page and updates the JSON mirror configuration.
It can be extended to support other data sources in the future.
"""

import json
import re
import sys
import urllib.request
from datetime import datetime
from pathlib import Path
from typing import Dict, List
from html.parser import HTMLParser


class MirrorHTMLParser(HTMLParser):
    """Parse HTML to extract mirror URLs from Kiwix mirrors page"""
    
    def __init__(self):
        super().__init__()
        self.mirrors = {
            'rsync': [],
            'ftp': [],
            'https': []
        }
        self.in_link = False
        self.current_href = None
    
    def handle_starttag(self, tag, attrs):
        if tag == 'a':
            for attr, value in attrs:
                if attr == 'href':
                    self.current_href = value
                    self.in_link = True
    
    def handle_endtag(self, tag):
        if tag == 'a':
            self.in_link = False
            self.current_href = None
    
    def handle_data(self, data):
        if self.in_link and self.current_href:
            # Extract mirror URL from href or data
            url = self.current_href
            
            # Categorize by protocol
            if url.startswith('https://'):
                if url not in self.mirrors['https']:
                    self.mirrors['https'].append(url)
            elif url.startswith('ftp://'):
                if url not in self.mirrors['ftp']:
                    self.mirrors['ftp'].append(url)
            elif url.startswith('rsync://') or ('rsync' in data.lower() and not url.startswith(('http', 'ftp'))):
                # For rsync, we need to extract the host/path without protocol
                rsync_url = url.replace('rsync://', '')
                if rsync_url not in self.mirrors['rsync']:
                    self.mirrors['rsync'].append(rsync_url)


def scrape_kiwix_mirrors(url: str = "https://mirror.download.kiwix.org/mirrors.html") -> Dict[str, List[str]]:
    """
    Scrape Kiwix mirrors from the official mirrors page
    
    Args:
        url: URL of the Kiwix mirrors page
        
    Returns:
        Dictionary with rsync, ftp, and https mirror lists
    """
    try:
        with urllib.request.urlopen(url, timeout=30) as response:
            html_content = response.read().decode('utf-8')
        
        parser = MirrorHTMLParser()
        parser.feed(html_content)
        
        # Also use regex as a backup method to find mirrors
        # This helps catch mirrors that might not be in <a> tags
        https_pattern = r'https://[a-zA-Z0-9\-\.]+(?:/[a-zA-Z0-9\-\._/]*)?'
        ftp_pattern = r'ftp://[a-zA-Z0-9\-\.]+(?:/[a-zA-Z0-9\-\._/]*)?'
        
        https_matches = re.findall(https_pattern, html_content)
        ftp_matches = re.findall(ftp_pattern, html_content)
        
        for match in https_matches:
            if 'kiwix' in match.lower() and match not in parser.mirrors['https']:
                parser.mirrors['https'].append(match)
        
        for match in ftp_matches:
            if 'kiwix' in match.lower() and match not in parser.mirrors['ftp']:
                parser.mirrors['ftp'].append(match)
        
        return parser.mirrors
        
    except Exception as e:
        print(f"Error scraping mirrors: {e}", file=sys.stderr)
        return None


def load_existing_mirrors(filepath: Path) -> Dict:
    """Load existing mirror configuration if it exists"""
    if filepath.exists():
        try:
            with open(filepath, 'r') as f:
                return json.load(f)
        except Exception as e:
            print(f"Warning: Could not load existing mirrors: {e}", file=sys.stderr)
    return {}


def save_mirrors(mirrors: Dict[str, List[str]], filepath: Path, source: str = "kiwix"):
    """
    Save scraped mirrors to JSON file
    
    Args:
        mirrors: Dictionary containing mirror lists by protocol
        filepath: Path to save the JSON file
        source: Name of the data source (e.g., "kiwix")
    """
    # Load existing data to preserve other sources
    existing_data = load_existing_mirrors(filepath)
    
    # Update with new mirror data
    mirror_data = {
        "source": source,
        "last_updated": datetime.utcnow().isoformat() + "Z",
        "mirrors": mirrors
    }
    
    # If this is part of a multi-source file, preserve structure
    if "sources" in existing_data:
        existing_data["sources"][source] = mirror_data
        data_to_save = existing_data
    else:
        # Single source file
        data_to_save = mirror_data
    
    # Ensure directory exists
    filepath.parent.mkdir(parents=True, exist_ok=True)
    
    # Save to file
    with open(filepath, 'w') as f:
        json.dump(data_to_save, f, indent=2)
    
    print(f"Successfully saved {sum(len(v) for v in mirrors.values())} mirrors to {filepath}")


def main():
    """Main execution function"""
    # Get script directory
    script_dir = Path(__file__).parent
    repo_root = script_dir.parent
    
    # Define output path
    mirrors_file = repo_root / "data" / "mirrors" / "kiwix.json"
    
    print("Scraping Kiwix mirrors...")
    mirrors = scrape_kiwix_mirrors()
    
    if mirrors is None:
        print("Failed to scrape mirrors", file=sys.stderr)
        sys.exit(1)
    
    # Display summary
    print(f"\nFound mirrors:")
    print(f"  RSYNC: {len(mirrors['rsync'])} mirrors")
    print(f"  FTP: {len(mirrors['ftp'])} mirrors")
    print(f"  HTTPS: {len(mirrors['https'])} mirrors")
    
    # Save to JSON
    save_mirrors(mirrors, mirrors_file, "kiwix")
    print(f"\nMirrors saved to {mirrors_file}")


if __name__ == "__main__":
    main()
