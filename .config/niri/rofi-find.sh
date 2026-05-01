#!/usr/bin/env bash
# Fast file search using fd and rofi

file=$(fd --type f . "$HOME" | rofi -dmenu -i -p "Find File")

if [ -n "$file" ]; then
    # Open the selected file using its default application
    xdg-open "$file"
fi