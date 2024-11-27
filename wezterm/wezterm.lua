local wezterm = require("wezterm")

-- Import configurations
local appearance = require("config.appearance")
local keybinds = require("config.keybinds")
local tabs = require("config.tabs")
local statusbar = require("config.statusbar")
local resurrect_config = require("config.resurrect")

-- Initialize base config
local config = {}

-- Merge configurations
local function merge_config(conf)
  if type(conf) == "table" then
    for k, v in pairs(conf) do
      config[k] = v
    end
  end
end

-- Merge all configurations
merge_config(appearance)
merge_config(keybinds)
merge_config(tabs)
merge_config(statusbar)
merge_config(resurrect_config)

return config
