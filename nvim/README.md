# Neovim config

Copy this folder to `~/.config/nvim` and start `nvim`. That is the whole setup.

```sh
git clone https://github.com/Wint3rNight/niridots
cp -r niridots/nvim ~/.config/nvim
nvim
```

What happens on the first start, by itself:
1. lazy.nvim installs every plugin at the versions pinned in `lazy-lock.json` (a progress
   window opens; wait for it to finish, then press `q`).
2. Mason installs the tools: language servers (lua, glsl, python: basedpyright + ruff),
   stylua, codelldb, debugpy, sql-formatter, djlint, and the tree-sitter CLI. If the
   machine has no clangd / clang-format / rust-analyzer, Mason installs those too. This
   runs in the background for a few minutes (debugpy and basedpyright are the slow ones).
3. Treesitter compiles the syntax parsers once the CLI is there (background, a few minutes).
4. If a CUDA toolkit is found, a clangd config with the right CUDA flags is written to
   `~/.config/clangd/config.yaml`.

Restart nvim after the first run and everything is in place.

The one thing not installed for you: the `psql` client, which the database sidebar
(`Space o q`) needs to talk to Postgres. `sudo pacman -S postgresql-libs` on Arch.

The only things the machine itself must provide: `git`, `curl`, `tar`, `unzip`, and a C
compiler (`gcc`). Nice to have, all optional: `ripgrep` and `fd` (faster search), `lazygit`,
`cmake` + `ninja`, `gdb`, `node` (Copilot), the `claude` CLI, `fish`.

Read `GUIDE.md` — it teaches this setup from zero, with every shortcut.
