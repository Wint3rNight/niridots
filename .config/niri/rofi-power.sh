#!/usr/bin/env bash

# Power menu using rofi
uptime=$(uptime -p | sed -e 's/up //g')
user=$(whoami)@$(hostname)

# Define icons
shutdown="󰐥"
reboot="󰜟"
lock="󰌾"
suspend="󰤄"
logout="󰍃"
sleep="󰒲"

options="$lock\n$suspend\n$sleep\n$reboot\n$logout\n$shutdown"

# Create a temporary config to avoid -theme-str parsing issues
temp_rasi=$(mktemp /tmp/rofi-power-XXXXXX.rasi)
cat <<EOF > "$temp_rasi"
@import "$HOME/.config/rofi/power.rasi"
textbox-user { 
    content: "󰀉 $user"; 
}
textbox-uptime { 
    content: "󱎫 Uptime: $uptime"; 
}
EOF

selected="$(echo -e "$options" | rofi -dmenu -theme "$temp_rasi" -i)"
rm "$temp_rasi"

case $selected in
    "$shutdown") systemctl poweroff ;;
    "$reboot") systemctl reboot ;;
    "$lock") swaylock || niri msg action session-lock ;;
    "$suspend") systemctl suspend ;;
    "$logout") niri msg action quit ;;
    "$sleep") systemctl hibernate ;;
esac
