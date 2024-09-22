-- To find any highlight groups: "<cmd> Telescope highlights"
-- Each highlight group can take a table with variables fg, bg, bold, italic, etc
-- base30 variable names can also be used as colors

local M = {}

---@type Base46HLGroupsList
M.override = {
	Comment = {
		italic = true,
	},

	-- NormalFloat = {},
	-- Normal = { bg = "none" },
	-- Folded = {},
	-- NvimTreeNormal = { bg = "none" },
	-- NvimTreeNormalNC = { bg = "none" },
	-- -- NvimTreeCursorLine = { underline = true },
	-- TelescopeNormal = {},
	-- TelescopePrompt = {},
	-- TelescopeResults = {},
	-- TelescopePromptNormal = {},
	-- TelescopePromptPrefix = {},
	-- CursorLine = { bold = true },
	-- Pmenu = {},
	-- CmpPmenu = {},
}

---@type HLTable
M.add = {
	NvimTreeOpenedFolderName = { bold = true, underline = true },
}

-- M.add_hlgroups = {
-- 	DiagnosticUnderlineError = { undercurl = true, fg = "red" },
-- 	DiagnosticUnderlineWarn = { undercurl = true, fg = "yellow" },
-- 	DiagnosticUnderlineInfo = { undercurl = true, fg = "green" },
-- 	DiagnosticUnderlineHint = { undercurl = true, fg = "purple" },
-- }

return M
