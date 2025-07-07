vim.opt.termguicolors = true

-- Set tab width to 2 spaces
vim.opt.tabstop = 2           -- How many columns a <Tab> counts for
vim.opt.shiftwidth = 2        -- Indent amount when using >>, <<, ==
vim.opt.expandtab = true      -- Convert tabs to spaces

vim.opt.number = true         -- show absolute line number on the current line
vim.opt.relativenumber = true -- show relative line numbers on all other lines

-- vim.opt.colorcolumn = "81" -- shows the column after the 80th char

vim.o.scrolloff = 10     -- for vertical scrolling
vim.o.sidescrolloff = 10 -- for horizontal scrolling

-- Markdown
vim.o.conceallevel = 2     -- fancy rendering for markdown
vim.o.concealcursor = "nc" -- Normal and Command mode

-- Hide command line.
vim.o.cmdheight = 0

-- Copy and paste uses system clipboard.
vim.o.clipboard = "unnamedplus"
vim.g.clipboard = "osc52"

vim.opt.backup = false
vim.opt.writebackup = false
vim.opt.swapfile = false

-- Search case-insensitive by default, but case-sensitive when the search query has upper case letters.
vim.opt.ignorecase = true
vim.opt.smartcase = true
