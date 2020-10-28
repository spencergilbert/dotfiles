local packages = {
  -- Packer
  { 'wbthomason/packer.nvim', opt = true },

  -- TreeSitter
  {
    'nvim-treesitter/nvim-treesitter',
    config = 'require [[config/treesitter]]',
    requires = {
      { 'nvim-treesitter/nvim-treesitter-refactor' },
    },
  },

  -- LSPs and Completion
  {
    'neovim/nvim-lspconfig',
    config = 'require [[config/lsp]]',
    requires = {
      { 'nvim-lua/completion-nvim' },
      { 'nvim-lua/diagnostic-nvim' },
      { 'nvim-lua/lsp-status.nvim' },
    },
  },

  -- Colorscheme
  {
    'dracula/vim',
    as = 'dracula',
    config = 'vim.cmd [[colorscheme dracula]]'
  },
}

return packages
