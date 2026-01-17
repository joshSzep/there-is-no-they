#!/bin/bash

# Build manuscript from chapter files
# Outputs MANUSCRIPT.md at repository root

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"
CHAPTERS_DIR="$REPO_ROOT/chapters"
OUTPUT_FILE="$REPO_ROOT/MANUSCRIPT.md"

# Start the manuscript
cat > "$OUTPUT_FILE" << 'EOF'
# There Is No They

Joshua Szepietowski

---
EOF

# Process each part in order
for part_num in 1 2 3 4 5; do
    # Find the part directory
    part_dir=$(find "$CHAPTERS_DIR" -maxdepth 1 -type d -name "Part $part_num - *" | head -1)
    
    if [ -z "$part_dir" ]; then
        echo "Warning: Part $part_num not found, skipping..."
        continue
    fi
    
    # Extract part name from directory
    part_name=$(basename "$part_dir")
    
    # Add part header
    echo "" >> "$OUTPUT_FILE"
    echo "## $part_name" >> "$OUTPUT_FILE"
    
    # Process chapters in order
    for chapter_file in "$part_dir"/Chapter*.md; do
        if [ ! -f "$chapter_file" ]; then
            continue
        fi
        
        # Extract chapter title from filename (e.g., "Chapter 01 - The Fog")
        chapter_filename=$(basename "$chapter_file" .md)
        
        # Add chapter header
        echo "" >> "$OUTPUT_FILE"
        echo "### $chapter_filename" >> "$OUTPUT_FILE"
        echo "" >> "$OUTPUT_FILE"
        
        # Add chapter content, skipping the first line (the # title)
        tail -n +2 "$chapter_file" >> "$OUTPUT_FILE"
        
        # Add separator
        echo "" >> "$OUTPUT_FILE"
        echo "---" >> "$OUTPUT_FILE"
    done
done

# Remove the trailing separator
sed -i '' -e '$ d' "$OUTPUT_FILE"

echo "Manuscript built: $OUTPUT_FILE"
echo "Word count: $(wc -w < "$OUTPUT_FILE" | tr -d ' ')"
