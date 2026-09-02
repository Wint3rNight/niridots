# Shortcuts

Every key bound in `.config/niri/config.kdl`. `Mod` is the Super/Windows key.

`Mod+Slash` opens the same list live (DMS reads the niri config); `Mod+Shift+Slash`
is niri's own built-in overlay. This file is the copy that still works when the shell
is down, and the one that ships with the repo.

**Keep this in sync when you touch the `binds` block in `config.kdl`.**

---

## DankMaterialShell — panels

| Key | Does |
|---|---|
| `Mod+D` | Spotlight (everything: apps, files, folders, plugins) |
| `Mod+Shift+V` | Spotlight, **apps only** — no files mixed in |
| `Mod+Shift+S` | Spotlight, **files only** |
| `Mod+C` | Clipboard history |
| `Mod+N` | Control centre |
| `Mod+Shift+N` | Notification centre |
| `Mod+Shift+D` | Dashboard — overview tab |
| `Mod+M` | Dashboard — media tab |
| `Mod+Shift+W` | Dashboard — wallpaper browser |
| `Mod+Shift+P` | Process list (task manager) |
| `Mod+Y` | Notepad |
| `Mod+Z` | Mux (session/tmux switcher) |
| `Mod+X` | Power menu |
| `Mod+Shift+O` | DMS settings |
| `Mod+Slash` | Keybind cheatsheet |
| `Mod+B` | Show/hide the bar |
| `Mod+Shift+B` | Bar frame style |
| `Mod+W` | Next wallpaper |

Spotlight takes a mode argument: `dms ipc call spotlight toggleWith <mode>`, where mode
is one of **`all`, `apps`, `files`, `plugins`** — and nothing else. `setMode()` does not
validate, so an unknown mode is accepted silently and then behaves like `all`. That is
why `clipboard` and `calc` look like they work from the CLI but do nothing useful.

Inside spotlight: `Ctrl+J` / `Ctrl+K` or `Ctrl+N` / `Ctrl+P` move the selection,
`Tab` cycles mode, `Enter` opens, `Esc` closes.

## System toggles

| Key | Does |
|---|---|
| `Mod+Shift+A` | Cycle audio output (speakers ↔ JBL) |
| `Mod+Shift+U` | Cycle power profile (power-saver / balanced / performance) |
| `Mod+Shift+M` | Night light — manual only, no schedule |
| `Mod+Shift+Z` | Do not disturb |
| `Mod+Shift+I` | Keep awake (stops swayidle; see Notes) |
| `Mod+Ctrl+R` | Rename this workspace |
| `Mod+Ctrl+W` | Window rules for the focused window |
| `Mod+Ctrl+T` | Next theme |
| `Mod+Ctrl+Shift+T` | Reset theme |
| `Mod+Shift+X` | Lock now (qylock) |
| `Mod+Shift+E` | **Quit niri** — sits next to `Mod+E` (yazi), mind the Shift |

## Windows

| Key | Does |
|---|---|
| `Mod+H` `J` `K` `L` | Focus left / down / up / right (arrows work too) |
| `Mod+Ctrl+H/J/K/L` | Move the window (also `Mod+Shift+H/J/K/L`) |
| `Mod+Q` | Close window |
| `Mod+F` | Maximise column |
| `Mod+Shift+F` | Fullscreen |
| `Mod+Alt+F` | Maximise to screen edges |
| `Mod+R` | Cycle preset column widths |
| `Mod+Minus` / `Mod+Equal` | Column narrower / wider |
| `Mod+Shift+Minus` / `Mod+Shift+Equal` | Window shorter / taller |
| `Mod+Shift+R` | Reset window height |
| `Mod+[` / `Mod+]` | Pull a window into / push it out of this column |
| `Mod+Shift+T` | Tabbed column display |
| `Mod+O` | Overview |
| `Mod+Tab` | Window switcher (rofi) |
| `Mod+Shift+Space` | Float / unfloat |
| `Mod+Alt+arrows` | Nudge a floating window 50 px |

## Workspaces

| Key | Does |
|---|---|
| `Mod+1`…`9` | Go to workspace |
| `Mod+Ctrl+1`…`9` | Send the **column** there |
| `Mod+Shift+1`…`9` | Send the **window** there |
| `Mod+Alt+J` / `Mod+Alt+K` | Next / previous workspace |
| `Mod+Escape` | Back to the previous workspace |
| `Mod+scroll` | Switch workspace |
| `Mod+Shift+scroll` | Switch column |

## Apps and tools

| Key | Does |
|---|---|
| `Mod+T` | kitty (plain, no zellij) |
| `Mod+E` | yazi file manager |
| `Mod+V` | Stats dashboard (zellij) |
| `Mod+G` / `Mod+Shift+G` | ChatGPT / Gemini panel |
| `Mod+A` | Calculator (rofi) |
| `Mod+S` | File search (rofi) |
| `Mod+Period` | Emoji picker (rofi) |
| `Mod+Shift+C` | Config switcher (rofi) |
| `Mod+P` | Colour picker (hyprpicker, copies hex) |

## Screenshots and media

| Key | Does |
|---|---|
| `Print` | Screenshot (select) |
| `Ctrl+Print` | Whole screen |
| `Alt+Print` | Focused window |
| `Mod+Print` | Area, via script |
| `F2` / `F3` | Volume down / up |
| `F6` / `F7` | Brightness down / up |
| Media keys | Play-pause, next, previous, mute, mic-mute — all work while locked |

---

## Notes

**`Mod+Shift+I` does not use `dms ipc call inhibit`.** That IPC call only flips
`SessionService.idleInhibited`, a plain boolean whose sole real consumer is
`IdleService.qml` — which gates *DMS's own* idle monitors. Every DMS timeout here is `0`
(`acLockTimeout`, `batteryLockTimeout`, `acMonitorTimeout`, `acSuspendTimeout`, …)
because locking is done by **swayidle + qylock**, not DMS. DMS never creates a
`zwp_idle_inhibit` surface or a D-Bus ScreenSaver inhibit, so the IPC call cannot reach
swayidle: it changed a control-centre label and nothing else.

`.config/niri/idle-toggle.sh` stops swayidle instead, which is the only thing on this
machine that locks or blanks the screen — `logind` `IdleAction` is `ignore`, so nothing
auto-suspends either. It also mirrors the state into the DMS flag so the "Keep Awake"
tile in the control centre agrees with reality.

Idle timers, when on: **lock at 5 min, monitors off at 10 min**, and lock before suspend.

**`Mod+Shift+E` quits niri** and is one Shift away from `Mod+E` (yazi). Left as-is
because it is the niri default, but it is the one dangerous key on this list.

**Free keys**, if you want to bind something: `Mod+I`, `Mod+U`, `Mod+Shift+Q`,
`Mod+Shift+Y`.

**Unbound DMS IPC targets** worth knowing about — see `dms ipc` for the full surface:
`systemupdater`, `dock`, `sessions`, `color-picker`, `theme` (light/dark),
`desktopWidget`, `outputs` (display profiles), `tray`, `mpris`.
