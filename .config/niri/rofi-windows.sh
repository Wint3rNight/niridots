#!/usr/bin/env bash

# Get windows in JSON, format them for rofi
# Format: "ID: Title (App-ID)"
WIN_LIST=$(niri msg -j windows | jq -r '.[] | "\(.id): \(.title) (\(.app_id))"')

# Show list in rofi
CHOICE=$(echo "$WIN_LIST" | rofi -dmenu -i -p "Switch to Window")

if [ -n "$CHOICE" ]; then
    # Extract the ID from the beginning of the string
    WIN_ID=$(echo "$CHOICE" | cut -d: -f1)
    niri msg action focus-window --id "$WIN_ID"
fi
