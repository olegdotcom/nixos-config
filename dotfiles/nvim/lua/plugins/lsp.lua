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
        window = {
          completion = {
            border = "single",
            scrollbar = false,
            winhighlight = "Normal:Pmenu,FloatBorder:FloatBorder,CursorLine:PmenuSel,Search:None",
          },
          documentation = {
            border = "single",
            winhighlight = "Normal:NormalFloat,FloatBorder:FloatBorder",
          },
        },
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
