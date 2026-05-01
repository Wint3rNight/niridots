#!/bin/bash

# Get current volume and mute status from wpctl
output=$(wpctl get-volume @DEFAULT_AUDIO_SINK@)
# output format is "Volume: 0.50 [MUTED]" or just "Volume: 0.50"
volume=$(echo "$output" | awk '{print $2 * 100}' | cut -d. -f1)
muted=$(echo "$output" | grep -o "\[MUTED\]")

if [[ -n "$muted" ]]; then
    icon="audio-volume-muted-symbolic"
    text="Muted"
elif (( volume <= 0 )); then
    icon="audio-volume-low-symbolic"
    text="0%"
elif (( volume <= 33 )); then
    icon="audio-volume-low-symbolic"
    text="$volume%"
elif (( volume <= 66 )); then
    icon="audio-volume-medium-symbolic"
    text="$volume%"
else
    icon="audio-volume-high-symbolic"
    text="$volume%"
fi

# Send notification using a tag to replace the previous one
# The 'volume-osd' tag ensures we don't spam the history
/usr/bin/notify-send -h string:x-canonical-private-synchronous:volume-osd \
    -h "int:value:$volume" \
    -i "$icon" \
    "Volume" "$text" -t 1500
