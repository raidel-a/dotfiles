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

M.mason = {
	ensure_installed = {
		-- lua stuff
		"lua-language-server",
		"stylua",

		-- web dev
		"css-lsp",
		"html-lsp",
		"typescript-language-server",
		"deno",
    "tailwindcss",

		-- C/C++
		"clangd",
		"clang-format",
		"cmake-language-server",
		"cpplint",
		"cpptools",

		-- shell
		"shellcheck",
		"shellharden",
		"bash-language-server",
		"bash-debug-adapter",
		"awk-language-server",

		-- python
		"pyright",
		"pylint",

		-- go
		"delve",
		"go-debug-adapter",
		"gofumpt",
		"goimports",
		"goimports-reviser",
		"golangci-lint",
		"golangci-lint-langserver",
		"golines",
		"gomodifytags",
		"gopls",
	},
}

-- git support in nvimtree
M.nvimtree = {
	view = {
		side = "right",
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

M.cmp = {
	formatting = {
		format = function(entry, vim_item)
			local icons = require("nvchad.icons.lspkind")
			vim_item.kind = string.format("%s %s", icons[vim_item.kind], vim_item.kind)
			vim_item.menu = ({
				luasnip = "[Luasnip]",
				nvim_lsp = "[Nvim LSP]",
				buffer = "[Buffer]",
				nvim_lua = "[Nvim Lua]",
				path = "[Path]",
			})[entry.source.name]
			return vim_item
		end,
	},
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

return M
