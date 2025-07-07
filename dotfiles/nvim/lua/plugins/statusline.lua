return {
  {
    "rebelot/heirline.nvim",
    name = "heirline",
    config = function()
      local Mode = {
        provider = function()
          local mode = vim.api.nvim_get_mode().mode
          return string.format(" %s ", mode:upper())
        end,
        hl = { fg = "black", bg = "lightblue", bold = true },
      }
      local Git = {
        condition = function()
          return vim.b.gitsigns_head ~= nil
        end,
        provider = function()
          local gsd = vim.b.gitsigns_status_dict
          local added = gsd.added or 0
          local changed = gsd.changed or 0
          local removed = gsd.removed or 0
          return string.format("  %s(+%d -%d ~%d)", vim.b.gitsigns_head, added, removed, changed)
        end,
        hl = {
          fg = "lightgreen",
          bold = true,
        }
      }
      local FileName = {
        provider = function()
          -- local bufname = vim.api.nvim_buf_get_name(0)
          -- local filename = vim.fs.basename(bufname) -- base file name
          local filename = vim.fn.expand("%:~") -- full file name
          return " " .. filename .. " "
        end,
        hl = { fg = "lightblue", bold = true }
      }
      local FileModified = {
        condition = function()
          return vim.bo.modified
        end,
        provider = "[+]",
        hl = { fg = "lightblue", bold = true },
      }
      local Align = { provider = "%=" } -- pushes content to the right
      local FilePercent = {
        provider = function()
          local curr = vim.fn.line(".")
          local total = vim.fn.line("$")
          if total == 0 then return " 0% " end
          local percent = math.floor((curr / total) * 100)
          return string.format(" %d%%%% ", percent)
        end,
        hl = { fg = "lightblue", bold = true },
      }
      require("heirline").setup {
        statusline = {
          Mode,
          Git,
          FileName,
          FileModified,
          Align,
          FilePercent,
        },
      }
    end,
  }
}
