#!/usr/bin/env bash
# Move ONE media player's audio to a given sink.
#
# Usage: media-move-output.sh <mpris-bus-name> <sink-name>
#   e.g. media-move-output.sh org.mpris.MediaPlayer2.spotify alsa_output.pci-...Speaker__sink
#
# Called from the patched DMS media panel (see scripts/patch-dms.sh). DMS's own device
# picker calls AudioService.setDefaultSinkByName, which changes the *default sink* and so
# moves every unpinned stream at once - it cannot move just the player you have selected.
#
# Resolving an MPRIS player to its PipeWire stream is done twice over, because neither
# method covers both players on this machine:
#   1. PID. The bus name's owner PID (GetConnectionUnixProcessID) is matched against the
#      stream's application.process.id. Works for Zen/Firefox, whose stream carries
#      pid 2335 matching org.mpris.MediaPlayer2.firefox.instance_1_40.
#   2. Name. Spotify's sink-input has NO application.process.id at all, so fall back to
#      matching application.name against the tail of the bus name ("spotify" -> "Spotify").
#
# WirePlumber pins whatever we move (node.stream.restore-target), so the choice sticks
# across restarts of that app - which is the whole point.

set -u

bus="${1:-}"
sink="${2:-}"
[ -z "$bus" ] || [ -z "$sink" ] && { echo "usage: $0 <mpris-bus-name> <sink-name>" >&2; exit 2; }

pid=$(busctl --user call org.freedesktop.DBus /org/freedesktop/DBus \
        org.freedesktop.DBus GetConnectionUnixProcessID s "$bus" 2>/dev/null \
      | awk '{print $2}')

# "org.mpris.MediaPlayer2.firefox.instance_1_40" -> "firefox"
short=$(printf '%s' "$bus" | sed 's/^org\.mpris\.MediaPlayer2\.//; s/\..*$//')

idx=$(PID="${pid:-}" SHORT="$short" python3 - <<'PY'
import json, os, subprocess, sys

pid = os.environ.get("PID") or ""
short = os.environ.get("SHORT", "").lower()
inputs = json.loads(subprocess.run(["pactl", "-f", "json", "list", "sink-inputs"],
                                   capture_output=True, text=True).stdout or "[]")

# Pass 1: exact PID match.
if pid:
    for i in inputs:
        if str(i.get("properties", {}).get("application.process.id") or "") == pid:
            print(i["index"]); sys.exit()

# Pass 2: name match. Zen reports application.name "Zen" for bus name "firefox", so
# compare against the binary too rather than the bus name alone.
for i in inputs:
    p = i.get("properties", {})
    hay = " ".join(str(p.get(k) or "").lower()
                   for k in ("application.name", "application.process.binary"))
    if short and short in hay:
        print(i["index"]); sys.exit()

# Pass 3: a Firefox fork ("zen") answers to the firefox bus name; match the other way.
for i in inputs:
    p = i.get("properties", {})
    name = str(p.get("application.name") or "").lower()
    if name and (name in short or short in name):
        print(i["index"]); sys.exit()
PY
)

if [ -z "$idx" ]; then
    command -v notify-send >/dev/null && \
        notify-send -a "Audio" -t 2500 "No stream found" "$short is not playing audio right now"
    exit 1
fi

pactl move-sink-input "$idx" "$sink" || exit 1

if command -v notify-send >/dev/null; then
    desc=$(pactl list sinks | grep -A1 "Name: $sink\$" | grep Description | sed 's/.*Description: //')
    notify-send -a "Audio" -t 2000 "$short" "→ ${desc:-$sink}"
fi
