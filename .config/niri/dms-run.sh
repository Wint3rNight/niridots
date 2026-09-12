#!/usr/bin/env bash
# Launch DMS from a patched copy of its embedded UI.
#
# WHY A COPY: since 1.6 the QML lives inside /usr/bin/dms and is unpacked to
# $XDG_RUNTIME_DIR/danklinux-shell/<hash> on every launch, so editing
# /usr/share/quickshell/dms is no longer possible. `dms run -c <dir>` is the
# supported way to run your own UI dir instead.
#
# WHY IT CAN'T GO STALE: the copy is tagged with `dms version`. When the binary
# changes, DMS starts stock, this harvests the UI it unpacks, re-applies the
# patches and swaps over (one short reload, once per update). If a patch's
# anchor text is gone because upstream rewrote that code, the build is abandoned
# and DMS just stays stock - nothing breaks, you only lose that patch until it's
# updated here. Check $XDG_RUNTIME_DIR/dms-run.log for that.
#
# Force a rebuild: rm ~/.local/share/dms-patched-ui/.dms-version
#
# Patches:
#   no-pause  MprisController.switchActivePlayer pauses the player you switch
#             away from (dash media dropdown and the island player list both
#             call it). Removed, so switching players is only a focus change.

set -u

RUN="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
UI="${XDG_DATA_HOME:-$HOME/.local/share}/dms-patched-ui"
LOG="$RUN/dms-run.log"

log() { printf '%s %s\n' "$(date +%T)" "$*" >>"$LOG"; }

ver=$(dms version 2>/dev/null | awk '{print $2}')

if [ -n "$ver" ] && [ -f "$UI/shell.qml" ] && [ "$(cat "$UI/.dms-version" 2>/dev/null)" = "$ver" ]; then
    exec dms run -c "$UI"
fi

log "no patched UI for ${ver:-unknown dms version}; starting stock and rebuilding"
dms run &

# Wait for the stock launch to unpack a UI matching this binary.
src=
for _ in $(seq 1 60); do
    for v in "$RUN"/danklinux-shell/*/VERSION; do
        [ -f "$v" ] && [ "$(cat "$v")" = "$ver" ] && src=${v%/VERSION} && break 2
    done
    sleep 0.5
done
if [ -z "$src" ]; then
    log "embedded UI for $ver never appeared; staying stock"
    wait
    exit
fi

tmp="$UI.tmp"
rm -rf "$tmp"
cp -r "$src" "$tmp" && chmod -R u+w "$tmp"

if ! python3 - "$tmp" >>"$LOG" 2>&1 <<'EOF'
import pathlib, sys

root = pathlib.Path(sys.argv[1])
patches = [
    ("no-pause", "Services/MprisController.qml",
     "        if (current && current !== player && current.canPause)\n"
     "            current.pause();\n",
     "        // dotfiles-patch no-pause: upstream pauses the player you switch away from here.\n"),
]
for name, rel, old, new in patches:
    path = root / rel
    text = path.read_text()
    if text.count(old) != 1:
        sys.exit(f"patch {name}: anchor not found in {rel}")
    path.write_text(text.replace(old, new))
EOF
then
    log "patching failed; staying stock"
    rm -rf "$tmp"
    wait
    exit
fi

echo "$ver" >"$tmp/.dms-version"
rm -rf "$UI" && mv "$tmp" "$UI"
log "built patched UI for $ver; switching over"

dms kill >/dev/null 2>&1
for _ in $(seq 1 30); do pgrep -x qs >/dev/null 2>&1 || break; sleep 0.2; done
exec dms run -c "$UI"
