-- To find any highlight groups: "<cmd> Telescope highlights"
-- Each highlight group can take a table with variables fg, bg, bold, italic, etc
-- base30 variable names can also be used as colors

local M = {}
local primary = "#222222"
local secondary = "#888888"
-- local tertiary = "#666666"
local tertiary = "#2D2C3C"
local vanta = "#000000"
---@type Base46HLGroupsList
M.override = {
	Comment = {
		italic = true,
	},

	TbFill = { bg = tertiary, fg = secondary },

	TbBufOn = { bg = NONE, fg = white },
	TbBufOnClose = { bg = NONE, bold = true },
	TbBufOnModified = { bg = none },
	-- TbBufOnTransparent xxx cterm=bold gui=bold guifg=#d9e0ee

	TbBufOff = { bg = tertiary, italic = true, underline = false },
	TbBufOffClose = { bg = tertiary, bold = true, underline = false },
	TbBufOffModified = { bg = tertiary, underline = false },

	WinSeparator = { fg = tertiary },
	NvimTreeOpenedFolderName = { bold = true, underline = true },
	NvimTreeWinSeparator = { fg = tertiary },
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
