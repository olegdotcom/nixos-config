return {
	{
		"neovim-treesitter/nvim-treesitter",
		branch = "main",
		dependencies = {
			"neovim-treesitter/treesitter-parser-registry",
		},
		build = ":TSUpdate",
		-- The plugin must configure its parser directory during startup.
		lazy = false,
		config = function()
			local treesitter = require("nvim-treesitter")

			-- C++ queries inherit C queries; Markdown uses the inline and Bash
			-- parsers for embedded content.
			local parsers = {
				"bash",
				"c",
				"cpp",
				"go",
				"lua",
				"markdown",
				"markdown_inline",
				"nix",
			}

			treesitter.setup({})
			treesitter.install(parsers)

			vim.api.nvim_create_autocmd("FileType", {
				group = vim.api.nvim_create_augroup("TreesitterConfig", { clear = true }),
				pattern = { "c", "cpp", "go", "lua", "markdown", "nix", "sh" },
				callback = function(args)
					vim.treesitter.start(args.buf)
					vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
				end,
			})
		end,
	},
	{
		"nvim-treesitter/nvim-treesitter-context",
		event = "VeryLazy",
		opts = {
			enable = true,
			max_lines = 3,
			trim_scope = "outer",
			mode = "cursor",
			separator = nil,
		},
	},
}
