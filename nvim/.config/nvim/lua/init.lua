-- Additional config
require 'lsp'
require 'statusline'
require 'treesitter'

-- Colors
vim.o.termguicolors = true
vim.cmd('colorscheme dracula')
--vim.g.colorscheme = "dracula"

-- diagnostic-nvim config
vim.g.diagnostic_enable_virtual_text = 1
vim.g.diagnostic_trimmed_virtual_text = 30

-- netrw
vim.g.netrw_home = '~/.cache/nvim'

vim.wo.signcolumn = 'yes'
