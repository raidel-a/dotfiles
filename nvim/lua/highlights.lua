-- To find any highlight groups: "<cmd> Telescope highlights"
-- Each highlight group can take a table with variables fg, bg, bold, italic, etc
-- base30 variable names can also be used as colors

local M = {}

---@type Base46HLGroupsList
M.override = {
	Comment = {
		italic = true,
	},

	NormalFloat = { bg = "#111111"},
	FloatBorder = { bg = "#eeeeee"},
	Float = { bg = "#111111"},
	-- Normal = { bg = "none" },
	-- Folded = {},
	-- NvimTreeNormal = { bg = "none" },
	-- NvimTreeNormalNC = { bg = "none" },
	NvimTreeCursorLine = { underline = true },
	NvimTreeOpenedFolderName = { bold = true, underline = true },
	-- TelescopeNormal = {},
	-- TelescopePrompt = {},
	-- TelescopeResults = {},
	-- TelescopePromptNormal = {},
	-- TelescopePromptPrefix = {},
	CursorLine = { underline = true },
	-- Pmenu = {},
	-- CmpPmenu = {},
	TbFill = {  bg = "#202431" },
  TbBufOn = { bg = "none", bold = true},
  TbBufonClose = { bg = "none", bold = true},
  TbBufOff = { bg = "#202431"},
  TbBufOffClose = { bg = "#202431", bold = true},
  
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
