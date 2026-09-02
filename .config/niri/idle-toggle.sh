#!/bin/sh
# Keep-awake toggle for Mod+Shift+I.
#
# WHY THIS EXISTS INSTEAD OF `dms ipc call inhibit toggle`:
# that IPC call only flips SessionService.idleInhibited, a plain bool. Its only real
# consumer is IdleService.qml, which gates *DMS's own* idle monitors - and every DMS
# timeout on this machine is 0 (acLockTimeout, batteryLockTimeout, acMonitorTimeout,
# acSuspendTimeout, ...) because the lock screen here is qylock driven by swayidle, not
# DMS. DMS never creates a zwp_idle_inhibit surface or a D-Bus ScreenSaver inhibit, so
# nothing it does can reach swayidle. The IPC call changed a control-centre label and
# nothing else.
#
# swayidle is the only thing that locks or blanks this machine
# (logind IdleAction is "ignore"), so keeping awake means stopping swayidle.
#
# The DMS flag is still toggled alongside, so the "Keep Awake" tile in the control
# centre agrees with reality rather than contradicting it.

LOCK="$HOME/Projects/qylock/quickshell-lockscreen/lock.sh"

notify() {
    command -v notify-send >/dev/null && notify-send -a "Idle" -t 2500 "$1" "$2"
}

if pgrep -x swayidle >/dev/null 2>&1; then
    pkill -x swayidle
    dms ipc call inhibit enable >/dev/null 2>&1
    notify "Staying awake" "Auto-lock and screen blanking are off"
else
    # Same invocation as the spawn-at-startup line in config.kdl: lock at 5 min,
    # monitors off at 10, and lock before suspend.
    swayidle -w \
        timeout 300 "$LOCK" \
        timeout 600 'niri msg action power-off-monitors' \
        resume 'niri msg action power-on-monitors' \
        before-sleep "$LOCK" >/dev/null 2>&1 &
    dms ipc call inhibit disable >/dev/null 2>&1
    notify "Idle timers back on" "Locks after 5 min, screen off at 10"
fi
