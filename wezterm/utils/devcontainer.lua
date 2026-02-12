local wezterm = require("wezterm")

local M = {}

-- Pre-allocate SSH domains for ports 2222-2231 (10 concurrent containers)
M.generate_ssh_domains = function()
  local domains = {}
  for port = 2222, 2231 do
    table.insert(domains, {
      name = "devcontainer-" .. port,
      remote_address = "127.0.0.1:" .. port,
      username = "vscode",
      connect_automatically = false,
      multiplexing = "WezTerm",
      remote_wezterm_path = "/usr/bin/wezterm",
      ssh_option = {
        identityfile = "~/.ssh/id_devcontainer",
        forwardagent = "yes",
      },
    })
  end
  return domains
end

-- Get running container IDs
M.get_container_ids = function()
  local container_ids = {}
  local cmd = "docker container ls --format '{{.ID}}'"
  local handle = io.popen(cmd)
  if handle then
    for line in handle:lines() do
      table.insert(container_ids, line)
    end
    handle:close()
  end
  return container_ids
end

-- Parse port mapping from docker inspect output
M.map_ports = function(ports)
  local port_map = {}
  if ports and ports ~= "" then
    for container_port, host_port in ports:gmatch("(%S+)->(%S+)") do
      port_map[container_port] = host_port
    end
  end
  return port_map
end

-- Extract workspace name from image
M.extract_workspace_name = function(image)
  local workspace = image:match("^([^:]+)")
  if workspace then
    -- Clean up long devcontainer image names
    workspace = workspace:gsub("^vsc%-", "")
    workspace = workspace:match("^([^%-]+)") or workspace
  end
  return workspace
end

-- Container info cache
M.devpods = {}

-- Get detailed info for all running containers
M.get_devpod_info = function()
  local ids = M.get_container_ids()
  local devpods = {}

  for _, id in ipairs(ids) do
    local cmd = string.format(
      "docker inspect -f '{{.Name}} {{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}} {{.Config.Image}} {{.State.Status}} {{.Config.User}} {{range $p, $conf := .NetworkSettings.Ports}}{{$p}}->{{if $conf}}{{(index $conf 0).HostPort}}{{end}} {{end}} {{index .Config.Labels \"devcontainer.local_folder\"}}' %s",
      id
    )
    local handle = io.popen(cmd)
    if handle then
      local line = handle:read("*l")
      handle:close()
      if line then
        local name, ip, image, state, user, ports, local_folder = line:match("^/(%S+)%s+(%S+)%s+(%S+)%s+(%S+)%s+(%S*)%s+(.*)%s+(%S*)$")
        if name and image and ports then
          -- Extract workspace name from local_folder path (e.g., /Users/rai/Desktop/urls -> urls)
          local workspace
          if local_folder and local_folder ~= "" then
            workspace = local_folder:match("([^/]+)$")
          end
          -- Fallback to image-based extraction if no local_folder label
          if not workspace then
            workspace = M.extract_workspace_name(image)
          end
          
          local port_map = M.map_ports(ports)
          
          -- Only include containers with SSH port exposed
          if port_map["2222/tcp"] then
            devpods[name] = {
              ip = ip,
              image = image,
              workspace = workspace,
              state = state,
              user = user ~= "" and user or nil,
              port = port_map["2222/tcp"],
              domain_name = "devcontainer-" .. port_map["2222/tcp"],
            }
          end
        end
      end
    end
  end
  
  M.devpods = devpods
  return devpods
end

-- Show container selector
M.show_domain_selector = function()
  -- Refresh container info
  M.devpods = M.get_devpod_info()

  if not M.devpods or not next(M.devpods) then
    return wezterm.action.ShowLauncherArgs({
      title = "No devcontainers found with SSH (port 2222) exposed",
      flags = "FUZZY",
    })
  end

  -- Build choices for selector
  local choices = {}
  local container_list = {}
  local idx = 1
  
  for name, data in pairs(M.devpods) do
    local display_name = data.workspace or name
    table.insert(choices, {
      id = tostring(idx - 1),
      label = string.format("%s (port %s)", display_name, data.port),
    })
    container_list[idx] = {
      name = name,
      display_name = display_name,
      port = data.port,
      domain_name = data.domain_name,
    }
    idx = idx + 1
  end

  return wezterm.action_callback(function(window, pane)
    window:perform_action(
      wezterm.action.InputSelector({
        action = wezterm.action_callback(function(window, pane, id, label)
          if not id and not label then
            wezterm.log_info("Container selection cancelled")
            return
          end
          
          -- Find the selected container
          local selected_idx = tonumber(id) + 1
          local container = container_list[selected_idx]
          
          if not container then
            wezterm.log_error("Could not find container at index: " .. tostring(selected_idx))
            return
          end
          
          wezterm.log_info("Connecting to domain: " .. container.domain_name .. " in workspace: " .. container.display_name)
          
          -- Use SwitchToWorkspace with spawn, which should work correctly
          -- The key is ensuring this happens in the current window
          window:perform_action(
            wezterm.action.SwitchToWorkspace({
              name = container.display_name,
              spawn = {
                domain = { DomainName = container.domain_name },
                cwd = "/" .. container.display_name,
              },
            }),
            pane
          )
        end),
        title = "Select Devcontainer",
        choices = choices,
        fuzzy = true,
      }),
      pane
    )
  end)
end

return M
