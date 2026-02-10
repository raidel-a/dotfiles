local wezterm = require("wezterm")
local devcontainer = require("utils.devcontainer")

-- Pre-allocate SSH domains for ports 2222-2231 (supports up to 10 concurrent containers)
local ssh_domains = devcontainer.generate_ssh_domains()

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
