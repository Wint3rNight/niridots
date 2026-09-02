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
| `Mod+S` | Spotlight, **files only** |
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
| `Mod+Shift+I` | Keep awake — no lock, no blanking, no suspend (see Notes) |
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

**`Mod+Shift+I` runs `.config/niri/idle-toggle.sh`, not plain `dms ipc call inhibit`.**
The IPC call is not a no-op — setting `SessionService.idleInhibited` activates a real
`zwp_idle_inhibit` object (`Quickshell.Wayland.IdleInhibitor` in `DankBarWindow.qml`),
niri honours it, and swayidle stops seeing idle events. Verified: with it on, a test
`swayidle timeout 3` never fired.

The catch is that the inhibitor hangs off the **bar surface**, and DMS's own
`IdleService.qml` notes it "goes inactive whenever the bar surface is occluded
(fullscreen windows) or hidden (auto-hide)" — exactly when you want keep-awake, i.e. a
fullscreen video or a fullscreen build log.

So the script does both: stops swayidle (unconditional, survives fullscreen — and
swayidle is the only thing that locks or blanks here, since `logind IdleAction` is
`ignore`), and sets the DMS flag so the shell's indicators light up.

**Indicators**, all driven by that flag: the "Keep Awake" tile in the control centre,
an icon on the control-centre bar button (`controlCenterShowIdleInhibitorIcon`), a
dedicated `idleInhibitor` bar pill, and an OSD on toggle (`osdIdleInhibitorEnabled`,
already on). Only the OSD is currently enabled — the tile is not in
`controlCenterWidgets` and the pill is not in any bar list.

Idle timers, when on: **lock at 5 min, monitors off at 10, suspend at 15 — battery only**,
plus a lock before any suspend. The 15-minute suspend goes through
`.config/niri/idle-suspend.sh`, which exits without doing anything if the AC adapter is
in: an idle 15 minutes on mains is usually a build or a download, and those die if the
machine sleeps. It also never fires while something holds a Wayland idle inhibitor, so
video playback on battery keeps the machine awake by itself.

**`Mod+Shift+E` quits niri** and is one Shift away from `Mod+E` (yazi). Left as-is
because it is the niri default, but it is the one dangerous key on this list.

**Free keys**, if you want to bind something: `Mod+I`, `Mod+U`, `Mod+Shift+Q`,
`Mod+Shift+S`, `Mod+Shift+Y`.

`Mod+S` was a rofi file search before it was a spotlight one. The rofi version shelled
out to `fd --type f . $HOME` on every press — re-walking the whole home directory with
no index — and then opened the result with `xdg-open`. Spotlight's file mode uses the
dsearch index instead. `rofi-find.sh` and its `find)` case in `rofi-toggle.sh` are gone.

**Unbound DMS IPC targets** worth knowing about — see `dms ipc` for the full surface:
`systemupdater`, `dock`, `sessions`, `color-picker`, `theme` (light/dark),
`desktopWidget`, `outputs` (display profiles), `tray`, `mpris`.
