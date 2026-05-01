#!/usr/bin/env bash

MODE=$1

# Find the PID of running rofi (if any)
ROFI_PID=$(pgrep -x rofi)

if [ -n "$ROFI_PID" ]; then
    # Read its command line arguments
    ROFI_CMD=$(tr '\0' ' ' < /proc/$ROFI_PID/cmdline)
    
    # Kill the current instance
    kill $ROFI_PID
    
    # Wait for Rofi to fully exit
    while kill -0 $ROFI_PID 2>/dev/null; do sleep 0.05; done
    
    # If the user pressed the same hotkey, we just exit (toggle off)
    if [[ "$MODE" == "drun" && "$ROFI_CMD" == *"-show drun"* ]]; then
        exit 0
    elif [[ "$MODE" == "find" && "$ROFI_CMD" == *"Find File"* ]]; then
        exit 0
    elif [[ "$MODE" == "clipboard" && "$ROFI_CMD" == *"Clipboard"* ]]; then
        exit 0
    elif [[ "$MODE" == "google" && "$ROFI_CMD" == *"Google Search"* ]]; then
        exit 0
    elif [[ "$MODE" == "calc" && "$ROFI_CMD" == *"calc"* ]]; then
        exit 0
    elif [[ "$MODE" == "configs" && "$ROFI_CMD" == *"Edit Config"* ]]; then
        exit 0
    elif [[ "$MODE" == "media" && ("$ROFI_CMD" == *"Now Playing"* || "$ROFI_CMD" == *"No Media Playing"*) ]]; then
        exit 0
    elif [[ "$MODE" == "windows" && "$ROFI_CMD" == *"Switch to Window"* ]]; then
        exit 0
    elif [[ "$MODE" == "emoji" && "$ROFI_CMD" == *"emoji"* ]]; then
        exit 0
    elif [[ "$MODE" == "volume" && "$ROFI_CMD" == *"Volume"* ]]; then
        exit 0
    elif [[ "$MODE" == "network" && "$ROFI_CMD" == *"Network"* ]]; then
        exit 0
    fi
fi

# Now launch the requested mode
if [ "$MODE" == "drun" ]; then
    exec rofi -show drun
elif [ "$MODE" == "find" ]; then
    exec bash ~/.config/niri/rofi-find.sh
elif [ "$MODE" == "google" ]; then
    exec bash ~/.config/niri/rofi-web-search.sh
elif [ "$MODE" == "calc" ]; then
    exec rofi -show calc -modi calc -no-show-match -no-sort
elif [ "$MODE" == "configs" ]; then
    exec bash ~/.config/niri/rofi-configs.sh
elif [ "$MODE" == "media" ]; then
    exec bash ~/.config/niri/rofi-media.sh
elif [ "$MODE" == "windows" ]; then
    exec bash ~/.config/niri/rofi-windows.sh
elif [ "$MODE" == "emoji" ]; then
    exec rofi -show emoji -modi emoji
elif [ "$MODE" == "clipboard" ]; then
    exec bash -c "cliphist list | rofi -dmenu -p 'Clipboard' | cliphist decode | wl-copy"
elif [ "$MODE" == "volume" ]; then
    exec ~/.local/bin/rofi-volume
elif [ "$MODE" == "network" ]; then
    exec bash -c "LANG=en_US.UTF-8 networkmanager_dmenu"
fi
