# niridots

My Linux desktop: **niri** (scrollable-tiling window manager) with
**DankMaterialShell** as the shell layer — bar, launcher, notifications, control
centre, dashboard and system monitor — plus rofi, kitty, fish, zellij and the
Neovim config. Everything here is a copy of what is live under `~/.config`.

Theme is **Cathedral**: ink `#0b0b0f`, blood `#a02c3c`, gilt `#c9a227`,
bone `#d8d3c8`. It is applied by hand across every surface — niri borders, kitty,
DMS, btop, cava, rofi, GTK, Qt, bat, fzf and Neovim.

## Put it back on a fresh machine

```bash
git clone https://github.com/Wint3rNight/niridots.git ~/dotfiles
~/dotfiles/scripts/bootstrap.sh
```

That installs the packages, backs up anything it replaces, copies the configs into
place, rewrites the baked-in `/home/winter` paths if your username differs, fixes
the locale (see below) and installs the fonts. Log out and back in when it finishes.

Doing it by hand instead:

1. `sudo pacman -S --needed - < pkglist.txt` (AUR ones need `yay`).
2. `cp -r .config/* ~/.config/`, `cp -r nvim ~/.config/nvim`, `cp scripts/* ~/.local/bin/`.
3. If your home is not `/home/winter`, rewrite it — ten files hardcode it,
   including `.config/DankMaterialShell/settings.json` (`customThemeFile`) and
   `.config/niri/config.kdl`:
   `grep -rl /home/winter ~/.config | xargs sed -i "s|/home/winter|$HOME|g"`
4. **Set `LANG` to something containing `UTF-8`.** `/etc/locale.conf` must read
   `LANG=en_IN.UTF-8`, not `LANG=en_IN`. btop and other TUIs string-match the
   *value* of `$LANG` for "UTF-8" and refuse to start without it — even when the
   locale genuinely is UTF-8 underneath. A bare `LANG=en_IN` makes btop exit
   instantly with `No UTF-8 locale detected!`.
5. Neovim: run `nvim` once. lazy.nvim installs every plugin at the exact versions
   in `nvim/lazy-lock.json`. Mason then installs stylua, codelldb, glsl_analyzer
   and lua-language-server. Treesitter parsers compile in the background.
   The tree-sitter CLI is needed:
   `npm i -g --allow-scripts=tree-sitter-cli tree-sitter-cli`.
6. clangd, clang-format, gdb, cmake, ninja, rg, fd, lazygit come from pacman.
   The CUDA flags for clangd are in `.config/clangd/config.yaml`; check
   `--cuda-path` and `--cuda-gpu-arch` if the machine is different.
7. Copilot: `:Copilot auth` inside nvim. Claude: log in with the `claude` CLI.
8. Set your weather city in DMS settings — it ships defaulting to New York.

## Where things are

- `SHORTCUTS.md` — every niri / DMS keybind, grouped by task. Keep it in sync with the
  `binds` block in `config.kdl`. (`Mod+Slash` shows the same list live.)
- `nvim/` — the Neovim config. `nvim/GUIDE.md` is the beginner's guide (every shortcut).
- `.config/niri/config.kdl` — window manager, keybinds, window/layer rules, animations.
- `.config/DankMaterialShell/` — the shell. `cathedral.json` is the theme;
  `settings.json` selects it via `currentThemeName: custom`.
- `.config/kitty`, `.config/zellij` — terminal and the `Mod+V` stats dashboard.
- `.config/rofi` — still used for the modes DMS has no equivalent for
  (calc, emoji, web search, configs, media, window switcher).
- `.config/btop`, `.config/cava`, `.config/fastfetch`, `.config/bat` — themed TUIs.
- `.config/gtk-3.0`, `.config/gtk-4.0`, `.config/qt5ct`, `.config/qt6ct` — app theming.
- `scripts/` — helpers that live in `~/.local/bin`, plus `bootstrap.sh`.
- `.config/niri/audio-output.sh` — per-app audio output picker (`Mod+Shift+A`), see Notes.
- `scripts/patch-dms.sh` — stops the DMS media panel pausing the player you switch
  away from. **A `dms-shell` update silently reverts it; re-run after upgrading.**
- `.config/spicetify/` — Spotify theming. `Themes/Cathedral/` is hand-written and
  vendored; SpicetifyCat (17 MB upstream clone) is fetched by `bootstrap.sh`.
- `system/` — the few files that live outside `$HOME`, mirroring their real paths
  (`etc/`, `usr/local/bin/`). Installed by `bootstrap.sh` step 8, which needs sudo
  and skips itself rather than prompting if it does not have it.
- `applications/` — `.desktop` entries for `~/.local/share/applications`. Currently
  the nvim-in-kitty file-open handler; `bootstrap.sh` step 9 installs it and points
  the MIME defaults at it.
- `pkglist.txt` — every explicitly installed package on the box.
- `dms-plugins.txt` — DMS plugin IDs. The plugins themselves are git clones
  (~21 MB) so they are gitignored; `bootstrap.sh` reinstalls them by ID.
- `dms-plugins-enabled.txt` — the subset that must also be **enabled**. `dms plugins
  install` leaves a plugin disabled, and a disabled plugin registers no IPC target, so
  keys bound to it fail silently. That is how quickCapture's keys were dead.

## Notes

- DMS is deliberately kept out of the way of the hand-built theme:
  `DMS_DISABLE_MATUGEN=1` is set in the niri `environment` block, and
  `gtkThemingEnabled` / `qtThemingEnabled` are false. DMS also generates
  `.config/niri/dms/*.kdl` (gaps 4, border 2) — these are **not** `include`d,
  so the settings in `config.kdl` stay authoritative.
- The lock screen is qylock (`Mod+Shift+X`, and DMS's idle timer at 5 min), not the
  DMS one. See the idle note below for why `lockBeforeSuspend` is safe to enable.
- DMS paints the wallpaper. waypaper and mpvpaper are gone. `Mod+W` cycles to
  the next image in the folder with a random transition; `Mod+Shift+W` opens the
  browser. Static images only - DMS has no video/mpv backend and uses plain
  `Image`, so a GIF renders as a still frame. Video exists only for the lock
  screen. For a video wallpaper you would reinstall mpvpaper.
- `wallpaperTransition` lives in `~/.local/state/DankMaterialShell/session.json`,
  not `settings.json` - `dms ipc call settings set` returns `undefined` for it.
  DMS holds session state in memory and rewrites that file on shutdown, so an
  edit made while DMS is running gets clobbered. Stop DMS, write the value,
  start it again. Set to `random` to cycle through all seven transitions.
- **The backdrop layer-rule matters.** DMS paints on a surface named
  `quickshell`; without `place-within-backdrop true` matching it, the backdrop
  is empty during workspace switches and shows as a grey band across the screen.
- **Per-app audio routing, and a fix that was worse than the bug.** WirePlumber
  remembers a per-app output target (`node.stream.restore-target`, on by default): move
  an app's stream once and it is pinned there for good. That pin is what makes
  "Spotify on the speaker, YouTube in the earphones" work at all.

  A previous version of this repo shipped
  `.config/wireplumber/wireplumber.conf.d/51-spotify-follow-default.conf`, setting
  `state.restore-target = "false"` for Spotify so it would always follow the default
  sink. It was meant to fix the DMS media panel being unable to move Spotify — but that
  rule makes `state-stream.lua` skip both the restore *and* the save path, so Spotify
  could never hold a target again, and every app ended up following the default
  together. It destroyed exactly the per-app routing it was supposed to help.
  **The file is deleted. Do not reintroduce it.**

  The actual gap was that DMS has **no per-app routing** — no UI, no IPC.
  `dms ipc call audio cycleoutput` (`Mod+Shift+A`) and the media panel's device list
  both only set the *default sink*, so every unpinned stream moves together.

  `.config/niri/audio-output.sh` (`Mod+Shift+Y`) covers the per-app case: a rofi picker
  over the live PipeWire streams, moving the one you choose. It reads raw streams rather
  than MPRIS, so it sees **everything that makes noise** — mpv without `mpv-mpris`,
  games, anything — and it touches no package files, so DMS upgrades cannot break it.

  Making the DMS media panel itself route per-player was tried and dropped: it needed a
  second QML patch plus an MPRIS→PipeWire resolver, only ever covered apps with an MPRIS
  interface, and reverted on every `dms-shell` upgrade. Not worth it for something done
  a few times a week.

  **Pins beat the default.** WirePlumber saves an app's output the moment you move it by
  hand (`node.stream.restore-target`), and a pinned app then ignores `Mod+Shift+A`
  entirely. That is what makes "Spotify on the speaker, YouTube in the earphones" work —
  but it also means "the toggle stopped working for this one app" nearly always means
  "that app is pinned". Moving it back onto the current default clears the pin.

  A stale `Output/Audio:media.role:Movie` entry pinned to the speaker sits in
  `stream-properties`. It is **inert** on WirePlumber 0.5.16: `formKey()` in
  `state-stream.lua` only uses the `media.role` key when the role is exactly
  `Notification`, and otherwise keys on `application.id` / `application.name`.
- `.config/waybar` and `.config/swaync` are the pre-DMS bar and notification
  daemon. Retired but kept as a fallback.
- **`Mod+Shift+S` used to be dead**, and is now free. It called
  `dms ipc call quickCapture fromClipboard edit`, which answered `Target not found` —
  not because the binding was wrong but because the **quickCapture plugin was
  disabled**, so the target did not exist. The plugin is enabled now and that exact
  command lives on `Mod+I` (see the screenshot note below). File search moved to
  `Mod+S`, replacing a rofi picker that re-walked all of `$HOME` with `fd` on every
  press. Spotlight takes a mode argument, but only
  **`all`, `apps`, `files`, `plugins`** are real — `Controller.setMode()` does no
  validation, so an unknown mode (`clipboard`, `calc`) is assigned silently and then
  behaves exactly like `all`. `Mod+Shift+V` — previously a duplicate of `Mod+N` — is
  the apps-only launcher, which is worth having because
  `dankLauncherV2IncludeFilesInAll` mixes files into `Mod+D`.
- **Power profiles switch themselves now.** power-profiles-daemon only exposes
  the profiles; nothing was choosing between them, so the machine sat on
  `power-saver` while plugged into an RTX 3050 laptop. `system/` adds a oneshot
  unit plus a udev rule on the `ACAD` power supply: **balanced on AC,
  power-saver on battery**, applied at boot and on every plug/unplug. A manual
  override with `Mod+Shift+U` holds until the next AC event. Change the one word
  in `power-profile-auto` if you want `performance` on AC instead.
- **Night light is deliberately manual.** `Mod+Shift+M` toggles it;
  `dms ipc call night getSchedule` reports `Automation disabled` and nothing
  here turns that on.
- **Idle is DMS's IdleService, not swayidle** — but it still locks with **qylock**.
  `customPowerActionLock` points at `lock.sh`, and `Modules/Lock/Lock.qml`'s `lock()`
  short-circuits to `spawnCustomLocker()` before DMS's own lock screen is ever engaged,
  so there is no second lock screen and `lockBeforeSuspend` is safe to enable (it is on,
  giving a systemd sleep inhibitor so a lid close locks first). Timings are in DMS
  settings, per power source: lock 5 min, monitors off 10 min, suspend 15 min on battery
  and never on AC. `fadeToLockEnabled` adds a 5 s cancellable warning.
  `Mod+Shift+I` is `dms ipc call inhibit toggle`, which is reliable here because
  `IdleService` gates its own monitors on the flag internally (`IdleService.qml:42`) —
  the bar-surface `zwp_idle_inhibit` it also creates goes inactive behind a fullscreen
  window, which is why an earlier swayidle-killing script existed. Trade-off taken
  knowingly: no auto-lock while quickshell is down.
- **Boot is SDDM**, themed `pixel-night-city` — which is itself a Qylock theme
  (`/usr/share/sddm/themes/pixel-night-city/metadata.desktop`), so the greeter and the
  lock screen match without being the same program. `theme.conf` beats
  `kde_settings.conf` (`breeze`) alphabetically in `/etc/sddm.conf.d/`.
- **Screenshots go through the DMS quickCapture plugin**, not niri's built-in
  screenshot actions and not the old slurp/grim/swappy script (`screenshot-area.sh`,
  deleted). The plugin ships with DMS but was **disabled**, which is the whole reason
  the original `Mod+Shift+S` → `quickCapture fromClipboard edit` did nothing: the
  binding was right, the IPC target simply did not exist. Enabling it also lit up the
  `quickCapture` widget already sitting inert in the bar's `rightWidgets`.
  `Print` / `Ctrl+Print` / `Alt+Print` use the `copyAndSave` action, which reproduces
  exactly what niri did (clipboard **and** `~/Pictures/Screenshots`); `Mod+Shift+Print` uses
  `edit`, which reproduces swappy. New on top: `Mod+Print` scrolling capture
  (grim and slurp cannot do this at all), `Mod+I` annotate-the-clipboard, `Mod+U`
  capture history. Modes and actions are not validated by the IPC, so a typo fails
  silently — the valid sets are in `SHORTCUTS.md`.
- **Opening a file from spotlight needs a working MIME handler.** The handler is
  `applications/nvim-kitty.desktop`, installed by `bootstrap.sh` step 9 along with
  the MIME defaults that point at it. It sets `Terminal=false` and calls
  `kitty -e nvim` explicitly, because `Terminal=true` entries make xdg-open and
  GLib search a hardcoded terminal list that does not contain kitty — on this
  machine the only match is konsole, so text files opened there instead.
