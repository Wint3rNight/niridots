-- nvim-treesitter `main` branch: setup() takes no ensure_installed/highlight.
-- Parsers are installed with install(); highlighting starts per buffer via vim.treesitter.start().
return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    lazy = false,
    build = function()
      if vim.fn.executable("tree-sitter") == 1 then vim.cmd("TSUpdate") end
    end,
    config = function()
      local ts = require("nvim-treesitter")
      ts.setup({})
      local function cli_ready() return vim.fn.executable("tree-sitter") == 1 end

      local parsers = {
        "c", "cpp", "cuda", "glsl", "hlsl", "wgsl", "slang", "rust", "lua", "vim", "vimdoc", "query", "regex",
        "markdown", "markdown_inline", "cmake", "make", "python", "bash", "json", "yaml", "toml",
        "diff", "gitcommit", "git_rebase", "gitignore", "dockerfile",
        "html", "htmldjango", "css", "javascript", "sql", -- Django/FastAPI templates and Postgres
      }
      if cli_ready() then
        ts.install(parsers)
      else
        -- Fresh machine: Mason is fetching tree-sitter-cli right now. Compile the parsers as soon as it lands.
        vim.api.nvim_create_autocmd("User", {
          pattern = "MasonToolsUpdateCompleted",
          once = true,
          callback = function()
            if cli_ready() then
              vim.notify("Compiling treesitter parsers in the background (first run only)", vim.log.levels.INFO)
              ts.install(parsers)
            end
          end,
        })
      end

      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("user_treesitter", { clear = true }),
        callback = function(ev)
          local lang = vim.treesitter.language.get_lang(ev.match)
          if not lang then return end

          -- Huge files: leave highlighting/folding to the basics (snacks.bigfile also guards >1.5 MB)
          local size = vim.fn.getfsize(vim.api.nvim_buf_get_name(ev.buf))
          if size > 1024 * 1024 or vim.api.nvim_buf_line_count(ev.buf) > 20000 then return end

          if not vim.treesitter.language.add(lang) then
            -- Parser missing: fetch it in the background; highlighting kicks in next time
            if cli_ready() and vim.tbl_contains(ts.get_available(), lang) then ts.install({ lang }) end
            return
          end

          vim.treesitter.start(ev.buf, lang)
          vim.bo[ev.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
          local win = vim.api.nvim_get_current_win()
          if vim.api.nvim_win_get_buf(win) == ev.buf then
            vim.wo[win][0].foldmethod = "expr"
            vim.wo[win][0].foldexpr = "v:lua.vim.treesitter.foldexpr()"
          end
        end,
      })
    end,
  },

  -- Move between functions/classes/arguments; also supplies the queries mini.ai uses for af/if etc.
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    branch = "main",
    event = "VeryLazy",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    config = function()
      require("nvim-treesitter-textobjects").setup({
        select = { lookahead = true },
        move = { set_jumps = true },
      })
      local move = require("nvim-treesitter-textobjects.move")
      local function m(lhs, fn, query, desc)
        vim.keymap.set({ "n", "x", "o" }, lhs, function() move[fn](query, "textobjects") end, { desc = desc })
      end
      m("]f", "goto_next_start", "@function.outer", "Next function")
      m("[f", "goto_previous_start", "@function.outer", "Previous function")
      m("]F", "goto_next_end", "@function.outer", "Next function end")
      m("[F", "goto_previous_end", "@function.outer", "Previous function end")
      m("]c", "goto_next_start", "@class.outer", "Next class/struct")
      m("[c", "goto_previous_start", "@class.outer", "Previous class/struct")
      m("]a", "goto_next_start", "@parameter.inner", "Next argument")
      m("[a", "goto_previous_start", "@parameter.inner", "Previous argument")
    end,
  },

  -- Correct comment strings per treesitter node (native gc/gcc do the commenting)
  { "folke/ts-comments.nvim", event = "VeryLazy", opts = {} },
}
