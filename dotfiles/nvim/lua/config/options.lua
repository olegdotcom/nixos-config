vim.opt.termguicolors = true

-- Indentation
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true

vim.opt.number = true
vim.opt.relativenumber = true

vim.o.scrolloff = 10
vim.o.sidescrolloff = 10

vim.o.conceallevel = 2
vim.o.concealcursor = "nc"

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
