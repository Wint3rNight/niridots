#!/usr/bin/env bash
# Patch two hardcoded behaviours in DankMaterialShell's media panel.
#
# These edit files owned by the `dms-shell` package, so **a DMS update silently reverts
# them**. Re-run this script after upgrading. It is idempotent: it checks for its own
# marker and does nothing if the patch is already in place.
#
#   1. Selecting a different player in the media dropdown pauses the one you switched
#      away from. DankDashPopout.qml's onPlayerSelected calls currentPlayer.pause()
#      before switching. There is no setting for it. Patch removes the pause.
#
#   2. The device list in the media dropdown calls
#      AudioService.setDefaultSinkByName(), which changes the *default sink* - so it
#      moves every unpinned stream, not the player you have selected. Patch routes it
#      through media-move-output.sh, which moves only that player's PipeWire stream and
#      lets WirePlumber pin it. It falls back to the original default-sink behaviour when
#      no player is active, so the device list still works with nothing playing.
#
# Upstream would be the better fix for both; this is the local stopgap.

set -euo pipefail

DMS=${DMS_ROOT:-/usr/share/quickshell/dms}
HELPER="$HOME/.config/niri/media-move-output.sh"
MARKER="// dotfiles-patch"

say() { printf '  %s\n' "$*"; }

[ -d "$DMS" ] || { echo "DMS not found at $DMS" >&2; exit 1; }
[ -x "$HELPER" ] || { echo "missing $HELPER" >&2; exit 1; }

SUDO=""
[ -w "$DMS/Modules/DankDash/DankDashPopout.qml" ] || SUDO="sudo"

# --- 1. stop pausing the player you switch away from -------------------------
POPOUT="$DMS/Modules/DankDash/DankDashPopout.qml"
if grep -q "$MARKER no-pause" "$POPOUT"; then
    say "no-pause: already patched"
elif grep -q "currentPlayer.pause();" "$POPOUT"; then
    $SUDO python3 - "$POPOUT" "$MARKER" <<'PY'
import re, sys
path, marker = sys.argv[1], sys.argv[2]
src = open(path).read()
old = """            onPlayerSelected: player => {
                const currentPlayer = MprisController.activePlayer;
                if (currentPlayer && currentPlayer !== player && currentPlayer.canPause) {
                    currentPlayer.pause();
                }
                MprisController.setActivePlayer(player);"""
new = f"""            onPlayerSelected: player => {{
                {marker} no-pause: upstream pauses the player you switch away from here.
                MprisController.setActivePlayer(player);"""
if old not in src:
    sys.exit("no-pause: anchor not found, upstream changed - patch by hand")
open(path, "w").write(src.replace(old, new))
PY
    say "no-pause: applied"
else
    say "no-pause: anchor missing (upstream changed?) - skipped"
fi

# --- 2. device list moves only the selected player ---------------------------
OVERLAY="$DMS/Modules/DankDash/MediaDropdownOverlay.qml"
if grep -q "$MARKER per-player-sink" "$OVERLAY"; then
    say "per-player-sink: already patched"
elif grep -q "AudioService.setDefaultSinkByName(modelData.name);" "$OVERLAY"; then
    $SUDO python3 - "$OVERLAY" "$MARKER" "$HELPER" <<'PY'
import sys
path, marker, helper = sys.argv[1], sys.argv[2], sys.argv[3]
src = open(path).read()

if "\nimport Quickshell\n" not in src:
    src = src.replace("import QtQuick\n", "import QtQuick\nimport Quickshell\n", 1)

old = "                                        AudioService.setDefaultSinkByName(modelData.name);"
new = f"""                                        {marker} per-player-sink: upstream sets the
                                        // default sink here, which moves every unpinned
                                        // stream. Move just the selected player instead.
                                        if (root.activePlayer && root.activePlayer.dbusName) {{
                                            Quickshell.execDetached(["{helper}", root.activePlayer.dbusName, modelData.name]);
                                        }} else {{
                                            AudioService.setDefaultSinkByName(modelData.name);
                                        }}"""
if old not in src:
    sys.exit("per-player-sink: anchor not found, upstream changed - patch by hand")
open(path, "w").write(src.replace(old, new))
PY
    say "per-player-sink: applied"
else
    say "per-player-sink: anchor missing (upstream changed?) - skipped"
fi

say "restart the shell to pick the changes up:  dms restart   (or log out/in)"
