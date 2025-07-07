return {
  -- Core DAP
  {
    "mfussenegger/nvim-dap",
    config = function()
      vim.fn.sign_define('DapBreakpoint', {
        text = '🔴',
        texthl = 'DapBreakpoint',
        linehl = '',
        numhl = '',
      })

      vim.fn.sign_define('DapBreakpointCondition', {
        text = '🟡',
        texthl = 'DapBreakpointCondition',
        linehl = '',
        numhl = '',
      })

      vim.fn.sign_define('DapLogPoint', {
        text = '🔵',
        texthl = 'DapLogPoint',
        linehl = '',
        numhl = '',
      })

      vim.fn.sign_define('DapStopped', {
        text = '🟢',
        texthl = 'DapStopped',
        linehl = 'Visual', -- optional highlight of the entire line
        numhl = '',
      })
    end,
  },

  -- DAP UI
  {
    "rcarriga/nvim-dap-ui",
    dependencies = {
      "mfussenegger/nvim-dap",
      "nvim-neotest/nvim-nio",
    },
    config = function()
      local dap = require("dap")
      local dapui = require("dapui")
      dapui.setup()
      dap.listeners.after.event_initialized["dapui_config"] = function() dapui.open() end
      dap.listeners.before.event_terminated["dapui_config"] = function() dapui.close() end
      dap.listeners.before.event_exited["dapui_config"] = function() dapui.close() end
    end,
  },

  -- Python
  {
    "mfussenegger/nvim-dap-python",
    ft = "python",
    config = function()
      require("dap-python").setup("/opt/homebrew/bin/python3") -- change if needed
    end,
  },

  -- Go
  {
    "leoluz/nvim-dap-go",
    ft = "go",
    config = function()
      require("dap-go").setup()
    end,
  },

  -- JavaScript/TypeScript
  {
    "mxsdev/nvim-dap-vscode-js",
    dependencies = { "mfussenegger/nvim-dap" },
    config = function()
      local dap = require("dap")
      require("dap-vscode-js").setup({
        debugger_path = vim.fn.stdpath("data") .. "/lazy/vscode-js-debug",
        adapters = { "pwa-node" },
      })
      for _, lang in ipairs({ "typescript", "javascript" }) do
        dap.configurations[lang] = {
          {
            type = "pwa-node",
            request = "launch",
            name = "Launch file",
            program = "${file}",
            cwd = "${workspaceFolder}",
          },
        }
      end
    end,
  },
}
