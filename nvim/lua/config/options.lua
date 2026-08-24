-- Remote-plugin providers (python/perl/ruby/node) are unused here; disabling them
-- removes checkhealth noise and a few startup probes.
vim.g.loaded_python3_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_node_provider = 0

-- Wayland clipboard: naming the tool skips nvim's slow provider auto-detection.
vim.g.clipboard = "wl-copy"
-- Sync yank/paste with the system clipboard, wired up after the UI is ready.
vim.schedule(function() vim.o.clipboard = "unnamedplus" end)

-- Autoformat policy (see plugins/formatting.lua): everything formats on save,
-- except C/C++/CUDA which is opt-in per repo (their upstreams differ on it).
vim.g.autoformat = true
vim.g.autoformat_c = false

local opt = vim.opt

-- Lines & cursor
opt.number = true
opt.relativenumber = true
opt.cursorline = true
opt.scrolloff = 8
opt.sidescrolloff = 8
opt.signcolumn = "yes"
opt.wrap = false
opt.linebreak = true
opt.breakindent = true
opt.smoothscroll = true
opt.mouse = "a"
opt.termguicolors = true

-- Indentation: 4 spaces (repos with .editorconfig override this automatically)
opt.tabstop = 4
opt.shiftwidth = 4
opt.expandtab = true
opt.smartindent = true
opt.shiftround = true

-- Search
opt.ignorecase = true
opt.smartcase = true
opt.inccommand = "split"

-- Windows
opt.splitright = true
opt.splitbelow = true
opt.splitkeep = "screen"
opt.winborder = "rounded"
opt.laststatus = 3          -- one global statusline
opt.showmode = false        -- lualine shows the mode
opt.pumheight = 12

-- Files
opt.undofile = true         -- undo history survives closing the file
opt.swapfile = false        -- no "E325 ATTENTION" prompts
opt.backup = false
opt.confirm = true          -- ask instead of failing on :q with unsaved changes
opt.exrc = true             -- load a trusted .nvim.lua from the project root

-- Make whitespace visible (trailing spaces fail CI in llama.cpp / cccl)
opt.list = true
opt.listchars = { tab = "» ", trail = "·", nbsp = "␣", extends = "…", precedes = "…" }

-- Folds (treesitter/LSP set foldexpr per buffer; start fully open)
opt.foldlevel = 99
opt.foldlevelstart = 99
opt.foldtext = ""
opt.fillchars = { foldopen = "▾", foldclose = "▸", fold = " ", foldsep = " ", diff = "╱", eob = " " }

-- Misc
opt.updatetime = 250
opt.timeoutlen = 300
opt.virtualedit = "block"
opt.jumpoptions = "view"
opt.sessionoptions = { "buffers", "curdir", "tabpages", "winsize", "help", "globals", "skiprtp", "folds" }
opt.grepprg = "rg --vimgrep --smart-case"
opt.grepformat = "%f:%l:%c:%m"
opt.shortmess:append({ W = true, I = true, c = true, C = true })
opt.spelllang = { "en" }

-- Builds: `:Make [target]` (async, via overseer) and plain `:make`.
-- Per-repo .nvim.lua can override makeprg (e.g. a build-opt/ directory).
opt.makeprg = "cmake --build build --target $*"
opt.errorformat:prepend([[%-G[%*\d/%*\d]%.%#,%-GFAILED:%.%#]]) -- hide ninja progress lines

-- Plugins run shell commands through a POSIX shell; interactive terminals stay fish
-- (toggleterm is configured with shell = "fish").
opt.shell = "sh"

-- tree-sitter CLI lives in the npm user prefix; fish doesn't export it, so nvim adds it itself
local npmbin = vim.fn.expand("~/.npm-global/bin")
if not string.find(vim.env.PATH or "", npmbin, 1, true) then
  vim.env.PATH = npmbin .. ":" .. vim.env.PATH
end

-- Diagnostics: icons in the gutter, sorted by severity
vim.diagnostic.config({
  virtual_text = { prefix = "●", spacing = 2 },
  float = { border = "rounded", source = "if_many" },
  severity_sort = true,
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = " ",
      [vim.diagnostic.severity.WARN] = " ",
      [vim.diagnostic.severity.HINT] = "󰠠 ",
      [vim.diagnostic.severity.INFO] = " ",
    },
  },
})

-- Extra shader extensions (nvim already knows .vert/.frag/.comp/.glsl/.cu/.cuh/.slang/.wgsl)
vim.filetype.add({
  extension = { hlsl = "hlsl", hlsli = "hlsl", fx = "hlsl", fxh = "hlsl", glslh = "glsl", glsli = "glsl" },
})
