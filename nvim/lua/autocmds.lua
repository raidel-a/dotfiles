-- autocmds.lua
--
-- NOTE: `nvchad.autocmds` is deliberately required from init.lua *before* this
-- module, because it emits the `User FilePost` event that most lazy-loaded
-- plugins (nvim-lspconfig, conform, indent-blankline, ...) are waiting on.

local M = {}

-- Sidebar filetypes that keep an emphasized current-line, dimmed when unfocused.
-- (The NvimTree* groups are reused for all of them; they are just styling.)
local sidebar_filetypes = {
	NvimTree = true,
	Trouble = true,
	mason = true,
	lazy = true,
	help = true,
	qf = true,
}

-- Style a single window as active or inactive. Everything touched here is
-- window-local, so there is no global state to leak or restore and no
-- scheduling: each focus event styles exactly one window.
local function style_window(win, active)
	if not vim.api.nvim_win_is_valid(win) then
		return
	end

	local buf = vim.api.nvim_win_get_buf(win)
	local filetype = vim.api.nvim_get_option_value("filetype", { buf = buf })
	local buftype = vim.api.nvim_get_option_value("buftype", { buf = buf })

	-- Terminals never get a cursorline
	if buftype == "terminal" or buftype == "prompt" then
		vim.api.nvim_set_option_value("cursorline", false, { win = win })
		return
	end

	if sidebar_filetypes[filetype] then
		vim.api.nvim_set_option_value("cursorline", true, { win = win })
		local hl_group = active and "NvimTreeCursorLine" or "NvimTreeCursorLineNC"
		vim.api.nvim_set_option_value("winhighlight", "CursorLine:" .. hl_group, { win = win })
		return
	end

	-- Normal buffers: cursorline only where focus is
	vim.api.nvim_set_option_value("cursorline", active, { win = win })
end

local function style_current(active)
	style_window(vim.api.nvim_get_current_win(), active)
end

-- In the NvimTree window the line highlight marks the position, so the
-- physical cursor is hidden while the tree has focus. guicursor is
-- global-only, hence a single synchronous toggle (no per-buffer writes,
-- no scheduling): WinEnter/BufEnter decide, CmdlineEnter always restores
-- so `:` stays usable, CmdlineLeave re-evaluates.
local default_guicursor = vim.o.guicursor
local cursor_hidden = false

local function set_cursor_hidden(hidden)
	if hidden == cursor_hidden then
		return
	end
	cursor_hidden = hidden
	vim.o.guicursor = hidden and "a:NvimTreeHiddenCursor" or default_guicursor
end

local function update_tree_cursor()
	local buf = vim.api.nvim_get_current_buf()
	if not vim.api.nvim_buf_is_valid(buf) then
		return
	end
	set_cursor_hidden(vim.api.nvim_get_option_value("filetype", { buf = buf }) == "NvimTree")
end

function M.setup()
	-- Create autocommand group
	local augroup = vim.api.nvim_create_augroup("CustomAutocmds", { clear = true })

	-- Directory handling
	vim.api.nvim_create_autocmd("VimEnter", {
		group = augroup,
		callback = function(data)
			if vim.fn.isdirectory(data.file) == 1 then
				vim.cmd.cd(data.file)
				require("nvim-tree.api").tree.open()
			end
		end,
	})

	-- highlight yank
	vim.api.nvim_create_autocmd("TextYankPost", {
		group = augroup,
		callback = function()
			vim.highlight.on_yank { timeout = 80 }
		end,
	})

	-- wrap git commit body message lines at 72 characters
	vim.api.nvim_create_autocmd("FileType", {
		group = augroup,
		pattern = "gitcommit",
		callback = function(args)
			vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
				group = augroup,
				buffer = args.buf,
				callback = function()
					vim.opt_local.textwidth = vim.fn.line(".") == 1 and 50 or 72
				end,
			})
		end,
	})

	-- Dim the window being left, light up the one being entered. During
	-- WinLeave the current window is still the leaving one; during WinEnter
	-- it is already the entering one, so each event styles exactly one window.
	style_current(true)
	update_tree_cursor()

	vim.api.nvim_create_autocmd("WinLeave", {
		group = augroup,
		callback = function()
			style_current(false)
		end,
	})

	vim.api.nvim_create_autocmd("WinEnter", {
		group = augroup,
		callback = function()
			style_current(true)
			update_tree_cursor()
		end,
	})

	-- Same-window buffer changes (e.g. opening a terminal or help page):
	-- re-evaluate the current window as active.
	vim.api.nvim_create_autocmd({ "BufEnter", "FileType" }, {
		group = augroup,
		callback = function()
			style_current(true)
			update_tree_cursor()
		end,
	})

	vim.api.nvim_create_autocmd("TermOpen", {
		group = augroup,
		callback = function()
			style_current(true)
		end,
	})

	-- The hidden cursor also covers the cmdline, so always show it there.
	vim.api.nvim_create_autocmd("CmdlineEnter", {
		group = augroup,
		callback = function()
			set_cursor_hidden(false)
		end,
	})

	vim.api.nvim_create_autocmd("CmdlineLeave", {
		group = augroup,
		callback = function()
			update_tree_cursor()
		end,
	})

	vim.api.nvim_create_autocmd("ColorScheme", {
		group = augroup,
		callback = function()
			style_current(true)
		end,
	})
end

return M
