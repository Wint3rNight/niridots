#!/usr/bin/env bash
# Open the stats dashboard, or focus it if it is already on screen.
#
# Two bugs this guards against:
#
#  1. The original ran `kitty ... zellij --layout <file>` unconditionally, so
#     every Mod+V press spawned another window AND another anonymously-named
#     zellij session. That is where 190+ stale sessions came from.
#
#  2. A zellij session that has EXITED can still be attached to, but attaching
#     "resurrects" it: the panes redisplay their last captured output and the
#     commands are NOT running, so the dashboard looks frozen and ignores
#     input. Attaching is therefore only correct for a LIVE session; a dead one
#     must be deleted and rebuilt from the layout.
#
#  3. `zellij --session X --layout Y` does NOT create session X. It tries to
#     ATTACH to an existing X and add Y as tabs; when X is absent it errors with
#     "Session 'X' not found" and prints the entire session list -- which is the
#     wall of text that was appearing at the top of the terminal. Creating a
#     named session from a layout requires --new-session-with-layout.

export LANG=en_US.utf8

# If this is ever invoked from inside a zellij pane, an inherited ZELLIJ
# makes the layout load as tabs in *that* session instead of the dashboard.
unset ZELLIJ ZELLIJ_SESSION_NAME ZELLIJ_PANE_ID

LAYOUT="$HOME/.config/zellij/layouts/dashboard.kdl"
SESSION="dashboard"

# --- 1. Already on screen? Focus it rather than opening a second one. -------
id=$(niri msg -j windows 2>/dev/null \
     | jq -r 'first(.[] | select(.app_id == "stats-terminal") | .id) // empty')
if [ -n "$id" ]; then
    exec niri msg action focus-window --id "$id"
fi

# --- 2. Always rebuild the session. -----------------------------------------
# Reattaching to a detached dashboard does NOT work. btop redraws a full screen
# every 200ms (-u 200); with no client attached nothing drains its pty, the
# buffer fills, and btop blocks in write() permanently. Measured: 0 CPU ticks
# over 4s while cava and cmatrix (far less output) kept running at 4-5. It stays
# wedged after a client reattaches, so attaching to an existing session hands
# you a frozen left pane.
#
# Every pane here is a live monitor with no state worth preserving, so the cure
# is to tear the session down and build a fresh one on each open.
zellij kill-session   "$SESSION" >/dev/null 2>&1
zellij delete-session "$SESSION" >/dev/null 2>&1

# kill-session returns before teardown finishes. Creating over a still-dying
# session silently reattaches to it -- which hands back the very frozen btop we
# are trying to get rid of. Wait for it to actually disappear (max ~4s).
for _ in $(seq 1 40); do
    zellij list-sessions --no-formatting 2>/dev/null | grep -q "^$SESSION " || break
    sleep 0.1
done

# --config gives this window the vivid dashboard palette; every other
# terminal keeps the gothic one from kitty.conf.
exec kitty --config "$HOME/.config/kitty/dashboard.conf" \
     --hold --class stats-terminal bash -c \
    "zellij --session '$SESSION' --new-session-with-layout '$LAYOUT'"
