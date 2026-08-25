-- Leader key must be set before plugins load
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Plugins managed by vim.pack (installed to $XDG_DATA_HOME/nvim/site/pack/core/opt)
vim.pack.add {
  { src = 'https://github.com/catppuccin/nvim',                name = 'catppuccin' },
  { src = 'https://github.com/nvim-treesitter/nvim-treesitter', name = 'nvim-treesitter' },
  { src = 'https://github.com/nvim-telescope/telescope.nvim',   name = 'telescope' },
  { src = 'https://github.com/nvim-telescope/telescope-fzf-native.nvim', name = 'telescope-fzf-native' },
}

-- Custom filetype detection
require('filetypes.helm')

-- Colorscheme (must load after plugins that define highlight groups)
vim.cmd.colorscheme('catppuccin-frappe')

-- OPTIONS

vim.o.number = true
vim.o.relativenumber = true

-- Sync clipboard between OS and Neovim. Schedule after `UIEnter` to avoid
-- increasing startup-time. Remove if you want your OS clipboard independent.
-- See `:h 'clipboard'`
local clipboard_group = vim.api.nvim_create_augroup('clipboard', { clear = true })
vim.api.nvim_create_autocmd('UIEnter', {
	group = clipboard_group,
	desc = 'Sync OS clipboard via unnamedplus',
	callback = function()
		vim.o.clipboard = 'unnamedplus'
	end,
})

-- Case-insensitive searching UNLESS \C or one or more capital letters in the term
vim.o.ignorecase = true
vim.o.smartcase = true

vim.o.cursorline = true
vim.o.scrolloff = 10
vim.o.list = true
vim.o.listchars = 'tab:>· ,trail:·,extends:>,precedes:<,nbsp:+,eol:$'

-- If performing an operation that would fail due to unsaved changes (like `:q`),
-- instead raise a dialog asking if you wish to save the current file(s).
-- See `:h 'confirm'`
vim.o.confirm = true

-- Completion options for LSP completion menus
vim.o.completeopt = 'menuone,noselect,popup'

-- KEYMAPS

-- Use <Esc> to exit terminal mode
vim.keymap.set('t', '<Esc>', '<C-\\><C-n>')

-- Map <A-j>, <A-k>, <A-h>, <A-l> to navigate between windows in any modes
vim.keymap.set({ 't', 'i' }, '<A-h>', '<C-\\><C-n><C-w>h')
vim.keymap.set({ 't', 'i' }, '<A-j>', '<C-\\><C-n><C-w>j')
vim.keymap.set({ 't', 'i' }, '<A-k>', '<C-\\><C-n><C-w>k')
vim.keymap.set({ 't', 'i' }, '<A-l>', '<C-\\><C-n><C-w>l')
vim.keymap.set({ 'n' }, '<A-h>', '<C-w>h')
vim.keymap.set({ 'n' }, '<A-j>', '<C-w>j')
vim.keymap.set({ 'n' }, '<A-k>', '<C-w>k')
vim.keymap.set({ 'n' }, '<A-l>', '<C-w>l')

-- Telescope keybindings
local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = 'Find files' })
vim.keymap.set('n', '<leader>fg', builtin.live_grep,   { desc = 'Live grep' })
vim.keymap.set('n', '<leader>fb', builtin.buffers,       { desc = 'Buffers' })
vim.keymap.set('n', '<leader>fh', builtin.help_tags,     { desc = 'Help tags' })
vim.keymap.set('n', '<leader>fk', builtin.keymaps,       { desc = 'Keymaps' })

-- Highlight when yanking (copying) text. Try `yap` in normal mode to test.
-- See `:h vim.hl.on_yank()`
local highlight_group = vim.api.nvim_create_augroup('highlight', { clear = true })
vim.api.nvim_create_autocmd('TextYankPost', {
	group = highlight_group,
	desc = 'Highlight yanked text briefly',
	callback = function()
		vim.hl.on_yank()
	end,
})

-- Filetype-specific indentation settings
local indent_group = vim.api.nvim_create_augroup('indent', { clear = true })
vim.api.nvim_create_autocmd('FileType', {
	group = indent_group,
	desc = 'Set buffer-local indentation for specific filetypes',
	pattern = { 'json', 'helm.tmpl', 'yaml', 'toml' },
	callback = function()
		vim.bo.tabstop = 2
		vim.bo.shiftwidth = 2
		vim.bo.softtabstop = 2
		vim.bo.expandtab = true
	end,
})

-- LSP: diagnostics display with virtual text and inline signs
vim.diagnostic.config({
	signs          = { text = { [vim.diagnostic.severity.ERROR] = '✗' } },
	virtual_text    = true,
	underline       = true,
	update_in_insert = true,
	float            = { border = 'single', source = 'if_many' },
})

-- LSP: disable the built-in global keymaps (gra, gri, grn, grr, grt)
-- so they don't conflict with normal usage
vim.keymap.del('n', 'gra')
vim.keymap.del('n', 'gri')
vim.keymap.del('n', 'grn')
vim.keymap.del('n', 'grr')
vim.keymap.del('n', 'grt')
vim.keymap.del('n', 'gO')

-- LSP: LspAttach handler — set up per-buffer keymaps when LSP attaches
local lsp_group = vim.api.nvim_create_augroup('lsp', { clear = true })
vim.api.nvim_create_autocmd('LspAttach', {
	group = lsp_group,
	desc = 'Set up LSP keymaps on attach',
	callback = function(ev)
		local client = vim.lsp.get_client_by_id(ev.data.client_id)
		if not client then return end

		local opts = { buffer = ev.buf, desc = 'vim.lsp: ' .. client.name }

		vim.keymap.set('n', 'grn', function() vim.lsp.buf.rename(opts) end, opts)
		vim.keymap.set({ 'n', 'v' }, 'gra', function() vim.lsp.buf.code_action(opts) end, opts)
		vim.keymap.set('n', 'K',   function() vim.lsp.buf.hover(opts) end, opts)
	end,
})

-- Enable language servers (loaded from lua/lsp/<name>.lua)
vim.lsp.enable({ 'gopls', 'helm_ls', 'yaml_language_server' })
