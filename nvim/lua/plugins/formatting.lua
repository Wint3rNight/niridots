return {
  {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd = { "ConformInfo", "FormatEnable", "FormatDisable" },
    keys = {
      {
        "<leader>mp",
        function() require("conform").format({ lsp_format = "fallback", timeout_ms = 2000 }) end,
        mode = { "n", "v" },
        desc = "Format file / selection",
      },
      {
        "<leader>mh",
        -- Format only the hunks you changed (what the Khronos repos and llama.cpp expect)
        function()
          local hunks = require("gitsigns").get_hunks() or {}
          local format = require("conform").format
          for i = #hunks, 1, -1 do -- bottom-up so line numbers stay valid
            local h = hunks[i]
            if h.type ~= "delete" then
              local s, e = h.added.start, h.added.start + h.added.count - 1
              local last = vim.api.nvim_buf_get_lines(0, e - 1, e, true)[1] or ""
              format({ range = { start = { s, 0 }, ["end"] = { e, #last } }, lsp_format = "fallback", timeout_ms = 2000 })
            end
          end
          vim.notify(#hunks > 0 and ("Formatted " .. #hunks .. " hunk(s)") or "No changed hunks", vim.log.levels.INFO)
        end,
        desc = "Format changed hunks only",
      },
    },
    opts = {
      formatters_by_ft = {
        c = { "clang-format" },
        cpp = { "clang-format" },
        cuda = { "clang-format" },
        rust = { "rustfmt" },
        lua = { "stylua" },
      },
      default_format_opts = { lsp_format = "fallback" },
      -- Policy lives in util/format.lua: global on, C-family opt-in per repo, per-buffer toggle <leader>of
      format_on_save = function(bufnr)
        if not require("util.format").enabled(bufnr) then return end
        return { timeout_ms = 2000, lsp_format = "fallback" }
      end,
    },
    config = function(_, opts)
      require("conform").setup(opts)
      vim.api.nvim_create_user_command("FormatDisable", function(args)
        if args.bang then vim.b.autoformat = false else vim.g.autoformat = false end
      end, { desc = "Disable format-on-save (! = this buffer only)", bang = true })
      vim.api.nvim_create_user_command("FormatEnable", function(args)
        if args.bang then vim.b.autoformat = true else vim.g.autoformat = true end
      end, { desc = "Enable format-on-save (! = this buffer only)", bang = true })
    end,
  },
}
