#!/bin/bash

# Get current brightness using brightnessctl
# It parses output like: Current brightness: 48 (50%)
brightness=$(brightnessctl i | grep -o "[0-9]*%" | head -n 1 | tr -d '%')

# Default to 0 if we couldn't parse
if [[ -z "$brightness" ]]; then
    brightness=0
fi

if (( brightness <= 33 )); then
    icon="display-brightness-low-symbolic"
elif (( brightness <= 66 )); then
    icon="display-brightness-medium-symbolic"
else
    icon="display-brightness-high-symbolic"
fi

# Send notification using a tag to replace the previous one
/usr/bin/notify-send -h string:x-canonical-private-synchronous:brightness-osd \
    -h "int:value:$brightness" \
    -i "$icon" \
    "Brightness" "${brightness}%" -t 1500