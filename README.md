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
- `.config/spicetify/` — Spotify theming. `Themes/Cathedral/` is hand-written and
  vendored; SpicetifyCat (17 MB upstream clone) is fetched by `bootstrap.sh`.
- `.config/wireplumber/` — one audio routing rule, see Notes.
- `system/` — the few files that live outside `$HOME`, mirroring their real paths
  (`etc/`, `usr/local/bin/`). Installed by `bootstrap.sh` step 8, which needs sudo
  and skips itself rather than prompting if it does not have it.
- `applications/` — `.desktop` entries for `~/.local/share/applications`. Currently
  the nvim-in-kitty file-open handler; `bootstrap.sh` step 9 installs it and points
  the MIME defaults at it.
- `pkglist.txt` — every explicitly installed package on the box.
- `dms-plugins.txt` — DMS plugin IDs. The plugins themselves are git clones
  (~21 MB) so they are gitignored; `bootstrap.sh` reinstalls them by ID.

## Notes

- DMS is deliberately kept out of the way of the hand-built theme:
  `DMS_DISABLE_MATUGEN=1` is set in the niri `environment` block, and
  `gtkThemingEnabled` / `qtThemingEnabled` are false. DMS also generates
  `.config/niri/dms/*.kdl` (gaps 4, border 2) — these are **not** `include`d,
  so the settings in `config.kdl` stay authoritative.
- The lock screen is qylock (`Mod+Shift+X`, and swayidle at 5 min), not the DMS
  one. Enabling `lockBeforeSuspend` in DMS would stack two lock screens.
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
- **Spotify audio output.** WirePlumber remembers a per-app output target
  (`node.stream.restore-target` defaults to true), and a saved
  `"target"` for Spotify overrode the default sink — so changing the output
  device in the DMS media panel moved every app *except* Spotify. The panel only
  sets the default sink (`Pipewire.preferredDefaultAudioSink`); it does not move
  pinned streams. Worse, the usual workaround of moving it by hand in pavucontrol
  re-saved the pin each time. `.config/wireplumber/wireplumber.conf.d/51-spotify-follow-default.conf`
  sets `state.restore-target = "false"` for Spotify so it always follows the
  default sink. Remove that file if you ever want to pin Spotify to its own device.
- `.config/waybar` and `.config/swaync` are the pre-DMS bar and notification
  daemon. Retired but kept as a fallback.
- **`Mod+Shift+S` used to be dead.** It called `dms ipc call quickCapture ...`,
  which is not a DMS IPC target — `dms ipc call quickCapture fromClipboard edit`
  answers `Target not found`, so the key silently did nothing. It now opens
  spotlight directly in file-search mode. Spotlight takes a mode argument, but only
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
- **`dms ipc call inhibit` is a no-op on this machine**, which is why `Mod+Shift+I`
  runs `.config/niri/idle-toggle.sh` instead. `inhibit` only flips
  `SessionService.idleInhibited`, a bool whose one real consumer gates *DMS's own*
  idle monitors — and every DMS timeout here is `0`, because swayidle + qylock do the
  locking. DMS creates no `zwp_idle_inhibit` surface and no D-Bus ScreenSaver inhibit,
  so it cannot reach swayidle; the call changed a control-centre label and nothing
  else. The script stops swayidle (the only thing that locks or blanks here — logind
  `IdleAction` is `ignore`) and mirrors the state back into the DMS flag so the
  "Keep Awake" tile stays truthful.
- **Opening a file from spotlight needs a working MIME handler.** The handler is
  `applications/nvim-kitty.desktop`, installed by `bootstrap.sh` step 9 along with
  the MIME defaults that point at it. It sets `Terminal=false` and calls
  `kitty -e nvim` explicitly, because `Terminal=true` entries make xdg-open and
  GLib search a hardcoded terminal list that does not contain kitty — on this
  machine the only match is konsole, so text files opened there instead.
