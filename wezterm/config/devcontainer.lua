local wezterm = require("wezterm")
local devcontainer = require("utils.devcontainer")

-- Configure SSH domains for devcontainer multiplexing
local ssh_domains = devcontainer.create_ssh_domains()

-- Add keybinding for container selector
local keys = {
  {
    key = "p",
    mods = "CMD",
    action = wezterm.action_callback(function(window, pane)
      window:perform_action(devcontainer.show_domain_selector(), pane)
    end),
  },
}

return {
  ssh_domains = ssh_domains,
  keys = keys,
}
