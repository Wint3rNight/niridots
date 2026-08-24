#!/usr/bin/env bash
# Pick a config file in rofi and open it in nvim inside a new kitty window.

declare -A configs
configs=(
    ["Niri Config"]="$HOME/.config/niri/config.kdl"
    ["Fish Config"]="$HOME/.config/fish/config.fish"
    ["Zsh Config"]="$HOME/.zshrc"
    ["Bash Config"]="$HOME/.bashrc"
    ["Kitty Config"]="$HOME/.config/kitty/kitty.conf"
    ["Neovim Config"]="$HOME/.config/nvim/init.lua"
    ["Waybar Config"]="$HOME/.config/waybar/config"
    ["Waybar CSS"]="$HOME/.config/waybar/style.css"
    ["SwayNC Config"]="$HOME/.config/swaync/config.json"
    ["SwayNC CSS"]="$HOME/.config/swaync/style.css"
    ["Rofi Config"]="$HOME/.config/rofi/config.rasi"
    ["Starship Config"]="$HOME/.config/starship.toml"
    ["Git Config"]="$HOME/.gitconfig"
    ["Mime Apps"]="$HOME/.config/mimeapps.list"
)

choice=$(printf "%s\n" "${!configs[@]}" | sort | rofi -dmenu -i -p "Edit Config")
[ -n "$choice" ] || exit 0

# Detach the editor so this script (and rofi-toggle's state) returns right away.
setsid -f kitty -e nvim "${configs[$choice]}" >/dev/null 2>&1
