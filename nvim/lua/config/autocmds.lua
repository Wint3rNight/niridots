local function augroup(name) return vim.api.nvim_create_augroup("user_" .. name, { clear = true }) end
local autocmd = vim.api.nvim_create_autocmd

-- Flash the text you just yanked
autocmd("TextYankPost", { group = augroup("yank_flash"), callback = function() vim.hl.on_yank({ timeout = 120 }) end })

-- Reopen a file where you left it
autocmd("BufReadPost", {
  group = augroup("last_position"),
  callback = function(ev)
    if vim.tbl_contains({ "gitcommit", "gitrebase" }, vim.bo[ev.buf].filetype) or vim.b[ev.buf].user_last_pos then return end
    vim.b[ev.buf].user_last_pos = true
    local mark = vim.api.nvim_buf_get_mark(ev.buf, '"')
    if mark[1] > 0 and mark[1] <= vim.api.nvim_buf_line_count(ev.buf) then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- Create missing parent directories when saving a new file
autocmd("BufWritePre", {
  group = augroup("auto_mkdir"),
  callback = function(ev)
    if ev.match:match("^%w%w+://") then return end
    vim.fn.mkdir(vim.fn.fnamemodify(vim.uv.fs_realpath(ev.match) or ev.match, ":p:h"), "p")
  end,
})

-- Reload files changed outside nvim (a build, git checkout, Claude editing on disk)
autocmd({ "FocusGained", "TermClose", "TermLeave" }, {
  group = augroup("checktime"),
  callback = function() if vim.o.buftype ~= "nofile" then vim.cmd("checktime") end end,
})

-- Keep splits proportional when the terminal window is resized
autocmd("VimResized", {
  group = augroup("resize_splits"),
  callback = function()
    local tab = vim.fn.tabpagenr()
    vim.cmd("tabdo wincmd =")
    vim.cmd("tabnext " .. tab)
  end,
})

-- `q` closes helper windows
autocmd("FileType", {
  group = augroup("close_with_q"),
  pattern = {
    "help", "qf", "man", "checkhealth", "query", "dap-float", "grug-far",
    "neotest-output", "neotest-output-panel", "neotest-summary", "gitsigns-blame", "startuptime",
  },
  callback = function(ev)
    vim.bo[ev.buf].buflisted = false
    vim.schedule(function()
      vim.keymap.set("n", "q", function()
        vim.cmd("close")
        pcall(vim.api.nvim_buf_delete, ev.buf, { force = true })
      end, { buffer = ev.buf, silent = true, desc = "Close window" })
    end)
  end,
})

-- Prose: wrap and spell-check
autocmd("FileType", {
  group = augroup("prose"),
  pattern = { "markdown", "gitcommit", "text" },
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.spell = true
  end,
})

-- Don't continue a comment when pressing `o` on a comment line
autocmd("FileType", {
  group = augroup("formatoptions"),
  callback = function() vim.opt_local.formatoptions:remove("o") end,
})
