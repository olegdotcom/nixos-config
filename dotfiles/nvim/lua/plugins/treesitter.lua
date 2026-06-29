-- Neovim 0.12 provides :Inspect and :InspectTree itself, so the archived
-- nvim-treesitter/playground plugin is deliberately no longer installed.
return {
	{
		"neovim-treesitter/nvim-treesitter",
		-- This maintained fork succeeds the archived legacy repository. Its main
		-- branch uses the current configuration API and supports Neovim 0.12,
		-- including Markdown language injections.
		branch = "main",
		-- The registry tells nvim-treesitter which parser and query revisions are
		-- compatible. This keeps compiled parsers aligned with their query files.
		dependencies = {
			"neovim-treesitter/treesitter-parser-registry",
		},
		-- Refresh installed parsers whenever lazy.nvim changes this plugin.
		build = ":TSUpdate",
		-- nvim-treesitter modifies the runtime path during startup and explicitly
		-- does not support lazy-loading.
		lazy = false,
		config = function()
			-- The current branch replaces the legacy
			-- require("nvim-treesitter.configs").setup(...) interface with this
			-- smaller parser-management API.
			local treesitter = require("nvim-treesitter")

			-- These parser names describe the languages to install. markdown_inline
			-- handles inline Markdown constructs, while bash handles both shell
			-- files and injected ```sh code blocks inside Markdown.
			local parsers = {
				"bash", -- Shell scripts and Markdown shell code blocks.
				"c", -- Base queries inherited by the C++ query set.
				"cpp", -- C++ source files.
				"go", -- Go source files.
				"lua", -- Neovim configuration files.
				"markdown", -- Markdown block structure and fenced code blocks.
				"markdown_inline", -- Inline Markdown emphasis, links, and code.
				"nix", -- NixOS and Home Manager configuration files.
			}

			-- setup() registers the parser installation directory on Neovim's
			-- runtime path. install() is idempotent: already-installed parsers are
			-- retained, while missing parsers are installed asynchronously.
			treesitter.setup({})
			treesitter.install(parsers)

			-- On the current branch, highlighting and indentation are Neovim
			-- features enabled per filetype instead of options inside setup().
			vim.api.nvim_create_autocmd("FileType", {
				-- Clearing this named group prevents duplicate callbacks if this
				-- configuration is loaded again in the same Neovim process.
				group = vim.api.nvim_create_augroup("TreesitterConfig", { clear = true }),
				-- "sh" is the Neovim filetype that uses the installed bash parser.
				-- markdown_inline is injected by the Markdown parser and therefore
				-- does not need its own FileType callback.
				pattern = { "c", "cpp", "go", "lua", "markdown", "nix", "sh" },
				callback = function(args)
					-- Start Neovim's native Treesitter highlighter for this buffer.
					vim.treesitter.start(args.buf)
					-- Ask nvim-treesitter to calculate indentation from the syntax tree
					-- rather than relying only on traditional Vim indentation scripts.
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
			max_lines = 3, -- How many lines of context to show
			trim_scope = "outer", -- Or "inner"
			mode = "cursor", -- Show context for where your cursor is
			separator = nil, -- You can add a line like '─' if you want
		},
	},
}
