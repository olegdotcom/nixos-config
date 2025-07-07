return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    config = function()
      require("catppuccin").setup({
        flavour = "mocha", -- options: latte, frappe, macchiato, mocha
      })
      vim.cmd.colorscheme "catppuccin"
      vim.api.nvim_set_hl(0, "@markup.list.checked", { link = "String" })
      vim.api.nvim_set_hl(0, "@markup.list.unchecked", { link = "Comment" })
    end,
  },
  {
    "ibhagwan/fzf-lua",
    name = "fzf-lua",
    config = function()
      require("fzf-lua").setup({
        sort_lastused = true,
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
    opts = {
      -- your configuration comes here
      -- or leave it empty to use the default settings
      -- refer to the configuration section below
    },
    keys = {
      {
        "<leader>?",
        function()
          require("which-key").show({ global = false })
        end,
        desc = "Buffer Local Keymaps (which-key)",
      },
    },
  }
}
