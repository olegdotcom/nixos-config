local map = vim.keymap.set
local opts = { noremap = true, silent = true }

-- Window splitting.
map("n", "<leader>-", "<cmd>split<CR>", { desc = "Horizontal split", unpack(opts) })
map("n", "<leader>|", "<cmd>vsplit<CR>", { desc = "Vertical split", unpack(opts) })

-- Navigating windows.
map("n", "<C-h>", "<C-w>h", opts)
map("n", "<C-j>", "<C-w>j", opts)
map("n", "<C-k>", "<C-w>k", opts)
map("n", "<C-l>", "<C-w>l", opts)

-- Jump half a screen down/up and center
map("n", "<C-d>", "<C-d>zz", { desc = "Half screen down and center", unpack(opts) })
map("n", "<C-u>", "<C-u>zz", { desc = "Half screen up and center", unpack(opts) })

-- Find and center
map("n", "n", "nzz", { desc = "Find next and center", unpack(opts) })
map("n", "N", "Nzz", { desc = "Find prev and center", unpack(opts) })

-- Copy and paste
map("x", "<leader>p", '"_dP', { desc = "Paste without losing yank", unpack(opts) })
-- map({ "n", "x" }, "<leader>p", '"+p', { desc = "Paste from system clipboard", unpack(opts) })
-- map({ "n", "x" }, "<leader>y", '"+y', { desc = "Copy to system clipboard", unpack(opts) })

map("n", "U", "<C-r>", { desc = "Redo", unpack(opts) })

-- Comments
map("n", "<leader>/", function() require("Comment.api").toggle.linewise.current() end,
  { desc = "Toggle comment", unpack(opts) })
map("v", "<leader>/", function()
  local esc = vim.api.nvim_replace_termcodes("<ESC>", true, false, true)
  vim.api.nvim_feedkeys(esc, "nx", false)
  require("Comment.api").toggle.linewise(vim.fn.visualmode())
end, { desc = "Toggle comment (visual mode)", unpack(opts) })

-- FZF
map("n", "<leader>ff", require("fzf-lua").files, { desc = "FZF files", unpack(opts) })
map("n", "<leader>fb", require("fzf-lua").buffers, { desc = "FZF buffer", unpack(opts) })
map("n", "<leader>fh", require("fzf-lua").help_tags, { desc = "FZF help", unpack(opts) })
map("n", "<leader>fc", require("fzf-lua").commands, { desc = "FZF commands", unpack(opts) })

-- Git
map("n", "<leader>gd", "<cmd>DiffviewOpen<cr>", { desc = "Git diff", unpack(opts) })
map("n", "<leader>gh", "<cmd>DiffviewFileHistory %<cr>", { desc = "Git file history (current file)", unpack(opts) })
map("n", "<leader>gH", "<cmd>DiffviewFileHistory<cr>", { desc = "Git file history (entire repo)", unpack(opts) })
map("n", "<leader>gq", "<cmd>DiffviewClose<cr>", { desc = "Close Git", unpack(opts) })

-- LSP
map("n", "<leader>cd", vim.lsp.buf.definition, { desc = "LSP definition", unpack(opts) })
map("n", "<leader>cr", vim.lsp.buf.references, { desc = "LSP references", unpack(opts) })
map("n", "<leader>cn", vim.lsp.buf.rename, { desc = "LSP rename symbol", unpack(opts) })
map("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "LSP code action", unpack(opts) })
map("n", "<leader>cw", vim.diagnostic.open_float, { desc = "LSP show message", unpack(opts) })

-- DAP
map("n", "<Leader>dc", function() require("dap").continue() end, { desc = "DAP: Continue", unpack(opts) })
map("n", "<Leader>dl", function() require("dap").step_over() end, { desc = "DAP: Step Over", unpack(opts) })
map("n", "<Leader>dj", function() require("dap").step_into() end, { desc = "DAP: Step Into", unpack(opts) })
map("n", "<Leader>dk", function() require("dap").step_out() end, { desc = "DAP: Step Out", unpack(opts) })
map("n", "<Leader>db", function() require("dap").toggle_breakpoint() end,
  { desc = "DAP: Toggle Breakpoint", unpack(opts) })
map("n", "<Leader>dB", function() require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: ")) end,
  { desc = "DAP: Set Conditional Breakpoint", unpack(opts) })
map("n", "<Leader>dm", function() require("dap").set_breakpoint(nil, nil, vim.fn.input("Log point message: ")) end,
  { desc = "DAP: Set Log Point", unpack(opts) })
map("n", "<Leader>du", function() require("dapui").toggle() end, { desc = "DAP: Toggle UI", unpack(opts) })
