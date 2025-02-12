local wezterm = require("wezterm")
local helpers = require("utils.helpers")
local process_icons = require("utils.process_icons")
local ccolors = require("utils.ccolors")

local CIRCLE = wezterm.nerdfonts.cod_circle_large
local CIRCLE_FILLED = wezterm.nerdfonts.cod_circle_large_filled
local nTAB_FILLED = wezterm.nerdfonts.md_plus_outline
local nTAB = wezterm.nerdfonts.md_plus_thick

wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
	local active_pane = tab.active_pane
	local current_dir = active_pane.current_working_dir and active_pane.current_working_dir.file_path

	if current_dir then
		local process = helpers.get_last_segment(active_pane.foreground_process_name):lower()
		local full_title = active_pane.title or ""
		local file_name = full_title:match("^(.+) %- ") or full_title
		local file_extension = file_name:match("%.%w+$") or ""

		local display_name
		if file_name ~= "" and process ~= "zsh" then
			display_name = file_name
		else
			local dir_name = current_dir:match("([^/]+)/?$") or current_dir
			display_name = "" .. dir_name .. "/"
		end

		local icon = process_icons.get_icon(process, file_extension)

		-- Account for the side bars and icon in the total width
		local side_bars_width = wezterm.column_width(helpers.left_bar) + wezterm.column_width(helpers.right_bar)
		local icon_width = wezterm.column_width(icon .. " ")
		local available_width = max_width - side_bars_width - icon_width

		-- If available width is very small (< 10), show only icon
		if available_width < 8 then
			return {
				{
					Text = string.format("%s %s %s", helpers.left_bar, icon, helpers.right_bar),
					-- Text = string.format("%s", icon),
				},
			}
		end

		-- Truncate display name if it's too long and add ".."
		if wezterm.column_width(display_name) > available_width then
			local truncated = ""
			local current_width = 0
			for char in display_name:gmatch(".") do
				local char_width = wezterm.column_width(char)
				if current_width + char_width + 2 > available_width then -- +2 for ".."
					break
				end
				truncated = truncated .. char
				current_width = current_width + char_width
			end
			display_name = truncated .. "‥"
		end

		local title = string.format("%s %s %s %s", helpers.left_bar, icon, display_name, helpers.right_bar)
		-- local title = string.format("%s %s", icon, display_name)

		return { {
			Text = title,
		} }
	end
end)

return {
	tab_bar_at_bottom = true,
	enable_tab_bar = true,
	use_fancy_tab_bar = false,
	tab_max_width = 25,
	hide_tab_bar_if_only_one_tab = false,
	show_new_tab_button_in_tab_bar = true,
	tab_bar_style = {

		new_tab = wezterm.format({
			{
				Background = {
					Color = ccolors.border,
				},
			},
			{
				Foreground = {
					Color = "white",
				},
			},
			{
				Text = " " .. nTAB .. " ",
			},
		}),

		new_tab_hover = wezterm.format({
			{
				Background = {
					Color = ccolors.border,
				},
			},
			{
				Foreground = {
					Color = "white",
				},
			},
			{
				Text = " " .. nTAB_FILLED .. " ",
			},
		}),
		window_close = wezterm.format({
			{
				Background = { Color = ccolors.border },
			},
			{
				Foreground = {
					Color = "white",
				},
			},
			{
				Text = "  " .. CIRCLE .. " ",
			},
		}),
		window_close_hover = wezterm.format({
			{
				Background = {
					Color = ccolors.border,
				},
			},
			{
				Foreground = {
					Color = "#F30710",
				},
			},
			{
				Text = "  " .. CIRCLE_FILLED .. " ",
			},
		}),
		window_hide = wezterm.format({
			{
				Background = {
					Color = ccolors.border,
				},
			},
			{
				Foreground = {
					Color = "white",
				},
			},
			{
				Text = " " .. CIRCLE .. " ",
			},
		}),
		window_hide_hover = wezterm.format({
			{
				Background = {
					Color = ccolors.border,
				},
			},
			{
				Foreground = {
					Color = "#FEC907",
				},
			},
			{
				Text = " " .. CIRCLE_FILLED .. " ",
			},
		}),
		window_maximize = wezterm.format({
			{
				Background = {
					Color = ccolors.border,
				},
			},
			{
				Foreground = {
					Color = "white",
				},
			},
			{
				Text = " " .. CIRCLE .. "  ",
			},
		}),
		window_maximize_hover = wezterm.format({
			{
				Background = {
					Color = ccolors.border,
				},
			},
			{
				Foreground = {
					Color = "#2FFF03",
				},
			},
			{
				Text = " " .. CIRCLE_FILLED .. "  ",
			},
		}),
	},
}
