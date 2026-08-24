-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
  vim.fn.system({ "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath })
end
vim.opt.rtp:prepend(lazypath)

-- Editor settings first (leader must exist before plugins define keys)
require("config.options")
require("config.keymaps")
require("config.autocmds")

require("lazy").setup({
  spec = { { import = "plugins" } },
  defaults = { lazy = false, version = false },
  install = { colorscheme = { "catppuccin-mocha" } },
  checker = { enabled = false },          -- no "updates available" nagging
  change_detection = { notify = false },  -- no popup every time a config file is saved
  ui = { border = "rounded" },
  rocks = { enabled = false },           -- no plugin here needs luarocks
  performance = {
    rtp = {
      -- Built-in plugins nothing here uses (netrw is replaced by nvim-tree + oil)
      disabled_plugins = { "gzip", "tarPlugin", "tohtml", "tutor", "zipPlugin", "netrwPlugin" },
    },
  },
})
