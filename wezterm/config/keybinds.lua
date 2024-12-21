local wezterm = require("wezterm")
local act = wezterm.action

-- Define key tables/modes
local keys = {
	-- Pane keybinds
	{
		key = "d",
		mods = "CMD",
		action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }),
	},
	{
		key = "d",
		mods = "CMD|SHIFT",
		action = act.SplitVertical({ domain = "CurrentPaneDomain" }),
	},
	{
		key = "w",
		mods = "CMD",
		action = act.CloseCurrentPane({ confirm = true }),
	},
	{
		key = "q",
		mods = "CMD",
		action = act.QuitApplication,
	},
	{
		key = "n",
		mods = "CMD",
		action = act.SpawnWindow,
	},

	{
		key = "H",
		mods = "CMD|SHIFT",
		action = act.AdjustPaneSize({ "Left", 5 }),
	},
	{
		key = "J",
		mods = "CMD|SHIFT",
		action = act.AdjustPaneSize({ "Down", 5 }),
	},
	{ key = "K", mods = "CMD|SHIFT", action = act.AdjustPaneSize({ "Up", 5 }) },
	{
		key = "L",
		mods = "CMD|SHIFT",
		action = act.AdjustPaneSize({ "Right", 5 }),
	},
	{
		key = "N",
		mods = "CMD|SHIFT",
		action = act.PaneSelect,
	},
	{
		key = "M",
		mods = "CMD|SHIFT",
		action = act.PaneSelect({
			mode = "SwapWithActive",
		}),
	},

	-- Tab keybinds
	{
		key = "t",
		mods = "CMD",
		action = act({ SpawnCommandInNewTab = { cwd = wezterm.home_dir } }),
	},
	{
		key = "t",
		mods = "CMD|SHIFT",
		action = act.SpawnTab("CurrentPaneDomain"),
	},
	{
		key = "Tab",
		mods = "CTRL",
		action = act.ActivateTabRelative(-1),
	},
	{
		key = "Tab",
		mods = "CTRL | SHIFT",
		action = act.ActivateTabRelative(1),
	},

	-- Font size
	{
		key = "=",
		mods = "CMD",
		action = act.IncreaseFontSize,
	},
	{
		key = "-",
		mods = "CMD",
		action = act.DecreaseFontSize,
	},
	{
		key = "0",
		mods = "CMD",
		action = act.ResetFontSize,
	},

	-- Pane navigation
	{
		key = "h",
		mods = "CMD",
		action = act.ActivatePaneDirection("Left"),
	},
	{
		key = "l",
		mods = "CMD",
		action = act.ActivatePaneDirection("Right"),
	},
	{
		key = "k",
		mods = "CMD",
		action = act.ActivatePaneDirection("Up"),
	},
	{
		key = "j",
		mods = "CMD",
		action = act.ActivatePaneDirection("Down"),
	},

	-- Copy/Paste
	{
		key = "c",
		mods = "CMD",
		action = act.CopyTo("Clipboard"),
	},
	{
		key = "v",
		mods = "CMD",
		action = act.PasteFrom("Clipboard"),
	},

	-- Quick select mode
	{
		key = "f",
		mods = "CMD|SHIFT",
		action = act.QuickSelect,
	},

	-- Full screen
	{
		key = "f",
		mods = "CMD",
		action = act.ToggleFullScreen,
	},

	--
	{
		key = "p",
		mods = "CMD|SHIFT",
		action = wezterm.action.ActivateCommandPalette,
	},

	{
		key = ",",
		mods = "CMD",
		action = wezterm.action.SpawnCommandInNewTab({
			cwd = os.getenv("WEZTERM_CONFIG_DIR"),
			args = { "/opt/homebrew/bin/nvim", os.getenv("WEZTERM_CONFIG_FILE") },
		}),
	},
	{
		key = "<",
		mods = "CMD | SHIFT",
		action = wezterm.action.SpawnCommandInNewTab({
			cwd = "/Users/rai/.config/nvim",
			args = { "/opt/homebrew/bin/nvim", "/Users/rai/.config/nvim/init.lua" },
		}),
	},

	{
		key = "p",
		mods = "CTRL | SHIFT",
		action = wezterm.action_callback(function(window, pane)
			local choices = {}
			for _, dir in ipairs(get_project_dirs()) do
				table.insert(choices, { label = dir })
			end

			window:perform_action(wezterm.action.InputSelector({
				title = "Projects",
				choices = choices,
				action = wezterm.action_callback(function(_, _, dir)
					if dir then
						window:perform_action(wezterm.action.SpawnCommandInNewTab({
							cwd = dir,
							args = { "bash" },
						}))
					end
				end),
			}))
		end),
	},

	-- Resurrect keys
	{
		key = "s",
		mods = "CMD | SHIFT",
		action = wezterm.action_callback(function(win, pane)
			resurrect.save_state(resurrect.workspace_state.get_workspace_state())
		end),
	},

	-- Combined fuzzy finder for load/delete/rename
	{
		key = "f",
		mods = "CMD | SHIFT",
		action = wezterm.action_callback(function(win, pane)
			local choices = {}
			local states = resurrect.get_saved_states()

			for _, state in ipairs(states) do
				local name = string.match(state, "([^/]+)%.json$") or state
				table.insert(choices, {
					id = state,
					label = string.format("󰆓 Load: %s", name),
					action = "load",
				})
				table.insert(choices, {
					id = state,
					label = string.format("󰩺 Delete: %s", name),
					action = "delete",
				})
				table.insert(choices, {
					id = state,
					label = string.format("󰑕 Rename: %s", name),
					action = "rename",
				})
			end

			win:perform_action(
				wezterm.action.InputSelector({
					title = " Workspace Manager",
					choices = choices,
					fuzzy = true,
					description = "Enter = select  Esc = cancel  / = filter",
					action = wezterm.action_callback(function(window, pane, id, label)
						if not id then
							return
						end
						for _, choice in ipairs(choices) do
							if choice.label == label then
								handle_state_action(window, pane, choice.id, choice.action)
								break
							end
						end
					end),
				}),
				pane
			)
		end),
	},
}

-- Return the config
return {
	disable_default_key_bindings = true,
	keys = keys,

	-- Mouse bindings
	mouse_bindings = {
		-- Right click to paste
		{
			event = { Down = { streak = 1, button = "Right" } },
			mods = "NONE",
			action = act.PasteFrom("Clipboard"),
		},
	},
}
