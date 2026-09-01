#!/usr/bin/env bash
# Toggle the frame (and with it, the space the bar reserves).
#
# WHY THIS RESTARTS DMS: frameEnabled is only read when the shell starts.
# Flipping it at runtime changes the setting but the frame surfaces stay up, so
# the space is not actually reclaimed until DMS reloads. A DMS limitation.
#
# WHY THE LOCK: pressing this twice quickly used to fire two overlapping
# `dms restart` calls, leaving two shell instances and two stacked bars. The
# flock makes a second press while a reload is in flight a no-op.
#
# Mod+B stays a plain, instant bar toggle. This is the heavier one.

set -u

LOCK="${XDG_RUNTIME_DIR:-/tmp}/dms-frame-toggle.lock"
exec 9>"$LOCK"
if ! flock -n 9; then
    dms notify --title "Frame" --message "already reloading" 2>/dev/null || true
    exit 0
fi

frame=$(dms ipc call settings get frameEnabled 2>/dev/null | tail -1 | tr -d '"')

if [ "$frame" = "true" ]; then
    dms ipc call settings set frameEnabled false >/dev/null 2>&1
    state="off"
else
    dms ipc call settings set frameEnabled true >/dev/null 2>&1
    state="on"
fi

# Stop every instance before starting one, so a stale shell can never survive
# into a second bar.
for p in $(pgrep -x qs) $(pgrep -x dms); do kill "$p" 2>/dev/null; done
for _ in $(seq 1 30); do
    pgrep -x qs >/dev/null 2>&1 || break
    sleep 0.2
done

niri msg action spawn -- dms run >/dev/null 2>&1

for _ in $(seq 1 60); do
    niri msg -j layers 2>/dev/null | grep -q 'dms:bar' && break
    sleep 0.5
done

dms notify --title "Frame" --message "$state" 2>/dev/null || true
