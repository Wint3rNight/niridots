-- Databases from inside Neovim (Postgres for the college project, anything else dadbod knows).
-- :DBUI / <leader>oq opens a sidebar of connections; write SQL in a buffer and run it with
-- <leader>S (dadbod-ui's mapping in query buffers). Needs the `psql` client on the machine
-- for Postgres (pacman -S postgresql-libs). Connections are saved under stdpath("data").
return {
  {
    "kristijanhusak/vim-dadbod-ui",
    dependencies = {
      "tpope/vim-dadbod",
      { "kristijanhusak/vim-dadbod-completion", ft = { "sql", "mysql", "plsql" } },
    },
    cmd = { "DBUI", "DBUIToggle", "DBUIAddConnection", "DBUIFindBuffer" },
    keys = { { "<leader>oq", "<cmd>DBUIToggle<cr>", desc = "Database UI (dadbod)" } },
    init = function()
      vim.g.db_ui_use_nerd_fonts = 1
      vim.g.db_ui_save_location = vim.fn.stdpath("data") .. "/dadbod_ui"
      vim.g.db_ui_show_database_icon = 1
      vim.g.db_ui_execute_on_save = 0 -- :w never fires a query; <leader>S does
    end,
  },
}
