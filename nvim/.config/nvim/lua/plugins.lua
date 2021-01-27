-- Required if packer is in `opt` path
vim.cmd('packadd packer.nvim')

local packer = require('packer')

return packer.startup(function()
	local use = packer.use

	use { 'wbthomason/packer.nvim', opt = true }

	-- Fuzzy Finder
	use { 'nvim-telescope/telescope.nvim',
		requires = {
			{ 'nvim-lua/plenary.nvim' },
			{ 'nvim-lua/popup.nvim' },
			{ 'nvim-telescope/telescope-github.nvim',
				config = function()
					require'telescope'.load_extension("gh")
				end
			},
		},
	}

	-- Tree-sitter
	use {
		'nvim-treesitter/nvim-treesitter',
		run = ':TSUpdate',
		config = function() require'treesitter' end,
	}

	-- LSP and Completion
	use {
		'neovim/nvim-lspconfig',
		config = function() require'lsp' end,
		requires = {
			{ 'glepnir/lspsaga.nvim' },
			{ 'nvim-lua/completion-nvim' },
		},
	}

	-- Statusline
	use {
		'glepnir/galaxyline.nvim',
		branch = 'main',
		config = function() require'statusline' end,
		requires = { 'kyazdani42/nvim-web-devicons', opt = true },
	}

	-- Colorscheme
	use {
		'dracula/vim',
		as = 'dracula',
		config = function()
			vim.o.termguicolors = true
			vim.cmd('colorscheme dracula')
		end
	}

	-- Browser
	use {
		'tpope/vim-vinegar',
		config = function()
			vim.g.netrw_home = "~/.cache/nvim"
		end
	}
end)
