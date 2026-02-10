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
      "docker inspect -f '{{.Name}} {{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}} {{.Config.Image}} {{.State.Status}} {{.Config.User}} {{range $p, $conf := .NetworkSettings.Ports}}{{$p}}->{{if $conf}}{{(index $conf 0).HostPort}}{{end}} {{end}}' %s",
      id
    )
    local handle = io.popen(cmd)
    if handle then
      local line = handle:read("*l")
      handle:close()
      if line then
        local name, ip, image, state, user, ports = line:match("^/(%S+)%s+(%S+)%s+(%S+)%s+(%S+)%s+(%S*)%s*(.*)$")
        if name and image and ports then
          local workspace = M.extract_workspace_name(image)
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
          
          wezterm.log_info("Connecting to domain: " .. container.domain_name)
          
          -- First, attach the SSH domain (this triggers the connection)
          -- Then switch to a workspace and spawn into that domain
          window:perform_action(
            wezterm.action.Multiple({
              wezterm.action.AttachDomain(container.domain_name),
              wezterm.action.SwitchToWorkspace({
                name = container.display_name,
                spawn = {
                  domain = { DomainName = container.domain_name },
                },
              }),
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
