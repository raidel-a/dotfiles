local M = {}

M.adapter = {
	type = "executable",
	-- Apple renamed lldb-vscode to lldb-dap; /usr/bin/ no longer ships either.
	command = "/Applications/Xcode.app/Contents/Developer/usr/bin/lldb-dap",
	name = "lldb",
}

M.config = {
	{
		name = "Launch",
		type = "lldb",
		request = "launch",
		program = function()
			return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
		end,
		cwd = "${workspaceFolder}",
		stopOnEntry = false,
		args = function()
			local argument_string = vim.fn.input("Program arguments: ")
			return vim.fn.split(argument_string, " ", true)
		end,
	},
}

return M
