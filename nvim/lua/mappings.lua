require("nvchad.mappings")

local map = vim.keymap.set

-- General
-- map("n", ";", ":", { nowait = true, desc = "Command mode" })
-- map("n", "<Leader><Leader>", ":nohlsearch<CR>", { desc = "Clear search highlighting" })
-- map("n", "C-f", ":Format<CR>", { desc = "Format file" })

-- Conform formatting
map(
    "n",
    "<C-f>",
    function()
        require("conform").format({ async = true, lsp_fallback = true })
    end,
    { desc = "Format file" }
)

map("n", "<Leader>s", ":ClangdSwitchSourceHeader<CR>", { desc = "Switch between header and source file" })

-- Telescope pickers (NvChad also maps ff/fa/fw/fb/fh/fo/fz/cm/gt by default;
-- re-declared here so the intent is visible).
map("n", "<Leader>ff", "<cmd>Telescope find_files<CR>", { desc = "Find files" })
map("n", "<Leader>fw", "<cmd>Telescope live_grep<CR>", { desc = "Live grep" })
map("n", "<Leader>fb", "<cmd>Telescope buffers<CR>", { desc = "Find buffers" })
map("n", "<Leader>fh", "<cmd>Telescope help_tags<CR>", { desc = "Help page" })
map("n", "<Leader>fo", "<cmd>Telescope oldfiles<CR>", { desc = "Find oldfiles" })
map("n", "<Leader>fz", "<cmd>Telescope current_buffer_fuzzy_find<CR>", { desc = "Find in current buffer" })
map({ "n", "x" }, "<Leader>fc", "<cmd>Telescope grep_string<CR>", { desc = "Grep word/selection" })
map("n", "<Leader>pk", "<cmd>Telescope keymaps<CR>", { desc = "Show keymaps" })
map("n", "<Leader>fa", "<cmd>Telescope find_files follow=true no_ignore=true hidden=true<CR>", {
	desc = "Telescope: find all files (incl. gitignored)",
})

-- Nvim DAP
map("n", "<Leader>dl", "<cmd>lua require'dap'.step_into()<CR>", { desc = "Debugger step into" })
map("n", "<Leader>dj", "<cmd>lua require'dap'.step_over()<CR>", { desc = "Debugger step over" })
map("n", "<Leader>dk", "<cmd>lua require'dap'.step_out()<CR>", { desc = "Debugger step out" })
map("n", "<Leader>dc", "<cmd>lua require'dap'.continue()<CR>", { desc = "Debugger continue" })
map("n", "<Leader>db", "<cmd>lua require'dap'.toggle_breakpoint()<CR>", { desc = "Debugger toggle breakpoint" })
map(
	"n",
	"<Leader>dd",
	"<cmd>lua require'dap'.set_breakpoint(vim.fn.input('Breakpoint condition: '))<CR>",
	{ desc = "Debugger set conditional breakpoint" }
)
map("n", "<Leader>de", "<cmd>lua require'dap'.terminate()<CR>", { desc = "Debugger reset" })
map("n", "<Leader>dr", "<cmd>lua require'dap'.run_last()<CR>", { desc = "Debugger run last" })

-- Terminal
map({ "n", "t" }, "<C-\\>", function()
	require("nvchad.term").toggle({ pos = "float", id = "floatTerm" })
end, { desc = "Terminal Toggle Floating term" })

-- File tree
-- nvim-tree must be `setup()` once per view variant. Re-running setup on every
-- toggle would re-register autocmds and reset the tree, so only switch views
-- when needed and otherwise just open/close.
local tree_view = "side"

local function toggle_tree()
	local api = require("nvim-tree.api")

	if require("nvim-tree.view").is_visible() then
		api.tree.close()
		return
	end

	api.tree.open()
end

-- Center floating nvim-tree
map("n", "<Leader>e", function()
	local ov = require("configs.overrides")
	if not require("nvim-tree.view").is_visible() and tree_view ~= "float" then
		require("nvim-tree").setup(ov.extend("nvchad.configs.nvimtree", ov.nvimtree_center))
		tree_view = "float"
	end
	toggle_tree()
end, { desc = "Toggle nvim-tree (center floating)" })

-- Right side nvim-tree
map("n", "<C-n>", function()
	local ov = require("configs.overrides")
	if not require("nvim-tree.view").is_visible() and tree_view ~= "side" then
		require("nvim-tree").setup(ov.extend("nvchad.configs.nvimtree", ov.nvimtree))
		tree_view = "side"
	end
	toggle_tree()
end, { desc = "Toggle nvim-tree (right side)" })

-- LSP config
map(
	"n",
	"gl",
	"<cmd>lua vim.diagnostic.open_float(0, { scope = 'line', border = 'single' })<CR>",
	{ desc = "Lsp show diagnostic" }
)
map("n", "<Leader>dF", "<cmd>lua vim.diagnostic.goto_prev()<CR>", { desc = "Go to previous diagnostic" })
map("n", "<Leader>df", "<cmd>lua vim.diagnostic.goto_next()<CR>", { desc = "Go to next diagnostic" })
map("n", "<Leader>dt", "<cmd>Trouble diagnostics toggle<CR>", { desc = "Trouble diagnostics" })
map("n", "<Leader>da", "<cmd>lua vim.lsp.buf.code_action()<CR>", { desc = "Lsp code action" })

-- Buffer delete
-- map("n", "<Leader>q", "<cmd>BufDel<CR>", { desc = "Close buffer" })
-- map("n", "<Leader>Q", "<cmd>BufDel!<CR>", { desc = "Close buffer ignore changes" })

-- Buffer line
map("n", "<TAB>", "<C-i>") -- Keep <C-i> for jump forward
map("n", "L", function()
	require("nvchad.tabufline").next()
end, { desc = "Go to next buffer" })
map("n", "H", function()
	require("nvchad.tabufline").prev()
end, { desc = "Go to previous buffer" })

-- Tests: use neotest (see the keys in lua/plugins/init.lua)

-- Toggles
map("n", "<leader>tT", function()
	require("base46").toggle_transparency()
end, { desc = "Toggle Transparency" })

map("n", "<leader>tt", function()
	require("base46").toggle_theme()
end, { desc = "Toggle Theme" })

-- vim.keymap.nnoremap { '<Leader>gx', [[:execute '!open ' . shellescape(expand('<cfile>'), 1)<CR>]] }
-- "https://x.com/xyz3va/status/1826747395696460076"
-- Telekasten
-- map("n", "<leader>z", "<cmd>Telekasten panel<CR>")

-- sidebar-nvim
-- map("n", "<Leader>sb", "<cmd>SidebarNvimToggle<CR>", { desc = "Toggle Sidebar" } )
--

-- map("i", "<CapsLock>", "<Esc>", { noremap = true, silent = true, desc = "Remap Caps Lock to Escape" })

-- map("i", "<Esc>", "<CapsLock>", { noremap = true, silent = true, desc = "Remap Escape to Caps Lock" })

map({ "n", "v" }, "<leader>st", function()
	require("stay-centered").toggle()
end, { desc = "Toggle stay-centered.nvim" })

-- horizontal resize split with control + shift + h
map("n", "<C-S-h>", "<C-w><", { desc = "Decrease horizontal split size" })

map("n", "<C-S-l>", "<C-w>>", { desc = "Increase horizontal split size" })

-- vertical resize split
map("n", "<C-S-k>", "<C-w>+", { desc = "Increase vertical split size" })

map("n", "<C-S-j>", "<C-w>-", { desc = "Decrease vertical split size" })


map("n", "<leader>fi", "<cmd>lua require('telescope.builtin').live_grep({ additional_args = {'--no-ignore'} })<CR>", { desc = "Find text (include gitignored)" })
