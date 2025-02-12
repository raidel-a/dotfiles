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

	{ key = "m", mods = "CMD", action = act.Hide },

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

	-- Command palette
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
