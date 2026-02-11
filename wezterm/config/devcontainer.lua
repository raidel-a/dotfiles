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

-- Clean up empty workspace windows when panes close
wezterm.on("window-focus-changed", function(window, pane)
  -- Check all windows and close any that are empty
  local mux = wezterm.mux
  for _, window_info in ipairs(mux.all_windows()) do
    local w = mux.get_window(window_info)
    if w then
      local tabs = w:tabs()
      if #tabs == 0 then
        wezterm.log_info("Closing empty window")
        w:close()
      end
    end
  end
end)

return {
  ssh_domains = ssh_domains,
  keys = keys,
}
