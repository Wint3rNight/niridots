#!/bin/sh
# Keep-awake toggle for Mod+Shift+I.
#
# WHY THIS EXISTS INSTEAD OF PLAIN `dms ipc call inhibit toggle`:
#
# The IPC call does work - it is not a no-op. Setting SessionService.idleInhibited
# activates a real zwp_idle_inhibit object (Quickshell.Wayland.IdleInhibitor, created in
# Modules/DankBar/DankBarWindow.qml around line 675), niri honours it, and swayidle then
# never sees an idle event. Verified: with it on, a test `swayidle timeout 3` never fired.
#
# The catch is that the inhibitor is attached to the *bar surface*. DMS says so itself in
# Services/IdleService.qml: it "goes inactive whenever the bar surface is occluded
# (fullscreen windows) or hidden (auto-hide)". That is exactly when keep-awake matters
# most - a fullscreen video, or a fullscreen terminal watching a long build.
#
# So this does both:
#   - stops swayidle, which is unconditional and survives a fullscreen window
#     (swayidle is the only thing that locks or blanks here; logind IdleAction is
#     "ignore", so nothing auto-suspends either)
#   - sets the DMS flag too, which lights up the shell's own indicators: the "Keep
#     Awake" control-centre tile, the icon on the control-centre bar button, the
#     idleInhibitor bar pill, and the OSD (osdIdleInhibitorEnabled is already true).

LOCK="$HOME/Projects/qylock/quickshell-lockscreen/lock.sh"

notify() {
    command -v notify-send >/dev/null && notify-send -a "Idle" -t 2500 "$1" "$2"
}

if pgrep -x swayidle >/dev/null 2>&1; then
    pkill -x swayidle
    dms ipc call inhibit enable >/dev/null 2>&1
    notify "Staying awake" "No lock, no blanking, no suspend"
else
    # Same invocation as the spawn-at-startup line in config.kdl. Keep the two in sync.
    swayidle -w \
        timeout 300 "$LOCK" \
        timeout 600 'niri msg action power-off-monitors' \
        resume 'niri msg action power-on-monitors' \
        timeout 900 "$HOME/.config/niri/idle-suspend.sh" \
        before-sleep "$LOCK" >/dev/null 2>&1 &
    dms ipc call inhibit disable >/dev/null 2>&1
    notify "Idle timers back on" "Lock 5 min · screen off 10 · suspend 15 on battery"
fi
