local overrides = require("configs.overrides")

return {
	-- {
	-- 	"neovim/nvim-lspconfig",
	-- 	dependencies = {
	-- 		-- format & linting
	-- 		{
	-- 			"jose-elias-alvarez/null-ls.nvim",
	-- 			config = function()
	-- 				require("configs.lsp.null-ls")
	-- 			end,
	-- 		},
	-- 	},
	-- 	config = function()
	-- 		require("nvchad.configs.lspconfig").defaults() -- nvchad defaults for lua
	-- 		require("configs.lsp")
	-- 	end, -- Override to setup mason-lspconfig
	-- },

	{
		"neovim/nvim-lspconfig",
		dependencies = {
			{
				"stevearc/conform.nvim",
				config = function()
					require("conform").setup({
						formatters_by_ft = {
							lua = { "stylua" },
							python = { "black" },
							javascript = { "prettier" },
							typescript = { "prettier" },
							css = { "prettier" },
							html = { "prettier" },
							json = { "prettier" },
							markdown = { "prettier" },
							rust = { "rustfmt" },
							go = { "gofmt" },
							cpp = { "clang_format" },
							c = { "clang_format" },
						},
						format_on_save = {
							timeout_ms = 500,
							lsp_fallback = true,
						},
					})
				end,
			},
		},
		config = function()
			require("nvchad.configs.lspconfig").defaults() -- nvchad defaults for lua
			require("configs.lsp")
		end,
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

	-- {
	-- 	"hrsh7th/nvim-cmp",
	-- 	opts = overrides.cmp,
	-- },

	{ import = "nvchad.blink.lazyspec" },

	{ "Saghen/blink.cmp", opts = {} },

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
					["heic"] = true,
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

	-- {
	-- 	"f-person/auto-dark-mode.nvim",
	-- 	lazy = false,
	-- 	config = function()
	-- 		local auto_dark_mode = require("auto-dark-mode")
	--
	-- 		local function change_theme(theme_name)
	-- 			print("Changing theme to: " .. theme_name)
	-- 			-- Set the theme name
	-- 			vim.g.nvchad_theme = theme_name
	-- 			-- Clear theme cache and reload
	-- 			package.loaded["base46"] = nil
	-- 			package.loaded["base46.themes." .. theme_name] = nil
	-- 			require("base46").load_all_highlights()
	-- 			-- Force UI refresh
	-- 			vim.cmd("redraw!")
	-- 			-- Trigger theme reload events
	-- 			vim.api.nvim_exec_autocmds("User", { pattern = "NvChadThemeReload" })
	-- 		end
	--
	-- 		local function set_dark_mode()
	-- 			print("Setting dark mode theme...")
	-- 			vim.schedule(function()
	-- 				change_theme("poimandres")
	-- 				print("Dark mode theme set!")
	-- 			end)
	-- 		end
	--
	-- 		local function set_light_mode()
	-- 			print("Setting light mode theme...")
	-- 			vim.schedule(function()
	-- 				change_theme("flexoki-light")
	-- 				print("Light mode theme set!")
	-- 			end)
	-- 		end
	--
	-- 		auto_dark_mode.setup({
	-- 			update_interval = 500,
	-- 			set_dark_mode = set_dark_mode,
	-- 			set_light_mode = set_light_mode,
	-- 		})
	--
	-- 		-- Set initial theme based on current system appearance
	-- 		local handle = io.popen('defaults read -g AppleInterfaceStyle 2>/dev/null')
	-- 		local result = handle and handle:read("*a") or ""
	-- 		handle:close()
	--
	-- 		if result:match("Dark") then
	-- 			set_dark_mode()
	-- 		else
	-- 			set_light_mode()
	-- 		end
	--
	-- 		auto_dark_mode.init()
	-- 	end,
	-- },

	{
		"lukas-reineke/indent-blankline.nvim",
		main = "ibl",
		---@module "ibl"
		---@type ibl.config
		opts = {},
	},

	{
		"sindrets/diffview.nvim",
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
