-- Required if packer is in `opt` path
vim.cmd [[packadd packer.nvim]]

local packer = require('packer')

return packer.startup(function()
  local use = packer.use

  -- Packer
  use { 'wbthomason/packer.nvim', opt = true }

  -- Search
  use { 'nvim-lua/telescope.nvim',
    requires = {
      { 'nvim-lua/plenary.nvim' },
      { 'nvim-lua/popup.nvim' },
    },
  }

  -- TreeSitter
  use {
    'nvim-treesitter/nvim-treesitter',
    config = 'require [[treesitter]]',
    requires = {
      { 'nvim-treesitter/nvim-treesitter-refactor' },
      { 'nvim-treesitter/completion-treesitter' },
    },
  }

  -- LSPs and Completion
  use {
    'neovim/nvim-lspconfig',
    config = 'require [[lsp]]',
    requires = {
      { 'nvim-lua/completion-nvim' },
      { 'nvim-lua/diagnostic-nvim' },
      { 'nvim-lua/lsp_extensions.nvim' },
      { 'nvim-lua/lsp-status.nvim' },
      { 'steelsojka/completion-buffers' },
    },
  }

  -- Status line
  use {
    'tjdevries/express_line.nvim',
    config = 'require [[expressline]]',
  }

  use { 'tpope/vim-vinegar' }

  -- Colorscheme
  use {
    'dracula/vim',
    as = 'dracula',
    config = function()
      vim.cmd [[set termguicolors]]
      vim.cmd [[colorscheme dracula]]
    end
  }
end)
