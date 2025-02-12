local wezterm = require("wezterm")
local resurrect = wezterm.plugin.require("https://github.com/MLFlexer/resurrect.wezterm")

resurrect.set_encryption({
  enable = true,
  method = "age", -- "age" is the default encryption method, but you can also specify "rage" or "gpg"
  private_key = "../key.txt", -- if using "gpg", you can omit this
  public_key = "age1w5gmrt0wrseuj72t9clajua3udaj8gzhcw0sut4vvqmfdl0yrq2s644qqw",
})

local resurrect_keys = {

	-- Save workspace
	-- {
	-- 	key = "w",
	-- 	mods = "ALT",
	-- 	action = wezterm.action_callback(function(win, pane)
	-- 		resurrect.save_state(resurrect.workspace_state.get_workspace_state())
	-- 	  end),
	--   },

	-- Save window
		--  {
		-- key = "W",
		-- mods = "ALT",
		-- action = resurrect.window_state.save_window_action(),
		--  },

	-- Save tab
		--  {
		-- key = "T",
		-- mods = "ALT",
		-- action = resurrect.tab_state.save_tab_action(),
		--  },

	-- Save workspace and window
		--  {
		-- key = "s",
		-- mods = "ALT",
		-- action = wezterm.action_callback(function(win, pane)
		-- 	resurrect.save_state(resurrect.workspace_state.get_workspace_state())
		-- 	resurrect.window_state.save_window_action()
		--   end),
		--  },

	-- Load state
	-- {
	-- 	key = "r",
	-- 	mods = "ALT",
	-- 	action = wezterm.action_callback(function(win, pane)
	-- 	  resurrect.fuzzy_load(win, pane, function(id, label)
	-- 		local type = string.match(id, "^([^/]+)") -- match before '/'
	-- 		id = string.match(id, "([^/]+)$") -- match after '/'
	-- 		id = string.match(id, "(.+)%..+$") -- remove file extention
	-- 		local opts = {
	-- 		  relative = true,
	-- 		  restore_text = true,
	-- 		  on_pane_restore = resurrect.tab_state.default_on_pane_restore,
	-- 		}
	-- 		if type == "workspace" then
	-- 		  local state = resurrect.load_state(id, "workspace")
	-- 		  resurrect.workspace_state.restore_workspace(state, opts)
	-- 		elseif type == "window" then
	-- 		  local state = resurrect.load_state(id, "window")
	-- 		  resurrect.window_state.restore_window(pane:window(), state, opts)
	-- 		elseif type == "tab" then
	-- 		  local state = resurrect.load_state(id, "tab")
	-- 		  resurrect.tab_state.restore_tab(pane:tab(), state, opts)
	-- 		end
	-- 	  end)
	-- 	end),
	--   },

  --   {
  --   key = "d",
  --   mods = "ALT",
  --   action = wezterm.action_callback(function(win, pane)
  --     resurrect.fuzzy_load(win, pane, function(id)
  --         resurrect.delete_state(id)
  --       end,
  --       {
  --         title = "Delete State",
  --         description = "Select State to Delete and press Enter = accept, Esc = cancel, / = filter",
  --         fuzzy_description = "Search State to Delete: ",
  --         is_fuzzy = true,
  --       })
  --   end),
  -- },

    -- Combined actions with fuzzy finder
    {
        key = "r",  -- 'r' for resurrect
        mods = "CMD",
        action = wezterm.action_callback(function(win, pane)
            win:perform_action(
                wezterm.action.InputSelector {
                    title = "Resurrect",
                    choices = {
                        { label = "Save", id = "menu_save" },
                        { label = "Load", id = "menu_load" },
                        { label = "Delete", id = "menu_delete" },
                    },
                    description = "Resurrect Menu:\r\n↑/↓    - Move selection\r\nEnter  - Open selected menu\r\nEsc    - Close menu\r\n",
                    action = wezterm.action_callback(function(window, pane, id, label)
                        if id == "menu_save" then
                            window:perform_action(
                                wezterm.action.InputSelector {
                                    title = "Save Menu",
                                    choices = {
                                        { label = "Save Workspace", id = "save_workspace" },
                                        { label = "Save Window", id = "save_window" },
                                        { label = "Save Tab", id = "save_tab" },
                                        { label = "Save Workspace & Window", id = "save_workspace_window" },
                                    },
                                    description = "Select what to save\r\n\r\nNavigation:\r\n↑/↓    - Move selection\r\nEnter  - Confirm selection\r\nEsc    - Go back/cancel\r\n",
                                    action = wezterm.action_callback(function(win2, pane2, sub_id)
                                        if sub_id == "save_workspace" then
                                            resurrect.save_state(resurrect.workspace_state.get_workspace_state())
                                        elseif sub_id == "save_window" then
                                            resurrect.window_state.save_window_action()(win2, pane2)
                                        elseif sub_id == "save_tab" then
                                            resurrect.tab_state.save_tab_action()(win2, pane2)
                                        elseif sub_id == "save_workspace_window" then
                                            resurrect.save_state(resurrect.workspace_state.get_workspace_state())
                                            resurrect.window_state.save_window_action()(win2, pane2)
                                        end
                                    end),
                                },
                                pane
                            )
                        elseif id == "menu_load" then
                            resurrect.fuzzy_load(window, pane, function(load_id)
                                local type = string.match(load_id, "^([^/]+)")
                                if type then
                                    load_id = string.match(load_id, "([^/]+)$")
                                    load_id = string.match(load_id, "(.+)%..+$")
                                    local opts = {
                                        relative = true,
                                        restore_text = true,
                                        on_pane_restore = resurrect.tab_state.default_on_pane_restore,
                                    }
                                    if type == "workspace" then
                                        local state = resurrect.load_state(load_id, "workspace")
                                        resurrect.workspace_state.restore_workspace(state, opts)
                                    elseif type == "window" then
                                        local state = resurrect.load_state(load_id, "window")
                                        resurrect.window_state.restore_window(window, state, opts)
                                    elseif type == "tab" then
                                        local state = resurrect.load_state(load_id, "tab")
                                        resurrect.tab_state.restore_tab(pane:tab(), state, opts)
                                    end
                                end
                            end, {
                                title = "Load Saved State",
                                description = "Select a state to restore\r\n\r\nNavigation:\r\n↑/↓    - Move selection\r\nEnter  - Load selected state\r\nEsc    - Go back/cancel\r\n",
                                fuzzy_description = "Search state to load: ",
                                is_fuzzy = true,
                            })
                        elseif id == "menu_delete" then
                            resurrect.fuzzy_load(window, pane, function(del_id)
                                resurrect.delete_state(del_id)
                            end, {
                                title = "Delete Saved State",
                                description = "Select a state to delete\r\n\r\nNavigation:\r\n↑/↓    - Move selection\r\nEnter  - Delete selected state\r\nEsc    - Go back/cancel\r\n",
                                fuzzy_description = "Search state to delete: ",
                                is_fuzzy = true,
                            })
                        end
                    end),
                },
                pane
            )
        end),
    },
}

return {
	keys = resurrect_keys,
}
