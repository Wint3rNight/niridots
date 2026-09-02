return {
  -- Harpoon: Quick jumping between files
  -- keys = lazy-loads on first use. Without it this plugin loaded during startup,
  -- because lazy.setup sets defaults.lazy = false for anything with no trigger.
  {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
      { "<leader>a", function() require("harpoon"):list():add() end, desc = "Harpoon: add file" },
      { "<C-e>", function() local h = require("harpoon") h.ui:toggle_quick_menu(h:list()) end, desc = "Harpoon: menu" },
      { "<C-h>", function() require("harpoon"):list():select(1) end, desc = "Harpoon: file 1" },
      { "<C-t>", function() require("harpoon"):list():select(2) end, desc = "Harpoon: file 2" },
      { "<C-n>", function() require("harpoon"):list():select(3) end, desc = "Harpoon: file 3" },
      { "<C-s>", function() require("harpoon"):list():select(4) end, desc = "Harpoon: file 4" },
    },
    config = function() require("harpoon"):setup() end,
  },

  -- Undotree: Visual undo history
  {
    "mbbill/undotree",
    cmd = { "UndotreeToggle", "UndotreeShow", "UndotreeFocus" },
    keys = {
      { "<leader>u", vim.cmd.UndotreeToggle, desc = "Toggle Undotree" },
    },
  },
}
