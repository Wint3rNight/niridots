-- snacks.nvim: picker (replaces telescope), notifier (replaces nvim-notify), bigfile guard,
-- fast first paint, vim.ui.input, LSP word highlighting, buffer delete, git browse, toggles.
return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  opts = {
    bigfile = { enabled = true },
    notifier = { enabled = true, timeout = 3000 },
    quickfile = { enabled = true },
    input = { enabled = true },
    words = { enabled = true },
    picker = {
      enabled = true,
      matcher = { frecency = true },   -- files you open often float to the top
      sources = {
        projects = {
          dev = { "~/Documents/WinterInOctober/Study/OpenSource", "~/Documents/WinterInOctober", "~/dotfiles", "~/.config" },
          patterns = { ".git", "CMakeLists.txt", "Cargo.toml", "package.json", "Makefile" },
        },
      },
      win = {
        input = {
          keys = {
            ["<a-t>"] = { "trouble_open", mode = { "n", "i" } },   -- send results to Trouble
          },
        },
      },
    },
    -- keep what other plugins already do well
    dashboard = { enabled = false }, explorer = { enabled = false }, indent = { enabled = false },
    scroll = { enabled = false }, statuscolumn = { enabled = false }, terminal = { enabled = false },
    styles = { notification = { wo = { wrap = true } } },
  },
  keys = {
    -- find
    { "<leader><space>", function() Snacks.picker.smart() end, desc = "Smart find (files + buffers + recent)" },
    { "<leader>ff", function() Snacks.picker.files() end, desc = "Find files" },
    { "<leader>fF", function() Snacks.picker.files({ hidden = true, ignored = true }) end, desc = "Find files (incl. hidden/ignored)" },
    { "<leader>fs", function() Snacks.picker.grep() end, desc = "Grep project" },
    { "<leader>fw", function() Snacks.picker.grep_word() end, desc = "Grep word under cursor / selection", mode = { "n", "x" } },
    { "<leader>fl", function() Snacks.picker.lines() end, desc = "Fuzzy lines in buffer" },
    { "<leader>fb", function() Snacks.picker.buffers() end, desc = "Buffers" },
    { "<leader>fr", function() Snacks.picker.recent() end, desc = "Recent files" },
    { "<leader>fg", function() Snacks.picker.git_files() end, desc = "Git-tracked files" },
    { "<leader>fp", function() Snacks.picker.projects() end, desc = "Projects (switch repo)" },
    { "<leader>fh", function() Snacks.picker.help() end, desc = "Help tags" },
    { "<leader>fk", function() Snacks.picker.keymaps() end, desc = "Keymaps" },
    { "<leader>fc", function() Snacks.picker.commands() end, desc = "Commands" },
    { "<leader>f:", function() Snacks.picker.command_history() end, desc = "Command history" },
    { "<leader>fd", function() Snacks.picker.diagnostics() end, desc = "Diagnostics (project)" },
    { "<leader>fD", function() Snacks.picker.diagnostics_buffer() end, desc = "Diagnostics (buffer)" },
    { "<leader>fS", function() Snacks.picker.lsp_workspace_symbols() end, desc = "Workspace symbols" },
    { "<leader>fu", function() Snacks.picker.undo() end, desc = "Undo history" },
    { "<leader>fj", function() Snacks.picker.jumps() end, desc = "Jumps" },
    { "<leader>fm", function() Snacks.picker.marks() end, desc = "Marks" },
    { "<leader>fR", function() Snacks.picker.resume() end, desc = "Resume last picker" },
    { "<leader>fN", function() Snacks.picker.notifications() end, desc = "Notification history" },
    -- git
    { "<leader>gl", function() Snacks.picker.git_log() end, desc = "Git: log (repo)" },
    { "<leader>gL", function() Snacks.picker.git_log_file() end, desc = "Git: log (this file)" },
    { "<leader>gc", function() Snacks.picker.git_status() end, desc = "Git: changed files" },
    { "<leader>gB", function() Snacks.picker.git_branches() end, desc = "Git: branches" },
    { "<leader>go", function() Snacks.gitbrowse() end, desc = "Git: open file on GitHub", mode = { "n", "v" } },
    -- buffers
    { "<leader>bd", function() Snacks.bufdelete() end, desc = "Close buffer (keep split)" },
    { "<leader>bo", function() Snacks.bufdelete.other() end, desc = "Close other buffers" },
    -- LSP word under cursor
    { "]]", function() Snacks.words.jump(vim.v.count1) end, desc = "Next reference of word", mode = { "n", "t" } },
    { "[[", function() Snacks.words.jump(-vim.v.count1) end, desc = "Previous reference of word", mode = { "n", "t" } },
  },
  init = function()
    vim.api.nvim_create_autocmd("User", {
      pattern = "VeryLazy",
      callback = function()
        -- Option toggles under <leader>o
        Snacks.toggle.inlay_hints():map("<leader>oh")
        Snacks.toggle.diagnostics():map("<leader>od")
        Snacks.toggle.option("spell", { name = "Spelling" }):map("<leader>os")
        Snacks.toggle.option("wrap", { name = "Wrap" }):map("<leader>ow")
        Snacks.toggle.option("relativenumber", { name = "Relative numbers" }):map("<leader>ol")
        Snacks.toggle.line_number():map("<leader>oL")
        Snacks.toggle.treesitter():map("<leader>oT")
        Snacks.toggle.zen():map("<leader>oz")
        Snacks.toggle.dim():map("<leader>oD")
        Snacks.toggle({
          name = "Transparent background",
          get = function() return UserTransparency.get() end,
          set = function(on) UserTransparency.set(on) end,
        }):map("<leader>ob")
        Snacks.toggle({
          name = "Autoformat (this buffer)",
          get = function() return require("util.format").enabled(0) end,
          set = function() require("util.format").toggle(0) end,
        }):map("<leader>of")
      end,
    })
  end,
}
