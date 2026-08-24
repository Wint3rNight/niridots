return {
  -- The map: a file tree for orienting in a repo
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    cmd = { "NvimTreeToggle", "NvimTreeFindFileToggle", "NvimTreeRefresh" },
    keys = {
      { "<leader>ee", "<cmd>NvimTreeToggle<cr>", desc = "Toggle file tree" },
      { "<leader>ef", "<cmd>NvimTreeFindFileToggle<cr>", desc = "Toggle tree on current file" },
      { "<leader>er", "<cmd>NvimTreeRefresh<cr>", desc = "Refresh file tree" },
    },
    init = function()
      -- `nvim .` opens the tree (netrw is disabled in init.lua)
      vim.api.nvim_create_autocmd("VimEnter", {
        group = vim.api.nvim_create_augroup("user_tree_on_dir", { clear = true }),
        callback = function(ev)
          if ev.file ~= "" and vim.fn.isdirectory(ev.file) == 1 then
            vim.cmd.cd(ev.file)
            require("nvim-tree.api").tree.open()
          end
        end,
      })
    end,
    opts = {
      hijack_netrw = true,
      sync_root_with_cwd = true,      -- follows :cd / the projects picker
      respect_buf_cwd = true,
      update_focused_file = { enable = true, update_root = false },
      actions = { change_dir = { global = true } },
      view = { width = 30, relativenumber = true },
      renderer = { indent_markers = { enable = true } },
      filters = { custom = { ".DS_Store" } },
    },
  },

  -- The editor for files: `-` opens the current directory as a text buffer.
  -- Rename by editing the line, delete with dd, create by typing a name (end with / for a folder), :w applies.
  {
    "stevearc/oil.nvim",
    lazy = false,
    dependencies = { "nvim-tree/nvim-web-devicons" },
    keys = { { "-", "<cmd>Oil<cr>", desc = "Oil: edit directory" } },
    opts = {
      default_file_explorer = false,   -- nvim-tree keeps `nvim .`
      skip_confirm_for_simple_edits = true,
      view_options = { show_hidden = true },
      keymaps = {
        -- keep the Harpoon jump keys global; use C-v / C-x for splits here
        ["<C-h>"] = false, ["<C-t>"] = false, ["<C-s>"] = false, ["<C-l>"] = false,
        ["<C-v>"] = { "actions.select", opts = { vertical = true } },
        ["<C-x>"] = { "actions.select", opts = { horizontal = true } },
        ["gr"] = "actions.refresh",
        ["q"] = "actions.close",
      },
    },
  },
}
