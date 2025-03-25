local overrides = require("configs.overrides")

return {
	{
		"neovim/nvim-lspconfig",
		dependencies = {
			-- format & linting
			{
				"jose-elias-alvarez/null-ls.nvim",
				config = function()
					require("configs.lsp.null-ls")
				end,
			},
		},
		config = function()
			require("nvchad.configs.lspconfig").defaults() -- nvchad defaults for lua
			require("configs.lsp")
		end, -- Override to setup mason-lspconfig
	},

	-- override plugin configs
	{
		"williamboman/mason.nvim",
		cmd = "Mason",
		event = "BufReadPre",
		opts = overrides.mason,
		config = function()
			require("mason").setup({
				ui = { border = "rounded" },
				PATH = "prepend",
				max_concurrent_installers = 10,
			})
		end,
	},

	{
		"williamboman/mason-lspconfig.nvim",
		lazy = false,
		config = function()
			local mason_lspconfig = require("mason-lspconfig")

			mason_lspconfig.setup({
				ensure_installed = {
					"lua_ls", -- Lua
					"cssls", -- CSS
					"html", -- HTML
					"ts_ls", -- TypeScript/JavaScript
					"clangd", -- C/C++
					"gopls", -- Go
					"rust_analyzer", -- Rust
					"tailwindcss",
				},
				automatic_installation = true,
			})
		end,
	},

	{
		"nvim-treesitter/nvim-treesitter",
		opts = overrides.treesitter,
	},

	{
		"nvim-tree/nvim-tree.lua",
		opts = overrides.nvimtree,
	},

	{
		"nvim-telescope/telescope.nvim",
		opts = overrides.telescope,
	},

	-- add telescope-fzf-native
	{
		"telescope.nvim",
		dependencies = {
			"nvim-telescope/telescope-fzf-native.nvim",
			build = "make",
			lazy = false,
			config = function()
				require("telescope").load_extension("fzf")
			end,
		},
	},

	{
		"lewis6991/gitsigns.nvim",
    lazy = false,
		opts = overrides.gitsigns,
	},

	{
		"hrsh7th/nvim-cmp",
		opts = overrides.cmp,
	},

	-- Additional plugins

	-- escape using key combo (currently set to jk)
	{
		"max397574/better-escape.nvim",
		event = "InsertEnter",
		config = function()
			require("configs.betterescape")
		end,
	},

	{
		"mfussenegger/nvim-dap",
		config = function()
			require("configs.dap")
		end,
	},

	{
		"rcarriga/nvim-dap-ui",
		config = function()
			require("dapui").setup()
		end,
		requires = { "mfussenegger/nvim-dap" },
	},

	{
		"theHamsta/nvim-dap-virtual-text",
		config = function()
			require("nvim-dap-virtual-text").setup()
		end,
		requires = { "mfussenegger/nvim-dap" },
	},

	{ "nvim-neotest/nvim-nio" },

	-- better bdelete, close buffers without closing windows
	{
		"ojroques/nvim-bufdel",
		lazy = false,
	},

	{
		"nvim-lua/plenary.nvim",
	},

	{
		"vimwiki/vimwiki",
	},

	-- {
	-- 	"zbirenbaum/copilot.lua",
	-- 	event = "InsertEnter",
	-- 	config = function()
	-- 		require("copilot").setup(require("configs.copilot"))
	-- 	end,
	-- },

	{
		"leoluz/nvim-dap-go",
		ft = "go",
		dependencies = "mfussenegger/nvim-dap",
		config = function(_, opts)
			require("dap-go").setup(opts)
		end,
	},

	{
		"arnamak/stay-centered.nvim",
		opts = function()
			require("stay-centered").setup({
				-- skip_filetypes = {"lua", "typescript"},
			})
		end,
	},

	-- tailwind-tools.lua
	{
		"luckasRanarison/tailwind-tools.nvim",
		name = "tailwind-tools",
		build = ":UpdateRemotePlugins",
		dependencies = {
			"nvim-treesitter/nvim-treesitter",
			"nvim-telescope/telescope.nvim", -- optional
			"neovim/nvim-lspconfig", -- optional
		},
		opts = {}, -- your configuration
	},

	-- {
	-- 		"3rd/image.nvim",
	-- },

	{
		"skardyy/neo-img",
		lazy = false,
		config = function()
			require("neo-img").setup({
				supported_extensions = {
					["png"] = true,
					["jpg"] = true,
					["jpeg"] = true,
					["gif"] = true,
					["webp"] = true,
					["heic"] = true
				},
        build = "cd ttyimg && go build",
				auto_open = true, -- Automatically open images when buffer is loaded
				oil_preview = true, -- changes oil preview of images too
				backend = "kitty", -- kitty / iterm / sixel / auto (auto detects what is supported in your terminal)
				size = { --scales the width, will maintain aspect ratio
					oil = 400,
					main = 800,
				},
				offset = { -- only x offset
					oil = 5,
					main = 10,
				},
			})
		end,
	},

	{
		"f-person/auto-dark-mode.nvim",
		config = function()
			local auto_dark_mode = require("auto-dark-mode")

			auto_dark_mode.setup({
				update_interval = 1000,
				set_dark_mode = function()
					-- Set the theme name
					vim.g.nvchad_theme = "poimandres" -- your dark theme
					-- Load base46 highlights
					require("base46").load_all_highlights()
					-- Trigger theme reload event
					vim.api.nvim_exec_autocmds("User", { pattern = "NvThemeReload" })
				end,
				set_light_mode = function()
					vim.g.nvchad_theme = "flexoki-light" -- your light theme
					require("base46").load_all_highlights()
					vim.api.nvim_exec_autocmds("User", { pattern = "NvThemeReload" })
				end,
			})

			auto_dark_mode.init()
		end,
	},

	-- To make a plugin not be loaded
	-- {
	--   "NvChad/nvim-colorizer.lua",
	--   enabled = false
	-- },

	-- All NvChad plugins are lazy-loaded by default
	-- For a plugin to be loaded, you will need to set either `ft`, `cmd`, `keys`, `event`, or set `lazy = false`
	-- If you want a plugin to load on startup, add `lazy = false` to a plugin spec, for example
	-- {
	--   "mg979/vim-visual-multi",
	--   lazy = false,
	-- }
}
