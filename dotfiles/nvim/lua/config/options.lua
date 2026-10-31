vim.opt.termguicolors = true
vim.opt.winborder = "single"

-- Keep the space between panes without drawing a vertical divider.
vim.opt.fillchars:append({ vert = " ", vertleft = " ", vertright = " ", verthoriz = " " })

-- Align each status line with its pane's text, after the sign and number columns.
local native_statusline = vim.api.nvim_get_option_info2("statusline", {}).default
vim.opt.statusline = "%!repeat(' ', getwininfo(g:statusline_winid)[0].textoff) . " .. vim.fn.string(native_statusline)

-- Indentation
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true

vim.opt.number = true
vim.opt.relativenumber = true

vim.o.scrolloff = 10
vim.o.sidescrolloff = 10

vim.o.conceallevel = 2
-- Always reveal concealed syntax on the cursor line, in every mode.
vim.o.concealcursor = ""

vim.o.cmdheight = 0

-- Use the system clipboard through OSC 52.
vim.o.clipboard = "unnamedplus"
vim.g.clipboard = "osc52"

vim.opt.backup = false
vim.opt.writebackup = false
vim.opt.swapfile = false

-- Make searches case-sensitive only when the query contains uppercase letters.
vim.opt.ignorecase = true
vim.opt.smartcase = true
