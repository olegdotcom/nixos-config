return {
  {
    "nvim-treesitter/playground",
    cmd = {
      "TSBufEnable", "TSBufDisable", "TSBufToggle",
      "TSHighlightCapturesUnderCursor", "TSPlaygroundToggle", "TSNodeUnderCursor",
      "TSBufInfo",
    },
  },
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    branch = "master",
    lazy = false,
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = {
          "lua", "markdown", "markdown_inline", "cpp", "go",
        },
        highlight = {
          enable = true,
          additional_vim_regex_highlighting = false,
        },
        indent = {
          enable = true,
        },
        playground = {
          enable = true,
          updatetime = 25,
          persist_queries = false,
        },
      })
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter-context",
    event = "VeryLazy",
    opts = {
      enable = true,
      max_lines = 3,        -- How many lines of context to show
      trim_scope = "outer", -- Or "inner"
      mode = "cursor",      -- Show context for where your cursor is
      separator = nil,      -- You can add a line like '─' if you want
    },
  },
}
