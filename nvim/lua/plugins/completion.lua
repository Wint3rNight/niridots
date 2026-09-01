return {
  -- Completion: blink.cmp (LSP, paths, snippets, buffer words, and the ":" / "/" command line)
  {
    "saghen/blink.cmp",
    version = "1.*",
    event = { "InsertEnter", "CmdlineEnter" },
    dependencies = { "rafamadriz/friendly-snippets", "folke/lazydev.nvim" },
    opts = {
      keymap = {
        preset = "enter",                                     -- Enter confirms the selected item
        ["<Tab>"] = { "select_next", "snippet_forward", "fallback" },
        ["<S-Tab>"] = { "select_prev", "snippet_backward", "fallback" },
        ["<C-Space>"] = { "show", "show_documentation", "hide_documentation" },
        ["<C-e>"] = { "hide", "fallback" },
        ["<C-b>"] = { "scroll_documentation_up", "fallback" },
        ["<C-f>"] = { "scroll_documentation_down", "fallback" },
      },
      appearance = { nerd_font_variant = "mono" },
      completion = {
        -- Nothing is pre-selected: Enter inserts a newline until you Tab onto an item
        list = { selection = { preselect = false, auto_insert = false } },
        menu = { border = "rounded", draw = { treesitter = { "lsp" } } },
        documentation = { auto_show = true, auto_show_delay_ms = 200, window = { border = "rounded" } },
        ghost_text = { enabled = false },                     -- Copilot owns the ghost text
        accept = { auto_brackets = { enabled = true } },
      },
      signature = { enabled = true, window = { border = "rounded" } },
      sources = {
        default = { "lsp", "path", "snippets", "buffer", "lazydev" },
        -- SQL buffers: table/column names from the live connection (vim-dadbod-completion)
        per_filetype = { sql = { "dadbod", "buffer", "snippets" }, mysql = { "dadbod", "buffer" }, plsql = { "dadbod", "buffer" } },
        providers = {
          lazydev = { name = "LazyDev", module = "lazydev.integrations.blink", score_offset = 100 },
          dadbod = { name = "Dadbod", module = "vim_dadbod_completion.blink" },
        },
      },
      cmdline = {
        enabled = true,
        keymap = {
          preset = "cmdline",
          ["<Tab>"] = { "show_and_insert", "select_next" },
          ["<S-Tab>"] = { "show_and_insert", "select_prev" },
        },
        completion = {
          menu = { auto_show = true },
          list = { selection = { preselect = false, auto_insert = true } },
        },
      },
      fuzzy = { implementation = "prefer_rust_with_warning" },
    },
    opts_extend = { "sources.default" },
  },

  -- Lua: completion + types for the nvim API while editing this config
  {
    "folke/lazydev.nvim",
    ft = "lua",
    opts = {
      library = {
        { path = "${3rd}/luv/library", words = { "vim%.uv" } },
        { path = "snacks.nvim", words = { "Snacks" } },
        { path = "lazy.nvim", words = { "LazyVim" } },
      },
    },
  },
}
