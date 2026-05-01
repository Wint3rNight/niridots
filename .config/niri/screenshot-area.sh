#!/usr/bin/env bash

# Screenshot script using grim, slurp and swappy
# Allows for region selection and immediate editing

# Create screenshots directory if it doesn't exist
mkdir -p ~/Pictures/Screenshots

TIMESTAMP=$(date +%Y-%m-%d_%H-%M-%S)
FILENAME="$HOME/Pictures/Screenshots/screenshot_${TIMESTAMP}.png"

# Take a screenshot of a region and open in swappy for editing
# -g specifies the region from slurp
# - means output to stdout, which we pipe to swappy
grim -g "$(slurp)" - | swappy -f - -o "$FILENAME"
