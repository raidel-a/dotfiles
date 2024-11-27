local wezterm = require("wezterm")

local function segments_for_right_status(window)
  return {
    window:active_workspace(),
    -- wezterm.strftime('%a %b %-d %H:%M'),
    wezterm.hostname(),
  }
end

wezterm.on("update-status", function(window, pane)
  local segments = segments_for_right_status(window)
  
  window:set_right_status(wezterm.format({
    { Background = { Color = "#000000" }},
    { Foreground = { Color = "#808080" }},
    { Text = " 🮔 󰬱 " .. segments[1] .. " ▐ 󰁥 " .. segments[2] .. " " },
  }))
end)

return {
  status_update_interval = 1000,
}