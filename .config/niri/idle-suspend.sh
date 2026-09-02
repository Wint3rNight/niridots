#!/bin/sh
# Called by swayidle at the 15-minute mark. Suspends, but only on battery.
#
# Deliberately not unconditional: on AC an idle 15 minutes is usually a long build, a
# download, or a git clone left running - none of which produce input, and all of which
# die if the machine suspends. On battery there is nothing to protect and everything to
# save, which is the case this was asked for.
#
# Make it unconditional by replacing the whole file with `exec systemctl suspend`.
#
# Note this never fires while inhibit mode is on (Mod+Shift+I), because that stops
# swayidle outright. It also will not fire while something holds a Wayland idle
# inhibitor - mpv and browsers do that during playback - so a video on battery keeps
# the machine awake on its own.

AC=/sys/class/power_supply/ACAD/online

[ "$(cat "$AC" 2>/dev/null)" = "1" ] && exit 0

exec systemctl suspend
