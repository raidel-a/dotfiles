local wezterm = require("wezterm")

local transparent = "rgba(0,0,0,0.0)"
local border = "#000000"

return {
  integrated_title_button_style = "Gnome",
  integrated_title_button_alignment = "Left",
  integrated_title_buttons = { "Close", "Hide", "Maximize" },
  enable_scroll_bar = false,
  window_background_opacity = 0.85,
  macos_window_background_blur = 10,
  window_decorations = "INTEGRATED_BUTTONS|RESIZE|MACOS_FORCE_ENABLE_SHADOW",
  window_frame = {
    font_size = 12,
    inactive_titlebar_bg = "black",
    border_left_width = "2.00cell",
    border_right_width = "2.00cell",
    border_bottom_height = "0cell",
    border_top_height = "1.0cell",
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
  font = wezterm.font_with_fallback({
    { family = "MapleMono Nerd Font", weight = "Regular" },
    { family = "Symbols Nerd Font", weight = "Regular" },
  }),
  font_size = 14.5,
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
}
