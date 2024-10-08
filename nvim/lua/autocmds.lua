local M = {}

-- Constants
local FOCUSED_BG = "#222f3f"
local UNFOCUSED_BG = "#222a3a"

-- Helper functions
local function setup_nvim_tree_highlights()
	local highlights = require("highlights")

	-- Set up NvimTreeTransparentCursor
	vim.api.nvim_set_hl(0, "NvimTreeTransparentCursor", { blend = 100, nocombine = true })

	-- Set up NvimTreeCursorLine, respecting existing settings
	local cursorline_opts =
		vim.tbl_extend("force", { bg = FOCUSED_BG, bold = true }, highlights.override.NvimTreeCursorLine or {})
	vim.api.nvim_set_hl(0, "NvimTreeCursorLine", cursorline_opts)

	-- Set up NvimTreeCursorLineNC
	vim.api.nvim_set_hl(0, "NvimTreeCursorLineNC", { bg = UNFOCUSED_BG })

	-- Apply additional NvimTree highlights
	if highlights.add.NvimTreeOpenedFolderName then
		vim.api.nvim_set_hl(0, "NvimTreeOpenedFolderName", highlights.add.NvimTreeOpenedFolderName)
	end
end

local function set_cursor_and_line_appearance()
	local current_win = vim.api.nvim_get_current_win()
	local current_buf = vim.api.nvim_win_get_buf(current_win)
	local filetype = vim.api.nvim_buf_get_option(current_buf, "filetype")

	-- Set cursor appearance
	if filetype == "NvimTree" then
		vim.opt_local.guicursor = "a:NvimTreeTransparentCursor"
	else
		vim.opt_local.guicursor = "n-v-c-sm:block,i-ci-ve:ver25,r-cr-o:hor20"
	end

	-- Set cursorline appearance
	for _, win in ipairs(vim.api.nvim_list_wins()) do
		local buf = vim.api.nvim_win_get_buf(win)
		local win_filetype = vim.api.nvim_buf_get_option(buf, "filetype")
		local is_focused = win == current_win
		local bg_color = is_focused and FOCUSED_BG or UNFOCUSED_BG

		vim.api.nvim_win_set_option(win, "cursorline", true)

		if win_filetype == "NvimTree" then
			local hl_group = is_focused and "NvimTreeCursorLine" or "NvimTreeCursorLineNC"
			vim.api.nvim_win_set_option(win, "winhighlight", "CursorLine:" .. hl_group)
		else
			local cursorline_opts =
				vim.tbl_extend("force", { bg = bg_color }, require("highlights").override.CursorLine or {})
			vim.api.nvim_set_hl(0, "CursorLine", cursorline_opts)
		end
	end
end

-- Setup functions
function M.setup_file_post_autocmd()
	local autocmd = vim.api.nvim_create_autocmd
	local augroup = vim.api.nvim_create_augroup("NvFilePost", { clear = true })

	autocmd({ "UIEnter", "BufReadPost", "BufNewFile" }, {
		group = augroup,
		callback = function(args)
			local file = vim.api.nvim_buf_get_name(args.buf)
			local buftype = vim.api.nvim_get_option_value("buftype", { buf = args.buf })

			if not vim.g.ui_entered and args.event == "UIEnter" then
				vim.g.ui_entered = true
			end

			if file ~= "" and buftype ~= "nofile" and vim.g.ui_entered then
				vim.api.nvim_exec_autocmds("User", { pattern = "FilePost", modeline = false })
				vim.api.nvim_del_augroup_by_name("NvFilePost")

				vim.schedule(function()
					vim.api.nvim_exec_autocmds("FileType", {})

					if vim.g.editorconfig then
						require("editorconfig").config(args.buf)
					end
				end)
			end
		end,
	})
end

function M.setup_cursor_and_line_autocmds()
	local augroup = vim.api.nvim_create_augroup("NvimTreeCursorAndLineBlend", { clear = true })

	setup_nvim_tree_highlights()

	vim.api.nvim_create_autocmd({ "WinEnter", "BufEnter", "WinLeave", "ColorScheme" }, {
		group = augroup,
		callback = function()
			vim.schedule(function()
				setup_nvim_tree_highlights()
				set_cursor_and_line_appearance()
			end)
		end,
	})

	vim.api.nvim_create_autocmd("VimLeave", {
		group = augroup,
		command = "set guicursor=a:block-blinkon0",
	})
end

-- Main setup function
function M.setup()
	M.setup_file_post_autocmd()
	M.setup_cursor_and_line_autocmds()
end

return M
