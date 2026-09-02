-- HTTP client. You have DAP configs for both Django and FastAPI, but no way to poke an
-- endpoint without leaving the editor. kulala runs plain-text .http files through curl and
-- shows the response in a split, so a request lives in the repo next to the code it exercises.
--
-- Write a file like api.http:
--   @base = http://127.0.0.1:8000
--   ### create a user
--   POST {{base}}/api/users/
--   Content-Type: application/json
--
--   { "name": "winter" }
--
-- Put the cursor in a block and press <leader>hs. `###` separates requests.
-- Variables come from http-client.env.json in the project root (<leader>he selects which set).
return {
  {
    "mistweaverco/kulala.nvim",
    ft = { "http", "rest" },
    keys = {
      { "<leader>hs", function() require("kulala").run() end, desc = "HTTP: send request under cursor" },
      { "<leader>ha", function() require("kulala").run_all() end, desc = "HTTP: send every request in file" },
      { "<leader>hr", function() require("kulala").replay() end, desc = "HTTP: replay last request" },
      { "<leader>hn", function() require("kulala").jump_next() end, desc = "HTTP: next request" },
      { "<leader>hp", function() require("kulala").jump_prev() end, desc = "HTTP: previous request" },
      { "<leader>ht", function() require("kulala").toggle_view() end, desc = "HTTP: toggle headers/body" },
      { "<leader>hc", function() require("kulala").copy() end, desc = "HTTP: copy as curl" },
      { "<leader>hi", function() require("kulala").from_curl() end, desc = "HTTP: import curl from clipboard" },
      { "<leader>he", function() require("kulala").set_selected_env() end, desc = "HTTP: select environment" },
      { "<leader>hq", function() require("kulala").close() end, desc = "HTTP: close response pane" },
    },
    opts = {
      default_view = "body",
      default_env = "dev",
      -- Keep the response beside the request rather than under it; on a 16:9 laptop
      -- a vertical split leaves both readable.
      display_mode = "split",
      split_direction = "vertical",
      -- Django and DRF return HTML error pages on a 500; formatting them makes the
      -- traceback readable instead of one enormous line.
      contenttypes = {
        ["application/json"] = { ft = "json", formatter = { "jq", "." } },
        ["text/html"] = { ft = "html", formatter = { "prettier", "--parser", "html" } },
      },
    },
  },
}
