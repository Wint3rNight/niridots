#!/usr/bin/env bash

# Select a config file to edit
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

# Generate the list of keys and pipe to rofi
choice=$(printf "%s\n" "${!configs[@]}" | sort | rofi -dmenu -i -p "Edit Config")

if [ -n "$choice" ]; then
    # Open in kitty with nvim
    kitty -e nvim "${configs[$choice]}" || xdg-open "${configs[$choice]}"
fi
