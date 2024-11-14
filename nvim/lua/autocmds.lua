-- autocmds.lua
local M = {}

function M.setup()
    -- Create autocommand group
    local augroup = vim.api.nvim_create_augroup("CustomAutocmds", { clear = true })

    -- Nvim-tree auto-open
    -- vim.api.nvim_create_autocmd("VimEnter", {
    --     group = augroup,
    --     callback = function()
    --         require("nvim-tree.api").tree.open()
    --     end,
    -- })

      -- Open nvim-tree only for directories
    vim.api.nvim_create_autocmd("VimEnter", {
        group = augroup,
        callback = function(data)
            -- Check if argument is a directory
            local is_directory = vim.fn.isdirectory(data.file) == 1

            if is_directory then
                -- Change to the directory
                vim.cmd.cd(data.file)
                -- Open the tree
                require("nvim-tree.api").tree.open()
            end
        end,
    })


end

return M
