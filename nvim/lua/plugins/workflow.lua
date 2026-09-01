-- The "everything else" of the daily workflow: terminals, AI, key discovery, sessions.
return {
  -- Terminals: one floating scratch terminal, one bottom terminal, dedicated lazygit
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    keys = { [[<C-\>]], "<leader>tt", "<leader>tf", "<leader>gg" },
    config = function()
      require("toggleterm").setup({
        shell = vim.fn.executable("fish") == 1 and "fish" or (vim.env.SHELL or "sh"), -- 'shell' is sh for plugins; humans get fish
        float_opts = { border = "rounded" },
      })
      -- Double-Esc leaves terminal insert mode (single Esc stays for TUI apps inside)
      vim.keymap.set("t", "<Esc><Esc>", [[<C-\><C-n>]], { desc = "Terminal: to normal mode" })

      local Terminal = require("toggleterm.terminal").Terminal
      local float_term = Terminal:new({ direction = "float", hidden = true })
      local bottom_term = Terminal:new({ direction = "horizontal", hidden = true })
      local lazygit = Terminal:new({
        cmd = "lazygit", direction = "float", hidden = true,
        float_opts = {
          border = "rounded",
          width = function() return math.floor(vim.o.columns * 0.95) end,
          height = function() return math.floor(vim.o.lines * 0.92) end,
        },
      })
      vim.keymap.set({ "n", "t" }, [[<C-\>]], function() float_term:toggle() end, { desc = "Terminal: floating scratch" })
      vim.keymap.set("n", "<leader>tt", function() bottom_term:toggle() end, { desc = "Terminal: bottom" })
      vim.keymap.set("n", "<leader>tf", function() float_term:toggle() end, { desc = "Terminal: floating" })
      vim.keymap.set("n", "<leader>gg", function() lazygit:toggle() end, { desc = "Git: lazygit" })
    end,
  },

  -- Which-key: pause after <space> and it shows what can follow
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      delay = 400,
      spec = {
        { "<leader>f", group = "find" },
        { "<leader>g", group = "git" },
        { "<leader>t", group = "terminal / tests" },
        { "<leader>c", group = "claude / code action" },
        { "<leader>e", group = "explorer" },
        { "<leader>s", group = "splits / search-replace" },
        { "<leader>x", group = "diagnostics / quickfix" },
        { "<leader>d", group = "debug" },
        { "<leader>m", group = "make / format" },
        { "<leader>o", group = "options / toggles" },
        { "<leader>b", group = "buffers" },
        { "<leader>q", group = "session / quit" },
        { "gr", group = "lsp" },
        { "gs", group = "surround" },
        { "[", group = "previous" },
        { "]", group = "next" },
      },
    },
  },

  -- GitHub Copilot: inline ghost-text suggestions, Alt-l to accept
  {
    "zbirenbaum/copilot.lua",
    cond = function() return vim.fn.executable("node") == 1 end, -- needs Node >= 22
    cmd = "Copilot",
    event = "InsertEnter",
    config = function()
      require("copilot").setup({
        suggestion = {
          enabled = true,
          auto_trigger = true,
          hide_during_completion = true,
          keymap = { accept = "<M-l>", accept_word = "<M-Right>", next = "<M-]>", prev = "<M-[>", dismiss = "<M-e>" },
        },
        panel = { enabled = false },
        filetypes = { markdown = true, ["*"] = true },
      })
      -- Hide the ghost text while blink's menu is open so the two never overlap
      local group = vim.api.nvim_create_augroup("user_copilot_blink", { clear = true })
      vim.api.nvim_create_autocmd("User", { group = group, pattern = "BlinkCmpMenuOpen",
        callback = function() vim.b.copilot_suggestion_hidden = true end })
      vim.api.nvim_create_autocmd("User", { group = group, pattern = "BlinkCmpMenuClose",
        callback = function() vim.b.copilot_suggestion_hidden = false end })
    end,
  },

  -- Claude Code inside nvim: terminal on the right, sends selections, shows real diffs
  {
    "coder/claudecode.nvim",
    cond = function() return vim.fn.executable("claude") == 1 end, -- needs the claude CLI
    dependencies = { "folke/snacks.nvim" },
    keys = {
      { "<leader>cc", "<cmd>ClaudeCode<cr>", desc = "Claude: toggle" },
      { "<leader>cf", "<cmd>ClaudeCodeFocus<cr>", desc = "Claude: focus" },
      { "<leader>cs", "<cmd>ClaudeCodeSend<cr>", mode = "v", desc = "Claude: send selection" },
      { "<leader>cb", "<cmd>ClaudeCodeAdd %<cr>", desc = "Claude: add current file" },
      { "<leader>cy", "<cmd>ClaudeCodeDiffAccept<cr>", desc = "Claude: accept diff" },
      { "<leader>cn", "<cmd>ClaudeCodeDiffDeny<cr>", desc = "Claude: reject diff" },
    },
    opts = { terminal = { split_side = "right", split_width_percentage = 0.35 } },
  },

  -- Markdown rendered in-buffer: headings, tables, checkboxes, code blocks
  {
    "MeanderingProgrammer/render-markdown.nvim",
    ft = { "markdown" },
    dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
    opts = { latex = { enabled = false } },   -- no LaTeX toolchain here; html rendering uses the html parser
    keys = { { "<leader>om", "<cmd>RenderMarkdown toggle<cr>", desc = "Markdown rendering" } },
  },

  -- Sessions: one per repo directory, restored on demand (never automatically)
  {
    "folke/persistence.nvim",
    event = "BufReadPre",
    opts = {},
    keys = {
      { "<leader>qs", function() require("persistence").load() end, desc = "Restore session for this directory" },
      { "<leader>qS", function() require("persistence").select() end, desc = "Pick a session" },
      { "<leader>ql", function() require("persistence").load({ last = true }) end, desc = "Restore last session" },
      { "<leader>qd", function() require("persistence").stop() end, desc = "Don't save this session" },
    },
  },
}
