#!/usr/bin/env bash
# Toggle the frame (and with it, the space the bar reserves). ~0.5s, no DMS restart.
#
# HOW: since 1.6, DMS can switch frameEnabled live - but it holds the old surfaces
# until the compositor confirms the new layout. It writes ~/.config/niri/dms/layout.kdl
# and waits for niri's ConfigLoaded event. That file is deliberately NOT included in
# our niri config (it would override gaps/radius), so niri never reloads on its own and
# DMS waited forever - which is why this script used to kill and relaunch DMS (~8s).
#
# So: set the value over IPC, wait for DMS to rewrite layout.kdl, then reload niri's
# own config. niri re-reads config.kdl unchanged (gaps stay ours), emits ConfigLoaded,
# and DMS swaps frame <-> bar in place. The reload must come AFTER the write: an
# earlier ConfigLoaded is ignored and leaves DMS waiting again.
#
# Falls back to the old full restart if DMS isn't running or the swap doesn't land.

set -u

RUN="${XDG_RUNTIME_DIR:-/tmp}"
LAYOUT="$HOME/.config/niri/dms/layout.kdl"

exec 9>"$RUN/dms-frame-toggle.lock"
flock -w 5 9 || exit 0      # serialize presses; each one is quick now

layers() { niri msg -j layers 2>/dev/null; }

cur=$(dms ipc call settings get frameEnabled 2>/dev/null)
if [ "$cur" != true ] && [ "$cur" != false ]; then
    # DMS is down or not answering - flip the stored value and start it.
    python3 - "$HOME/.config/DankMaterialShell/settings.json" <<'PY'
import json, sys
p = sys.argv[1]; d = json.load(open(p))
d['frameEnabled'] = not d.get('frameEnabled', False)
json.dump(d, open(p, 'w'), indent=2)
PY
    pgrep -x qs >/dev/null || niri msg action spawn -- "$HOME/.config/niri/dms-run.sh"
    exit 0
fi
[ "$cur" = true ] && new=false || new=true

before=$(stat -c %y "$LAYOUT" 2>/dev/null)
dms ipc call settings set frameEnabled "$new" >/dev/null
for _ in $(seq 1 60); do
    [ "$(stat -c %y "$LAYOUT" 2>/dev/null)" != "$before" ] && break
    sleep 0.05
done
niri msg action load-config-file >/dev/null 2>&1

# Frame on: a dms:frame surface and no standalone bar. Frame off: a dms:bar surface.
for _ in $(seq 1 60); do
    if [ "$new" = true ]; then
        layers | grep -q '"dms:frame"' && ! layers | grep -q '"dms:bar"' && exit 0
    else
        layers | grep -q '"dms:bar"' && ! layers | grep -q '"dms:frame"' && exit 0
    fi
    sleep 0.05
done

# Swap didn't land in 3s - do it the slow, sure way.
dms kill >/dev/null 2>&1
for _ in $(seq 1 30); do pgrep -x qs >/dev/null 2>&1 || break; sleep 0.2; done
niri msg action spawn -- "$HOME/.config/niri/dms-run.sh" >/dev/null 2>&1
