#!/usr/bin/env bash
# Cycle the DMS theme through ~/.config/DankMaterialShell/themes/.
#
#   theme-cycle.sh          next theme
#   theme-cycle.sh prev     previous
#   theme-cycle.sh reset    back to Cathedral
#   theme-cycle.sh list     show the pool
#
# Deliberately manual: matugen stays disabled (DMS_DISABLE_MATUGEN=1 in the niri
# environment block), so changing the wallpaper never touches the theme and this
# script is the only thing that does. Themes live-reload - no restart.

set -u

DIR="$HOME/.config/DankMaterialShell/themes"
SETTINGS="$HOME/.config/DankMaterialShell/settings.json"

mapfile -t THEMES < <(find "$DIR" -maxdepth 1 -name '*.json' | sort)
[ ${#THEMES[@]} -eq 0 ] && { echo "no themes in $DIR" >&2; exit 1; }

name() { basename "$1" .json | sed 's/^[0-9]*-//'; }

if [ "${1:-next}" = "list" ]; then
    cur=$(python3 -c "import json;print(json.load(open('$SETTINGS')).get('customThemeFile',''))" 2>/dev/null)
    for t in "${THEMES[@]}"; do
        [ "$t" = "$cur" ] && printf '* %s\n' "$(name "$t")" || printf '  %s\n' "$(name "$t")"
    done
    exit 0
fi

if [ "${1:-}" = "reset" ]; then
    target="$DIR/00-cathedral.json"
else
    cur=$(python3 -c "import json;print(json.load(open('$SETTINGS')).get('customThemeFile',''))" 2>/dev/null)
    idx=-1
    for i in "${!THEMES[@]}"; do [ "${THEMES[$i]}" = "$cur" ] && idx=$i && break; done
    n=${#THEMES[@]}
    if [ "${1:-next}" = "prev" ]; then
        idx=$(( (idx - 1 + n) % n ))
    else
        idx=$(( (idx + 1) % n ))
    fi
    target="${THEMES[$idx]}"
fi

python3 - "$SETTINGS" "$target" <<'EOF'
import json, sys
p, target = sys.argv[1], sys.argv[2]
d = json.load(open(p))
d["currentThemeName"] = "custom"
d["customThemeFile"] = target
json.dump(d, open(p, "w"), indent=2)
EOF

dms notify --title "Theme" --message "$(name "$target")" 2>/dev/null \
    || notify-send "Theme" "$(name "$target")" 2>/dev/null || true
echo "$(name "$target")"
