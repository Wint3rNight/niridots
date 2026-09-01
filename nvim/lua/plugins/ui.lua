return {
  -- Colorscheme
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    config = function()
      -- Transparency is remembered across sessions in a tiny state file.
      local state = vim.fn.stdpath("state") .. "/transparent"
      local function transparent() return vim.uv.fs_stat(state) ~= nil end
      local function apply()
        require("catppuccin").setup({
          transparent_background = transparent(),
          -- Cathedral: remap Catppuccin's palette slots rather than swapping
          -- the plugin, so every integration below keeps working.
          -- Desaturated throughout; blood and gilt are the only vivid slots.
          color_overrides = {
            mocha = {
              base      = "#0b0b0f", mantle    = "#08080b", crust    = "#000000",
              surface0  = "#14141b", surface1  = "#23232e", surface2 = "#2a2a35",
              overlay0  = "#4a4550", overlay1  = "#5a5560", overlay2 = "#6a6570",
              subtext0  = "#7d7a86", subtext1  = "#9a97a3", text     = "#d8d3c8",
              red       = "#a02c3c", maroon    = "#c84a58", peach    = "#c47a33",
              yellow    = "#c9a227", green     = "#6b7a4f", teal     = "#5f7d78",
              sky       = "#7d9c96", sapphire  = "#6b7d9e", blue     = "#4a5a7a",
              lavender  = "#7d5a7a", mauve     = "#9c7599", pink     = "#b08a9e",
              flamingo  = "#c9a89e", rosewater = "#d8c8c0",
            },
          },
          integrations = {
            blink_cmp = true, dap = true, dap_ui = true, diffview = true, flash = true, gitsigns = true,
            grug_far = true, harpoon = true, indent_blankline = { enabled = true }, lsp_trouble = true,
            mason = true, mini = { enabled = true }, neotest = true, noice = true, nvimtree = true,
            overseer = true, render_markdown = true, snacks = { enabled = true }, treesitter = true,
            which_key = true,
            native_lsp = {
              enabled = true,
              underlines = {
                errors = { "undercurl" }, hints = { "undercurl" }, warnings = { "undercurl" }, information = { "undercurl" },
              },
            },
          },
        })
        vim.cmd.colorscheme("catppuccin-mocha")
      end
      apply()
      -- Toggle lives under <leader>o (options) with the other UI switches; see snacks.lua
      _G.UserTransparency = {
        get = transparent,
        set = function(on)
          if on then io.open(state, "w"):close() else os.remove(state) end
          apply()
        end,
      }
    end,
  },

  -- Statusline
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    event = "VeryLazy",
    config = function()
      -- noice swallows the "recording @q" message, so show it here instead
      local function recording()
        local r = vim.fn.reg_recording()
        return r ~= "" and ("󰑊 recording @" .. r) or ""
      end
      require("lualine").setup({
        options = {
          theme = "auto",
          globalstatus = true,
          component_separators = "|",
          section_separators = { left = "", right = "" },
          disabled_filetypes = { statusline = { "NvimTree" } },
        },
        sections = {
          lualine_b = { "branch", "diff" },
          lualine_c = { { "filename", path = 1 } },
          lualine_x = { { recording, color = { fg = "#f38ba8", gui = "bold" } }, "overseer", "diagnostics", "filetype" },
          lualine_y = { "progress" },
          lualine_z = { "location" },
        },
      })
    end,
  },

  -- Icons
  { "nvim-tree/nvim-web-devicons", lazy = true },

  -- Subtle vertical indent guides
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    event = { "BufReadPre", "BufNewFile" },
    opts = { indent = { char = "▏" }, scope = { enabled = false } },
  },

  -- Modern cmdline/messages UI: centered ":" popup, LSP progress, long messages in a split.
  -- Notifications are routed to snacks.notifier automatically.
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    dependencies = { "MunifTanjim/nui.nvim" },
    opts = {
      lsp = {
        override = {
          ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
          ["vim.lsp.util.stylize_markdown"] = true,
        },
      },
      presets = {
        bottom_search = true,
        command_palette = true,
        long_message_to_split = true,
        lsp_doc_border = true,
      },
    },
    keys = {
      { "<leader>fn", function() require("noice").cmd("history") end, desc = "Message history" },
    },
  },
}
