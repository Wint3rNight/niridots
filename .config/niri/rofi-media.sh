#!/usr/bin/env bash

# Media control using rofi and playerctl
OPTIONS="  Play/Pause\n  Previous\n  Next"

# Get current playing info
if playerctl status &>/dev/null; then
    INFO=$(playerctl metadata --format "{{title}} - {{artist}}")
    CHOICE=$(echo -e "$OPTIONS" | rofi -dmenu -i -p "Now Playing: $INFO")
else
    CHOICE=$(echo -e "$OPTIONS" | rofi -dmenu -i -p "No Media Playing")
fi

case "$CHOICE" in
    *Play/Pause) playerctl play-pause ;;
    *Previous) playerctl previous ;;
    *Next) playerctl next ;;
esac
