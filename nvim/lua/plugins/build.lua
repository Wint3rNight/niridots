return {
  -- Async task runner: build output streams into a task window, errors land in quickfix
  {
    "stevearc/overseer.nvim",
    cmd = { "OverseerRun", "OverseerToggle", "OverseerRestartLast", "Make" },
    keys = {
      { "<leader>mo", "<cmd>OverseerToggle<cr>", desc = "Task list" },
      { "<leader>mk", "<cmd>OverseerRun<cr>", desc = "Run a task template" },
      { "<leader>mm", ":Make ", desc = "Make [target]  (:Make, async)" },
      { "<leader>mM", "<cmd>OverseerRestartLast<cr>", desc = "Re-run last task" },
    },
    opts = { task_list = { direction = "bottom", min_height = 10 } },
    config = function(_, opts)
      local overseer = require("overseer")
      overseer.setup(opts)
      -- :Make [target] — runs 'makeprg' asynchronously, quickfix opens on errors
      vim.api.nvim_create_user_command("Make", function(params)
        local cmd, n = vim.o.makeprg:gsub("%$%*", params.args)
        if n == 0 then cmd = cmd .. " " .. params.args end
        local task = overseer.new_task({
          cmd = vim.fn.expandcmd(cmd),
          components = {
            { "on_output_quickfix", open = not params.bang, open_height = 8, errorformat = vim.o.errorformat },
            "default",
          },
        })
        task:start()
      end, { nargs = "*", bang = true, desc = "Run makeprg asynchronously" })
    end,
  },

  -- CMake: pick a target, build, run, debug — from inside nvim
  {
    "Civitasv/cmake-tools.nvim",
    dependencies = { "nvim-lua/plenary.nvim", "stevearc/overseer.nvim", "akinsho/toggleterm.nvim" },
    ft = { "c", "cpp", "cuda", "cmake" },
    cmd = { "CMakeGenerate", "CMakeBuild", "CMakeRun", "CMakeDebug", "CMakeSelectBuildTarget", "CMakeSelectLaunchTarget", "CMakeSettings" },
    keys = {
      { "<leader>mg", "<cmd>CMakeGenerate<cr>", desc = "CMake: generate (configure)" },
      { "<leader>mb", "<cmd>CMakeBuild<cr>", desc = "CMake: build target" },
      { "<leader>mr", "<cmd>CMakeRun<cr>", desc = "CMake: run target" },
      { "<leader>md", "<cmd>CMakeDebug<cr>", desc = "CMake: debug target" },
      { "<leader>ms", "<cmd>CMakeSelectBuildTarget<cr>", desc = "CMake: select build target" },
      { "<leader>mS", "<cmd>CMakeSelectLaunchTarget<cr>", desc = "CMake: select launch target" },
      { "<leader>mt", "<cmd>CMakeSelectBuildType<cr>", desc = "CMake: select build type" },
      { "<leader>mc", "<cmd>CMakeClean<cr>", desc = "CMake: clean" },
    },
    opts = {
      cmake_build_directory = "build",
      cmake_generate_options = { "-G", "Ninja", "-DCMAKE_EXPORT_COMPILE_COMMANDS=ON" },
      cmake_regenerate_on_save = false,
      cmake_use_preset = false,
      cmake_compile_commands_options = { action = "soft_link" },
      cmake_dap_configuration = { name = "cpp", type = "gdb", request = "launch", stopAtBeginningOfMainSubprogram = false },
      cmake_executor = {
        name = "overseer",
        opts = { new_task_opts = { strategy = { "toggleterm", direction = "horizontal", quit_on_exit = "success" } } },
      },
      cmake_runner = { name = "toggleterm", opts = { direction = "float", close_on_exit = false } },
    },
  },

  -- Tests: run the test under the cursor / the file / everything, results inline
  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-neotest/nvim-nio", "nvim-lua/plenary.nvim", "nvim-treesitter/nvim-treesitter",
      "orjangj/neotest-ctest",
      "nvim-neotest/neotest-python",   -- pytest / unittest (Django too, via pytest-django in the project venv)
    },
    keys = {
      { "<leader>tr", function() require("neotest").run.run() end, desc = "Test: run nearest" },
      { "<leader>tR", function() require("neotest").run.run(vim.fn.expand("%")) end, desc = "Test: run file" },
      { "<leader>ta", function() require("neotest").run.run({ suite = true }) end, desc = "Test: run all" },
      { "<leader>td", function() require("neotest").run.run({ strategy = "dap" }) end, desc = "Test: debug nearest" },
      { "<leader>tS", function() require("neotest").run.stop() end, desc = "Test: stop" },
      { "<leader>ts", function() require("neotest").summary.toggle() end, desc = "Test: summary" },
      { "<leader>to", function() require("neotest").output.open({ enter = true, auto_close = true }) end, desc = "Test: output" },
      { "<leader>tO", function() require("neotest").output_panel.toggle() end, desc = "Test: output panel" },
    },
    opts = function()
      return {
        adapters = {
          require("neotest-ctest").setup({ frameworks = { "gtest", "catch2", "doctest" }, dap_adapter = "gdb" }),
          require("neotest-python")({ dap = { justMyCode = false } }),   -- runner auto-detected: pytest if installed
        },
      }
    end,
  },
}
