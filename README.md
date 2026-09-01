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
- `pkglist.txt` — every explicitly installed package on the box.

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
- **The backdrop layer-rule matters.** DMS paints on a surface named
  `quickshell`; without `place-within-backdrop true` matching it, the backdrop
  is empty during workspace switches and shows as a grey band across the screen.
- `.config/waybar` and `.config/swaync` are the pre-DMS bar and notification
  daemon. Retired but kept as a fallback.
