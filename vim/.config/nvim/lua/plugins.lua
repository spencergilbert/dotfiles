vim.cmd 'packadd paq-nvim'
local paq = require'paq-nvim'.paq

paq {'savq/paq-nvim', opt = true}

paq 'neovim/nvim-lspconfig'

paq 'nvim-lua/completion-nvim'
paq 'nvim-lua/diagnostic-nvim'
paq 'nvim-lua/lsp_extensions.nvim'
paq 'nvim-lua/lsp-status.nvim'
paq 'nvim-lua/plenary.nvim'
paq 'nvim-lua/popup.nvim'
paq 'nvim-lua/telescope.nvim'

paq 'nvim-treesitter/nvim-treesitter'

-- Ensure lua plugins work properly
vim.cmd [[packloadall]]
