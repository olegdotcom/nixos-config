return {
  {
    "stevearc/aerial.nvim",
    name = "aerial",
    config = function()
      require("aerial").setup({
        backends = { "lsp", "treesitter", "markdown" },
        layout = {
          default_direction = "left",
          min_width = 35,
        },
        show_guides = true,
        open_automatic = false,
        attach_mode = "global",
        open_fold_levels = 99,
      })
    end,
    keys = {
      { "<leader>o", "<cmd>AerialToggle!<CR>", desc = "Toggle Outline" },
    },
  },
}
