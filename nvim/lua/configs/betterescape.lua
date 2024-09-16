return {
	-- lua, default settings
	require("better_escape").setup({
		timeout = vim.o.timeoutlen,
		default_mappings = true,
		mappings = {
			i = {
				-- j = {
				--     -- These can all also be functions
				--     k = "<Esc>",
				--     j = "<Esc>",
				-- },
				[" "] = {
					["<tab>"] = function()
						-- Defer execution to avoid side-effects
						vim.defer_fn(function()
							-- set undo point
							vim.o.ul = vim.o.ul
							require("luasnip").expand_or_jump()
						end, 1)
					end,
				},
			},
			c = {
				j = {
					k = "<Esc>",
					j = "<Esc>",
				},
			},
			t = {
				j = {
					k = "<C-\\><C-n>",
				},
			},
			v = {
				j = {
					k = "<Esc>",
				},
			},
			s = {
				j = {
					k = "<Esc>",
				},
			},
		},
	}),
}
