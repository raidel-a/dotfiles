---@type ChadrcConfig
local M = {}

-- Path to overriding theme and highlights files
local highlights = require("highlights")
local header = require("header")

M.base46 = {
	theme = "catppuccin",
	theme_toggle = { "rosepine-dawn", "catppuccin" },
	transparency = true,

	-- Integrations for plugins NvChad doesn't manage. These are not compiled by
	-- default; load them with configs.overrides.load_base46_cache.
	integrations = {
		"blink-pair",
		"dap",
		"diffview",
		"flash",
		"git-conflict",
		"gitsigns",
		"neogit",
		"neotest",
		"render-markdown",
		"semantic_tokens",
		"tiny-inline-diagnostic",
		"trouble",
		"lspsaga",
	},

	hl_override = highlights.override,
	hl_add = highlights.add,
}

M.nvdash = {
	load_on_startup = true,
	header = header,
}

M.ui = {
	tabufline = {
		lazyload = false,
		order = { "tabs", "buffers" },
		overriden_modules = nil,
	},

	statusline = {
		theme = "minimal",
		separator_style = "block",
	},
}

-- check core.mappings for table structure
-- M.mappings = require("mappings")

return M
