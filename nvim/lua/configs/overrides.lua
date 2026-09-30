local M = {}

M.treesitter = {
	ensure_installed = {
		"vim",
		"lua",
		"html",
		"css",
		"typescript",
		"c",
		"cpp",
		"python",
	},
}

-- LSP servers to install, using lspconfig server names.
-- This is the single source of truth: configs/lsp/init.lua enables this same list.
M.mason_lsp_servers = {
	"lua_ls", -- Lua
	"cssls", -- CSS
	"html", -- HTML
	"ts_ls", -- TypeScript / JavaScript
	"clangd", -- C / C++
	"gopls", -- Go
	"rust_analyzer", -- Rust
	"zls", -- Zig
	"jdtls", -- Java
	"tailwindcss",
}

-- Formatters, linters and debug adapters to install, using mason package names.
-- mason.nvim dropped its own `ensure_installed` option, so these are installed
-- by mason-tool-installer.nvim instead.
M.mason_tools = {
	-- lua
	"stylua",
	-- web
	"prettier",
	-- C / C++
	"clang-format",
	"cpplint",
	-- python
	"black",
	"pylint",
	-- shell
	"shellcheck",
	"shellharden",
	-- go
	"gofumpt",
	"goimports",
	"golangci-lint",
	"delve",
	"go-debug-adapter",
	-- java
	"google-java-format",
	-- debug adapters
	"bash-debug-adapter",
	"cpptools",
	"netcoredbg",
}

M.mason = {
	ui = { border = "rounded" },
	PATH = "prepend",
	max_concurrent_installers = 10,
}

-- git support in nvimtree
local HEIGHT_RATIO = 0.8
local WIDTH_RATIO = 0.5

M.nvimtree = {
	view = {
		side = "right",
		width = 35,
	},

	git = {
		enable = true,
	},

	renderer = {
		add_trailing = true,
		highlight_git = true,
		icons = {
			show = {
				git = true,
			},
		},
	},
}

-- Custom nvim-tree configurations
M.nvimtree_center = {
	view = {
		float = {
			enable = true,
			open_win_config = function()
				local screen_w = vim.opt.columns:get()
				local screen_h = vim.opt.lines:get() - vim.opt.cmdheight:get()
				local window_w = screen_w * WIDTH_RATIO
				local window_h = screen_h * HEIGHT_RATIO
				local window_w_int = math.floor(window_w)
				local window_h_int = math.floor(window_h)
				local center_x = (screen_w - window_w) / 2
				local center_y = ((vim.opt.lines:get() - window_h) / 2) - vim.opt.cmdheight:get()
				return {
					border = "rounded",
					relative = "editor",
					row = center_y,
					col = center_x,
					width = window_w_int,
					height = window_h_int,
				}
			end,
		},
		width = function()
			return math.floor(vim.opt.columns:get() * WIDTH_RATIO)
		end,
	},

	git = {
		enable = true,
	},

	renderer = {
		add_trailing = true,
		highlight_git = true,
		icons = {
			show = {
				git = true,
			},
		},
	},
}

M.gitsigns = {
	signs = {
		add = { text = "│" },
		change = { text = "│" },
		delete = { text = "_" },
		topdelete = { text = "‾" },
		changedelete = { text = "~" },
		untracked = { text = "┆" },
	},
	signcolumn = true,
	numhl = true,
	linehl = false,
	word_diff = false,
	watch_gitdir = {
		interval = 1000,
		follow_files = true,
	},
	attach_to_untracked = true,
	current_line_blame = false,
	sign_priority = 6,
	update_debounce = 100,
	status_formatter = nil,
}

M.telescope = {
	style = "bordered",
	defaults = {
		vimgrep_arguments = {
			"rg",
			"-L",
			"--color=never",
			"--no-heading",
			"--with-filename",
			"--line-number",
			"--column",
			"--smart-case",
			"--hidden",
		},
		mappings = {
			i = {
				["<esc>"] = function(...)
					require("telescope.actions").close(...)
				end,
			},
		},
	},
}

-- Called from the nvim-tree plugin config. Kept out of module scope because
-- requiring nvim-tree.api while this module is first imported (from the plugin
-- specs) would force nvim-tree to load at startup.
function M.setup_nvimtree_autocmds()
	local api = require("nvim-tree.api")

	vim.api.nvim_create_augroup("NvimTreeResize", {
		clear = true,
	})

	vim.api.nvim_create_autocmd({ "VimResized", "WinResized" }, {
		group = "NvimTreeResize",
		callback = function()
			-- Get the nvim-tree window ID
			if api.tree.winid() then
				api.tree.reload()
			end
		end,
	})
end

-- Merge our overrides on top of an NvChad default config.
-- The `nvchad.configs.*` modules also dofile their base46 highlight cache at
-- require time, so calling them matters even when we replace most of the table.
function M.extend(nvchad_config, our_opts)
	return vim.tbl_deep_extend("force", require(nvchad_config), our_opts or {})
end

-- Load a base46 integration cache for a plugin NvChad doesn't manage (dap,
-- diffview, git-conflict, gitsigns, ...). These integrations aren't compiled by
-- default, and base46 only (re)compiles them on a rebuild (`:Lazy build base46`)
-- or a theme toggle, so guard the dofile instead of erroring on startup.
function M.load_base46_cache(name)
	local path = vim.g.base46_cache .. name
	if vim.uv.fs_stat(path) then
		dofile(path)
	end
end

return M
