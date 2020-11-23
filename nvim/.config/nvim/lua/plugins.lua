-- Required if packer is in `opt` path
vim.cmd [[packadd packer.nvim]]

local packer = require('packer')

return packer.startup(function()
  local use = packer.use

  -- Packer
  use { 'wbthomason/packer.nvim', opt = true }

  -- Search
  use { 'nvim-telescope/telescope.nvim',
    requires = {
      { 'nvim-lua/plenary.nvim' },
      { 'nvim-lua/popup.nvim' },
      { 'nvim-telescope/telescope-dap.nvim', disabled = true },
    },
  }

  -- TreeSitter
  use {
    'nvim-treesitter/nvim-treesitter',
    config = 'require [[treesitter]]',
    requires = {
      { 'nvim-treesitter/nvim-treesitter-refactor' },
      { 'nvim-treesitter/nvim-treesitter-textobjects' },
      { 'nvim-treesitter/completion-treesitter' },
    },
  }

  -- LSPs and Completion
  use {
    'neovim/nvim-lspconfig',
    config = 'require [[lsp]]',
    requires = {
      { 'nvim-lua/completion-nvim' },
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

  use {
    'tpope/vim-vinegar',
    config = function()
      vim.g.netrw_home = '~/.cache/nvim'
    end
  }

  -- Colorscheme
  use {
    'dracula/vim',
    as = 'dracula',
    config = function()
      vim.cmd [[set termguicolors]]
      vim.cmd [[colorscheme dracula]]
    end
  }

  -- Disabled
  use {
    { 'glepnir/galaxyline.nvim', disable = true },
    { 'glepnir/indent-guides.nvim', disable = true },
    { 'kyazdani42/nvim-web-devicons', disable = true },
    { 'norcalli/snippets.nvim', disable = true },
  }
end)
