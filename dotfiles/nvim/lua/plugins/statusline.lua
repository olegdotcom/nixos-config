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
				hl = { bold = true },
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
				hl = { bold = true },
			}
			local FileName = {
				provider = function()
					local filename = vim.fn.expand("%:~")
					return " " .. filename .. " "
				end,
				hl = { bold = true },
			}
			local FileModified = {
				condition = function()
					return vim.bo.modified
				end,
				provider = "[+]",
				hl = { bold = true },
			}
			-- Push the remaining components to the right.
			local Align = { provider = "%=" }
			local FilePercent = {
				provider = function()
					local curr = vim.fn.line(".")
					local total = vim.fn.line("$")
					if total == 0 then
						return " 0% "
					end
					local percent = math.floor((curr / total) * 100)
					return string.format(" %d%%%% ", percent)
				end,
				hl = { bold = true },
			}
			require("heirline").setup({
				statusline = {
					hl = "StatusLine",
					Mode,
					Git,
					FileName,
					FileModified,
					Align,
					FilePercent,
				},
			})
		end,
	},
}
