return {
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      { "rcarriga/nvim-dap-ui", dependencies = { "nvim-neotest/nvim-nio" } },
      { "theHamsta/nvim-dap-virtual-text", opts = { virt_text_pos = "eol" } },
    },
    keys = {
      { "<leader>db", function() require("dap").toggle_breakpoint() end, desc = "Toggle breakpoint" },
      { "<leader>dB", function() require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: ")) end, desc = "Conditional breakpoint" },
      { "<leader>dc", function() require("dap").continue() end, desc = "Start / continue" },
      { "<leader>dl", function() require("dap").run_last() end, desc = "Run last configuration" },
      { "<leader>do", function() require("dap").step_over() end, desc = "Step over" },
      { "<leader>di", function() require("dap").step_into() end, desc = "Step into" },
      { "<leader>dO", function() require("dap").step_out() end, desc = "Step out" },
      { "<leader>dC", function() require("dap").run_to_cursor() end, desc = "Run to cursor" },
      { "<leader>dr", function() require("dap").repl.toggle() end, desc = "Toggle REPL" },
      { "<leader>dt", function() require("dap").terminate() end, desc = "Terminate" },
      { "<leader>du", function() require("dapui").toggle() end, desc = "Toggle debug UI" },
      { "<leader>de", function() require("dapui").eval() end, desc = "Evaluate expression", mode = { "n", "v" } },
      { "<leader>dh", function() require("dap.ui.widgets").hover() end, desc = "Hover value" },
      -- F-keys (niri now sends F10 through since screenshots moved to Print)
      { "<F5>", function() require("dap").continue() end, desc = "Debug: continue" },
      { "<F10>", function() require("dap").step_over() end, desc = "Debug: step over" },
      { "<F11>", function() require("dap").step_into() end, desc = "Debug: step into" },
      { "<F12>", function() require("dap").step_out() end, desc = "Debug: step out" },
    },
    config = function()
      local dap, dapui = require("dap"), require("dapui")

      dapui.setup({ floats = { border = "rounded" } })
      dap.listeners.after.event_initialized["dapui_config"] = function() dapui.open() end
      dap.listeners.before.event_terminated["dapui_config"] = function() dapui.close() end
      dap.listeners.before.event_exited["dapui_config"] = function() dapui.close() end

      -- Gutter icons
      for name, s in pairs({
        DapBreakpoint = { "●", "DiagnosticError" },
        DapBreakpointCondition = { "◆", "DiagnosticWarn" },
        DapLogPoint = { "◇", "DiagnosticInfo" },
        DapStopped = { "→", "DiagnosticOk" },
        DapBreakpointRejected = { "○", "DiagnosticHint" },
      }) do
        vim.fn.sign_define(name, { text = s[1], texthl = s[2], linehl = name == "DapStopped" and "Visual" or "", numhl = "" })
      end

      -- Adapters: gdb (>= 14 speaks DAP natively) and codelldb (installed by Mason)
      dap.adapters.gdb = {
        type = "executable",
        command = "gdb",
        args = { "--interpreter=dap", "--eval-command", "set print pretty on" },
      }
      dap.adapters.codelldb = {
        type = "server",
        port = "${port}",
        executable = { command = vim.fn.stdpath("data") .. "/mason/bin/codelldb", args = { "--port", "${port}" } },
      }

      local function pick_program()
        return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/build/", "file")
      end

      -- A .vscode/launch.json in the project is picked up automatically as well.
      dap.configurations.cpp = {
        { name = "Launch (gdb)", type = "gdb", request = "launch", program = pick_program,
          cwd = "${workspaceFolder}", stopAtBeginningOfMainSubprogram = false },
        { name = "Launch (codelldb)", type = "codelldb", request = "launch", program = pick_program,
          cwd = "${workspaceFolder}", stopOnEntry = false },
        { name = "Attach to process (gdb)", type = "gdb", request = "attach",
          pid = require("dap.utils").pick_process, cwd = "${workspaceFolder}" },
      }
      dap.configurations.c = dap.configurations.cpp
      dap.configurations.cuda = dap.configurations.cpp
      dap.configurations.rust = dap.configurations.cpp
    end,
  },
}
