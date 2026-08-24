return {
  -- Jump anywhere on screen: s + two chars. S selects a treesitter node; r/R in operator mode.
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    opts = {},
    keys = {
      { "s", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash jump" },
      { "S", mode = { "n", "x", "o" }, function() require("flash").treesitter() end, desc = "Flash treesitter select" },
      { "r", mode = "o", function() require("flash").remote() end, desc = "Remote flash" },
      { "R", mode = { "o", "x" }, function() require("flash").treesitter_search() end, desc = "Treesitter search" },
      { "<c-s>", mode = { "c" }, function() require("flash").toggle() end, desc = "Toggle flash in search" },
    },
  },

  -- mini.ai: af/if function, ac/ic class, ao/io block/loop/if, aa/ia argument, aq/iq quotes, ab/ib brackets
  -- mini.surround: gsa add, gsd delete, gsr replace, gsf find (gs* because flash owns `s`)
  -- mini.pairs: auto-close brackets/quotes
  {
    "nvim-mini/mini.nvim",
    version = false,
    event = "VeryLazy",
    config = function()
      local ai = require("mini.ai")
      ai.setup({
        n_lines = 500,
        custom_textobjects = {
          o = ai.gen_spec.treesitter({
            a = { "@block.outer", "@conditional.outer", "@loop.outer" },
            i = { "@block.inner", "@conditional.inner", "@loop.inner" },
          }),
          f = ai.gen_spec.treesitter({ a = "@function.outer", i = "@function.inner" }),
          c = ai.gen_spec.treesitter({ a = "@class.outer", i = "@class.inner" }),
          d = { "%f[%d]%d+" }, -- digits
          g = function() -- whole buffer
            local from = { line = 1, col = 1 }
            local to = { line = vim.fn.line("$"), col = math.max(vim.fn.getline("$"):len(), 1) }
            return { from = from, to = to }
          end,
        },
      })
      require("mini.surround").setup({
        mappings = {
          add = "gsa", delete = "gsd", find = "gsf", find_left = "gsF",
          highlight = "gsh", replace = "gsr", update_n_lines = "gsn",
        },
      })
      require("mini.pairs").setup({ modes = { insert = true, command = true, terminal = false } })
    end,
  },

  -- TODO / FIX / HACK / NOTE / PERF highlighting and navigation
  {
    "folke/todo-comments.nvim",
    event = { "BufReadPost", "BufNewFile" },
    opts = {},
    keys = {
      { "]t", function() require("todo-comments").jump_next() end, desc = "Next TODO" },
      { "[t", function() require("todo-comments").jump_prev() end, desc = "Previous TODO" },
      { "<leader>ft", function() Snacks.picker.todo_comments() end, desc = "TODOs (project)" },
      { "<leader>fT", function() Snacks.picker.todo_comments({ keywords = { "TODO", "FIX", "FIXME" } }) end, desc = "TODO/FIX only" },
    },
  },

  -- Diagnostics / quickfix / symbols panels
  {
    "folke/trouble.nvim",
    cmd = "Trouble",
    opts = { focus = true },
    keys = {
      { "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", desc = "Diagnostics (project)" },
      { "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", desc = "Diagnostics (buffer)" },
      { "<leader>xs", "<cmd>Trouble symbols toggle<cr>", desc = "Symbols outline" },
      { "<leader>xS", "<cmd>Trouble lsp toggle<cr>", desc = "LSP references/definitions" },
      { "<leader>xl", "<cmd>Trouble loclist toggle<cr>", desc = "Location list" },
      { "<leader>xq", "<cmd>Trouble qflist toggle<cr>", desc = "Quickfix list" },
      { "<leader>xt", "<cmd>Trouble todo toggle<cr>", desc = "TODOs" },
      {
        "[q",
        function()
          if require("trouble").is_open() then
            require("trouble").prev({ skip_groups = true, jump = true })
          else
            local ok, err = pcall(vim.cmd.cprev)
            if not ok then vim.notify(err, vim.log.levels.ERROR) end
          end
        end,
        desc = "Previous quickfix/trouble item",
      },
      {
        "]q",
        function()
          if require("trouble").is_open() then
            require("trouble").next({ skip_groups = true, jump = true })
          else
            local ok, err = pcall(vim.cmd.cnext)
            if not ok then vim.notify(err, vim.log.levels.ERROR) end
          end
        end,
        desc = "Next quickfix/trouble item",
      },
    },
  },

  -- Editable quickfix window: change lines in it and :w applies them to the files
  {
    "stevearc/quicker.nvim",
    ft = "qf",
    opts = {
      keys = {
        { ">", function() require("quicker").expand({ before = 2, after = 2, add_to_existing = true }) end, desc = "Expand quickfix context" },
        { "<", function() require("quicker").collapse() end, desc = "Collapse quickfix context" },
      },
    },
  },

  -- Project-wide search & replace with a live preview buffer
  {
    "MagicDuck/grug-far.nvim",
    cmd = "GrugFar",
    opts = { headerMaxWidth = 80 },
    keys = {
      {
        "<leader>sr",
        function()
          local ext = vim.bo.buftype == "" and vim.fn.expand("%:e") or ""
          require("grug-far").open({ transient = true, prefills = { filesFilter = ext ~= "" and "*." .. ext or nil } })
        end,
        mode = { "n", "v" },
        desc = "Search & replace in project",
      },
    },
  },
}
