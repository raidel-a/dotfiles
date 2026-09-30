-- Neovim 0.11+ LSP setup: per-server config via vim.lsp.config, then enable.
-- require("nvchad.configs.lspconfig").defaults() (called before this module)
-- already registers the "*" defaults (capabilities, on_init) and the LspAttach
-- keymaps.
local overrides = require("configs.overrides")
local servers = overrides.mason_lsp_servers

for _, server in ipairs(servers) do
	local exists, settings = pcall(require, "configs.lsp.server-settings." .. server)

	vim.lsp.config(server, exists and settings or {})
end

-- NvChad's "*" defaults deliberately disable semantic tokens, because by default
-- vim.hl.priorities.semantic_tokens (125) outranks treesitter (100) and would
-- take over. Re-enable them, but drop them below treesitter so treesitter stays
-- authoritative and semantic tokens only fill in what it doesn't cover.
overrides.load_base46_cache "semantic_tokens"
vim.hl.priorities.semantic_tokens = 75
vim.lsp.config("*", { on_init = function() end })

vim.lsp.enable(servers)

local config = {
	virtual_text = false,
	underline = true,
	update_in_insert = false,
	severity_sort = true,
	float = {
		focusable = false,
		style = "minimal",
		border = "single",
		source = "always",
	},
}

vim.diagnostic.config(config)
