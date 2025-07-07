return {
  {
    "nvim-tree/nvim-tree.lua",
    name = "nvim-tree",
    dependencies = {
      "nvim-tree/nvim-web-devicons", -- optional but recommended
    },
    config = function()
      require("nvim-tree").setup({
        view = {
          width = 35,
          side = "left",
          preserve_window_proportions = true,
        },
        filters = {
          dotfiles = false,
        },
        git = {
          enable = true,
        },
        renderer = {
          highlight_git = true,
          icons = {
            show = {
              git = true,
              folder = true,
              file = true,
            },
          },
        },
        update_focused_file = {
          enable = true,
        },
      })
    end,
    keys = {
      { "<leader>e", "<cmd>NvimTreeToggle<CR>", desc = "Toggle file explorer" },
    },
  },
}
