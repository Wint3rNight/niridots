return {
  -- Changed lines in the gutter, hunk actions, blame
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      current_line_blame = false,
      on_attach = function(buf)
        local gs = require("gitsigns")
        local function map(m, l, r, d) vim.keymap.set(m, l, r, { buffer = buf, desc = d }) end
        map("n", "]h", function() gs.nav_hunk("next") end, "Next changed hunk")
        map("n", "[h", function() gs.nav_hunk("prev") end, "Previous changed hunk")
        map("n", "<leader>gp", gs.preview_hunk, "Git: preview hunk diff")
        map("n", "<leader>gs", gs.stage_hunk, "Git: stage hunk")
        map("v", "<leader>gs", function() gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") }) end, "Git: stage selection")
        map("n", "<leader>gr", gs.reset_hunk, "Git: reset hunk")
        map("v", "<leader>gr", function() gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") }) end, "Git: reset selection")
        map("n", "<leader>gu", gs.undo_stage_hunk, "Git: undo stage hunk")
        map("n", "<leader>gS", gs.stage_buffer, "Git: stage whole file")
        map("n", "<leader>gR", gs.reset_buffer, "Git: reset whole file")
        map("n", "<leader>gb", function() gs.blame_line({ full = true }) end, "Git: blame line")
        map("n", "<leader>gd", gs.diffthis, "Git: diff file against index")
        map("n", "<leader>gt", gs.toggle_current_line_blame, "Git: toggle inline blame")
        map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", "Select hunk")
      end,
    },
  },

  -- Diff / history / merge tool
  {
    "sindrets/diffview.nvim",
    cmd = { "DiffviewOpen", "DiffviewFileHistory", "DiffviewClose" },
    opts = {},
    keys = {
      { "<leader>gv", "<cmd>DiffviewOpen<cr>", desc = "Git: diff view (working tree)" },
      { "<leader>gh", "<cmd>DiffviewFileHistory %<cr>", desc = "Git: history of this file" },
      { "<leader>gH", "<cmd>DiffviewFileHistory<cr>", desc = "Git: history of branch" },
      { "<leader>gq", "<cmd>DiffviewClose<cr>", desc = "Git: close diff view" },
    },
  },
}
