local wezterm = require("wezterm")
local ccolors = require("utils.ccolors")

local function get_appearance()
  if wezterm.gui then
    return wezterm.gui.get_appearance()
  end
  return 'Dark'
end

local function scheme_for_appearance(appearance)
  if appearance:find 'Dark' then
    return 'Poimandres'
  else
    return 'Tokyo Night Light (Gogh)'
  end
end
local light_theme = "Tokyo Night Light (Gogh)"
local dark_theme = "Poimandres"

local appearance_themes = {
	Light = "Tokyo Night Light (Gogh)",
	Dark = "Poimandres",
}
local bg_colors = {
	Light = ccolors.light_background,
	Dark = ccolors.background,
}
local fg_colors = {
	Light = ccolors.background,
	Dark = ccolors.fg,
}

-- Always use dark theme to avoid light mode appearing in workspace windows
-- If you want to respect system appearance, change this to: get_appearance()
local appearance = get_appearance()  -- Force dark mode for all windows

-- Force dark theme for SSH domains (devcontainer workspaces)
-- to ensure consistent appearance across workspaces
-- wezterm.on("update-status", function(window, pane)
--   local domain = pane:get_domain_name()
--   if domain and domain:match("^devcontainer%-") then
--     -- This pane is in a devcontainer domain, ensure dark theme
--     local overrides = window:get_config_overrides() or {}
--     if overrides.color_scheme ~= dark_theme then
--       overrides.color_scheme = dark_theme
--       overrides.colors = {
--         background = ccolors.background,
--       }
--       window:set_config_overrides(overrides)
--     end
--   end
-- end)

return {
	integrated_title_button_style = "Gnome",
	integrated_title_button_alignment = "Left",
	integrated_title_buttons = { "Close", "Hide", "Maximize" },
	enable_scroll_bar = false,
	window_background_opacity = 0.82,
	macos_window_background_blur = 0,
	window_decorations = " RESIZE |INTEGRATED_BUTTONS|MACOS_FORCE_ENABLE_SHADOW",
	-- |INTEGRATED_BUTTONS
	-- |MACOS_FORCE_ENABLE_SHADOW
	pane_select_font_size = 60,
	window_frame = {
		inactive_titlebar_bg = ccolors.inactive_titlebar_bg,
		border_left_width = "0.45cell",
		border_right_width = "0.45cell",
		border_top_height = "0.2cell",
		border_bottom_height = "0.2cell",
		border_left_color = ccolors.border,
		border_right_color = ccolors.border,
		border_bottom_color = ccolors.border,
		border_top_color = ccolors.border,
	},
	window_padding = {
		left = "0.0cell",
		right = "0.0cell",
		top = "0.0cell",
		bottom = "0.0cell",
	},
	inactive_pane_hsb = {
		saturation = 0.2,
		brightness = 0.8,
	},
	font = wezterm.font_with_fallback({
		{
			family = "Maple Mono NF",
			weight = "Regular",
		},
		{
			family = "Symbols Nerd Font",
			weight = "Regular",
		},
	}),
	font_size = 15,
	color_scheme = appearance_themes[appearance] or dark_theme,
	colors = {
		background = bg_colors[appearance],
		split = ccolors.fg,
		tab_bar = {
			background = ccolors.border,
			active_tab = {
				bg_color = ccolors.border,
				fg_color = fg_colors[appearance],
				intensity = "Bold",
			},
			inactive_tab = {
				bg_color = ccolors.border,
				fg_color = ccolors.fg_inactive,
			},
			inactive_tab_hover = {
				bg_color = ccolors.border,
				fg_color = ccolors.fg,
				italic = true,
			},
			new_tab = {
				bg_color = ccolors.border,
				fg_color = ccolors.fg,
			},
			inactive_tab_edge = ccolors.fg_inactive,
		},
	},
}
