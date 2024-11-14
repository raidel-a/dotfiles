local wezterm = require("wezterm")
-- local config = require("wezterm")
-- config.setup()
local resurrect = wezterm.plugin.require("https://github.com/MLFlexer/resurrect.wezterm")

local io = require("io")
local os = require("os")
local process_icons = require("process_icons")

local transparent = "rgba(0,0,0,0.0)"
local border = "#000000"
-- local border = "#191B28"

local CIRCLE = wezterm.nerdfonts.cod_circle_large
local CIRCLE_FILLED = wezterm.nerdfonts.cod_circle_large_filled

function calculate_tab_width(window)
	if not window or type(window.get_dimensions) ~= "function" then
		return 200 -- default width
	end

	local dimensions = window:get_dimensions()
	local tabs = window:mux_window():tabs_with_info()
	local num_tabs = #tabs

	local available_width = dimensions.pixel_width - 10
	local tab_width = math.floor(available_width / num_tabs)

	return math.max(tab_width, 100)
end

local function get_last_segment(str)
	return string.match(str, "([^/\\]+)$") or str
end

local function get_nvim_cwd_and_file()
	local cwd = vim.fn.getcwd()
	local file_name = vim.fn.expand("%:t")
	local dir_name = vim.fn.fnamemodify(cwd, ":t")
	return dir_name .. "/" .. file_name
end

local left_bar = "\u{258F}" -- ▏
local right_bar = "\u{2595}" -- ▕

wezterm.on("format-tab-title", function(tab, tabs_max_width)
	local window = wezterm.mux.get_window(tab.window_id)
	local dynamic_max_width = window and calculate_tab_width(window) or 200

	local active_pane = tab.active_pane
	local current_dir = active_pane.current_working_dir and active_pane.current_working_dir.file_path

	if current_dir then
		local process = get_last_segment(active_pane.foreground_process_name):lower()

		-- Get the file name and extension
		local file_name = active_pane.title or ""
		local file_extension = file_name:match("%.%w+$") or "" -- Match the file extension

		-- Determine what to display: file_name or dir
		local display_name
		if file_name ~= "" and file_name ~= process then
			display_name = file_name -- Show filename if a file is open
		else
			display_name = get_last_segment(current_dir) -- Show directory if no file is open
		end

		-- Get the appropriate icon
		local icon = process_icons.get_icon(process, file_extension)

		local inner_title = string.format("%s %s", icon, display_name)

		-- Calculate the available space for the inner title
		local available_width = dynamic_max_width - 4 -- Subtract 4 for the bars and spaces

		-- Truncate the inner title if necessary
		if #inner_title > available_width then
			inner_title = wezterm.truncate_right(inner_title, available_width - 3) .. "..."
		end

		-- Add the bars outside of the truncation
		local title = string.format("%s %s %s", left_bar, inner_title, right_bar)

		-- Ensure the entire title fits within the dynamic_max_width
		if #title > dynamic_max_width then
			title = wezterm.truncate_right(title, dynamic_max_width)
		end

		return {
			{ Text = title },
		}
	end
end)

wezterm.on("window-resized", function(window, pane)
	window:set_config_overrides({
		tab_max_width = calculate_tab_width(window),
	})
end)

wezterm.on("window-config-reloaded", function(window)
	window:set_config_overrides({
		tab_max_width = calculate_tab_width(window),
	})
end)

-- Add this before your key bindings
local function handle_state_action(win, pane, id, action)
	if action == "load" then
		local type = string.match(id, "^([^/]+)")
		local name = string.match(id, "([^/]+)%.json$")

		local opts = {
			relative = true,
			restore_text = true,
			on_pane_restore = resurrect.tab_state.default_on_pane_restore,
		}

		if type == "workspace" then
			local state = resurrect.load_state(name, "workspace")
			resurrect.workspace_state.restore_workspace(state, opts)
		end
	elseif action == "delete" then
		win:perform_action(wezterm.action.PromptInputLine({
			description = 'Type "yes" to confirm deletion',
			action = wezterm.action_callback(function(window, pane, line)
				if line == "yes" then
					resurrect.delete_state(id)
				end
			end),
		}))
	elseif action == "rename" then
		win:perform_action(wezterm.action.PromptInputLine({
			description = "Enter new name",
			action = wezterm.action_callback(function(window, pane, line)
				if line then
					local new_name = string.gsub(line, "[^%w%-_]", "_")
					local new_path = string.gsub(id, "[^/]+%.json$", new_name .. ".json")
					os.rename(id, new_path)
				end
			end),
		}))
	end
end

-- Move this function definition before the return statement
local function setup_notifications()
	local events = {
		["resurrect.error"] = "Error",
		["resurrect.save_state.finished"] = "Saved",
		["resurrect.load_state.finished"] = "Loaded",
		["resurrect.delete_state.finished"] = "Deleted",
	}

	local is_periodic_save = false
	wezterm.on("resurrect.periodic_save", function()
		is_periodic_save = true
	end)

	for event, action in pairs(events) do
		wezterm.on(event, function(...)
			if event == "resurrect.save_state.finished" and is_periodic_save then
				is_periodic_save = false
				return
			end

			local args = { ... }
			local state_name = args[1] and string.match(args[1], "([^/]+)%.json$") or ""
			local msg = string.format("%s workspace: %s", action, state_name)

			wezterm.gui.gui_windows():toast_notification("Wezterm", msg, nil, 2000)
		end)
	end
end

-- Initialize resurrect features
setup_notifications()
resurrect.periodic_save({
	interval_seconds = 300,
	save_tabs = true,
	save_windows = true,
	save_workspaces = true,
})
resurrect.set_max_nlines(2000)

return {
	integrated_title_button_style = "Gnome",
	integrated_title_button_alignment = "Left",
	integrated_title_buttons = { "Close", "Hide", "Maximize" },
	use_fancy_tab_bar = false,
	tab_bar_at_bottom = true,
	enable_scroll_bar = false,

	window_background_opacity = 0.80,
	macos_window_background_blur = 10,
	window_decorations = "INTEGRATED_BUTTONS|RESIZE|MACOS_FORCE_ENABLE_SHADOW",
	window_frame = {
		font_size = 12,
		inactive_titlebar_bg = "black",
		border_left_width = "1.00cell",
		border_right_width = "1.00cell",
		border_bottom_height = "0cell",
		border_top_height = "0.5cell",
		border_left_color = border,
		border_right_color = border,
		border_bottom_color = border,
		border_top_color = border,
	},
	window_padding = {
		left = "0cell",
		right = "0cell",
		top = "0cell",
		bottom = "0cell",
	},
	inactive_pane_hsb = {
		saturation = 0.5,
		brightness = 0.5,
	},
	keys = {
		-- Configuration keys
		{
			key = ",",
			mods = "CMD",
			action = wezterm.action.SpawnCommandInNewTab({
				cwd = os.getenv("WEZTERM_CONFIG_DIR"),
				args = { "/opt/homebrew/bin/nvim", os.getenv("WEZTERM_CONFIG_FILE") },
			}),
		},
		{
			key = "<",
			mods = "CMD | SHIFT",
			action = wezterm.action.SpawnCommandInNewTab({
				cwd = "/Users/rai/.config/nvim",
				args = { "/opt/homebrew/bin/nvim", "/Users/rai/.config/nvim/init.lua" },
			}),
		},

		-- Resurrect keys
		{
			key = "s",
			mods = "CMD | SHIFT",
			action = wezterm.action_callback(function(win, pane)
				resurrect.save_state(resurrect.workspace_state.get_workspace_state())
			end),
		},

		-- Combined fuzzy finder for load/delete/rename
		{
			key = "f",
			mods = "CMD | SHIFT",
			action = wezterm.action_callback(function(win, pane)
				local choices = {}
				local states = resurrect.get_saved_states()

				for _, state in ipairs(states) do
					local name = string.match(state, "([^/]+)%.json$") or state
					table.insert(choices, {
						id = state,
						label = string.format("󰆓 Load: %s", name),
						action = "load",
					})
					table.insert(choices, {
						id = state,
						label = string.format("󰩺 Delete: %s", name),
						action = "delete",
					})
					table.insert(choices, {
						id = state,
						label = string.format("󰑕 Rename: %s", name),
						action = "rename",
					})
				end

				win:perform_action(
					wezterm.action.InputSelector({
						title = " Workspace Manager",
						choices = choices,
						fuzzy = true,
						description = "Enter = select  Esc = cancel  / = filter",
						action = wezterm.action_callback(function(window, pane, id, label)
							if not id then
								return
							end
							for _, choice in ipairs(choices) do
								if choice.label == label then
									handle_state_action(window, pane, choice.id, choice.action)
									break
								end
							end
						end),
					}),
					pane
				)
			end),
		},
	},

	font = wezterm.font_with_fallback({
		{ family = "MapleMono Nerd Font", weight = "Regular" },
		{ family = "Symbols Nerd Font", weight = "Regular" },
	}),
	font_size = 14.5,

	-- color_scheme = (wezterm.gui.get_appearance():find("Dark") and "Ashes (dark) (terminal.sexy)" or "Ashes (light) (terminal.sexy)"),

	-- color_scheme = "Tokyo Night",
	colors = {
		background = "#121112",
		tab_bar = {
			background = border,
			active_tab = {
				bg_color = transparent,
				fg_color = "#fefefe",
				intensity = "Bold",
			},
			inactive_tab = {
				bg_color = border,
				fg_color = "#808080",
				italic = true,
			},
			new_tab = {
				bg_color = border,
				fg_color = "#fefefe",
			},
			inactive_tab_edge = "grey",
		},
	},
	tab_bar_style = {
		window_close = wezterm.format({
			{ Background = { Color = border } },
			{ Foreground = { Color = "#F30710" } },
			{ Text = "  " .. CIRCLE .. " " },
		}),
		window_close_hover = wezterm.format({
			{ Background = { Color = border } },
			{ Foreground = { Color = "#F30710" } },
			{ Text = "  " .. CIRCLE_FILLED .. " " },
		}),
		window_hide = wezterm.format({
			{ Background = { Color = border } },
			{ Foreground = { Color = "#FEC907" } },
			{ Text = " " .. CIRCLE .. " " },
		}),
		window_hide_hover = wezterm.format({
			{ Background = { Color = border } },
			{ Foreground = { Color = "#FEC907" } },
			{ Text = " " .. CIRCLE_FILLED .. " " },
		}),
		window_maximize = wezterm.format({
			{ Background = { Color = border } },
			{ Foreground = { Color = "#2FFF03" } },
			{ Text = " " .. CIRCLE .. "  " },
		}),
		window_maximize_hover = wezterm.format({
			{ Background = { Color = border } },
			{ Foreground = { Color = "#2FFF03" } },
			{ Text = " " .. CIRCLE_FILLED .. "  " },
		}),
	},
}
