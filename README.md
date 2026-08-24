# niridots

My Linux desktop: niri (window manager), waybar, swaync, rofi, kitty, fish, and the
Neovim config. Everything here is a copy of what is live under `~/.config`.

## Put it back on a fresh machine

1. Install packages: `sudo pacman -S --needed - < pkglist.txt` (AUR ones need `yay`).
2. Copy the folders into place:
   `cp -r .config/* ~/.config/`, `cp -r nvim ~/.config/nvim`, and `cp scripts/* ~/.local/bin/`.
3. Neovim: run `nvim` once. lazy.nvim installs every plugin at the exact versions in
   `nvim/lazy-lock.json`. Mason then installs stylua, codelldb, glsl_analyzer
   and lua-language-server. Treesitter parsers compile in the background.
   The tree-sitter CLI is needed: `npm i -g --allow-scripts=tree-sitter-cli tree-sitter-cli`.
4. clangd, clang-format, gdb, cmake, ninja, rg, fd, lazygit come from pacman (step 1).
   The CUDA flags for clangd are in `.config/clangd/config.yaml`; check `--cuda-path`
   and `--cuda-gpu-arch` if the machine is different.
5. Copilot: `:Copilot auth` inside nvim. Claude: log in with the `claude` CLI.

## Where things are

- `nvim/` — the Neovim config, in its own folder. `nvim/GUIDE.md` is the beginner's guide (every shortcut).
- `.config/niri/config.kdl` — window manager; the `rofi-*.sh` next to it are the menus.
- `.config/waybar`, `.config/swaync`, `.config/rofi` — bar, notifications, launcher.
- `scripts/` — helpers that live in `~/.local/bin` (volume/brightness popups, wifi/audio menus).
- `pkglist.txt` — every explicitly installed package on the box.
