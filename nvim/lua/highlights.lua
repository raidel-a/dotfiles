-- To find any highlight groups: "<cmd> Telescope highlights"
-- Each highlight group can take a table with variables fg, bg, bold, italic, etc
-- base30 variable names can also be used as colors

local M = {}
local primary = "#222222"
---@type Base46HLGroupsList
M.override = {
	Comment = {
		italic = true,
	},

	-- NormalFloat = { bg = "#111111"},
	-- FloatBorder = { bg = "#eeeeee"},
	-- Float = { bg = "#111111"},
	-- Normal = { bg = none },
	-- Folded = {},
	-- NvimTreeNormal = { bg = none },
	-- NvimTreeNormalNC = { bg = none },
	NvimTreeCursorLine = { italic = true,  undercurl = true },
	NvimTreeOpenedFolderName = { bold = true, underline = true },
	-- TelescopeNormal = {},
	-- TelescopePrompt = {},
	-- TelescopeResults = {},
	-- TelescopePromptNormal = {},
	-- TelescopePromptPrefix = {},
	-- CursorLine = { bold = true },
	-- Pmenu = {},
	-- CmpPmenu = {},
	TbFill = { bg = none, underline = true },
	tbBufOn = { bg = none, bold = true},
	-- TbBufonClose = { bg = none, bold = true },
	TbBufOff = { bg = none, italic = true, underline = true },
	TbBufOffClose = { bg = none, bold = true, underline = true },
	TbBufOffModified = { bg = none, underline = true },
	WinSeparator = { fg = "#888888" },
	NvimTreeWinSeparator = { fg = "#666666" },
}

---@type HLTable
M.add = {
	-- NvimTreeOpenedFolderName = { underline = true },
}

-- M.add_hlgroups = {
-- 	DiagnosticUnderlineError = { undercurl = true, fg = "red" },
-- 	DiagnosticUnderlineWarn = { undercurl = true, fg = "yellow" },
-- 	DiagnosticUnderlineInfo = { undercurl = true, fg = "green" },
-- 	DiagnosticUnderlineHint = { undercurl = true, fg = "purple" },
-- }

return M
