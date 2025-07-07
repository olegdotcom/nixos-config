return {
  -- Core LSP setup
  { "neovim/nvim-lspconfig" },

  -- Completion
  {
    "hrsh7th/nvim-cmp",
    name = "cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
    },
    config = function()
      local cmp = require("cmp")
      cmp.setup({
        mapping = cmp.mapping.preset.insert({
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
        }),
        sources = {
          { name = "nvim_lsp" },
        },
        experimental = {
          ghost_text = false,
        },
      })
    end,
  },
}
