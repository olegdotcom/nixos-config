return {
  {
    "lukas-reineke/headlines.nvim",
    dependencies = "nvim-treesitter/nvim-treesitter",
    ft = { "markdown" },
    config = function()
      require("headlines").setup({
        markdown = {
          checkboxes = {
            ["unchecked"] = "☐", -- maps `markup.list.unchecked`
            ["checked"] = "☑", -- maps `markup.list.checked`
            ["partial"] = "⛝", -- optional
          },
        },
      })
    end,
  },
}
