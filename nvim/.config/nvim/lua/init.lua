require 'plugins'

-- Additional config
require 'lsp'
require 'statusline'
require 'treesitter'

-- diagnostic-nvim config
vim.api.nvim_set_var('diagnostic_enable_virtual_text', 1)
vim.api.nvim_set_var('diagnostic_trimmed_virtual_text', 30)
