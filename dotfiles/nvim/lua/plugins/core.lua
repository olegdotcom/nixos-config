return {
  {
    "Mofiqul/vscode.nvim",
    name = "vscode.nvim",
    priority = 1000,
    config = function()
      vim.o.background = "light"
      require("vscode").setup({
        style = "light",
        transparent = false,
        terminal_colors = true,
        disable_nvimtree_bg = true,
        group_overrides = require("config.ui")(require("vscode.colors").get_colors()),
      })
      vim.cmd.colorscheme("vscode")
    end,
  },
  {
    "ibhagwan/fzf-lua",
    name = "fzf-lua",
    config = function()
      require("fzf-lua").setup({
        sort_lastused = true,
        winopts = {
          backdrop = 100,
          border = "single",
          preview = { border = "single" },
        },
      })
    end,
  },
  {
    "numToStr/Comment.nvim",
    opts = {},
    lazy = false,
  },
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {},
    keys = {
      {
        "<leader>?",
        function()
          require("which-key").show({ global = false })
        end,
        desc = "Buffer Local Keymaps (which-key)",
      },
    },
  },
}
