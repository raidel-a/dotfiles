local overrides = require("configs.overrides")

return {
	-- base46 must match ui: ui v3.0's blink config unconditionally dofiles a
	-- `blink` cache, and only base46 v3.0 has a blink integration to produce one.
	-- NvChad doesn't pin this and lazy keeps the branch recorded in the lockfile,
	-- so pin it explicitly to stop it drifting again.
	{
		"nvchad/base46",
		branch = "v3.0",
	},

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
							java = { "google-java-format" },
						},
						-- format on save, but skip huge buffers so saving never blocks
						format_on_save = function(bufnr)
							if vim.api.nvim_buf_line_count(bufnr) > 2000 then
								return
							end
							return { timeout_ms = 500, lsp_fallback = true }
						end,
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
		cmd = { "Mason", "MasonInstall", "MasonUninstall", "MasonUpdate", "MasonLog" },
		opts = function()
			return overrides.extend("nvchad.configs.mason", overrides.mason)
		end,
	},

	{
		"williamboman/mason-lspconfig.nvim",
		dependencies = { "williamboman/mason.nvim" },
		event = "User FilePost",
		opts = {
			ensure_installed = overrides.mason_lsp_servers,
			-- servers are set up manually in configs/lsp/init.lua
			automatic_enable = false,
		},
	},

	-- mason's own `ensure_installed` no longer exists; tools (formatters, linters,
	-- debug adapters) are installed by mason-tool-installer instead.
	{
		"WhoIsSethDaniel/mason-tool-installer.nvim",
		dependencies = { "williamboman/mason.nvim" },
		event = "VeryLazy",
		opts = {
			ensure_installed = overrides.mason_tools,
			auto_update = false,
			run_on_start = true,
		},
	},

	{
		"nvim-treesitter/nvim-treesitter",
		-- Nvim 0.12 needs the rewritten `main` branch. The old `master` branch
		-- is archived, only supports Nvim <= 0.11, and crashes when its query
		-- predicates/directives run. `main` is also what NvChad v2.5 expects:
		-- it highlights via native vim.treesitter.start() and installs parsers
		-- with require("nvim-treesitter").install() (its TSInstallAll command).
		-- main doesn't support lazy-loading, so load it eagerly.
		branch = "main",
		lazy = false,
		opts = function()
			return overrides.extend("nvchad.configs.treesitter", overrides.treesitter)
		end,
	},

	{
		"nvim-tree/nvim-tree.lua",
		opts = function()
			return overrides.extend("nvchad.configs.nvimtree", overrides.nvimtree)
		end,
		config = function(_, opts)
			require("nvim-tree").setup(opts)
			overrides.setup_nvimtree_autocmds()
		end,
	},

	-- Telescope is the picker (NvChad defaults provide ff/fw/fb/fh/fo/fz/cm/gt).
	{
		"nvim-telescope/telescope.nvim",
		dependencies = {
			{
				"nvim-telescope/telescope-fzf-native.nvim",
				build = "make",
			},
		},
		opts = function()
			return overrides.extend("nvchad.configs.telescope", overrides.telescope)
		end,
		config = function(_, opts)
			require("telescope").setup(opts)
			require("telescope").load_extension("fzf")
		end,
	},

	{
		"lewis6991/gitsigns.nvim",
		event = { "BufReadPre", "BufNewFile" },
		opts = function()
			return overrides.extend("nvchad.configs.gitsigns", overrides.gitsigns)
		end,
		config = function(_, opts)
			overrides.load_base46_cache "gitsigns"
			require("gitsigns").setup(opts)
		end,
	},

	{ import = "nvchad.blink.lazyspec" },

	-- Tier 2. Declared after the lazyspec import so these take precedence.

	-- nvim-autopairs is replaced by blink.pairs (auto-pairs + rainbow delimiters)
	{
		"windwp/nvim-autopairs",
		enabled = false,
	},

	{
		"saghen/blink.pairs",
		version = "*",
		dependencies = "saghen/blink.lib",
		-- must load before better-escape (InsertEnter) so its <Space> mapping
		-- does not swallow the <space><tab> luasnip sequence
		event = { "BufReadPre", "BufNewFile" },
		-- prebuilt binary; if the download ever fails, swap for
		-- require("blink.pairs").build():pwait(60000) to compile from source
		build = function()
			require("blink.pairs").download():pwait(60000)
		end,
		opts = {},
		config = function(_, opts)
			overrides.load_base46_cache "blink-pair"
			require("blink.pairs").setup(opts)
		end,
	},

	-- diagnostics: inline messages + a proper panel
	{
		"rachartier/tiny-inline-diagnostic.nvim",
		event = "VeryLazy",
		priority = 1000, -- must load after the LSP diagnostic config
		opts = { preset = "modern" },
		config = function(_, opts)
			overrides.load_base46_cache "tiny-inline-diagnostic"
			require("tiny-inline-diagnostic").setup(opts)
		end,
	},

	{
		"folke/trouble.nvim",
		cmd = "Trouble",
		opts = {},
		config = function(_, opts)
			overrides.load_base46_cache "trouble"
			require("trouble").setup(opts)
		end,
	},

	-- motions
	{
		"folke/flash.nvim",
		opts = {},
		keys = {
			{ "s", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash" },
			-- normal-mode S is deliberately left alone
			{ "S", mode = { "x", "o" }, function() require("flash").treesitter() end, desc = "Flash Treesitter" },
			{ "<C-s>", mode = "c", function() require("flash").toggle() end, desc = "Toggle Flash Search" },
		},
		config = function(_, opts)
			overrides.load_base46_cache "flash"
			require("flash").setup(opts)
		end,
	},

	-- tests (replaces the PlenaryTestFile mapping)
	{
		"nvim-neotest/neotest",
		dependencies = {
			"nvim-neotest/nvim-nio",
			"nvim-lua/plenary.nvim",
			"nvim-neotest/neotest-plenary",
		},
		opts = {},
		keys = {
			{ "<Leader>tn", function() require("neotest").run.run() end, desc = "Neotest: run nearest" },
			{ "<Leader>tf", function() require("neotest").run.run(vim.fn.expand "%") end, desc = "Neotest: run file" },
			{ "<Leader>ts", function() require("neotest").summary.toggle() end, desc = "Neotest: toggle summary" },
			{ "<Leader>to", function() require("neotest").output.open { enter = true } end, desc = "Neotest: show output" },
		},
		config = function(_, opts)
			opts.adapters = { require "neotest-plenary" }
			overrides.load_base46_cache "neotest"
			require("neotest").setup(opts)
		end,
	},

	-- markdown rendering (vimwiki is intentionally left in place)
	{
		"MeanderingProgrammer/render-markdown.nvim",
		ft = "markdown",
		dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
		opts = {},
		config = function(_, opts)
			overrides.load_base46_cache "render-markdown"
			require("render-markdown").setup(opts)
		end,
	},

	-- native git UI
	{
		"NeogitOrg/neogit",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"sindrets/diffview.nvim",
			"nvim-telescope/telescope.nvim",
		},
		keys = { { "<Leader>gn", "<cmd>Neogit<CR>", desc = "Neogit" } },
		opts = { integrations = { diffview = true, telescope = true } },
		config = function(_, opts)
			overrides.load_base46_cache "neogit"
			require("neogit").setup(opts)
		end,
	},

	-- LSP UI. Deliberately installed without keymaps so nothing silently
	-- overrides the built-in NvChad LSP mappings; everything is reachable via
	-- the :Lspsaga* commands, and we can wire keys once you pick them.
	-- lightbulb/beacon are also off by default: lspsaga would otherwise add a
	-- code-action sign + virtual text (which collides with tiny-inline-diagnostic)
	-- and flash a beacon on every jump. Flip them on when you want them.
	{
		"nvimdev/lspsaga.nvim",
		event = "LspAttach",
		dependencies = {
			"nvim-treesitter/nvim-treesitter",
			"nvim-tree/nvim-web-devicons",
		},
		opts = {
			lightbulb = { enable = false },
			beacon = { enable = false },
		},
		config = function(_, opts)
			overrides.load_base46_cache "lspsaga"
			require("lspsaga").setup(opts)
		end,
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

	-- debugging
	{
		"mfussenegger/nvim-dap",
		event = "VeryLazy",
		dependencies = {
			{
				"rcarriga/nvim-dap-ui",
				dependencies = { "nvim-neotest/nvim-nio" },
				opts = {},
			},
			{
				"theHamsta/nvim-dap-virtual-text",
				opts = {},
			},
		},
		config = function()
			overrides.load_base46_cache "dap"
			require("configs.dap")
		end,
	},

	-- better bdelete, close buffers without closing windows
	{
		"ojroques/nvim-bufdel",
		lazy = false,
	},

	-- NOTE: plenary is a dependency of several plugins above, keep it lazy
	{
		"nvim-lua/plenary.nvim",
	},

	{
		"vimwiki/vimwiki",
		event = "VeryLazy",
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
		opts = {},
	},

	-- tailwind-tools.lua
	-- server.override = false: the server itself is started natively via
	-- vim.lsp.enable("tailwindcss") (see configs/lsp/init.lua). Letting
	-- tailwind-tools start it would call lspconfig.tailwindcss.setup(), which
	-- uses the deprecated require('lspconfig') framework. Its color/conceal
	-- features keep working: its setup() still registers an LspAttach hook.
	{
		"luckasRanarison/tailwind-tools.nvim",
		name = "tailwind-tools",
		build = ":UpdateRemotePlugins",
		ft = { "html", "css", "scss", "javascript", "javascriptreact", "typescript", "typescriptreact", "vue", "svelte", "astro" },
		dependencies = {
			"nvim-treesitter/nvim-treesitter",
			"nvim-telescope/telescope.nvim", -- optional
			"neovim/nvim-lspconfig", -- optional
		},
		opts = {
			server = { override = false },
		},
	},

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

	{
		"lukas-reineke/indent-blankline.nvim",
	},

	{
		"sindrets/diffview.nvim",
		cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewToggleFiles", "DiffviewFocusFiles", "DiffviewRefresh", "DiffviewFileHistory" },
		config = function()
			overrides.load_base46_cache "diffview"
		end,
	},

	{
		"akinsho/git-conflict.nvim",
		version = "*",
		event = { "BufReadPre", "BufNewFile" },
		config = function()
			overrides.load_base46_cache "git-conflict"
			require("git-conflict").setup()
		end,
	},

	{
		"apyra/nvim-unity-sync",
		lazy = false,
		config = function()
			require("unity.plugin").setup()
		end,
	},
	-- To make a plugin not be loaded
	-- {
	--   "NvChad/nvim-colorizer.lua",
	--   enabled = false
	-- },
}
