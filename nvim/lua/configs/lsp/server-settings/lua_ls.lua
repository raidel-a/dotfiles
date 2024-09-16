return {
	settings = {
		Lua = {
			runtime = {
				version = "LuaJIT",
			},
			diagnostics = {
				globals = { "vim" },
			},
			workspace = {
				library =
          vim.list_extend(
            vim.api.nvim_get_runtime_file("", true),
          { "~/.config/wezterm/wezterm-types" }),
				checkThirdParty = false,
			},
			telemetry = {
				enable = false,
			},
		},
	},
}
