#!/usr/bin/env python3
"""
Script to download and combine word lists from multiple sources.
Sources:
- https://github.com/dolph/dictionary
- https://github.com/dwyl/english-words
"""

import urllib.request
import os

def download_file(url, description):
    """Download a file from URL and return its content as a set of words."""
    print(f"Downloading {description}...")
    try:
        with urllib.request.urlopen(url) as response:
            content = response.read().decode('utf-8')
            words = set(line.strip().lower() for line in content.splitlines() if line.strip())
            print(f"  ✓ Downloaded {len(words)} words from {description}")
            return words
    except Exception as e:
        print(f"  ✗ Failed to download {description}: {e}")
        return set()

def main():
    print("=" * 60)
    print("Downloading and combining word lists...")
    print("=" * 60)

    all_words = set()

    # Download from dolph/dictionary repository
    sources = [
        ("https://raw.githubusercontent.com/dolph/dictionary/master/popular.txt",
         "dolph/dictionary - popular.txt"),
        ("https://raw.githubusercontent.com/dolph/dictionary/master/enable1.txt",
         "dolph/dictionary - enable1.txt"),
        ("https://raw.githubusercontent.com/dolph/dictionary/master/unix-words",
         "dolph/dictionary - unix-words"),
    ]

    # Download from dwyl/english-words repository
    sources.extend([
        ("https://raw.githubusercontent.com/dwyl/english-words/master/words_alpha.txt",
         "dwyl/english-words - words_alpha.txt"),
    ])

    for url, description in sources:
        words = download_file(url, description)
        all_words.update(words)

    print("\n" + "=" * 60)
    print(f"Total unique words collected: {len(all_words)}")
    print("=" * 60)

    # Sort words alphabetically
    sorted_words = sorted(all_words)

    # Create assets directory if it doesn't exist
    assets_dir = os.path.join(os.path.dirname(os.path.dirname(__file__)), 'assets')
    os.makedirs(assets_dir, exist_ok=True)

    # Write to file
    output_file = os.path.join(assets_dir, 'wordlist.txt')
    with open(output_file, 'w', encoding='utf-8') as f:
        for word in sorted_words:
            f.write(f"{word}\n")

    print(f"\n✓ Successfully wrote {len(sorted_words)} words to {output_file}")
    print("=" * 60)

if __name__ == "__main__":
    main()
