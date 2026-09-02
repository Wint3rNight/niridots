#!/usr/bin/env bash
# Patch one hardcoded behaviour in DankMaterialShell's media panel.
#
# Selecting a different player in the media dropdown pauses the one you switched away
# from: DankDashPopout.qml's onPlayerSelected calls currentPlayer.pause() before
# switching. There is no setting for it. This removes the pause.
#
# This edits a file owned by the `dms-shell` package, so **a DMS update silently reverts
# it**. Re-run after upgrading. Idempotent: checks for its own marker and does nothing if
# already applied. Restart the shell afterwards (`dms restart`) - quickshell holds the
# QML in memory, so an unrestarted shell keeps the old behaviour.
#
# NOT patched, deliberately: the device list in that same panel calls
# AudioService.setDefaultSinkByName(), i.e. it changes the *default sink* rather than
# moving the selected player. Making it per-player needed a second patch plus a helper to
# resolve MPRIS players to PipeWire streams, and it only ever covered apps with an MPRIS
# interface. Mod+Shift+Y (.config/niri/audio-output.sh) does per-app routing over raw
# PipeWire streams instead - it covers everything, including mpv and games, and survives
# DMS upgrades because it touches no package files.

set -euo pipefail

DMS=${DMS_ROOT:-/usr/share/quickshell/dms}
MARKER="// dotfiles-patch"
POPOUT="$DMS/Modules/DankDash/DankDashPopout.qml"

say() { printf '  %s\n' "$*"; }

[ -f "$POPOUT" ] || { echo "not found: $POPOUT" >&2; exit 1; }

SUDO=""
[ -w "$POPOUT" ] || SUDO="sudo"

if grep -q "$MARKER no-pause" "$POPOUT"; then
    say "no-pause: already patched"
    exit 0
fi

if ! grep -q "currentPlayer.pause();" "$POPOUT"; then
    say "no-pause: anchor missing - upstream changed, patch by hand"
    exit 1
fi

$SUDO python3 - "$POPOUT" "$MARKER" <<'PY'
import sys
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
say "restart the shell to pick it up:  dms restart"
