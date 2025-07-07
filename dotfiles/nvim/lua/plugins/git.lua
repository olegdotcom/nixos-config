return {
  { "lewis6991/gitsigns.nvim" },
  {
    "sindrets/diffview.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewFileHistory" },
    config = true, -- optional if you want default behavior
  },
}
