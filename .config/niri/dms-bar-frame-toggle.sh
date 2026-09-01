#!/usr/bin/env bash
# Toggle the frame (and with it, the space the bar reserves).
#
# WHY THIS RELOADS DMS: frameEnabled is only read when the shell starts.
# Verified - setting it true at runtime produces zero frame surfaces until a
# restart. So a ~8s reload is unavoidable.
#
# WHY THE PENDING FILE: the reload takes long enough that a second press lands
# mid-flight. Silently dropping it made the key feel dead. Now a press during a
# reload is queued, and the running instance toggles again when it finishes -
# so pressing twice ends up back where you started, as you'd expect.
#
# State is read from settings.json, not IPC, because DMS is down for part of
# this and `dms ipc call settings get` returns nothing then.
#
# Mod+B stays a plain, instant bar toggle. This is the heavier one.

set -u

SETTINGS="$HOME/.config/DankMaterialShell/settings.json"
RUN="${XDG_RUNTIME_DIR:-/tmp}"
LOCK="$RUN/dms-frame-toggle.lock"
PENDING="$RUN/dms-frame-toggle.pending"

exec 9>"$LOCK"
if ! flock -n 9; then
    : > "$PENDING"          # a reload is in flight - ask it to toggle once more
    exit 0
fi

read_frame() {
    python3 -c "
import json
try: print(json.load(open('$SETTINGS')).get('frameEnabled', False))
except Exception: print('False')"
}

write_frame() {
    python3 -c "
import json
p='$SETTINGS'
d=json.load(open(p))
d['frameEnabled'] = ('$1' == 'true')
json.dump(d, open(p,'w'), indent=2)"
}

while :; do
    rm -f "$PENDING"

    cur=$(read_frame)
    [ "$cur" = "True" ] && new=false || new=true

    # Stop every instance first, so a stale shell can never survive into a
    # second stacked bar, then write the setting while nothing can overwrite it.
    for p in $(pgrep -x qs) $(pgrep -x dms); do kill "$p" 2>/dev/null; done
    for _ in $(seq 1 30); do pgrep -x qs >/dev/null 2>&1 || break; sleep 0.2; done

    write_frame "$new"

    niri msg action spawn -- dms run >/dev/null 2>&1
    for _ in $(seq 1 60); do
        niri msg -j layers 2>/dev/null | grep -q 'dms:bar' && break
        sleep 0.5
    done

    # Another press arrived while we were reloading - honour it.
    [ -e "$PENDING" ] || break
done

sleep 1
dms notify --title "Frame" --message "$new" 2>/dev/null || true
