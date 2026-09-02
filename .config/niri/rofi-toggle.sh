#!/usr/bin/env bash
# Toggle a rofi menu.
#   same hotkey again  -> close it
#   a different hotkey -> swap to that menu
#
# The mode that is open is remembered in a small state file. The old version
# guessed it from rofi's command line, which broke when more than one rofi
# PID existed or when two prompts shared a word.

MODE=$1
STATE="${XDG_RUNTIME_DIR:-/tmp}/rofi-toggle.mode"

running=$(pgrep -x rofi)
if [ -n "$running" ]; then
    last=$(cat "$STATE" 2>/dev/null)
    # shellcheck disable=SC2086
    kill $running 2>/dev/null
    for pid in $running; do
        while kill -0 "$pid" 2>/dev/null; do sleep 0.05; done
    done
    rm -f "$STATE"
    [ "$last" = "$MODE" ] && exit 0
fi

echo "$MODE" > "$STATE"
# Clear the state when our menu exits, but only if nobody replaced it meanwhile.
trap '[ "$(cat "$STATE" 2>/dev/null)" = "$MODE" ] && rm -f "$STATE"' EXIT

case "$MODE" in
    drun)      rofi -show drun ;;
    google)    bash ~/.config/niri/rofi-web-search.sh ;;
    calc)      rofi -show calc -modi calc -no-show-match -no-sort ;;
    configs)   bash ~/.config/niri/rofi-configs.sh ;;
    media)     bash ~/.config/niri/rofi-media.sh ;;
    windows)   bash ~/.config/niri/rofi-windows.sh ;;
    emoji)     rofi -show emoji -modi emoji ;;
    clipboard) cliphist list | rofi -dmenu -p 'Clipboard' | cliphist decode | wl-copy ;;
    volume)    ~/.local/bin/rofi-volume ;;
    network)   LANG=en_US.UTF-8 networkmanager_dmenu ;;
    *)         echo "rofi-toggle: unknown mode '$MODE'" >&2; exit 1 ;;
esac
