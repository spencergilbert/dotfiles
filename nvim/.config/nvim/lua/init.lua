-- Required if packer is in the `opt` path
vim.cmd [[packadd packer.nvim]]

local packer = require('packer')
local packages = require('packages')

packer.startup(function()
  for _, value in pairs(packages) do
    packer.use(value)
  end
end)

vim.o.termguicolors = true
