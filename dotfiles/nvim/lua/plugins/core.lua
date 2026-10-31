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
          -- Keep syntax colors without fzf's reverse-video match highlights.
          treesitter = { fzf_colors = false },
          preview = { border = "single" },
        },
        fzf_colors = {
          true,
          bg = { "bg", "Normal" },
          ["bg+"] = { "bg", "Normal" },
          gutter = { "bg", "Normal" },
          ["preview-bg"] = { "bg", "Normal" },
          ["fg+"] = { "fg", "Directory", "bold" },
          hl = { "fg", "Statement", "bold", "underline" },
          ["hl+"] = { "fg", "Statement", "bold", "underline" },
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
