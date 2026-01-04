#!/bin/bash

# Script to generate release notes with app versions and filenames

METADATA_FILE="./release/app_versions.txt"
OUTPUT_FILE="./release/release_notes.md"

# Check if metadata file exists
if [ ! -f "$METADATA_FILE" ]; then
    echo "No version metadata found. Skipping version information in release."
    exit 0
fi

# Start building the release notes
{
    echo "## 📦 Patched Apps in This Release"
    echo ""
    echo "This release includes the following patched applications:"
    echo ""
    echo "| App Name | Version | Filename | Package Name |"
    echo "|----------|---------|----------|--------------|"
    
    # Read and format each line from metadata
    while IFS='|' read -r app_name app_version filename package_name; do
        # Skip empty lines
        [ -z "$app_name" ] && continue
        
        # Format the app name nicely (capitalize, replace dashes with spaces)
        formatted_name=$(echo "$app_name" | sed 's/-/ /g; s/\b\(.\)/\u\1/g')
        
        # Output table row
        echo "| $formatted_name | \`$app_version\` | \`$filename\` | \`$package_name\` |"
    done < "$METADATA_FILE" | sort -u
    
    echo ""
    echo "---"
    echo ""
} > "$OUTPUT_FILE"

echo "✓ Generated release notes at $OUTPUT_FILE"

# Display the content for debugging
cat "$OUTPUT_FILE"
