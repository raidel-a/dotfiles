local wezterm = require("wezterm")
local io = require("io")
local os = require("os")

local transparent = "rgba(0,0,0,1)"
local CIRCLE = wezterm.nerdfonts.cod_circle_large
local CIRCLE_FILLED = wezterm.nerdfonts.cod_circle_large_filled

--- creates a second pane if there is only one pane in the current tab
---@param current_window any
---@param current_pane any
---@return boolean did_create whether or not it did create a new pane
local create_second_pane = function(current_window, current_pane)
	local current_tab = current_window:active_tab()
	local current_tab_pane_ids = current_tab:panes()
	-- if current pane is the only pane in the tab, create a new horizontal split pane
	if #current_tab_pane_ids == 1 then
		current_window:perform_action(
			wezterm.action.SplitPane({ direction = "Down", size = { Percent = 30 } }),
			current_pane
		)
		return true
	end
	return false
end

wezterm.on("vim-mode", function(current_window, current_pane)
	-- retrieve the last 300 lines of terminal output
	local viewport_text = current_pane:get_lines_as_text(300)

	-- create a temporary file to pass to vim
	local tmpfile = os.tmpname()
	local f, err = io.open(tmpfile, "w+")
	if f == nil then
		print(err)
	else
		f:write(viewport_text)
		f:flush()
		f:close()
	end

	-- Open a new window running vim and tell it to open the file
	current_window:perform_action(
		wezterm.action.SpawnCommandInNewWindow({
			args = {
				-- path to executable
				"/opt/homebrew/bin/nvim",
				-- temporary file name
				tmpfile,
				-- set cursor to last line
				"+",
				-- set filetype to sh for some best effor highlighting
				"+set filetype=sh",
			},
		}),
		current_pane
	)

	-- remove tmpfile after giving nvim time to read it
	wezterm.sleep_ms(1000)
	os.remove(tmpfile)
end)

--- switch to the alternate pane of the current tab
wezterm.on("alternate-pane", function(current_window, current_pane)
	local did_create = create_second_pane(current_window, current_pane)
	if not did_create then
		current_window:perform_action(wezterm.action.ActivatePaneDirection("Next"), current_pane)
	end
end)

--- toggle zoom of the current pane to reveal the alternate-pane
wezterm.on("alternate-zoom", function(current_window, current_pane)
	local did_create = create_second_pane(current_window, current_pane)
	if not did_create then
		-- if two panes exist already, get the alternate pane (currently *not* selected pane)
		current_window:perform_action(wezterm.action.TogglePaneZoomState, current_pane)
	else
		current_pane:activate()
	end
end)

local process_icons = {
	["nvim"] = wezterm.nerdfonts.custom_v_lang,
	["node"] = wezterm.nerdfonts.dev_nodejs_small,
	["zsh"] = wezterm.nerdfonts.cod_terminal,
	["git"] = wezterm.nerdfonts.dev_git,
	["python"] = wezterm.nerdfonts.dev_python,
  ["spotify_player"] = wezterm.nerdfonts.md_spotify,

}

local get_last_segment = function(str)
	return str:gsub("(.*[/\\])(.*)", "%2")
end

wezterm.on("format-tab-title", function(tab)
	local active_pane = tab.active_pane
	local current_dir = active_pane.current_working_dir
	local process = get_last_segment(active_pane.foreground_process_name):lower()
	local dir = current_dir and get_last_segment(current_dir.file_path) or "No Directory"
	local process_icon = process_icons[process] or (" %s "):format(process)
	local title = active_pane.title or "No Title"
	return {
		{ Text = (" %s  %s  %s "):format(process_icon, dir, title) },
	}
end)

return {
	integrated_title_button_style = "Gnome",
	integrated_title_button_alignment = "Left",
	integrated_title_buttons = { "Close", "Hide", "Maximize" },
	use_fancy_tab_bar = false,
	-- window_background_opacity = 0.85,
	-- macos_window_background_blur = 20,
	window_decorations = "INTEGRATED_BUTTONS|RESIZE",
	window_frame = {
		font_size = 14,
		inactive_titlebar_bg = "grey",
	},
	inactive_pane_hsb = {
		saturation = 0.5,
		brightness = 0.5,
	},
	keys = {
		-- bind wezterm copy mode to inspector hotkey
		{
			key = "i",
			mods = "CMD|ALT",
			action = wezterm.action.EmitEvent("vim-mode"),
		},
		-- go to alternate pane
		{
			key = "k",
			mods = "CMD",
			action = wezterm.action.EmitEvent("alternate-pane"),
		},
		-- show or hide alternate pane with cmd + h
		{
			key = "h",
			mods = "CMD",
			action = wezterm.action.EmitEvent("alternate-zoom"),
		},
	},
	font = wezterm.font_with_fallback({
		"MapleMono Nerd Font",
		-- Fallback to Nerd Font symbols if glyph is not available
		"Symbols Nerd Font",
	}),
	font_size = 14,

	-- color_scheme = (wezterm.gui.get_appearance():find("Dark") and "Ashes (dark) (terminal.sexy)" or "Ashes (light) (terminal.sexy)"),

	color_scheme = "Tokyo Night",
	colors = {
		-- background = "#15171E",
		tab_bar = {
			background =  "black",
			active_tab = {
				bg_color = "#1C1E28",
				fg_color = "#fefefe",
				intensity = "Bold",
			},
			inactive_tab = {
				bg_color = "black",
				fg_color = "#808080",
				italic = true,
			},
			new_tab = {
				bg_color = "black",
				fg_color = "#fefefe",
			},
			inactive_tab_edge = "grey",
			active_tab_edge = "white",
		},
	},
	tab_bar_style = {
		window_close = wezterm.format {
			{ Background = { Color = "#000" } },
			{ Foreground = { Color = "#F30710"} },
			{ Text =  "  ".. CIRCLE .. " " },
	},
		window_close_hover = wezterm.format {
			{ Background = { Color = "#000" } },
			{ Foreground = { Color = "#F30710"} },
			{ Text =  "  ".. CIRCLE_FILLED .. " " },
	},
		window_hide = wezterm.format {
			{ Background = { Color = "#000" } },
			{ Foreground = { Color = "#FEC907"} },
			{ Text =  " ".. CIRCLE .. " " },
	},
		window_hide_hover = wezterm.format {
			{ Background = { Color = "#000" } },
			{ Foreground = { Color = "#FEC907"} },
			{ Text =  " ".. CIRCLE_FILLED .. " " },
	},
    		window_maximize = wezterm.format {
			{ Background = { Color = "#000" } },
			{ Foreground = { Color = "#2FFF03"} },
			{ Text =  " ".. CIRCLE .. "  " },
	},
    		window_maximize_hover = wezterm.format {
			{ Background = { Color = "#000" } },
			{ Foreground = { Color = "#2FFF03"} },
			{ Text =  " ".. CIRCLE_FILLED .. "  " },
	},
}
}
