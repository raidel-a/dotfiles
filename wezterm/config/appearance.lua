local wezterm = require("wezterm")
local ccolors = require("utils.ccolors")

return {
	integrated_title_button_style = "Gnome",
	integrated_title_button_alignment = "Left",
	integrated_title_buttons = { "Close", "Hide", "Maximize" },
	enable_scroll_bar = false,
	window_background_opacity = 0.85,
	-- window_background_opacity = 1.0,
	macos_window_background_blur = 5,
	window_decorations = " RESIZE",
	-- |INTEGRATED_BUTTONS
	-- |MACOS_FORCE_ENABLE_SHADOW
	pane_select_font_size = 60,
	window_frame = {
		inactive_titlebar_bg = ccolors.inactive_titlebar_bg,
		border_left_width = "0.8cell",
		border_right_width = "0.8cell",
		border_top_height = "0.35cell",
		border_left_color = ccolors.border,
		border_right_color = ccolors.border,
		border_bottom_color = ccolors.border,
		border_top_color = ccolors.border,
	},
	window_padding = {
		left = "0.75cell",
		right = "0.0cell",
		top = "0cell",
		bottom = "0cell",
	},
	inactive_pane_hsb = {
		saturation = 0.0,
		brightness = 0.8,
	},
	font = wezterm.font_with_fallback({
		{
			family = "MapleMono Nerd Font",
			weight = "Regular",
		},
		{
			family = "Symbols Nerd Font",
			weight = "Regular",
		},
	}),
	font_size = 16,
	color_scheme = "Poimandres",
	colors = {
		background = ccolors.background,
		split = ccolors.border,
		tab_bar = {
			background = ccolors.border,
			active_tab = {
				bg_color = ccolors.transparent,
				fg_color = ccolors.fg,
				intensity = "Bold",
			},
			inactive_tab = {
				bg_color = ccolors.border,
				fg_color = ccolors.fg_inactive,
				italic = true,
			},
			inactive_tab_hover = {
				bg_color = ccolors.border,
				fg_color = ccolors.fg,
			},
			new_tab = {
				bg_color = ccolors.border,
				fg_color = ccolors.fg,
			},
			inactive_tab_edge = ccolors.fg_inactive,
		},
	},
}
