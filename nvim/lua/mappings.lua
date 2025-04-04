require("nvchad.mappings")

local map = vim.keymap.set

-- General
-- map("n", ";", ":", { nowait = true, desc = "Command mode" })
-- map("n", "<Leader><Leader>", ":nohlsearch<CR>", { desc = "Clear search highlighting" })
map("n", "C-f", ":Format<CR>", { desc = "Format file" })
map("n", "<Leader>s", ":ClangdSwitchSourceHeader<CR>", { desc = "Switch between header and source file" })

-- Telescope
-- map("n", "<C-p>", "<cmd>Telescope git_files<CR>", { desc = "Find files in version control" })
-- map("n", "<Leader>pf", "<cmd>Telescope find_files<CR>", { desc = "Find files" })
-- map(
-- 	"n",
-- 	"<Leader>pfa",
-- 	"<cmd>Telescope find_files follow=true no_ignore=true hidden=true<CR>",
-- 	{ desc = "Find all files" }
-- )
-- map("n", "<Leader>pg", "<cmd>Telescope live_grep<CR>", { desc = "Grep files" })
-- map("n", "<Leader>pb", "<cmd>Telescope buffers<CR>", { desc = "Find buffers" })
-- map("n", "<Leader>ph", "<cmd>Telescope help_tags<CR>", { desc = "Help page" })
-- map("n", "<Leader>po", "<cmd>Telescope oldfiles<CR>", { desc = "Find oldfiles" })
map("n", "<Leader>pk", "<cmd>Telescope keymaps<CR>", { desc = "Show keymaps" })

-- Nvim DAP
map("n", "<Leader>dl", "<cmd>lua require'dap'.step_into()<CR>", { desc = "Debugger step into" })
map("n", "<Leader>dj", "<cmd>lua require'dap'.step_over()<CR>", { desc = "Debugger step over" })
map("n", "<Leader>dk", "<cmd>lua require'dap'.step_out()<CR>", { desc = "Debugger step out" })
map("n", "<Leader>d<space>", "<cmd>lua require'dap'.continue()<CR>", { desc = "Debugger continue" })
map("n", "<Leader>d<space>", "<cmd>lua require'dap'.toggle_breakpoint()<CR>", { desc = "Debugger toggle breakpoint" })
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
-- map("n", "<C-a>", "<cmd>NvimTreeToggle<Cr>", { desc = "Toggle file tree" })

-- LSP config
map(
	"n",
	"gl",
	"<cmd>lua vim.diagnostic.open_float(0, { scope = 'line', border = 'single' })<CR>",
	{ desc = "Lsp show diagnostic" }
)
map("n", "<Leader>dF", "<cmd>lua vim.diagnostic.goto_prev()<CR>", { desc = "Go to previous diagnostic" })
map("n", "<Leader>df", "<cmd>lua vim.diagnostic.goto_next()<CR>", { desc = "Go to next diagnostic" })
map("n", "<Leader>dt", "<cmd>Telescope diagnostics<CR>", { desc = "Telescope diagnostics" })
map("n", "<Leader>da", "<cmd>lua vim.lsp.buf.code_action()<CR>", { desc = "Lsp code action" })

-- Null-ls
map(
	"n",
	"<C-f>",
	"<cmd>lua require('configs.lsp.null-ls').lsp_formatting(vim.api.nvim_get_current_buf())<CR>",
	{ desc = "Format current file using null-ls" }
)

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

-- Plenary
map("n", "<Leader>tp", "<Plug>PlenaryTestFile", { desc = "Run plenary test on file" })

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

map({ "n", "v" }, "<leader>st", require("stay-centered").toggle, { desc = "Toggle stay-centered.nvim" })

-- horizontal resize split with control + shift + h
map("n", "<C-S-h>", "<C-w><", { desc = "Decrease horizontal split size" })

map("n", "<C-S-l>", "<C-w>>", { desc = "Increase horizontal split size" })

-- vertical resize split
map("n", "<C-S-k>", "<C-w>+", { desc = "Increase vertical split size" })

map("n", "<C-S-j>", "<C-w>-", { desc = "Decrease vertical split size" })


map("n", "<leader>fi", "<cmd>lua require('telescope.builtin').live_grep({ additional_args = {'--no-ignore'} })<CR>", { desc = "Find text (include gitignored)" })
