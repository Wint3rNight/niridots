#!/usr/bin/env bash
# Region screenshot: pick an area with slurp, edit it in swappy, save to
# ~/Pictures/Screenshots.

mkdir -p ~/Pictures/Screenshots

TIMESTAMP=$(date +%Y-%m-%d_%H-%M-%S)
FILENAME="$HOME/Pictures/Screenshots/screenshot_${TIMESTAMP}.png"

# Esc in slurp means "cancel" - do not fall through to grim with an empty region.
GEOM=$(slurp) || exit 0
[ -n "$GEOM" ] || exit 0

grim -g "$GEOM" - | swappy -f - -o "$FILENAME"
