local wezterm = require("wezterm")
local ccolors = require("utils.ccolors")
local helpers = require("utils.helpers")

-- Nerd font icons
local DIVIDER = wezterm.nerdfonts.md_play
local GIT_BRANCH = wezterm.nerdfonts.dev_git_branch
local FOLDER = wezterm.nerdfonts.md_folder
local COMMAND = wezterm.nerdfonts.md_home_roof
local HOST = wezterm.nerdfonts.md_home
local SSH = wezterm.nerdfonts.cod_remote

-- Status elements colors
local colors = {
  workspace = {
	bg = ccolors.border,
    fg = "rgb(210,10,100)",
  },
  git = {
	bg = ccolors.border,
    fg = "rgb(210,110,10)",
  },
  cwd = {
	bg = ccolors.border,
    fg = "rgb(0,135,95)",
  },
  cmd = {
	bg = ccolors.border,
    fg = "rgb(10,190,200)",
  },
  hostname = {
	bg = ccolors.border,
    fg = "rgb(250,200,30)",
  },
}

local function get_git_branch(cwd)
  local success, stdout, stderr = wezterm.run_child_process({"git", "-C", cwd, "branch", "--show-current"})
  if success then
    return stdout:gsub("\n", "")
  end
  return nil
end

local function get_current_command(pane)
  local process_name = pane:get_foreground_process_name()
  local cmd_name = helpers.get_last_segment(process_name)
  
  -- Check if we're in an SSH session
  local is_ssh = process_name:match("ssh") ~= nil
  
  -- Return both the command name and whether it's SSH
  return {
    name = cmd_name,
    is_ssh = is_ssh
  }
end

wezterm.on("update-right-status", function(window, pane)
  -- Get current working directory
  local cwd = pane:get_current_working_dir()
  if not cwd then return end
  
  local cwd_path = cwd.file_path
  local cwd_name = helpers.get_last_segment(cwd_path)
  
  -- Get git branch
  local git_branch = get_git_branch(cwd_path)
  
  -- Get current command
  local current_cmd = get_current_command(pane)
  
  -- Get hostname
--   local hostname = wezterm.hostname()
  
  -- Build status segments
  local elements = {}
  
  -- Workspace/CWD
--   table.insert(elements, {Foreground={Color=colors.cwd.fg}})
--   table.insert(elements, {Background={Color=colors.cwd.bg}})
--   table.insert(elements, {Text=" " .. FOLDER .. " " .. cwd_name .. " "})
  
  -- Git branch (if available)
  if git_branch then
    table.insert(elements, {Foreground={Color=colors.git.fg}})
    table.insert(elements, {Background={Color=colors.git.bg}})
    table.insert(elements, {Text=" " .. GIT_BRANCH .. " " .. git_branch .. " "})
  end
  
  -- Current command
  local cmd_info = get_current_command(pane)
  table.insert(elements, {Foreground={Color=colors.cmd.fg}})
  table.insert(elements, {Background={Color=colors.cmd.bg}})
  table.insert(elements, {Text=" " .. (cmd_info.is_ssh and SSH or COMMAND) .. " " .. cmd_info.name .. " "})
  
  -- Hostname
--   table.insert(elements, {Foreground={Color=colors.hostname.fg}})
--   table.insert(elements, {Background={Color=colors.hostname.bg}})
--   table.insert(elements, {Text=" " .. HOST .. " " .. hostname .. " "})
  
  window:set_right_status(wezterm.format(elements))
end)

return {
  status_update_interval = 1000,
}