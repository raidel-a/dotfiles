-- autocmds.lua
local M = {}

-- Constants
local FOCUSED_BG = "#222f3f"
local UNFOCUSED_BG = "#222a3a"

-- Helper functions
local function setup_nvim_tree_highlights()
	-- Set up NvimTreeTransparentCursor
	vim.api.nvim_set_hl(0, "NvimTreeTransparentCursor", { blend = 100, nocombine = true })

	-- Set up NvimTreeCursorLine
	vim.api.nvim_set_hl(0, "NvimTreeCursorLine", {
		-- bg = FOCUSED_BG,
		bold = true,
		underline = true,
	})

	-- Set up NvimTreeCursorLineNC
	vim.api.nvim_set_hl(0, "NvimTreeCursorLineNC", {
		-- bg = UNFOCUSED_BG
		-- italic = true,
		underdashed = true,
	})
end

local function set_cursor_and_line_appearance()
	local current_win = vim.api.nvim_get_current_win()
	local current_buf = vim.api.nvim_win_get_buf(current_win)
	local filetype = vim.api.nvim_buf_get_option(current_buf, "filetype")

	-- Set cursor appearance
	if filetype == "NvimTree" then
		vim.opt_local.guicursor = "a:NvimTreeTransparentCursor"
		vim.opt_local.cursorline = true
	else
		vim.opt_local.guicursor = "n-v-c-sm:block,i-ci-ve:ver25,r-cr-o:hor20"
	end

	-- Set cursorline appearance for all windows
	for _, win in ipairs(vim.api.nvim_list_wins()) do
		local buf = vim.api.nvim_win_get_buf(win)
		local win_filetype = vim.api.nvim_buf_get_option(buf, "filetype")
		local is_focused = win == current_win

		if win_filetype == "NvimTree" then
			local hl_group = is_focused and "NvimTreeCursorLine" or "NvimTreeCursorLineNC"
			vim.api.nvim_win_set_option(win, "winhighlight", "CursorLine:" .. hl_group)
		end
	end
end

function M.setup()
	-- Create autocommand group
	local augroup = vim.api.nvim_create_augroup("CustomAutocmds", { clear = true })

	-- Directory handling
	vim.api.nvim_create_autocmd("VimEnter", {
		group = augroup,
		callback = function(data)
			local is_directory = vim.fn.isdirectory(data.file) == 1
			if is_directory then
				vim.cmd.cd(data.file)
				require("nvim-tree.api").tree.open()
			end
		end,
	})

	-- Setup cursor and highlights
	setup_nvim_tree_highlights()

	-- Update cursor and highlights on window/buffer events
	vim.api.nvim_create_autocmd({ "WinEnter", "BufEnter", "WinLeave", "ColorScheme" }, {
		group = augroup,
		callback = function()
			vim.schedule(function()
				setup_nvim_tree_highlights()
				set_cursor_and_line_appearance()
			end)
		end,
	})

	-- Restore cursor on vim exit
	vim.api.nvim_create_autocmd("VimLeave", {
		group = augroup,
		command = "set guicursor=a:block-blinkon0",
	})
end

return M
