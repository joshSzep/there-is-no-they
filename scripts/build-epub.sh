#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"
MANUSCRIPT_SCRIPT="$SCRIPT_DIR/build-manuscript.sh"
MANUSCRIPT_FILE="$REPO_ROOT/MANUSCRIPT.md"
COVER_FILE="$REPO_ROOT/cover.png"
OUTPUT_FILE="$REPO_ROOT/There Is No They.epub"

require_command() {
  if ! command -v "$1" >/dev/null 2>&1; then
    printf 'Missing required command: %s\n' "$1" >&2
    exit 1
  fi
}

require_file() {
  if [[ ! -f "$1" ]]; then
    printf 'Required file not found: %s\n' "$1" >&2
    exit 1
  fi
}

require_command pandoc
require_file "$MANUSCRIPT_SCRIPT"
require_file "$COVER_FILE"

"$MANUSCRIPT_SCRIPT"
require_file "$MANUSCRIPT_FILE"

pandoc "$MANUSCRIPT_FILE" \
  --from markdown \
  --to epub3 \
  --toc \
  --toc-depth=2 \
  --split-level=2 \
  --metadata title="There Is No They" \
  --metadata author="Joshua Szepietowski" \
  --metadata lang="en-US" \
  --resource-path="$REPO_ROOT" \
  --epub-cover-image="$COVER_FILE" \
  --output "$OUTPUT_FILE"

printf 'EPUB built: %s\n' "$OUTPUT_FILE"
