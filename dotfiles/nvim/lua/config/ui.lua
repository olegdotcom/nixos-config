-- Keep structural styling separate from the theme's default selection highlights.
-- Keeping these in vscode's overrides also reapplies them on colorscheme reload.
return function(c)
  return {
    NormalFloat = { fg = c.vscFront, bg = c.vscBack },
    FloatBorder = { fg = c.vscSplitDark, bg = c.vscBack },
    FloatTitle = { fg = c.vscDarkBlue, bg = c.vscBack, bold = true },
    WinSeparator = { fg = c.vscSplitDark, bg = c.vscBack },
    StatusLine = { fg = c.vscDarkBlue, bg = c.vscBack, bold = true },
    StatusLineNC = { fg = c.vscCursorDark, bg = c.vscBack },
    ModeMsg = { fg = c.vscDarkBlue, bold = true },
    MoreMsg = { link = "ModeMsg" },
    Folded = { fg = c.vscCursorDark, italic = true },
    ColorColumn = {},

    NvimTreeNormal = { link = "Normal" },
    NvimTreeNormalNC = { link = "Normal" },
    NvimTreeWinSeparator = { link = "WinSeparator" },
    NvimTreeRootFolder = { fg = c.vscDarkBlue, bold = true },
    NvimTreeSpecialFile = { fg = c.vscPink, bold = true },
    NvimTreeSymlink = { fg = c.vscDarkBlue, bold = true },
    FzfLuaNormal = { link = "Normal" },
    FzfLuaBorder = { link = "FloatBorder" },
    FzfLuaTitle = { link = "FloatTitle" },
    FzfLuaPreviewNormal = { link = "Normal" },
    FzfLuaPreviewBorder = { link = "FloatBorder" },
    TreesitterContext = { link = "Normal" },
    TreesitterContextLineNumber = { link = "LineNr" },
    TreesitterContextBottom = {},
    TreesitterContextSeparator = { link = "WinSeparator" },

    RenderMarkdownCode = {},
    RenderMarkdownCodeInline = { fg = c.vscOrange, bold = true },
    RenderMarkdownCodeBorder = { link = "WinSeparator" },
    RenderMarkdownTableHead = { link = "WinSeparator" },
    RenderMarkdownTableRow = { link = "WinSeparator" },
    RenderMarkdownDash = { link = "WinSeparator" },
    ["@markup.heading.markdown"] = { fg = c.vscLightBlue, bold = true },
    ["@markup.raw.markdown_inline"] = { fg = c.vscOrange, bold = true },
    ["@markup.list.checked"] = { link = "String" },
    ["@markup.list.unchecked"] = { link = "Comment" },
  }
end
