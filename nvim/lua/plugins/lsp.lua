return {
  { "mason-org/mason.nvim", opts = { ui = { border = "rounded" } } },

  -- Non-LSP tools Mason should keep installed (formatters, debug adapters)
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    dependencies = { "mason-org/mason.nvim" },
    opts = { ensure_installed = { "stylua", "codelldb" } },
  },

  -- clangd extras: :ClangdAST, :ClangdSymbolInfo, :ClangdTypeHierarchy, :ClangdMemoryUsage
  { "p00f/clangd_extensions.nvim", ft = { "c", "cpp", "cuda" }, opts = {} },

  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "mason-org/mason.nvim",
      {
        "mason-org/mason-lspconfig.nvim",
        opts = {
          ensure_installed = { "lua_ls", "glsl_analyzer" },
          -- clangd and rust-analyzer come from the system toolchains (pinned below)
          automatic_enable = { exclude = { "clangd", "rust_analyzer" } },
        },
      },
    },
    config = function()
      -- Advertise blink's completion capabilities to every server
      local ok, blink = pcall(require, "blink.cmp")
      if ok then vim.lsp.config("*", { capabilities = blink.get_lsp_capabilities() }) end

      -- C / C++ / CUDA. System clangd (22.1.8) instead of Mason's older one; CUDA flags come
      -- from ~/.config/clangd/config.yaml so nothing has to be dropped into the OSS repos.
      vim.lsp.config("clangd", {
        cmd = {
          "/usr/bin/clangd",
          "--background-index",
          "--background-index-priority=background",
          "--clang-tidy",
          "--completion-style=detailed",
          "--function-arg-placeholders=0",
          "--header-insertion=never",     -- never silently add #includes to upstream files
          "--query-driver=/usr/bin/g++*,/usr/bin/clang*",
          "-j=4",
          "--pch-storage=memory",
          "--log=error",
        },
      })

      -- Rust: rustup's rust-analyzer tracks the installed toolchain
      vim.lsp.config("rust_analyzer", { cmd = { "/usr/lib/rustup/bin/rust-analyzer" } })

      -- Lua (nvim config); lazydev supplies the runtime library paths
      vim.lsp.config("lua_ls", {
        settings = {
          Lua = {
            workspace = { checkThirdParty = false },
            completion = { callSnippet = "Replace" },
            diagnostics = { globals = { "vim", "Snacks" } },
          },
        },
      })

      vim.lsp.enable({ "clangd", "rust_analyzer", "lua_ls", "glsl_analyzer" })

      -- Per-buffer setup when a server attaches.
      -- Neovim 0.11+ already provides: grn rename, gra code action, grr references, gri implementation,
      -- grt type definition, gO document symbols, K hover, <C-s> signature (insert), ]d/[d diagnostics.
      -- Below: picker-backed versions of the navigation keys plus a few aliases.
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("user_lsp_attach", { clear = true }),
        callback = function(ev)
          local client = vim.lsp.get_client_by_id(ev.data.client_id)
          if not client then return end
          local function map(mode, lhs, rhs, desc) vim.keymap.set(mode, lhs, rhs, { buffer = ev.buf, desc = desc }) end

          map("n", "gd", function() Snacks.picker.lsp_definitions() end, "Goto definition")
          map("n", "gD", function() Snacks.picker.lsp_declarations() end, "Goto declaration")
          map("n", "grr", function() Snacks.picker.lsp_references() end, "References")
          map("n", "gri", function() Snacks.picker.lsp_implementations() end, "Implementations")
          map("n", "grt", function() Snacks.picker.lsp_type_definitions() end, "Type definition")
          map("n", "gO", function() Snacks.picker.lsp_symbols() end, "Document symbols")
          map("n", "<leader>rn", vim.lsp.buf.rename, "Rename symbol")
          map({ "n", "x" }, "<leader>ca", vim.lsp.buf.code_action, "Code action")

          if client.name == "clangd" then
            map("n", "<A-o>", "<cmd>LspClangdSwitchSourceHeader<cr>", "Switch source/header")
          end

          if client:supports_method("textDocument/inlayHint") then
            vim.lsp.inlay_hint.enable(true, { bufnr = ev.buf })
          end

          -- LSP-aware folds when the server offers them (clangd does); treesitter otherwise
          if client:supports_method("textDocument/foldingRange") then
            local win = vim.api.nvim_get_current_win()
            if vim.api.nvim_win_get_buf(win) == ev.buf then
              vim.wo[win][0].foldmethod = "expr"
              vim.wo[win][0].foldexpr = "v:lua.vim.lsp.foldexpr()"
            end
          end
        end,
      })
    end,
  },
}
