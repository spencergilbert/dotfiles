vim.pack.add { { src = 'https://github.com/catppuccin/nvim', name = 'catppuccin' } }

vim.cmd.colorscheme('catppuccin-frappe')

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
	pattern = { 'json', 'yaml', 'toml' },
	callback = function()
		vim.bo.tabstop = 2
		vim.bo.shiftwidth = 2
		vim.bo.softtabstop = 2
		vim.bo.expandtab = true
	end,
})

-- Enable language servers (loaded from lua/lsp/<name>.lua)
vim.lsp.enable({ 'gopls', 'helm_ls', 'yaml_language_server' })
