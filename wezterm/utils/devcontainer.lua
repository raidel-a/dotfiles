local wezterm = require("wezterm")

local M = {}

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
    workspace = workspace:match("^(.*)%-.+$") or workspace
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
          devpods[name] = {
            ip = ip,
            image = image,
            workspace = workspace,
            state = state,
            user = user ~= "" and user or nil,
            ports = port_map,
          }
        end
      end
    end
  end
  
  M.devpods = devpods
  return devpods
end

-- SSH domains cache
M.ssh_domains = {}

-- Create SSH domains for WezTerm multiplexing
M.create_ssh_domains = function()
  -- Only regenerate if cache is empty
  if next(M.ssh_domains) ~= nil then
    return M.ssh_domains
  end

  -- Refresh container info
  if next(M.devpods) == nil then
    M.devpods = M.get_devpod_info()
  end

  -- Generate SSH domains
  for name, data in pairs(M.devpods) do
    -- Check if container has SSH port exposed
    local ssh_port = data.ports["2222/tcp"]
    if ssh_port then
      table.insert(M.ssh_domains, {
        name = data.workspace or name,
        remote_address = string.format("127.0.0.1:%s", ssh_port),
        username = data.user or "vscode",
        connect_automatically = false,
        multiplexing = "WezTerm",
        remote_wezterm_path = "/usr/bin/wezterm",
        ssh_option = {
          identityfile = "~/.ssh/id_devcontainer",
          forwardagent = "yes",
        },
      })
    end
  end

  return M.ssh_domains
end

-- Show container selector
M.show_domain_selector = function()
  -- Refresh container info
  M.devpods = M.get_devpod_info()

  if not M.devpods or not next(M.devpods) then
    return wezterm.action.ShowLauncherArgs({
      title = "No devcontainers found",
      flags = "FUZZY",
    })
  end

  -- Build choices for selector
  local choices = {}
  local container_list = {}
  
  for name, data in pairs(M.devpods) do
    if data.ports["2222/tcp"] then
      local display_name = data.workspace or name
      local port = data.ports["2222/tcp"]
      table.insert(choices, {
        label = string.format("%s (port %s)", display_name, port),
      })
      table.insert(container_list, {
        name = name,
        display_name = display_name,
        port = port,
        user = data.user or "vscode",
      })
    end
  end

  if #choices == 0 then
    return wezterm.action.ShowLauncherArgs({
      title = "No devcontainers with SSH (port 2222) found",
      flags = "FUZZY",
    })
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
          
          if container then
            wezterm.log_info("Connecting to container: " .. container.name .. " on port " .. container.port)
            
            -- Spawn SSH connection in new tab
            window:perform_action(
              wezterm.action.SpawnCommandInNewTab({
                label = container.display_name,
                args = {
                  "ssh",
                  "-p",
                  container.port,
                  "-l",
                  container.user,
                  "-i",
                  wezterm.home_dir .. "/.ssh/id_devcontainer",
                  "-o",
                  "StrictHostKeyChecking=no",
                  "-o",
                  "UserKnownHostsFile=/dev/null",
                  "127.0.0.1",
                },
              }),
              pane
            )
          end
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
