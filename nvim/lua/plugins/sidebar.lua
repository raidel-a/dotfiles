return {
	"sidebar-nvim/sidebar.nvim",

	event = "VeryLazy",
	lazy = false,
	keys = {
		{ "<leader>sb", "<cmd>SidebarNvimToggle<cr>", desc = "Toggle Sidebar" },
	},
	-- require("sidebar-nvim").setup({
	opts = {
		disable_default_keybindings = 0,
		bindings = {},
		open = true,
		side = "left",
		initial_width = 30,
		hide_statusline = false,
		update_interval = 1000,
		sections = { "datetime", "todos", "git", "diagnostics" },
		section_separator = { "", "-----", "" },
		section_title_separator = { "" },
		containers = {
			attach_shell = "/bin/sh",
			show_all = true,
			interval = 5000,
		},
		datetime = { format = "%a %b %d, %H:%M", clocks = { { name = "local" } } },
		-- todos = { ignored_paths = { "~" } },
	},
	-- }),
}
