local wezterm = require("wezterm")

-- Import configurations
local appearance = require("config.appearance")
local keybinds = require("config.keybinds")
local tabs = require("config.tabs")
local statusbar = require("config.statusbar")
local resurrect = require("config.resurrect")

-- Initialize base config
local config = {}

-- Merge configurations
local function merge_config(conf)
  if type(conf) == "table" then
    for k, v in pairs(conf) do
      if k == "keys" and config.keys then
        -- Merge keys instead of replacing them
        for _, key_binding in ipairs(v) do
          table.insert(config.keys, key_binding)
        end
      else
        config[k] = v
      end
    end
  end
end

-- Merge all configurations
merge_config(appearance)
merge_config(keybinds)
merge_config(tabs)
merge_config(statusbar)
merge_config(resurrect)

return config
