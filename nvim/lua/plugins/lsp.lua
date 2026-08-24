-- Prefer the system toolchain; Mason installs whatever is missing so a fresh machine
-- needs no manual setup (this is why a clone of this folder works out of the box).
local function has(bin) return vim.fn.executable(bin) == 1 end
local system_clangd = has("/usr/bin/clangd") and "/usr/bin/clangd" or (has("clangd") and "clangd" or nil)
local rustup_ra = "/usr/lib/rustup/bin/rust-analyzer"
local system_ra = has(rustup_ra) and rustup_ra or (has("rust-analyzer") and "rust-analyzer" or nil)

local mason_tools = { "stylua", "codelldb", "tree-sitter-cli" } -- tree-sitter-cli compiles treesitter parsers
if not system_clangd then table.insert(mason_tools, "clangd") end
if not has("clang-format") then table.insert(mason_tools, "clang-format") end
if not system_ra then table.insert(mason_tools, "rust-analyzer") end

return {
  { "mason-org/mason.nvim", opts = { ui = { border = "rounded" } } },

  -- Non-LSP tools Mason keeps installed (formatters, debug adapters, the tree-sitter CLI)
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    dependencies = { "mason-org/mason.nvim" },
    opts = { ensure_installed = mason_tools },
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

      -- C / C++ / CUDA. System clangd when there is one (Mason's otherwise); CUDA flags come
      -- from ~/.config/clangd/config.yaml (written on first run by config/bootstrap.lua).
      vim.lsp.config("clangd", {
        cmd = {
          system_clangd or "clangd",
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

      -- Rust: rustup's rust-analyzer tracks the installed toolchain (Mason's as fallback)
      vim.lsp.config("rust_analyzer", { cmd = { system_ra or "rust-analyzer" } })

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
