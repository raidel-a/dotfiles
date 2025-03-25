-- To find any highlight groups: "<cmd> Telescope highlights"
-- Each highlight group can take a table with variables fg, bg, bold, italic, etc
-- base30 variable names can also be used as colors

local M = {}
local primary = "#222222"
local vanta = "#000000"
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
	NvimTreeOpenedFolderName = { bold = true, underline = true },
	-- TelescopeNormal = {},
	-- TelescopePrompt = {},
	-- TelescopeResults = {},
	-- TelescopePromptNormal = {},
	-- TelescopePromptPrefix = {},
	CursorLine = { underline = false },
	-- Pmenu = {},
	-- CmpPmenu = {},
	TbFill = { bg = vanta, fg = "#888888", underdashed = true },
	tbBufOn = { bg = "NONE", bold = true },
	-- TbBufonClose = { bg = none, bold = true },
	TbBufOff = { bg = vanta, italic = true, underline = false },
	TbBufOffClose = { bg = vanta, bold = true, underline = false },
	TbBufOffModified = { bg = vanta, underline = false },
	WinSeparator = { fg = "#888888" },
	NvimTreeWinSeparator = { fg = "#666666" },
	-- NvimTreeCursor = { blend = 0 },
	-- NvimTreeCursorLine = {
	-- 	bg = "#2d3149",
	-- 	bold = true,
	-- 	italic = true,
	--    underdashed = true
	-- },
}

---@type HLTable
M.add = {
	-- Base highlights
	GitSignsAdd = { link = "DiffAdd" },
	GitSignsChange = { link = "DiffChange" },
	GitSignsDelete = { link = "DiffDelete" },
	
	-- Line highlights
	GitSignsAddLn = { link = "DiffAdd" },
	GitSignsChangeLn = { link = "DiffChange" },
	GitSignsDeleteLn = { link = "DiffDelete" },
	
	-- Number highlights
	GitSignsAddNr = { link = "DiffAdd" },
	GitSignsChangeNr = { link = "DiffChange" },
	GitSignsDeleteNr = { link = "DiffDelete" },
	
	-- Composite types
	GitSignsChangedelete = { link = "GitSignsChange" },
	GitSignsChangedeleteLn = { link = "GitSignsChangeLn" },
	GitSignsChangedeleteNr = { link = "GitSignsChangeNr" },
	GitSignsTopdelete = { link = "GitSignsDelete" },
	GitSignsTopdeleteLn = { link = "GitSignsDeleteLn" },
	GitSignsTopdeleteNr = { link = "GitSignsDeleteNr" },
	
	-- Untracked files
	GitSignsUntracked = { link = "GitSignsAdd" },
	GitSignsUntrackedNr = { link = "GitSignsAddNr" },
	GitSignsUntrackedLn = { link = "GitSignsAddLn" },
}

-- M.add_hlgroups = {
-- 	DiagnosticUnderlineError = { undercurl = true, fg = "red" },
-- 	DiagnosticUnderlineWarn = { undercurl = true, fg = "yellow" },
-- 	DiagnosticUnderlineInfo = { undercurl = true, fg = "green" },
-- 	DiagnosticUnderlineHint = { undercurl = true, fg = "purple" },
-- }

return M
