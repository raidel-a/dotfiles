vim.g.base46_cache = vim.fn.stdpath "data" .. "/nvchad/base46/"
vim.g.mapleader = " "

vim.env.PATH = "/opt/homebrew/bin:" .. vim.env.PATH

-- bootstrap lazy and all plugins
local lazypath = vim.fn.stdpath "data" .. "/lazy/lazy.nvim"

if not vim.uv.fs_stat(lazypath) then
  local repo = "https://github.com/folke/lazy.nvim.git"
  vim.fn.system { "git", "clone", "--filter=blob:none", repo, "--branch=stable", lazypath }
end

vim.opt.rtp:prepend(lazypath)

local lazy_config = require "configs.lazy"

-- load plugins
require("lazy").setup({
  {
    "NvChad/NvChad",
    lazy = false,
    branch = "v2.5",
    import = "nvchad.plugins",
    config = function()
      require "options"
      require "nvchad.options"
    end,
  },

  { import = "plugins" },
}, lazy_config)

-- load theme
dofile(vim.g.base46_cache .. "defaults")
dofile(vim.g.base46_cache .. "statusline")

-- globals (P, R, RELOAD) before anything that might use them
require "globals"

-- nvchad.autocmds fires the `User FilePost` event, which lazy-loaded plugins
-- (nvim-lspconfig, conform, indent-blankline, ...) wait on. Without it none of
-- them ever load. It must run before the first buffer is read.
require "nvchad.autocmds"

require("autocmds").setup()

vim.schedule(function()
  require "mappings"
end)

-- the python3 provider is enabled by default, this keeps it that way even if a
-- plugin/after file disabled it
local enable_providers = { "python3_provider" }

for _, provider in ipairs(enable_providers) do
  vim.g["loaded_" .. provider] = nil
  vim.cmd("runtime! plugin/" .. provider .. ".vim")
end

dofile(vim.g.base46_cache .. "syntax")
