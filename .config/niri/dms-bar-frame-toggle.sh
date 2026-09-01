#!/usr/bin/env bash
# Toggle the frame (and with it, the bar's reserved space).
#
# WHY THIS RESTARTS DMS: frameEnabled is only read when the shell starts.
# Flipping it at runtime changes the setting but the frame surfaces stay up,
# so the space is not actually reclaimed until DMS reloads. That is a DMS
# limitation, not a choice - hence the ~8s reload.
#
# Mod+B stays a plain, instant bar toggle. This is the heavier one.

set -u

frame=$(dms ipc call settings get frameEnabled 2>/dev/null | tail -1 | tr -d '"')

if [ "$frame" = "true" ]; then
    dms ipc call settings set frameEnabled false >/dev/null 2>&1
    dms notify --title "Frame" --message "off - reloading shell" 2>/dev/null || true
else
    dms ipc call settings set frameEnabled true >/dev/null 2>&1
    dms notify --title "Frame" --message "on - reloading shell" 2>/dev/null || true
fi

dms restart >/dev/null 2>&1
