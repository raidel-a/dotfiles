---@type ChadrcConfig
local M = {}

-- Path to overriding theme and highlights files
local highlights = require("highlights")
local header = require("header")
-- local overrides = require("configs.overrides")

M.base46 = {
	theme = "poimandres",
	theme_toggle = { "poimandres", "flexoki-light" },
	transparency = true,

	hl_override = highlights.override,
	hl_add = highlights.add,
}

-- M.plugins = "plugins"

M.nvdash = {
	load_on_startup = true,
	header = header,
	-- buttons = {
	-- { "  Find File", ", f f", "Telescope find_files" },
	-- { "󰈚  Recent Files", ", f o", "Telescope oldfiles" },
	-- { "󰈭  Find Word", ", f w", "Telescope live_grep" },
	-- { "  Bookmarks", ", m a", "Telescope marks" },
	-- { "  Themes", ", t h", "Telescope themes" },
	-- { "  Mappings", ", c h", "NvCheatsheet" },
	-- { "󰩈  Quit", ";q", "quit" },
	-- },
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
